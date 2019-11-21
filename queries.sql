SELECT 
	l.id,
	coalesce((SELECT COUNT(*) FROM Registrations 
	WHERE date_part('year', schedule) = '2019' 
	AND locationId = l.id GROUP BY locationId), 0) as CourseCount
FROM locations l;