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
# Returns--
#
# None
#
def publishOutgoingResponse(msgID, clientName, payload, respond):
    newMsg = "ID:" + msgID + ";client:" + clientName + ";payload:" + payload + ";respond:" + respond
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
    
    msgElements = entireMsg.split(";")
    ID = msgElements[0].split(":")
    client = msgElements[1].split(":")
    payload = msgElements[2].split(":")
    request = msgElements[3].split(":")
    
    # Create a hash of the message
    msgHash = {
        ID[0]       :   ID[1],
        client[0]   :   client[1],
        payload[0]  :   payload[1],
        request[0]  :   request[1]
    }
    
    # Make sure the message is not just a PUBACK (publish sent back) from the RPI host
    if (msgHash["client"] != serverName):
        # If the client wants the plant data
        if (msgHash["request"] == "requestPlantData"): 
            # Publish the up-to-date plant data here
            publishOutgoingResponse("0", serverName, "data requested", "RES_requestPlantData")
        
    print("New request " + request[-1] + " with payload \"" + payload[-1] + "\" from client " + client[-1] + " with ID " + ID[-1])
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
