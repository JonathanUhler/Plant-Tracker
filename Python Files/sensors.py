import time # Import time
from board import SCL, SDA # Import SCL and SDA for sensor IO
import busio # Import busio for sensor IO
from adafruit_seesaw.seesaw import Seesaw # Import seesaw


# ======================================================================
# def readSensor
#
# Reads the moisture and temperature of a sensor
#
# Arguments--
#
# sensorID: the identifying number of the sensor
#
# Returns--
#
# [moisture: moist, temperature: temp]: a dictionary that contains the
#                                       temperature and moisture of a 
#                                       sensor
#
def readSensor(sensorID):
    
    i2cBus = busio.I2C(SCL, SDA) # Define the i2c bus
    try:
        ss = Seesaw(i2cBus, sensorID) # Define seesaw arguments
    except:
        return "ERR_invalidPlantSensorID"
    
    # Read moisture level through capacitive touch pad
    touch = ss.moisture_read()
    # Read and temperature
    tempC = ss.get_temp()
    tempF = (tempC * 9/5) + 32
 
    # Create a dictionary of the needed data and return it
    sensorReadings = {"moisture": int(touch), "temperature": int(tempF)}
    
    return sensorReadings
# end: def readSensor

