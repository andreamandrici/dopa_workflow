#!/bin/bash

# ============================================================
# firm_pa.sh
#
# ESECUZIONE
#
# In foreground:
#     ./firm_pa.sh
#
# In background:
#     nohup ./firm_pa.sh </dev/null > firm_pa_main.log 2>&1 &
#
# Controllare il log:
#     tail -f firm_pa_main.log
#
# FERMARE IL PROCESSO
#
# Se eseguito in foreground:
#     Ctrl+C
#
# Se eseguito in background:
#     ps -ef | grep '[f]irm_pa.sh'
#     kill PID
#
# Se necessario, verificare/fermare i worker:
#     ps aux | grep '[p]sql'
#
# ============================================================


HOST="gosling"
USER="h05ibex"
DB="wolfe"
NWORKERS=72

PSQL="psql -h $HOST -U $USER -d $DB -v ON_ERROR_STOP=1"

PIDS=()

echo "========================================"
echo "firm_pa - $NWORKERS worker"
echo "========================================"


# ------------------------------------------------------------
# 1. Elimina le vecchie tabelle
# ------------------------------------------------------------

echo "Elimino vecchie tabelle..."

for W in $(seq 0 $((NWORKERS-1))); do
    $PSQL -c "DROP TABLE IF EXISTS pollutants.firm_pa_${W};"
done

$PSQL -c "DROP TABLE IF EXISTS pollutants.firm_pa;"


# ------------------------------------------------------------
# 2. Avvia i worker
# ------------------------------------------------------------

echo "Avvio i worker..."

for W in $(seq 0 $((NWORKERS-1))); do

    echo "Avvio worker $W..."

    $PSQL > "firm_pa_${W}.log" 2>&1 <<SQL &

CREATE TABLE pollutants.firm_pa_${W} AS
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
        pa.site_id,
        pa.site_type,
        pa.geom
    FROM pollutants.pa_year py
    JOIN pollutants.pa pa
        ON pa.site_id = py.site_id
    WHERE py.r_yr = fy.r_yr
    ORDER BY f.point <-> pa.geom
    LIMIT 1
) p ON TRUE
WHERE MOD(fy.ffid, ${NWORKERS}) = ${W};

ANALYZE pollutants.firm_pa_${W};

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
        echo "Controlla firm_pa_${W}.log"
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
echo "Creo pollutants.firm_pa..."

$PSQL <<SQL

CREATE TABLE pollutants.firm_pa AS
SELECT *
FROM pollutants.firm_pa_0
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

INSERT INTO pollutants.firm_pa
SELECT *
FROM pollutants.firm_pa_${W};

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

CREATE INDEX firm_pa_ffid_idx
ON pollutants.firm_pa (ffid);

ANALYZE pollutants.firm_pa;

SELECT COUNT(*) AS rows
FROM pollutants.firm_pa;

SQL


echo
echo "========================================"
echo "COMPLETATO"
echo "========================================"

