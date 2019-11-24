-- 2) Для Лекарств, у которых заменитель является им же, вывести:
WITH cteMedicines(Id, Title, SubstituteId, ClientIntolerance)
AS
(
	SELECT 
		med.id,
		med.title, 
		s.medicineid,
		i.clientid
	FROM Medicines med
	RIGHT JOIN Intolerances i ON i.medicineid = med.id
	RIGHT JOIN Substitutes s ON s.intoleranceid = i.id
)
SELECT 
	-- название Лекарства
	cte1.Title AS Title,
	-- заменители через запятую в одно поле
	string_agg(cte2.Title, ', ') AS SubstitutesList,
	-- количество клиентов, обладающих непереносимостью
	COUNT(DISTINCT cte1.ClientIntolerance) AS ClientsIntoleranceCount
FROM cteMedicines cte1
JOIN cteMedicines cte2 
ON cte1.SubstituteId = cte2.Id
GROUP BY cte1.Id, cte1.Title
HAVING bool_or(cte1.Id = cte2.SubstituteId);