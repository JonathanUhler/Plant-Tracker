import RPi.GPIO as gpio # Import GPIO --> This will not be used in this case


# ======================================================================
# def gpioSetup
#
# Sets up the modes and status of the pins to be used
#
# Arguments--
#
# None
#
# Returns--
#
# None
def gpioSetup():
	gpio.setmode(gpio.BCM)
	gpio.setup(21, gpio.OUT)


gpioSetup() # Setup GPIO pins
