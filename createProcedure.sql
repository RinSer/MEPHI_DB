/* 
    Определение студии для записи на курс 
    и стоимости проведения курся 
*/
CREATE FUNCTION find_location_and_cost(regId INTEGER) 
RETURNS void AS $$
DECLARE
    clientsCount INTEGER;
    locId INTEGER;
    possibleDate TIMESTAMP;
    totalCost INTEGER;
BEGIN
    -- Узнаем число записавшихся
    SELECT COUNT(*) INTO clientsCount FROM RegistrationClient rc
    WHERE rc.registrationId = regId;
    IF clientsCount > 0 THEN
        -- Находим самую дешевую Студия, которая всех вместит
        SELECT id, possibleTime, rentCost INTO locId, possibleDate, totalCost
        FROM Locations l WHERE l.capacity >= clientsCount AND l.possibleTime > now()
        AND NOT EXISTS (SELECT id FROM Registrations r WHERE r.locationId = l.id)
        ORDER BY capacity, rentCost LIMIT 1;
        IF locId IS NULL THEN 
            RAISE EXCEPTION 'Нет студии с вместимостью %', clientsCount;
        ELSE
            -- Прибавляем стоимость аренды и доставки кухонного оборудования
            totalCost := totalCost + COALESCE((SELECT SUM(c) FROM
            (SELECT (les.quantity - COALESCE(loc.quantity, 0))*(e.averageRentalCost + e.deliveryCost) c 
            FROM LessonEquipment les
            JOIN Lessons l ON l.id = les.lessonid 
            JOIN Equipment e ON e.id = les.equipmentid
            LEFT JOIN (SELECT equipmentid, quantity FROM LocationEquipment 
            WHERE locationId = locId) loc ON loc.equipmentid = les.equipmentid  
            WHERE l.courseId = (SELECT courseId FROM Registrations 
            WHERE id = regId LIMIT 1)) costs), 0)*clientsCount;
            -- Прибавляем стоимость покупки и доставки продуктов
            totalCost := totalCost + COALESCE((SELECT SUM(c) FROM
            (SELECT lf.quantity*(f.averagePrice + f.deliveryCost) c 
            FROM LessonFood lf 
            JOIN Lessons l ON l.id = lf.lessonid
            JOIN Food f ON f.id = lf.foodid 
            WHERE l.courseId = (SELECT courseId FROM Registrations 
            WHERE id = regId LIMIT 1)) costs), 0)*clientsCount;
            -- Обновляем данные регистрации
            UPDATE Registrations 
            SET locationId = locId, schedule = possibleDate, cost = totalCost
            WHERE id = regId;
        END IF;
    ELSE
        RAISE EXCEPTION 'На курс никто не записался!';
    END IF;
END;
$$ LANGUAGE plpgsql;
/* 
    Определение стоимости проведения
    для записи на курс (одного потока)
*/
CREATE FUNCTION find_registration_cost(regId INTEGER) 
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
        -- Находим Студия, зарезервированную под Регистрацию
        SELECT id, rentCost INTO locId, totalCost
        FROM Locations l WHERE id = 
        (SELECT locationId FROM Registrations r WHERE r.id = regId LIMIT 1);
        IF locId IS NULL THEN 
            RAISE EXCEPTION 'У регистрации не определена Студия!';
        ELSE
            -- Прибавляем стоимость аренды и доставки кухонного оборудования
            totalCost := totalCost + COALESCE((SELECT SUM(c) FROM
            (SELECT (les.quantity - COALESCE(loc.quantity, 0))*(e.averageRentalCost + e.deliveryCost) c 
            FROM LessonEquipment les
            JOIN Lessons l ON l.id = les.lessonid 
            JOIN Equipment e ON e.id = les.equipmentid
            LEFT JOIN (SELECT equipmentid, quantity FROM LocationEquipment 
            WHERE locationId = locId) loc ON loc.equipmentid = les.equipmentid  
            WHERE l.courseId = (SELECT courseId FROM Registrations 
            WHERE id = regId LIMIT 1)) costs), 0)*clientsCount;
            -- Прибавляем стоимость покупки и доставки продуктов
            totalCost := totalCost + COALESCE((SELECT SUM(c) FROM
            (SELECT lf.quantity*(f.averagePrice + f.deliveryCost) c 
            FROM LessonFood lf 
            JOIN Lessons l ON l.id = lf.lessonid
            JOIN Food f ON f.id = lf.foodid 
            WHERE l.courseId = (SELECT courseId FROM Registrations 
            WHERE id = regId LIMIT 1)) costs), 0)*clientsCount;
            -- Обновляем данные регистрации
            UPDATE Registrations 
            SET cost = totalCost
            WHERE id = regId;
        END IF;
    ELSE
        RAISE EXCEPTION 'На курс никто не записался!';
    END IF;
END;
$$ LANGUAGE plpgsql;