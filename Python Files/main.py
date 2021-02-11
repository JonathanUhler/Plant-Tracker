#!/usr/bin/env python
# -*- coding: utf-8 -*-

import paho.mqtt.client as mqtt # Import mqtt
# import RPi.GPIO as gpio # Import GPIO --> This will not be used in this case


# ======================================================================
# def connectionStatus
#
# Subscribes the RPI to the topic "rpi/gpio"
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
	mqttClient.subscribe("rpi/gpio")
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
	message = msg.payload.decode(encoding='UTF-8')
	
	# If the message is "on"
	if message == "on":
		print("Msg = on")
		
	# If the message is off
	elif message == "off":
		print("Msg = off")
		
	# If the message is unknown
	else:
		print("Unknown message!")
# end: def messageDecoder


# Set client name
clientName = "Joffy-RPI3B+"
# Set the address of the Raspberry Pi
serverAddress = "172.20.8.47"

# Instate Eclipse Paho as mqttClient
mqttClient = mqtt.Client(clientName)

# Set calling functions to mqttClient
mqttClient.on_connect = connectionStatus # Called when a device connects
mqttClient.on_message = messageDecoder # Called when a message is recieved

# Connect client to Server
mqttClient.connect(serverAddress)
# Monitor client activity forever
mqttClient.loop_forever()