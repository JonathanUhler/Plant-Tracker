# Plant-Tracker
This is a light-weight iPhone app designed to work with a Raspberry Pi 3b+. After hosting a MQTT server, the app and the Pi can be connected with other components to alert the user to water plants. The app and server follow https://www.raspberrypi.org/forums/viewtopic.php?t=196010 and https://anoop4real.medium.com/how-to-send-data-from-ios-to-raspberry-pi-and-an-lcd-display-using-mqtt-764fee6e8fc5 but expand on the general concepts presented in the tutorials.


# Dependencies
iOS 14.3 or higher | CocoaPods - https://guides.cocoapods.org/using/getting-started.html | CocoaMQTT | Python 3 or higher - https://www.python.org/downloads/ | pip (used to install packages and APIs) - https://pip.pypa.io/en/stable/installing/ | Paho-MQTT - https://pypi.org/project/paho-mqtt/


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


# RPI Python Files
On the Raspberry Pi, install the "subscriber.py" file inside the "Python Files" folder. This file will read and decode messages received from the client device.

Make sure the required libraries are already installed

```
sudo apt-get install python-dev

sudo apt-get install python-rpi.gpio

sudo apt-get install python-pip

pip install paho-mqtt
```

Compile the python file as an executable, then run it

```
cd <location of host.py file>

chmod +x host.py

./host.py
```

