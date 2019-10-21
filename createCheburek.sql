/* Скрипт создания таблиц БД Беляш-Чебурек */

-- Клиент/E1
CREATE TABLE Clients (
    id BIGSERIAL PRIMARY KEY,
    lastName VARCHAR(100) NOT NULL, -- ФАМИЛИЯ
    firstName VARCHAR(100) NOT NULL, -- ИМЯ
    patronimicName VARCHAR(100) NULL, -- ОТЧЕСТВО
    phone VARCHAR(20) NOT NULL, -- ТЕЛЕФОН
    email VARCHAR(100) NULL, -- ПОЧТА
    account VARCHAR(30) NULL -- СЧЕТ
);

-- Мастер/E2
CREATE TABLE Masters (
    id SERIAL PRIMARY KEY,
    lastName VARCHAR(100) NOT NULL, -- ФАМИЛИЯ
    firstName VARCHAR(100) NOT NULL, -- ИМЯ
    patronimicName VARCHAR(100) NULL, -- ОТЧЕСТВО
    passportSerial VARCHAR(4) NOT NULL, -- СЕРИЯ ПАСПОРТА
    passportNumber VARCHAR(6) NOT NULL, -- НОМЕР ПАСПОРТА
    coursesCount INT NOT NULL, -- КОЛИЧЕСТВО КУРСОВ
    characteristic VARCHAR(500) NULL -- ХАРАКТЕРИСТИКА
);

-- Студия/E3
CREATE TABLE Locations (
    id SERIAL PRIMARY KEY,
    capacity INT NOT NULL, -- ВМЕСТИМОСТЬ
    possibleTime TIME NOT NULL, -- ВОЗМОЖНОЕ ВРЕМЯ
    rentCost DECIMAL(12, 2), -- СТОИМОСТЬ АРЕНДЫ
    address VARCHAR(300) NOT NULL -- АДРЕС
);

-- Курс/E5
CREATE TABLE Courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL, -- НАЗВАНИЕ
    description VARCHAR(500) NOT NULL, -- ОПИСАНИЕ
    duration INTERVAL NOT NULL -- ПРОДОЛЖИТЕЛЬНОСТЬ
);

-- Тип занятия/E12
CREATE TABLE LessonTypes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL -- НАЗВАНИЕ
);

-- Занятие/E4
CREATE TABLE Lessons (
    id SERIAL PRIMARY KEY,
    courseId INTEGER REFERENCES Courses(id) ON DELETE RESTRICT, -- ИД КУРСА
    typeId INTEGER REFERENCES LessonTypes(id) ON DELETE RESTRICT, -- ИД ТИПА
    duration INTERVAL NOT NULL -- ВРЕМЯ
);

-- Запись/E6
CREATE TABLE Registrations (
    id SERIAL PRIMARY KEY,
    courseId INTEGER REFERENCES Courses(id) ON DELETE RESTRICT, -- ИД КУРСА
    locationId INTEGER REFERENCES Locations(id) ON DELETE RESTRICT, -- ИД СТУДИИ
    schedule TIMESTAMP NOT NULL, -- РАСПИСАНИЕ
    cost DECIMAL(12, 2) NOT NULL -- СТОИМОСТЬ
);

-- Продукт/E7
CREATE TABLE Food (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL, -- НАЗВАНИЕ
    averagePrice DECIMAL(12, 2) NOT NULL, -- СРЕДНЯЯ ЦЕНА
    deliveryTime INTERVAL NOT NULL, -- ВРЕМЯ ДОСТАВКИ
    deliveryCost DECIMAL(12, 2) NOT NULL -- СТОИМОСТЬ ДОСТАВКИ
);

-- Оборудование/E8
CREATE TABLE Equipment (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL, -- НАЗВАНИЕ
    averageRentalCost DECIMAL(12, 2) NOT NULL, -- СРЕДНЯЯ СТОИМОСТЬ АРЕНДЫ
    deliveryTime INTERVAL NOT NULL, -- ВРЕМЯ ДОСТАВКИ
    deliveryCost DECIMAL(12, 2) NOT NULL -- СТОИМОСТЬ ДОСТАВКИ
);

-- Тип лекарства/E13
CREATE TABLE MedicineTypes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL -- НАЗВАНИЕ
);

