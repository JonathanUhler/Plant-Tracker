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
									
	pre-3.1.0	2/14/21			Changes in this version:
									-Added support for hashes on the iOS side
									
	pre-3.2.0	2/15/21			Changes in this version:
									-Added error handling on the server and iOS side
									-Updated documentation
									
	pre-3.3.0	2/15/21			Changes in this version:
									-Fixed issues with the server-side data structure
									-Changed the way responses are handled within the app
									
	pre-3.4.0	2/15/21			Changes in this version:
									-Changed host name in a comment (for M.U.)
									-Fixed error checking
									
	pre-3.4.1	2/16/21			Changes in this version:
									-Changed name of python file subscriber.py -> host.py
									-Documentation changes
									-Began implementation of add plant button
									
	pre-3.5.0	2/17/21			Changes in this version:
									-Plant information will now be saved
									-Added userdata folder with user .json files
									
	pre-4.0.0	2/17/21			Changes in this version:
									-Improved and refined plant info data-structure
									-Implemented RES_plantInfoOnStartup
									-Fixed existing issues with plant info not being returned properly
									-Improved error checking; error alerts will now appear
									-The user now has a limited number of plants, and the plant boxes appear properly
									-Plant names appear in the boxes
									-Updated documentation
									
	pre-4.0.1	2/18/21			Changes in this version:
									-Changed the style of the plant boxes
									-Added in the red-green-red gradient bars (not yet functional)
									
	pre-4.0.2	2/18/21			Changes in this version:
									-Minor improvements in error handling
									
	pre-4.1.0	2/18/21			Changes in this version:
									-Plant interaction has been added
									-Plants can now be deleted
									
	pre-4.1.1	2/18/21			Changes in this version:
									-Removed debug statements
									-Spelling correction
									
	pre-4.2.0	2/20/21			Changes in this version:
									-Clicking on a plant will now display sensor information
									-Began introducing the ability to edit plant name
									-Documentation changes
											

FULL-RELEASES--

	version		date							changes
	-------		--------			----------------------------------
	
