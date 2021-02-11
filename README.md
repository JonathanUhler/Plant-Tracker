# Plant-Tracker
This is a light-weight iPhone app designed to work with a Raspberry Pi 3b+. After hosting a MQTT server, the app and the Pi can be connected with other components to alert the user to water plants. The app and server follow this tutorial: https://www.raspberrypi.org/forums/viewtopic.php?t=196010 but expand on the general concepts.


# Dependencies
iOS 14.3 or higher | CocoaPods - https://guides.cocoapods.org/using/getting-started.html | CocoaMQTT


# MQTT Server Setup
See guide linked above for more in-depth instruction.

Installing MQTT--

```
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key

sudo apt-key add mosquitto-repo.gpg.key

cd /etc/apt/sources.list.d/

sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list

sudo apt-get update

sudo apt-get install mosquitto
```


Starting the MQTT Server--

```
mosquitto -v
```

When trying to run the server, the error message "Address already in use" might come up. To get around this:

```
sudo lsof -i TCP:1883

sudo kill <the PID of the process running on port 1883>

mosquitto -v
```
