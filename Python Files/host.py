#!/usr/bin/env python
# -*- coding: utf-8 -*-

import paho.mqtt.client as mqtt # Import mqtt
import paho.mqtt.publish as publish # Import mqtt
from os import path # Import the path function to check if a userdata file exists or not
import json # Used to read and write userdata
import sensors # Import the sensors.py file
# import RPi.GPIO as gpio # Import GPIO --> This will not be used in this case


serverAddress = "172.20.8.47"
serverTo = "rpi/torpi"
serverFrom = "rpi/fromrpi"
serverName = "Host-RPI3B+" # Emily for short
maxPlants = 7 # Maximum number of plants the user can have
maxPlantName = 15 # Longest plant name the user can have


# ======================================================================
# Request Tag Functions---


# ======================================================================
# def REQ_plantSensorData
#
def REQ_plantSensorData(msg):
    
    userpath = "userdata/" + msg["sender"] + ".json"
    # Check for existing file
    if (path.exists(userpath)):
        try:
            with open(userpath) as infile:
                plants = json.load(infile)
        # An error occured while reading plant information from the users's .json file
        except:
            # If the requesting client has no plant data, throw an error
            operationError("ERR_noPlantDataToRequest", "null", msg["sender"])
            return
                
        # Get the data from the sensors
        if (msg["payload"] == "all"): # the user requested all plant data
            
            # For every sensor of every plant, return the data for each plant at a time
            for plant in plants:
                # Data for any given plant
                dataForPlant = []
                
                # Parse the json sensor names as a literal array
                sensorsParsed = json.loads(plant["Sensors"])
                
                for sensor in range(len(sensorsParsed)):
                    try:
                        sensorData = sensors.readSensor(int(sensorsParsed[sensor], 16))
                    except:
                        operationError("ERR_invalidPlantSensorID", "null", msg["sender"])
                        return
                    
                    # If the sensor ID is invalid, throw an error
                    if (sensorData == "ERR_invalidPlantSensorID"):
                        operationError("ERR_invalidPlantSensorID", "null", msg["sender"])
                        return
                        
                    # If the data was valid, save it
                    sensorData["plant"] = plant["Name"]
                    sensorData["sensor"] = sensorsParsed[sensor]
                    sensorData = str(sensorData).replace(":", "-")
                    dataForPlant = sensorData
                    
                    # Otherwise, return the data
                    publishOutgoingResponse("0", serverName, msg["sender"], str(dataForPlant), "RES_plantSensorData")
# end: def REQ_plantSensorData

# ======================================================================
# def REQ_numPlants
#
def REQ_numPlants(msg):
    # Make sure the user has plant data already
    userpath = "userdata/" + msg["sender"] + ".json"
    
    # Check for existing file
    if (path.exists(userpath)):
        try:
            with open(userpath) as infile:
                plants = json.load(infile)
            # Send the client back the number of plants
            publishOutgoingResponse("0", serverName, msg["sender"], str(len(plants)), "RES_numPlants")
        except:
            # If the requesting client has no plant data, throw an error
            operationError("ERR_noPlantDataToRequest", "null", msg["sender"])
            return
# end: def REQ_numPlants

# ======================================================================
# def REQ_plantInfoOnStartup
#
def REQ_plantInfoOnStartup(msg):
    # Make sure the user has plant data already
    userpath = "userdata/" + msg["sender"] + ".json"
    
    # Check for existing file
    if (path.exists(userpath)):
        with open(userpath) as infile:
            plants = json.load(infile)
    # If the requesting client has no plant data, throw an error
    else:
        operationError("ERR_noPlantDataToRequest", "", msg["sender"])
        return
        
    # Get the specific plant to return
    plantDataToSend = plants[int(msg["payload"]) - 1]
    plantDataAsStr = json.dumps(plantDataToSend)
    plantDataAsStr = plantDataAsStr.replace(":", "||")
    # Return the data for a single plant
    publishOutgoingResponse("0", serverName, msg["sender"], plantDataAsStr, "RES_plantInfoOnStartup")
