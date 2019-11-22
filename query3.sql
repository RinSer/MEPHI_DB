-- 3) Для каждого Мастера вывести:
SELECT
	-- Идентификатор мастера
	masters.id,
	-- среднее время промежутков между проводимыми курсами
	(SELECT AVG(Gap) FROM (SELECT 
	(LEAD(r.schedule) OVER (ORDER BY r.schedule) - r.schedule) AS Gap
	FROM RegistrationMaster rm
	JOIN Registrations r ON r.id = rm.registrationid
	JOIN Masters m ON m.id = rm.masterid
	WHERE m.id = masters.id
	ORDER BY r.schedule) Gaps) AS AverageIntervalBetweenCourses
	-- количество разных обученных студентов
	-- количество проведенных курсов
	-- количество проведенных занятий по каждому типу в разрезе каждого месяца за последний год
FROM Masters masters
WHERE (SELECT COUNT(*) FROM RegistrationMaster WHERE masterid = masters.id) > 1;