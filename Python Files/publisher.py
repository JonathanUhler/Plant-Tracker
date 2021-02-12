import paho.mqtt.publish as publish # Import mqtt
 
serverAddress = "172.20.8.47"
serverTopic = "rpi/gpio"
 
# Publish a new message
publish.single(serverTopic, "This is a response from Raspberry Pi", hostname = serverAddress)