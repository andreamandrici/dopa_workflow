-- CREATE LIST OF CEP CIDs WHICH ARE NOT PROTECTED
CREATE TABLE cep.cep_202003_oecm_cid_non_oecm AS
WITH
-- get list of oecm wdpaids
a AS (SELECT wdpaid pa FROM protected_sites.wdpa_202003_oecm WHERE pa_def = 0),
-- create array of eocm wdpaids
b AS (SELECT ARRAY_AGG(DISTINCT pa ORDER BY pa) pa FROM a),
-- find oecm wdpaid in current cep pa -- also count the number of wdpaid in the cep pa array
c AS (SELECT c.*,CARDINALITY(c.pa) ch FROM cep.cep_202003_oecm c,b WHERE b.pa && c.pa),
-- find oecm wdpaid in cids which contain multiple wdpaid, with at least one is oecm - from step above
d AS (
SELECT cid,ARRAY_AGG(DISTINCT pa ORDER BY pa) pa,ch FROM
(SELECT DISTINCT cid,UNNEST(c.pa) pa,ch FROM c WHERE ch > 1 ORDER BY cid,pa) d
WHERE pa IN (SELECT DISTINCT pa FROM a)
GROUP BY cid,ch
),
-- find cids which are protected only by oecm wdpaid
e AS (
-- find cids which contain multiple oecm wdpaid
SELECT DISTINCT cid FROM d WHERE CARDINALITY(pa) = ch
UNION
-- find cids which contain one oecm wdpaid
SELECT DISTINCT cid FROM c WHERE ch =1
ORDER BY cid
)
SELECT DISTINCT cid FROM e
