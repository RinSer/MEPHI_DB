-- 2) Для Лекарств, у которых заменитель является им же, вывести:
SELECT 
	-- название Лекарства
	m.title,
	-- заменители через запятую в одно поле
	(SELECT string_agg(med.title, ', ') FROM Substitutes sub
	JOIN Intolerances ins ON ins.id = sub.intoleranceid
	JOIN Medicines med ON med.id = ins.medicineid
	WHERE sub.medicineid = m.id) AS Substitutes,
	-- количество клиентов, обладающих непереносимостью
	(SELECT COUNT(DISTINCT clientId) FROM Intolerances 
	WHERE medicineid = m.id) AS ClientsIntoleranceCount
FROM Medicines m
JOIN Intolerances i ON i.medicineid = m.id
JOIN Substitutes s ON s.intoleranceid = i.id
WHERE s.medicineid = m.id;