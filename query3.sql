-- 3) Для каждого Мастера вывести:
SELECT md.*, 
	-- Тип занятия
	lc.LessonType,
	-- Месяц
	lc.Month,
	-- Количество занятий данного типа за месяц в этом году
	lc.LessonsCount
	FROM
	(SELECT
		-- Идентификатор мастера
		m.id AS MasterId,
		-- среднее время промежутков между проводимыми курсами
		(SELECT AVG(Gap) FROM (SELECT 
		(LEAD(schedule) OVER (ORDER BY schedule) - schedule) AS Gap
		FROM Registrations
		WHERE id = ANY(array_agg(rm.registrationid))
		) AS Gaps) AS AverageIntervalBetweenCourses,
		-- количество разных обученных студентов
		(SELECT COUNT(*) FROM RegistrationClient
		WHERE registrationid = ANY(array_agg(rm.registrationid))) AS StudentsCount,
		-- количество проведенных курсов
		COUNT(rm.*) AS CoursesCount
	FROM RegistrationMaster rm 
	JOIN Masters m ON rm.masterid = m.id
	GROUP BY rm.masterid, m.id) md
RIGHT JOIN
	-- количество проведенных занятий по каждому типу в разрезе каждого месяца за последний год
	(SELECT 
		m.id AS MasterId,
		l.typeid AS LessonType,
		extract(month from r.schedule) AS MonthIndex,
		to_char(r.schedule, 'month') AS Month,
		COUNT(l.*) AS LessonsCount
	FROM Registrations r
	JOIN Courses c ON r.courseid = c.id
	RIGHT JOIN Lessons l ON l.courseid = c.id
	RIGHT JOIN RegistrationMaster rm ON r.id = rm.registrationid
	JOIN Masters m ON rm.masterid = m.id
	WHERE r.schedule < NOW() AND date_part('year', r.schedule) = '2019'
	GROUP BY 1, 2, 3, 4
	ORDER BY 1, 2, 3) lc
ON md.MasterId = lc.MasterId;