import random


TYPE_ENTITY_COUNT = 4
MAIN_ENTITY_COUNT = 1000
AUX_ENTITY_COUNT = 1000


def get_user(faker):
    '''
    Function to return user name as a tuple
    '''
    name = faker.name().split(' ')
    i = 1 if len(name) > 3 else 0
    return (name[i], name[i+1], name[i+2])


def get_int_str(length):
    '''
    Function to get a random int sequence as str
    '''
    seq = ""
    for _ in range(length):
        seq += str(random.randrange(0, 9, 1))
    return seq


def create_row(row):
    '''
    Function to return row str from tuple
    '''
    return '(' + ','.join("'" + str(e) + "'" for e in row) + ')'


def create_db(cursor, connection, faker):
    '''
    Creates all tables in the db and seeds them with data
    '''
    # Load schema creation script 
    with open('createCheburek.sql', 'r', encoding='utf8') as script:
        cursor.execute(script.read())
    connection.commit()

    # Seeding clients
    query = "INSERT INTO Clients (lastName, firstName, patronimicName, phone, email, account) VALUES "
    clients = list()
    for _ in range(MAIN_ENTITY_COUNT*5):
        name = get_user(faker)
        clients.append(create_row((name[0], name[1], name[2], 
            faker.phone_number().replace(' ', ''), faker.free_email(), faker.isbn10(separator="-"))))
    query_data = ','.join(clients)
    cursor.execute(query + query_data)

    # Seeding masters
    query = "INSERT INTO Masters (lastName, firstName, patronimicName, passportSerial, passportNumber, coursesCount, characteristic) VALUES "
    masters = list()
    for _ in range(MAIN_ENTITY_COUNT):
        name = get_user(faker)
        masters.append(create_row((name[0], name[1], name[2], 
            get_int_str(4), get_int_str(6), random.randrange(0, 100, 1), faker.text(max_nb_chars=300))))
    query_data = ','.join(masters)
    cursor.execute(query + query_data)

    # Seeding locations
    query = "INSERT INTO Locations (capacity, possibleTime, rentCost, address) VALUES "
    locations = list()
    for _ in range(int(MAIN_ENTITY_COUNT/10)):
        locations.append(create_row((random.randrange(10, 500, 1), 
            faker.time(pattern="%H:%M:%S", end_datetime=None), random.randrange(0, 25000, 250), faker.address())))
    query_data = ','.join(locations)
    cursor.execute(query + query_data)

    # Seeding courses
    query = "INSERT INTO Courses (title, description, duration) VALUES "
    courses = list()
    for _ in range(int(MAIN_ENTITY_COUNT/5)):
        courses.append(create_row((faker.text(max_nb_chars=100), faker.text(max_nb_chars=300), random.randrange(10, 100, 1))))
    query_data = ','.join(courses)
    cursor.execute(query + query_data)

    # Seeding lesson types
    query = "INSERT INTO LessonTypes (title) VALUES "
    lessonTypes = list()
    for _ in range(TYPE_ENTITY_COUNT):
        lessonTypes.append(create_row((faker.text(max_nb_chars=100),)))
    query_data = ','.join(lessonTypes)
    cursor.execute(query + query_data)

    # Seeding lessons
    cursor.execute("SELECT id FROM Courses")
    courses = [c[0] for c in cursor.fetchall()]
    cursor.execute("SELECT id FROM LessonTypes")
    lessonTypes = [t[0] for t in cursor.fetchall()]
    query = "INSERT INTO Lessons (courseId, typeId, duration) VALUES "
    lessons = list()
    for _ in range(MAIN_ENTITY_COUNT*10):
        lessons.append(create_row((courses[random.randrange(0, len(courses), 1)], 
            lessonTypes[random.randrange(0, len(lessonTypes), 1)], random.randrange(40, 120, 40))))
    query_data = ','.join(lessons)
    cursor.execute(query + query_data)

    # Seeding registrations
    cursor.execute("SELECT id FROM Locations")
    locations = [l[0] for l in cursor.fetchall()]
    query = "INSERT INTO Registrations (courseId, locationId, schedule, cost) VALUES "
    registrations = list()
    for _ in range(MAIN_ENTITY_COUNT):
        registrations.append(create_row((courses[random.randrange(0, len(courses), 1)], 
            locations[random.randrange(0, len(locations), 1)], 
            faker.date_time_this_decade(before_now=True, after_now=True, tzinfo=None), 
            random.randrange(10000, 100000, 1000))))
    query_data = ','.join(registrations)
    cursor.execute(query + query_data)

    # Seeding food
    query = "INSERT INTO Food (title, averagePrice, deliveryTime, deliveryCost) VALUES "
    food = list()
    for _ in range(MAIN_ENTITY_COUNT*10):
        food.append(create_row((faker.text(max_nb_chars=100), random.randrange(10, 10000, 10), 
            random.randrange(10, 600, 10), random.randrange(10, 1000, 10))))
    query_data = ','.join(food)
    cursor.execute(query + query_data)

    # Seeding equipment
    query = "INSERT INTO Equipment (title, averageRentalCost, deliveryTime, deliveryCost) VALUES "
    equipment = list()
    for _ in range(MAIN_ENTITY_COUNT*10):
        equipment.append(create_row((faker.text(max_nb_chars=100), random.randrange(10, 10000, 10), 
            random.randrange(10, 600, 10), random.randrange(10, 1000, 10))))
    query_data = ','.join(equipment)
    cursor.execute(query + query_data)

    # Seeding medicine types
    query = "INSERT INTO MedicineTypes (title) VALUES "
    medicineTypes = list()
    for _ in range(TYPE_ENTITY_COUNT*10):
        medicineTypes.append(create_row((faker.text(max_nb_chars=100),)))
    query_data = ','.join(medicineTypes)
    cursor.execute(query + query_data)

    # Seeding medicines
    cursor.execute("SELECT id FROM MedicineTypes")
    medicineTypes = [t[0] for t in cursor.fetchall()]
    query = "INSERT INTO Medicines (typeId, title, cost) VALUES "
    lessons = list()
    for _ in range(MAIN_ENTITY_COUNT*10):
        lessons.append(create_row((medicineTypes[random.randrange(0, len(medicineTypes), 1)], 
            faker.text(max_nb_chars=100), random.randrange(100, 10000, 10))))
    query_data = ','.join(lessons)
    cursor.execute(query + query_data)

    # Seeding registration medicines
    cursor.execute("SELECT id FROM Registrations")
    registrations = [r[0] for r in cursor.fetchall()]
    cursor.execute("SELECT id FROM Medicines")
    medicines = [m[0] for m in cursor.fetchall()]
    query = "INSERT INTO RegistrationMedicines (registrationId, medicineId, quantity) VALUES "
    registrationMedicines = set()
    for _ in range(AUX_ENTITY_COUNT):
        registrationMedicines.add((registrations[random.randrange(0, len(registrations), 1)], 
            medicines[random.randrange(0, len(medicines), 1)]))
    query_data = ','.join(create_row((r[0], r[1], random.randrange(1, 100, 1))) for r in registrationMedicines)
    cursor.execute(query + query_data)

    # Seeding intolerances
    cursor.execute("SELECT id FROM Clients")
    clients = [c[0] for c in cursor.fetchall()]
    query = "INSERT INTO Intolerances (clientId, medicineId) VALUES "
    intolerances = set()
    for _ in range(AUX_ENTITY_COUNT):
        intolerances.add(create_row((clients[random.randrange(0, len(clients), 1)], 
            medicines[random.randrange(0, len(medicines), 1)])))
    query_data = ','.join(intolerances)
    cursor.execute(query + query_data)

    # Seeding substitutes
    cursor.execute("SELECT id FROM Intolerances")
    intolerances = [i[0] for i in cursor.fetchall()]
    query = "INSERT INTO Substitutes (intoleranceId, medicineId) VALUES "
    substitutes = set()
    for _ in range(AUX_ENTITY_COUNT):
        substitutes.add(create_row((intolerances[random.randrange(0, len(intolerances), 1)], 
            medicines[random.randrange(0, len(medicines), 1)])))
    query_data = ','.join(substitutes)
    cursor.execute(query + query_data)

    # Seeding lesson masters
    cursor.execute("SELECT id FROM Lessons")
    lessons = [l[0] for l in cursor.fetchall()]
    cursor.execute("SELECT id FROM Masters")
    masters = [m[0] for m in cursor.fetchall()]
    query = "INSERT INTO LessonMaster (lessonId, registrationId, masterId, lessonDate) VALUES "
    lessonMasters = set()
    for _ in range(AUX_ENTITY_COUNT):
        lessonMasters.add((lessons[random.randrange(0, len(lessons), 1)],
            registrations[random.randrange(0, len(registrations), 1)], 
            masters[random.randrange(0, len(masters), 1)]))
    query_data = ','.join(create_row((l[0], l[1], l[2], 
            faker.date_time_this_decade(before_now=True, after_now=False, tzinfo=None))) for l in lessonMasters)
    cursor.execute(query + query_data)

    # Seeding lesson food
    cursor.execute("SELECT id FROM Food")
    food = [f[0] for f in cursor.fetchall()]
    query = "INSERT INTO LessonFood (lessonId, foodId, quantity) VALUES "
    lessonFood = set()
    for _ in range(AUX_ENTITY_COUNT):
        lessonFood.add((lessons[random.randrange(0, len(lessons), 1)],
            food[random.randrange(0, len(food), 1)]))
    query_data = ','.join(create_row((f[0], f[1], random.randrange(1, 100, 1))) for f in lessonFood)
    cursor.execute(query + query_data)

    # Seeding lesson equipment
    cursor.execute("SELECT id FROM Equipment")
    equipment = [e[0] for e in cursor.fetchall()]
    query = "INSERT INTO LessonEquipment (lessonId, equipmentId, quantity) VALUES "
    lessonEquipment = set()
    for _ in range(AUX_ENTITY_COUNT):
        lessonEquipment.add((lessons[random.randrange(0, len(lessons), 1)],
            equipment[random.randrange(0, len(equipment), 1)]))
    query_data = ','.join(create_row((e[0], e[1], random.randrange(1, 100, 1))) for e in lessonEquipment)
    cursor.execute(query + query_data)

    # Seeding registration masters
    query = "INSERT INTO RegistrationMaster (registrationId, masterId) VALUES "
    registrationMaster = set()
    for _ in range(AUX_ENTITY_COUNT):
        registrationMaster.add(create_row((registrations[random.randrange(0, len(registrations), 1)], 
            masters[random.randrange(0, len(masters), 1)])))
    query_data = ','.join(registrationMaster)
    cursor.execute(query + query_data)

    # Seeding location equipment
    query = "INSERT INTO LocationEquipment (locationId, equipmentId, quantity) VALUES "
    locationEquipment = set()
    for _ in range(AUX_ENTITY_COUNT):
        locationEquipment.add((locations[random.randrange(0, len(locations), 1)],
            equipment[random.randrange(0, len(equipment), 1)]))
    query_data = ','.join(create_row((e[0], e[1], random.randrange(1, 100, 1))) for e in locationEquipment)
    cursor.execute(query + query_data)

    # Seeding registration client
    query = "INSERT INTO RegistrationClient (registrationId, clientId) VALUES "
    registrationClient = set()
    for _ in range(AUX_ENTITY_COUNT):
        registrationClient.add(create_row((registrations[random.randrange(0, len(registrations), 1)], 
            clients[random.randrange(0, len(clients), 1)])))
    query_data = ','.join(registrationClient)
    cursor.execute(query + query_data)
