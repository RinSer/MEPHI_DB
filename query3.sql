-- 3) Для каждого Мастера вывести:
SELECT md.*, 
	-- Тип занятия
	lc.LessonType,
	-- Месяц
	lc.Month,
	-- Количество занятий данного типа за месяц в этом году
	lc.LessonsCount
	FROM
	(WITH cteRegistrations(RegistrationId, MasterId, Gap, ClientsCount)
	AS
	(
		SELECT
			r.id
			,lm.masterid
			-- время до следующего курса мастера
			,LEAD(r.schedule) OVER (PARTITION BY lm.masterid ORDER BY r.schedule) - MAX(lm.lessondate)
			-- количество разных обученных студентов на курс
			,COUNT(DISTINCT rc.clientid)
		FROM Registrations r
		JOIN RegistrationClient rc ON rc.registrationid = r.id
		JOIN LessonMaster lm ON lm.registrationid = r.id
		WHERE r.schedule < NOW()
		GROUP BY r.id, lm.masterid
	)
	SELECT
		-- Идентификатор мастера
		masterid
		-- среднее время промежутков между проводимыми курсами
		,AVG(Gap) AS AverageIntervalBetweenCourses
		-- количество разных обученных студентов
		,SUM(clientsCount) AS StudentsCount
		-- количество проведенных курсов
		,COUNT(DISTINCT registrationid) AS CoursesCount
	FROM cteRegistrations
	GROUP BY masterid) md
JOIN
	-- количество проведенных занятий по каждому типу в разрезе каждого месяца за последний год
	(SELECT 
		lm.masterid AS MasterId,
		l.typeid AS LessonType,
		extract(month from lm.lessondate) AS MonthIndex,
		to_char(lm.lessondate, 'month') AS Month,
		COUNT(l.*) AS LessonsCount
	FROM LessonMaster lm
	JOIN Lessons l ON lm.lessonid = l.id
	WHERE lm.lessondate < NOW() AND date_part('year', lm.lessondate) = '2019'
	GROUP BY 1, 2, 3, 4
	ORDER BY 1, 2, 3) lc
ON md.MasterId = lc.MasterId;