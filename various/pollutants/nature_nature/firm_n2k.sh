#!/bin/bash

HOST="gosling"
USER="h05ibex"
DB="wolfe"
NWORKERS=72

PSQL="psql -h $HOST -U $USER -d $DB -v ON_ERROR_STOP=1"

PIDS=()

echo "========================================"
echo "firm_n2k - $NWORKERS worker"
echo "========================================"


# ------------------------------------------------------------
# 1. Elimina le vecchie tabelle
# ------------------------------------------------------------

echo "Elimino vecchie tabelle..."

for W in $(seq 0 $((NWORKERS-1))); do
    $PSQL -c "DROP TABLE IF EXISTS pollutants.firm_n2k_${W};"
done

$PSQL -c "DROP TABLE IF EXISTS pollutants.firm_n2k;"


# ------------------------------------------------------------
# 2. Avvia i worker
# ------------------------------------------------------------

echo "Avvio i worker..."

for W in $(seq 0 $((NWORKERS-1))); do

    echo "Avvio worker $W..."

    $PSQL > "firm_n2k_${W}.log" 2>&1 <<SQL &

CREATE TABLE pollutants.firm_n2k_${W} AS
SELECT
    fy.ffid,
    fy.r_yr,
    p.site_id,
    p.site_type,
    ST_Distance(
        f.point::geography,
        p.geom::geography
    ) AS distance
FROM pollutants.firm_years fy
JOIN pollutants.firm_facility f
    ON f.ffid = fy.ffid
LEFT JOIN LATERAL (
    SELECT
        n.site_id,
        n.site_type,
        n.geom
    FROM pollutants.n2k_year ny
    JOIN pollutants.n2k n
        ON n.site_id = ny.site_id
    WHERE ny.r_yr = fy.r_yr
    ORDER BY f.point <-> n.geom
    LIMIT 1
) p ON TRUE
WHERE MOD(fy.ffid, ${NWORKERS}) = ${W};

ANALYZE pollutants.firm_n2k_${W};

SQL

    PIDS[$W]=$!

done


# ------------------------------------------------------------
# 3. Attendi tutti i worker
# ------------------------------------------------------------

echo
echo "Attendo la fine dei worker..."

ERROR=0

for W in $(seq 0 $((NWORKERS-1))); do

    PID=${PIDS[$W]}

    if wait "$PID"; then
        echo "Worker $W terminato correttamente"
    else
        RC=$?
        echo "ERRORE nel worker $W (exit code $RC)"
        echo "Controlla firm_n2k_${W}.log"
        ERROR=1
    fi

done


# ------------------------------------------------------------
# 4. Se un worker è fallito, stop
# ------------------------------------------------------------

if [ "$ERROR" -ne 0 ]; then
    echo
    echo "ERRORE: almeno un worker è fallito."
    echo "Il risultato finale NON viene creato."
    exit 1
fi


# ------------------------------------------------------------
# 5. Crea tabella finale
# ------------------------------------------------------------

echo
echo "Creo pollutants.firm_n2k..."

$PSQL <<SQL

CREATE TABLE pollutants.firm_n2k AS
SELECT *
FROM pollutants.firm_n2k_0
WHERE FALSE;

SQL


# ------------------------------------------------------------
# 6. Merge
# ------------------------------------------------------------

echo
echo "Eseguo merge..."

for W in $(seq 0 $((NWORKERS-1))); do

    echo "Inserimento worker $W..."

    $PSQL <<SQL

INSERT INTO pollutants.firm_n2k
SELECT *
FROM pollutants.firm_n2k_${W};

SQL

    if [ $? -ne 0 ]; then
        echo "ERRORE nel merge del worker $W."
        exit 1
    fi

done


# ------------------------------------------------------------
# 7. Indice e statistiche
# ------------------------------------------------------------

echo
echo "Creo indice..."

$PSQL <<SQL

CREATE INDEX firm_n2k_ffid_idx
ON pollutants.firm_n2k (ffid);

ANALYZE pollutants.firm_n2k;

SELECT COUNT(*) AS rows
FROM pollutants.firm_n2k;

SQL


echo
echo "========================================"
echo "COMPLETATO"
echo "========================================"