-- 2) Для Лекарств, у которых заменитель является им же, вывести:
WITH RECURSIVE cteMedicines(Id, Title, SubstituteId, SubstituteTitle, IntoleranceCount) AS
(
	SELECT 
		med.id
		,med.title
		,s.medicineid
		,m.title
		,COUNT(i.id) OVER (PARTITION BY med.id)
	FROM Medicines med
	JOIN Intolerances i ON i.medicineid = med.id
	JOIN Substitutes s ON s.intoleranceid = i.id
	JOIN Medicines m ON s.medicineid = m.id
)
, cteSubstitutes(Id, Title, SubstituteId, SubstituteTitle, IntoleranceCount, depth)
AS
(
		SELECT
			Id
			,Title
			,SubstituteId
			,SubstituteTitle
			,IntoleranceCount
			,1
		FROM cteMedicines
	UNION ALL
		SELECT 
			cs.Id
			,cs.Title
			,cm.SubstituteId
			,cm.SubstituteTitle
			,cs.IntoleranceCount
			,depth+1
		FROM cteSubstitutes cs
		JOIN cteMedicines cm ON cs.SubstituteId = cm.Id
		WHERE depth < 5
)
SELECT 
	-- название Лекарства
	s.Title
	-- заменители через запятую в одно поле
	,string_agg(s.SubstituteTitle, ', ') AS SubstitutesList
	-- количество клиентов, обладающих непереносимостью
	,s.IntoleranceCount AS ClientsIntoleranceCount
FROM cteSubstitutes s
GROUP BY s.Title, s.IntoleranceCount
HAVING bool_or(s.Id = s.SubstituteId);