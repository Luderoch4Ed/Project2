# dependencies
from flask import Flask, jsonify, request
from flask_pymongo import pymongo


# db connection string
client = pymongo.MongoClient(
    "mongodb+srv://Luderoch:1234@accidentcluster.zvsni.mongodb.net/US_Accidents?retryWrites=true&w=majority")

# set up app
app = Flask(__name__)   

# Database
Database = client.get_database('US_Accidents')

# get db names
dbn = client.list_database_names()  

# verify
print("My dbs:", Database, dbn)

# test a route, return some text
@app.route('/', methods=['GET'])
def home():
    return "<h1>This is just some text</p>" 

# run app test - good on local http://127.0.0.1:5000/
if __name__ == '__main__':
    app.run(debug=True)
                         
