#!/usr/bin/env python
# -*- coding: utf-8 -*-

import paho.mqtt.client as mqtt # Import mqtt
import paho.mqtt.publish as publish # Import mqtt
# import RPi.GPIO as gpio # Import GPIO --> This will not be used in this case


serverAddress = "172.20.8.47"
serverTo = "rpi/torpi"
serverFrom = "rpi/fromrpi"
serverName = "Host-RPI3B+"


# ======================================================================
# Request Tag Functions---

# ======================================================================
# def REQ_plantSensorData
#
# Request tag for REQ_plantSensorData
#
def REQ_plantSensorData():
    publishOutgoingResponse("0", serverName, "data requested", "RES_plantSensorData")
# end: def REQ_plantSensorData

# ======================================================================
# def REQ_plantInfoOnStartup
#
# Request tag for REQ_plantInfoOnStartup
#
def REQ_plantInfoOnStartup():
    publishOutgoingResponse("0", serverName, "this would contain # of plants, plant names, etc", "RES_plantInfoOnStartup")
# end: def REQ_plantInfoOnStartup



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
# Returns--
#
# None
def operationError(error, msg):
    
    publishOutgoingResponse("0", serverName, msg, error)

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
def publishOutgoingResponse(msgID, clientName, payload, operation):
    newMsg = "ID:" + msgID + ";client:" + clientName + ";payload:" + payload + ";operation:" + operation
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
            operationError("ERR_missingKeys", errMsg)
            return
        elif (len(keyValue) < 2): 
            operationError("ERR_missingVals", errMsg)
            return

        key = keyValue[0]
        value = keyValue[1]
        
        msgHash[key] = value
    
    # Make sure there is the reqired number of elements in the hash
    if (not (len(msgHash) == 4)): 
        operationError("ERR_hashLength", errMsg)
        return
    
    # Make sure the message is not just a PUBACK (publish sent back) from the RPI host
    if (not msgHash["client"] == serverName):
        
        # Hash to handle request tags
        requestTagHash = {
            "REQ_plantSensorData"   :   REQ_plantSensorData,
            "REQ_plantInfoOnStartup":   REQ_plantInfoOnStartup
        }
        
        # Figure out if the request is valid (is it in the hash above?) and call the associated function
        try:
            requestTagHash[msgHash["operation"]]()
        except KeyError:
            # If the tag is invalid, throw an error
            operationError("ERR_invalidOpTag", errMsg)
            return
        
    print("New operation " + msgHash["operation"] + " with payload \"" + msgHash["payload"] + "\" from client " + msgHash["client"] + " with ID " + msgHash["ID"])
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
