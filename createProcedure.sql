/* 
    Определение студии для записи на курс 
    и стоимости проведения курся 
*/
CREATE FUNCTION find_location_and_cost(registrationId INTEGER) 
RETURNS void AS $$
DECLARE
    clientsCount INTEGER;
    locationId INTEGER;
    totalCost INTEGER;
BEGIN
    -- Узнаем число записавшихся
    clientsCount := SELECT COUNT(*) 
    FROM RegistrationClient WHERE registrationId = registrationId;
    IF clientsCount > 0 THEN
        -- Находим самую дешевую Студия, которая всех вместит
        SELECT id, rentCost INTO locationId, totalCost
        FROM Locations WHERE capacity >= clientsCount
        ORDER BY capacity, rentCost LIMIT 1;
        -- Считаем аренду кухонного оборудования
        SELECT (e.averageRentalCost + e.deliveryCost)*(les.quantity - COALESCE(loc.quantity, 0))
        FROM Lessons l RIGHT JOIN LessonEquipment les ON l.id = les.lessonId
        JOIN LocationEquipment loc ON les.equipmentId = loc.equipmentId
        JOIN Equipment e ON e.id = les.equipmentId
        WHERE l.courseId = (SELECT courseId FROM Registrations 
        WHERE id = 1 LIMIT 1)
        GROUP BY les.equipmentId, les.quantity, loc.quantity, 
        e.deliveryCost, e.averageRentalCost;

        select * from lessons l right join lessonequipment les on l.id = les.lessonid left join locationequipment loc on loc.equipmentid = les.equipmentid join equipment e on e.id = les.equipmentid where l.courseId = 19475;
    END IF;
END;
$$ LANGUAGE plpgsql;