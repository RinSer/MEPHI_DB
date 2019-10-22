import time, psycopg2, seed
from faker import Faker

start = time.time()

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

seed.create_db(cursor, connection, faker)    
connection.commit()

end = time.time()
print('DB has been successfully created and seeded')
print(end - start)

# Close DB connection
cursor.close()
connection.close()