# end: def REQ_plantInfoOnStartup

# ======================================================================
# def REQ_addNewPlant
#
def REQ_addNewPlant(msg):
    # Init the path of the new or existing file
    userpath = "userdata/" + msg["sender"] + ".json"
    userdata = msg["payload"].split("||")
    
    # Make sure the path exsits
    if (path.exists(userpath)):
        # First read in any existing data
        try:
            with open(userpath) as infile:
                plants = json.load(infile)
        except:
            plants = []
    # If the path doesn't exist create new data
    else:
        plants = []
        
    # The user already has the maximum number of plants
    if (len(plants) >= maxPlants):
        operationError("ERR_tooManyPlants", "null", msg["sender"])
        return
    # The user already has a plant with this name
    for i in range(len(plants)):
        if (userdata[0] == plants[i]["Name"]):
            operationError("ERR_plantNameTaken", "null", msg["sender"])
            return
    # Make sure the plant name isn't too long
    if (len(userdata[0]) > maxPlantName):
        operationError("ERR_plantNameTooLong", "null", msg["sender"])
        return
        
    # Init the data to save
    plants.append({
        "Name"      :   userdata[0],
        "Sensors"   :   userdata[1]
    })
    
    # Save the data (this will create a new file if one does not already exist)
    with open(userpath, "w") as outfile:
        json.dump(plants, outfile)
    
    # Print out what was saved
    print("New plant added with data: " + msg["payload"] + ", for user: " + msg["sender"])
# end: def REQ_addNewPlant

# ======================================================================
# def REQ_deletePlant
#
def REQ_deletePlant(msg):
    # Make sure the user has plant data already
    userpath = "userdata/" + msg["sender"] + ".json"
    
    # Check for existing file
    if (path.exists(userpath)):
        with open(userpath) as infile:
            plants = json.load(infile)
    # If the requesting client has no plant data, throw an error
    else:
        operationError("ERR_noPlantDataToRequest", "null", msg["sender"])
        return
        
    # Search for and remove the desired plant
    for i in range(len(plants)):
        # If the plant was found, delete it
        if (plants[i]["Name"] == msg["payload"]):
            del plants[i]
            # Save the new plant data (any not deleted plants)
            with open(userpath, "w") as outfile:
                json.dump(plants, outfile)
            return
        # If the plant was not found, throw an error
        if (i >= len(plants) - 1):
            operationError("ERR_cannotDeletePlant", "null", msg["sender"])
# end: def REQ_deletePlant



# ======================================================================
# def connectionStatus
#
# Subscribes the RPI to the topic "rpi/to" which handles data from the
# iOS device to the RPI and the topic "rpi/from" which handles data from
# the RPI to the iOS
#
# Arguments--
#
# client:	the client connecting
#
# userdata:	the data from the user connecting
#
# flags:	
#
# rc:
#
# Returns--
#
# None
#
def connectionStatus(client, userdata, flags, rc):
    mqttClient.subscribe(serverTo)
    mqttClient.subscribe(serverFrom)
# end: def connectionStatus


# ======================================================================
# def operationError
#
# Creates and throws an error if something is wrong with a request
#
# Arguments--
#
# error:    the error to throw
#
# msg:  the hash that created the error
#
# receiver: the client who should receiver the error
#
# Returns--
#
# None
def operationError(error, msg, receiver):
    
    publishOutgoingResponse("0", serverName, receiver, msg, error)

# end: def operationError


# ======================================================================
# def publishOutgoingResponse
#
# Publish an outgoing message with correct formatting
#
# Arguments--
#
# msgID:        the ID of the message being sent
#
# clientName:   the name of the client sending the message
#
# payload:      the contents of the message
#
# operation:    the request or response
#
# Returns--
#
# None
#
def publishOutgoingResponse(msgID, sender, receiver, payload, operation):
    newMsg = "ID:" + msgID + ";sender:" + sender + ";receiver:" + receiver + ";payload:" + payload + ";operation:" + operation
    publish.single(serverFrom, newMsg, hostname = serverAddress)
