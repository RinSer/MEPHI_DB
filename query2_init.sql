-- 2) Для Лекарств, у которых заменитель является им же, вывести:
SELECT 
	-- название Лекарства
	med.title, 
	-- заменители через запятую в одно поле
	string_agg(m.title, ', ') AS SubstitutesList,
	-- количество клиентов, обладающих непереносимостью
	COUNT(DISTINCT i.clientid) AS ClientsIntoleranceCount
FROM Medicines med
RIGHT JOIN Intolerances i ON i.medicineid = med.id
RIGHT JOIN Substitutes s ON s.intoleranceid = i.id
JOIN Medicines m ON m.id = s.medicineid
GROUP BY med.id, med.title
HAVING bool_or(med.id = m.id);