-- 1) Для каждой Студии за год вывести:
SELECT * FROM (
	SELECT 
		-- Идентификатор Студии
		l.id,
		-- количество проведенных курсов за этот год
		COALESCE((SELECT COUNT(*) FROM Registrations 
		WHERE date_part('year', schedule) = '2019' AND schedule < NOW()
		AND locationId = l.id GROUP BY locationId), 0) AS CoursesCount,
		-- среднее количество студентов за курс за этот год
		COALESCE((SELECT AVG(num) FROM 
		(SELECT COUNT(*) AS num FROM RegistrationClient rc
		JOIN Registrations r ON r.id = rc.registrationId
		WHERE date_part('year', r.schedule) = '2019' AND schedule < NOW()
		AND r.locationId = l.id GROUP BY r.courseId) AS ClientsCountPerCourse), 0) AS AverageClientsCountPerCourse,
		-- дата первого занятия
		(SELECT MIN(schedule) FROM Registrations 
		WHERE locationId = l.id AND date_part('year', schedule) = '2019'
		AND schedule < NOW()) AS FirstLessonDate,
		-- дата последнего занятия
		(SELECT MAX(schedule) FROM 
		(SELECT (regs.schedule + CONCAT(CAST(COUNT(les.*) AS VARCHAR), ' day')::INTERVAL) AS schedule
		FROM Lessons les JOIN Registrations regs ON regs.courseid = les.courseid
		WHERE regs.locationid = l.id AND date_part('year', regs.schedule) = '2019'
		AND schedule < NOW()
		GROUP BY les.courseid, regs.id) AS LastLessons) AS LastLessonDate,
		-- количество поставленных продуктов
		(SELECT SUM(quantity) FROM LessonFood lf
		JOIN Lessons lsn ON lsn.id = lf.lessonid
		JOIN Registrations rgs ON rgs.courseid = lsn.courseid
		WHERE rgs.locationid = l.id
		AND date_part('year', rgs.schedule) = '2019' AND rgs.schedule < NOW()) AS ProductsCount
	FROM locations l
) q WHERE CoursesCount > 0;