# end: def publishMessage


# ======================================================================
# def decodeIncomingRequest
#
# Decode a message recieved from the topic
#
# Arguments--
#
# client:	the client connecting
#
# userdata:	the data of the connected user
#
# msg:		the message that came with the topic
#
# Returns--
#
# None
#
def decodeIncomingRequest(client, userdata, msg):
    
    # Decode the message
    entireMsg = msg.payload.decode(encoding='UTF-8')
    errMsg = entireMsg.replace(";", "|")
    errMsg = errMsg.replace(":", "-")
    
    msgElements = entireMsg.split(";")
    msgHash = {}
    
    for i in msgElements:
        keyValue = i.split(":")

        # Confirm there is one key and one value only
        if (len(keyValue) > 2): 
            operationError("ERR_missingKeys", errMsg, msgHash["sender"])
            return
        elif (len(keyValue) < 2): 
            operationError("ERR_missingVals", errMsg, msgHash["sender"])
            return

        key = keyValue[0]
        value = keyValue[1]
        
        msgHash[key] = value
    
    # Make sure there is the reqired number of elements in the hash
    if (not (len(msgHash) == 5)): 
        operationError("ERR_hashLength", errMsg, msgHash["sender"])
        return
    
    # Make sure the message is not just a PUBACK (publish sent back) from the RPI host
    if (not msgHash["sender"] == serverName):
        
        # Hash to handle request tags
        requestTagHash = {
            "REQ_plantSensorData"   :   REQ_plantSensorData,
            "REQ_numPlants"         :   REQ_numPlants,
            "REQ_plantInfoOnStartup":   REQ_plantInfoOnStartup,
            "REQ_addNewPlant"       :   REQ_addNewPlant,
            "REQ_deletePlant"       :   REQ_deletePlant,
        }
        
        # Ignore errors about errors to prevent bouncing back
        dropErr = {
            "ERR_hashLength"		    :	-1,
			"ERR_missingVals"		    :	-2,
			"ERR_missingKeys"		    :	-3,
			"ERR_invalidOpTag"		    :	-4,
            "ERR_noPlantDataToRequest"  :   -5,
            "ERR_tooManyPlants"         :   -6,
            "ERR_cannotDeletePlant"     :   -7,
            "ERR_invalidPlantSensorID"  :   -8,
        }
        
        # Figure out if the request is valid (is it in the hash above?) and call the associated function
        if (msgHash["operation"] in requestTagHash):
            requestTagHash[msgHash["operation"]](msgHash)
        elif (msgHash["operation"] in dropErr):
            print("New ERROR " + msgHash["operation"] + " with payload \"" + msgHash["payload"] + "\". Sender " + msgHash["sender"] + ", Receiver: " + msgHash["receiver"] + ", with ID " + msgHash["ID"])
            return
        else:
            # If the tag is invalid, throw an error
            operationError("ERR_invalidOpTag", errMsg, msgHash["sender"])
            return
        
    print("New operation " + msgHash["operation"] + " with payload \"" + msgHash["payload"] + "\". Sender " + msgHash["sender"] + ", Receiver: " + msgHash["receiver"] + ", with ID " + msgHash["ID"])
# end: def decodeIncomingRequest



# Set client name (of the raspberry pi)
clientName = serverName

# Instate Eclipse Paho as mqttClient
mqttClient = mqtt.Client(clientName)

# Set calling functions to mqttClient
mqttClient.on_connect = connectionStatus # Called when the RPI
mqttClient.on_message = decodeIncomingRequest # Called when a message is recieved

# Connect client to Server
mqttClient.connect(serverAddress)
# Monitor client activity forever
mqttClient.loop_forever()
