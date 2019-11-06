/* 
    Определение студии для записи на курс 
    и стоимости проведения курся 
*/
CREATE FUNCTION find_location_and_cost(regId INTEGER) 
RETURNS void AS $$
DECLARE
    clientsCount INTEGER;
    locId INTEGER;
    totalCost INTEGER;
BEGIN
    -- Узнаем число записавшихся
    SELECT COUNT(*) INTO clientsCount FROM RegistrationClient rc
    WHERE rc.registrationId = regId;
    IF clientsCount > 0 THEN
        -- Находим самую дешевую Студия, которая всех вместит
        SELECT id, rentCost INTO locId, totalCost
        FROM Locations WHERE capacity >= clientsCount
        ORDER BY capacity, rentCost LIMIT 1;
        -- Прибавляем стоимость аренды и доставки кухонного оборудования
        totalCost := totalCost + (SELECT SUM(c) FROM
        (SELECT (les.quantity - COALESCE(loc.quantity, 0))*(e.averageRentalCost + e.deliveryCost) c 
        FROM Lessons l 
        RIGHT JOIN LessonEquipment les ON l.id = les.lessonid 
        LEFT JOIN LocationEquipment loc ON loc.equipmentid = les.equipmentid 
        JOIN Equipment e ON e.id = les.equipmentid 
        WHERE l.courseId = (SELECT courseId FROM Registrations 
        WHERE id = regId LIMIT 1) 
        AND loc.locationId = locId) costs);
        -- Прибавляем стоимость покупки и доставки продуктов
        totalCost := totalCost + (SELECT SUM(c) FROM
        (SELECT lf.quantity*(f.averagePrice + f.deliveryCost) c 
        FROM Lessons l 
        RIGHT JOIN LessonFood lf ON l.id = lf.lessonid
        JOIN Food f ON f.id = lf.foodid 
        WHERE l.courseId = (SELECT courseId FROM Registrations 
        WHERE id = regId LIMIT 1)) costs);
        -- Обновляем данные регистрации
        UPDATE Registrations 
        SET locationId = locId, cost = totalCost
        WHERE id = regId;
    END IF;
END;
$$ LANGUAGE plpgsql;