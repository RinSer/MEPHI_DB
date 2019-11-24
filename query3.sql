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
		rm.masterid AS MasterId,
		-- среднее время промежутков между проводимыми курсами
		(SELECT AVG(Gap) FROM (SELECT 
		(LEAD(rgs.schedule) OVER (ORDER BY rgs.schedule) - MAX(lmr.lessondate)) AS Gap
		FROM Registrations rgs JOIN LessonMaster lmr ON rgs.id = lmr.registrationid
		WHERE rgs.id = ANY(array_agg(rm.registrationid))
		GROUP BY rgs.id
		) AS Gaps) AS AverageIntervalBetweenCourses,
		-- количество разных обученных студентов
		(SELECT COUNT(*) FROM RegistrationClient
		WHERE registrationid = ANY(array_agg(rm.registrationid))) AS StudentsCount,
		-- количество проведенных курсов
		COUNT(rm.*) AS CoursesCount
	FROM RegistrationMaster rm
	JOIN registrations r ON rm.registrationid = r.id
	WHERE r.schedule < NOW()
	GROUP BY rm.masterid) md
RIGHT JOIN
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