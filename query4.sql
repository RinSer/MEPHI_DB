CREATE MATERIALIZED VIEW ClientsStat
AS
	-- 4) Для каждого клиента возвращает:
	SELECT c.*
		-- количество непереносимостей,
		,COUNT(i.id)
	FROM (
		WITH cteClientRegistrations(
			clientid, 
			courseid, 
			lastDate, 
			costPerClient, 
			lessonsCount,
			mastersCount
		)
		AS (
			SELECT 
				rc.clientid AS clientid
				,regs.courseid AS courseid
				,MAX(lm.lessondate) AS lastDate
				,ROUND(regs.cost / COUNT(rc.clientid) OVER (PARTITION BY regs.id), 2) AS costPerClient
				,COUNT(DISTINCT lm.lessonid)
				,COUNT(DISTINCT lm.masterid)
			FROM LessonMaster lm 
			JOIN Registrations regs ON regs.id = lm.registrationid
			JOIN RegistrationClient rc ON rc.registrationid = regs.id
			-- уже проведенные
			WHERE regs.schedule < NOW()
			GROUP BY regs.id, rc.clientid
		)
		SELECT 
			-- идентификатор клиента,
			cr.clientid
			-- количество посещенных курсов,
			,COUNT(cr.courseid) AS CoursesCount
			-- количество посещенных занятий,
			,SUM(cr.lessonsCount) AS LessonsCount
			-- количество разных мастеров,
			,SUM(cr.mastersCount) AS MastersCount
			-- потраченные деньги,
			,SUM(cr.costPerClient) AS MoneySpent
			-- дата последнего посещения курсов
			,to_char(MAX(cr.lastDate), 'DD.MM.YYYY') AS LastLessonDate
		FROM cteClientRegistrations cr
		GROUP BY cr.clientid
		ORDER BY cr.clientid
	) c
	JOIN Intolerances i ON i.clientid = c.clientid
	GROUP BY 1, 2, 3, 4, 5, 6;