import random
import psycopg2
from faker import Faker

# Create russian faker
faker = Faker('ru_RU')

# Create DB connection
connection = psycopg2.connect("dbname=test user=test password=12345")

# Create DB cursor
cursor = connection.cursor()

# Create a test table
cursor.execute(
    """CREATE TABLE test 
        (id serial PRIMARY KEY, 
        number integer, 
        name varchar, 
        text varchar);""")

# Add data to test table
for i in range(100):
    query = "INSERT INTO test (number, name, text) VALUES (%s, %s, %s)"
    cursor.execute(query, (random.randint(0, i), faker.name(), faker.text()))

# Commit changes to DB
connection.commit()

# Get inserted data
cursor.execute("SELECT * FROM test")
for row in cursor.fetchall():
    print(row)

# Drop test table
cursor.execute("DROP TABLE test")
connection.commit()

# Close DB connection
cursor.close()
connection.close()
