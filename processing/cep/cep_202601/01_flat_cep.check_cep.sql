SELECT *
INTO TEMPORARY checka
FROM (VALUES
(120,12713),
(120,13800),
(155,15946),
(238,23253),
(253,27368),
(321,29844),
(405,41843),
(407,41503),
(453,45568),
(474,49737),
(489,47006),
(507,52221),
(514,53740),
(516,50520),
(516,52320),
(517,51605),
(517,52321),
(546,57292),
(548,56954),
(549,54086),
(550,55895),
(550,56974),
(550,57339),
(551,54830),
(553,56649),
(553,57008),
(554,54135),
(554,55220),
(555,55941),
(559,54186),
(559,55270),
(561,55282),
(562,55660),
(562,57453),
(564,57111),
(566,57138),
(597,57808),
(610,57935),
(96,8518)
) AS t(eid,qid);
DROP TABLE IF EXISTS cep202601.z_checkrast_points;CREATE TABLE cep202601.z_checkrast_points AS
SELECT * FROM checka;

DROP TABLE IF EXISTS cep202601.z_checkrast_maskpoints;CREATE TABLE cep202601.z_checkrast_maskpoints AS
SELECT qid,(p).geom
FROM cep202601.o_raster r
CROSS JOIN LATERAL ST_PixelAsPoints(r.rast,1,false) p
WHERE qid IN (SELECT DISTINCT qid FROM cep202601.z_checkrast_points)
AND (p).val = 0;

SELECT * FROM cep202601.z_checkrast_maskpoints;

