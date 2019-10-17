import re, random
import psycopg2
from faker import Faker

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

# Close DB connection
cursor.close()
connection.close()
