import re, random
import psycopg2
from faker import Faker

MAIN_ENTITY_COUNT = 500
AUX_ENTITY_COUNT = 300

# Create russian faker
faker = Faker('ru_RU')

# Create DB connection
connection = psycopg2.connect("dbname=postgres user=cheburek password=belyash")
connection.autocommit = True
cursor = connection.cursor()

# Create a DB
cursor.execute(
    "CREATE DATABASE belyashcheburek ENCODING 'UTF8';"
    )

cursor.close()
connection.close()

# Connect to the created DB
connection = psycopg2.connect("dbname=belyashcheburek user=cheburek password=belyash")
cursor = connection.cursor()

# Load schema creation script 
with open('createCheburek.sql', 'r', encoding='utf8') as script:
    cursor.execute(script.read())
connection.commit()

# Seeding clients
query = "INSERT INTO Clients (lastName, firstName, patronimicName, phone, email, account) VALUES "
clients = list()
for i in range(MAIN_ENTITY_COUNT):
    name = faker.name().split(' ')
    clients.append("('%s','%s','%s','%s','%s','%s')" % (name[0], name[1], name[2], 
        faker.phone_number().replace(' ', ''), faker.free_email(), faker.bban()))
query_data = ','.join(clients)
cursor.execute(query + query_data)
connection.commit()

# Close DB connection
cursor.close()
connection.close()
