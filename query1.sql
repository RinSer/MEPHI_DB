-- 1) Для каждой Студии за год вывести:
WITH cteRegistrations(id, courseid, locationid, firstDate, lastDate)
AS (
	SELECT 
		regs.id AS id
		,regs.courseid AS courseid
		,regs.locationid AS locationid
		,regs.schedule AS firstDate
		,MAX(lm.lessondate) AS lastDate
	FROM LessonMaster lm JOIN Registrations regs ON regs.id = lm.registrationid
	-- за этот год
	WHERE date_part('year', regs.schedule) = '2019'
	-- уже проведенные
	AND regs.schedule < NOW()
	GROUP BY regs.id
)
SELECT 
	-- Идентификатор Студии
	l.id, 
	-- количество проведенных курсов за этот год
	COUNT(r.*) AS CoursesCount,
	-- среднее количество студентов за курс за этот год
	(SELECT AVG(num) FROM (SELECT COUNT(*) AS num 
	FROM RegistrationClient WHERE registrationid = ANY(array_agg(r.id))
	GROUP BY registrationid) AS ClientsCountPerCourse) AS AverageClientsCountPerCourse,
	-- дата первого занятия
	to_char(MIN(r.firstDate), 'DD.MM.YYYY') AS FirstLessonDate,
	-- дата последнего занятия
	to_char(MAX(r.lastDate), 'DD.MM.YYYY') AS LastLessonDate,
	-- количество поставленных продуктов
	(SELECT SUM(quantity) FROM LessonFood lf
	JOIN Lessons lsn ON lsn.id = lf.lessonid
	WHERE lsn.courseid = ANY(array_agg(r.courseid))) AS ProductsCount
FROM cteRegistrations r
JOIN Locations l ON l.id = r.locationid
GROUP BY l.id, r.locationId;