CREATE MATERIALIZED VIEW ClientsStat
AS
	-- 4) Для каждого клиента возвращает:
	WITH cteRegistrations(id, courseid, lastDate, costPerClient)
	AS (
		SELECT 
			regs.id AS id
			,regs.courseid AS courseid
			,MAX(lm.lessondate) AS lastDate
			,ROUND(regs.cost / (SELECT COUNT(*) 
			FROM RegistrationClient WHERE registrationid = regs.id), 2) AS costPerClient
		FROM LessonMaster lm JOIN Registrations regs ON regs.id = lm.registrationid
		-- уже проведенные
		WHERE regs.schedule < NOW()
		GROUP BY regs.id
	)
	SELECT 
		-- идентификатор клиента,
		c.id
		-- количество посещенных курсов,
		,COUNT(r.*) AS CoursesCount
		-- количество посещенных занятий,
		,(SELECT COUNT(*) FROM RegistrationClient rc
		JOIN cteRegistrations r ON r.id = rc.registrationid
		RIGHT JOIN Lessons l ON l.courseid = r.courseid
		WHERE clientid = c.id) AS LessonsCount
		-- количество разных мастеров,
		,(SELECT COUNT(DISTINCT masterid) FROM registrationmaster
		WHERE registrationid = ANY(array_agg(r.id))) AS MastersCount
		-- количество непереносимостей,
		,(SELECT COUNT(*) FROM Intolerances
		WHERE clientid = c.id) AS IntolerancesCount
		-- потраченные деньги,
		,SUM(r.costPerClient) AS MoneySpent
		-- дата последнего посещения курсов
		,to_char(MAX(r.lastDate), 'DD.MM.YYYY') AS LastLessonDate
	FROM Clients c
	LEFT JOIN RegistrationClient rc ON rc.clientid = c.id
	LEFT JOIN cteRegistrations r ON rc.registrationid = r.id
	GROUP BY rc.clientid, c.id
	ORDER BY c.id