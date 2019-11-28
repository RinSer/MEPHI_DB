-- 1) Для каждой Студии за год вывести:
WITH cteRegistrations(id, courseid, locationid, firstDate, lastDate)
AS (
	SELECT 
		regs.id AS id
		,regs.courseid AS courseid
		,regs.locationid AS locationid
		,regs.schedule AS firstDate
		,MAX(lm.lessondate) AS lastDate
		,COUNT(DISTINCT rc.clientid) AS clientsCount
	FROM Registrations regs
	JOIN LessonMaster lm ON regs.id = lm.registrationid
	JOIN RegistrationClient rc ON regs.id = rc.registrationid
	-- за этот год
	WHERE date_part('year', regs.schedule) = '2019'
	-- уже проведенные
	AND regs.schedule < NOW()
	GROUP BY regs.id
)
SELECT
	-- Идентификатор Студии
	r.locationId
	-- количество проведенных курсов за этот год
	,COUNT(DISTINCT r.id) AS CoursesCount
	-- среднее количество студентов за курс за этот год
	,AVG(r.clientsCount) AS AverageClientsCountPerCourse
	-- дата первого занятия
	,to_char(MIN(r.firstDate), 'DD.MM.YYYY') AS FirstLessonDate
	-- дата последнего занятия
	,to_char(MAX(r.lastDate), 'DD.MM.YYYY') AS LastLessonDate
	-- количество поставленных продуктов
	,SUM(lf.quantity) AS ProductsCount
FROM cteRegistrations r
JOIN Lessons l ON l.courseid = r.courseid
JOIN LessonFood lf ON lf.lessonid = l.id
GROUP BY r.locationId;