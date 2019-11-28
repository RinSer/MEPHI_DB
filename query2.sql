-- 2) Для Лекарств, у которых заменитель является им же, вывести:
WITH RECURSIVE cteMedicines(Id, Title, SubstituteId) AS
(
	SELECT 
		med.id
		,med.title
		,s.medicineid
	FROM Medicines med
	JOIN Intolerances i ON i.medicineid = med.id
	JOIN Substitutes s ON s.intoleranceid = i.id
)
, cteSubstitutes(Id, Title, SubstituteId, depth)
AS
(
		SELECT
			Id
			,Title
			,SubstituteId
			,1
		FROM cteMedicines
	UNION ALL
		SELECT 
			cs.Id
			,cs.Title
			,cm.SubstituteId
			,depth+1
		FROM cteSubstitutes cs
		JOIN cteMedicines cm ON cs.SubstituteId = cm.Id
		WHERE depth < 5
)
SELECT 
	-- название Лекарства
	s.Title
	-- заменители через запятую в одно поле
	,string_agg(m.Title, ', ') AS SubstitutesList
	-- количество клиентов, обладающих непереносимостью
	,COUNT(DISTINCT i.id) AS ClientsIntoleranceCount
FROM cteSubstitutes s
JOIN Medicines m ON s.SubstituteId = m.id
LEFT JOIN Intolerances i ON s.Id = i.medicineid
GROUP BY s.Title
HAVING bool_or(s.Id = m.id);