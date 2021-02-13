#!/usr/bin/env python
# -*- coding: utf-8 -*-

import paho.mqtt.client as mqtt # Import mqtt
import paho.mqtt.publish as publish # Import mqtt
# import RPi.GPIO as gpio # Import GPIO --> This will not be used in this case


serverAddress = "172.20.8.47"
serverTo = "rpi/torpi"
serverFrom = "rpi/fromrpi"


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
# def messageDecoder
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
def messageDecoder(client, userdata, msg):
    
    # Decode the message
    entireMsg = msg.payload.decode(encoding='UTF-8')

    # Expected format: "ID: 0; client: Joffy-iPhone; payload: test"
    msgElements = entireMsg.split(";")
    ID = msgElements[0].split(":")
    client = msgElements[1].split(":")
    payload = msgElements[-1].split(":")
    
    # If the client wants the plant data
    if (payload == "requestPlantData"):
        # Publish the up-to-date plant data here
        publish.single(serverFrom, "ID: 0; client: Joffy-RPI3B+; payload: data requested", hostname = serverAddress)
        
    print(f"New message \"{payload}\" from client {client} with ID {ID}")
# end: def messageDecoder


# Set client name (of the raspberry pi)
clientName = "Joffy-RPI3B+"

# Instate Eclipse Paho as mqttClient
mqttClient = mqtt.Client(clientName)

# Set calling functions to mqttClient
mqttClient.on_connect = connectionStatus # Called when a device connects
mqttClient.on_message = messageDecoder # Called when a message is recieved

# Connect client to Server
mqttClient.connect(serverAddress)
# Monitor client activity forever
mqttClient.loop_forever()