-- Лекарство/E10
CREATE TABLE Medicines (
    id BIGSERIAL PRIMARY KEY,
    typeId INTEGER REFERENCES MedicineTypes(id) ON DELETE RESTRICT, -- ИД ТИПА
    title VARCHAR(300) NOT NULL, -- НАЗВАНИЕ
    cost DECIMAL(12, 2) NOT NULL -- СТОИМОСТЬ
);

-- Аптечка/E9
CREATE TABLE RegistrationMedicines (
    registrationId INTEGER REFERENCES Registrations(id) ON DELETE RESTRICT, -- ИД ЗАПИСИ
    medicineId BIGINT REFERENCES Medicines(id) ON DELETE RESTRICT, -- ИД ЛЕКАРСТВА
    quantity INTEGER, -- КОЛИЧЕСТВО
    PRIMARY KEY (registrationId, medicineId)
);

-- Непереносимость/E11
CREATE TABLE Intolerances (
    id BIGSERIAL PRIMARY KEY,
    clientId BIGINT REFERENCES Clients(id) ON DELETE RESTRICT, -- ИД КЛИЕНТА
    medicineId BIGINT REFERENCES Medicines(id) ON DELETE RESTRICT -- ИД ЛЕКАРСТВА
);

-- Заменитель/E20
CREATE TABLE Substitutes (
    intoleranceId BIGINT REFERENCES Intolerances(id) ON DELETE RESTRICT, -- ИД НЕПЕРЕНОСИМОСТИ
    medicineId BIGINT REFERENCES Medicines(id) ON DELETE RESTRICT, -- ИД ЛЕКАРСТВА
    PRIMARY KEY (intoleranceId, medicineId)
);

-- ЗанятиеМастер/E14
CREATE TABLE LessonMaster (
    lessonId INTEGER REFERENCES Lessons(id) ON DELETE RESTRICT, -- ИД ЗАНЯТИЯ
    registrationId INTEGER REFERENCES Registrations(id) ON DELETE RESTRICT, -- ИД ЗАПИСИ
    masterId INTEGER REFERENCES Masters(id) ON DELETE RESTRICT, -- ИД МАСТЕРА
    lessonDate TIMESTAMP NOT NULL, -- ДАТА ЗАНЯТИЯ
    PRIMARY KEY (lessonId, registrationId)
);

-- ЗанятиеПродукт/E15
CREATE TABLE LessonFood (
    lessonId INTEGER REFERENCES Lessons(id) ON DELETE RESTRICT, -- ИД ЗАНЯТИЯ
    foodId BIGINT REFERENCES Food(id) ON DELETE RESTRICT, -- ИД ПРОДУКТА
    quantity INTEGER NOT NULL, -- КОЛИЧЕСТВО
    PRIMARY KEY (lessonId, foodId)
);

-- ЗанятиеОборудование/E16
CREATE TABLE LessonEquipment (
    lessonId INTEGER REFERENCES Lessons(id) ON DELETE RESTRICT, -- ИД ЗАНЯТИЯ
    equipmentId BIGINT REFERENCES Equipment(id) ON DELETE RESTRICT, -- ИД ОБОРУДОВАНИЯ
    quantity INTEGER NOT NULL, -- КОЛИЧЕСТВО
    PRIMARY KEY (lessonId, equipmentId)
);

-- ЗаписьМастер/E17
CREATE TABLE RegistrationMaster (
    registrationId INTEGER REFERENCES Registrations(id) ON DELETE RESTRICT, -- ИД ЗАПИСИ
    masterId INTEGER REFERENCES Masters(id) ON DELETE RESTRICT, -- ИД МАСТЕРА
    PRIMARY KEY (registrationId, masterId)
);

-- СтудияОборудование/E18
CREATE TABLE LocationEquipment (
    locationId INTEGER REFERENCES Locations(id) ON DELETE RESTRICT, -- ИД СТУДИИ
    equipmentId BIGINT REFERENCES Equipment(id) ON DELETE RESTRICT, -- ИД ОБОРУДОВАНИЯ
    quantity INTEGER NOT NULL, -- КОЛИЧЕСТВО
	PRIMARY KEY (locationId, equipmentId)
);

-- ЗаписьКлиент/E19
CREATE TABLE RegistrationClient (
    registrationId INTEGER REFERENCES Registrations(id) ON DELETE RESTRICT, -- ИД ЗАПИСИ
    clientId BIGINT REFERENCES Clients(id) ON DELETE RESTRICT, -- ИД КЛИЕНТА
    PRIMARY KEY (registrationId, clientId)
);
