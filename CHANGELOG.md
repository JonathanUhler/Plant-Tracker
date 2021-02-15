# Plant-Tracker Changelog

Note: The most recent versions of the app will also be at the top of ViewController.swift as comments

Project created 1/18/2021 -- Changelog begin:

PRE-RELEASES--

	version		 date						changes
	-------		--------		----------------------------------
	pre-0.0.0	2/8/21			Create Xcode files
	
	pre-1.0.0	2/10/21			First working version of Plant Tracker
	
	pre-2.0.0	2/11/21			Changes in this version:
									-Added app icons
									-Added printMessage function and button to request plant data from RPI
									-Changed layout of elements in the storyboard
									
	pre-2.1.0	2/12/21			Changes in this version:
									-Added displayClearRect and displayText functions
									-Added a method of pinging the server to ensure a connection was made
									
	pre-2.2.0	2/12/21			Changes in this version:
									-Changed the way the client pings the server to establish a connection
									
	pre-2.3.0	2/13/21			Changes in this version:
									-Added alert system to addPlant function
									-Tweaked the way the server connection status is displayed
									
	pre-2.4.0	2/13/21			Changes in this version:
									-Added decodeIncomingMsg and publishOutgoingMsg functions
									-Changed the way messages are sent and received
									
	pre-2.5.0	2/13/21			Changes in this version:
									-UI elements will now correctly reposition and resize depending on the device being used
									
	pre-2.5.1	2/13/21			Changes in this version:
									-Documentation cleanup
									-Added line in app between server information and plant information
									
	pre-2.6.0	2/13/21			Changes in this version:
									-Added in support for changing the host IP address
									
	pre-2.6.1	2/13/21			Changes in this version:
									-Fixed UILabel text alignment
									
	pre-3.0.0	2/14/21			Changes in this version:
									-Changed the way data is handled and stored on the server-side
									-Changed the outgoing and incoming message functions on both the iOS and server-side
									-Added in DOCUMENTATION.md to provide clear documentation and conventions
									-Added the "request" or "respond" argument to all messages
									
	pre-3.0.1	2/14/21			Changes in this version:
									-Fixed the way data is handled on server-side
									-Updated documentation; added TO-DO list
											

FULL-RELEASES--

	version		date							changes
	-------		--------			----------------------------------
	
