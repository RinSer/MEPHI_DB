/* 
	Регистрирует клиента на курс только 
	если он уже не зарегистрирован на 
	проходящий одновременно
 */
BEGIN TRANSACTION

WITH ids (reg, client) AS (
   SELECT 9604, 1 -- 26263
)
INSERT INTO registrationclient
(registrationId, clientId)
SELECT reg, client FROM ids WHERE
(WITH cteRegistrations (id, firstLesson, lastLesson) 
AS (
	SELECT DISTINCT r.id
		,r.schedule
		,r.schedule + COUNT(2)*'1 days'::interval
	FROM registrations r
	LEFT JOIN lessons l ON l.courseid = r.courseid
	LEFT JOIN registrationclient rc ON rc.registrationid = r.id
	GROUP BY r.id, rc.clientid
	HAVING r.id = (SELECT reg FROM ids LIMIT 1) 
	OR rc.clientId = (SELECT client FROM ids LIMIT 1)
)
SELECT 
	COUNT(*)
FROM cteRegistrations r
WHERE 
(SELECT firstLesson FROM cteRegistrations 
WHERE id = (SELECT reg FROM ids LIMIT 1) LIMIT 1)
BETWEEN r.firstLesson AND r.lastLesson
OR (SELECT lastLesson FROM cteRegistrations 
WHERE id = (SELECT reg FROM ids LIMIT 1) LIMIT 1)
BETWEEN r.firstLesson AND r.lastLesson) < 2
RETURNING registrationId, clientid

ROLLBACK TRANSACTION