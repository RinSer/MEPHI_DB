-- 1) Для каждой Студии за год вывести:
SELECT 
	-- Идентификатор Студии
	l.id, 
	-- количество проведенных курсов за этот год
	COUNT(r.locationid) AS CoursesCount,
	-- среднее количество студентов за курс за этот год
	(SELECT AVG(num) FROM (SELECT COUNT(*) AS num 
	FROM RegistrationClient WHERE registrationid = ANY(array_agg(r.id))
	GROUP BY registrationid) AS ClientsCountPerCourse) AS AverageClientsCountPerCourse,
	-- дата первого занятия
	to_char(MIN(r.schedule), 'DD.MM.YYYY') AS FirstLessonDate,
	-- дата последнего занятия
	(SELECT to_char(MAX(schedule), 'DD.MM.YYYY') FROM 
	(SELECT (regs.schedule + CONCAT(CAST(COUNT(*) AS VARCHAR), ' day')::INTERVAL) AS schedule
	FROM Lessons les JOIN Registrations regs ON regs.courseid = les.courseid
	WHERE regs.id = ANY(array_agg(r.id))
	GROUP BY les.courseid, regs.id) AS LastLessons) AS LastLessonDate,
	-- количество поставленных продуктов
	(SELECT SUM(quantity) FROM LessonFood lf
	JOIN Lessons lsn ON lsn.id = lf.lessonid
	WHERE lsn.courseid = ANY(array_agg(r.courseid))) AS ProductsCount
FROM Registrations r
JOIN Locations l ON l.id = r.locationid
-- за этот год
WHERE date_part('year', r.schedule) = '2019'
-- уже проведенные
AND r.schedule < NOW()
GROUP BY l.id, r.locationId