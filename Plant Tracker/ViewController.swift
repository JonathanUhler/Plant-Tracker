// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
//  ViewController.swift
//  Plant Tracker
//
//  Created by Jonathan Uhler on 2/8/21.
// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+


// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// MIT License
//
// Copyright (c) 2021 JonathanUhler
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+


// ====================================================================================================
// Revision History
//
// PRE-RELEASES
//
//	version		  date					changes
//  -------		--------		-----------------------
//	pre-1.0.0	2/10/21			First buildable version of Plant Tracker
//
//	pre-2.0.0	2/11/21			Changes in this version:
//									-Added app icons
//									-Added printMessage function and button to request plant data from RPI
//									-Changed layout of elements in the storyboard
//
// pre-2.1.0	2/12/21			Changes in this version:
//									-Added displayClearRect and displayText functions
//									-Added a method of pinging the server to ensure a connection was made
//
// pre-2.2.0	2/12/21			Changes in this version:
//									-Changed the way the client pings the server to establish a connection
//
// pre-2.3.0	2/13/21			Changes in this version:
//									-Added alert system to addPlant function
//									-Tweaked the way the server connection status is displayed
//
// pre-2.4.0	2/13/21			Changes in this version:
//									-Added decodeIncomingResponse and publishOutgoingRequest functions
//									-Changed the way messages are sent and received
//
// pre-2.5.0	2/13/21			Changes in this version:
//									-UI elements will now correctly reposition and resize depending on the device being used
//
// pre-2.5.1	2/13/21			Changes in this version:
//									-Documentation cleanup
//									-Added line in app between server information and plant information
//
// pre-2.6.0	2/13/21			Changes in this version:
//									-Added in support for changing the host IP address
//
// pre-2.6.1	2/13/21			Changes in this version:
//									-Fixed UILabel text alignment
//
// pre-3.0.0	2/14/21			Changes in this version:
//									-Changed the way data is handled and stored on the server-side
//									-Changed the outgoing and incoming message functions on both the iOS and server-side
//									-Added in DOCUMENTATION.md to provide clear documentation and conventions
//									-Added the "request" or "respond" argument to all messages
// pre-3.0.1	2/14/21			Changes in this version:
//									-Fixed the way data is handled on server-side
//									-Updated documentation; added TO-DO list
//
// pre-3.1.0	2/14/21			Changes in this version:
//									-Added support for hashes on the iOS side
//
// pre-3.2.0	2/15/21			Changes in this version:
//									-Added error handling on the server and iOS side
//									-Updated documentation


// TO-DO--
//
// 1) Add in message ID functionality; when a request is sent, it is given a message ID and the response to that request is given the same message ID


// Import libraries
import UIKit // Basic UIKit (UI elements such as switches and buttons)
import CocoaMQTT // MQTT server support


// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// MARK: class ViewController
//
class ViewController: UIViewController {
	
	// MARK: Init Class Variables
	// Get the screen dimensions
	let screenRect = UIScreen.main.bounds
	lazy var screenWidth = screenRect.size.width
	lazy var screenHeight = screenRect.size.height
	// Declare the topics used to send and receive data
	let rpi_torpi = "rpi/torpi"
	let rpi_fromrpi = "rpi/fromrpi"
	// Host IP address
	var hostAddress = ""
	
	// Instace of CocoaMQTT as mqttClient
	//
	// host:		the IP address of the host device (in this case the RP3B+)
	// port:		the port used by the host (1883 is standard for MQTT)
	// clientID:	the name of the client requesting to connect --> UIDevice.current.name is the name
	//				of the user's phone (eg "Bob's iPhone")
	var mqttClient: CocoaMQTT = CocoaMQTT(clientID: UIDevice.current.name, host: "", port: 1883)
	
	
	
	// ====================================================================================================
	// MARK: func viewDidLoad
	//
	// The function that is called after the view loads
	//
	// Arguments--
	//
	// None
	//
	// Returns--
	//
	// None
	//
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		// Init the host address
		hostAddress = UserDefaults.standard.string(forKey: "hostAddress") ?? ""
		mqttClient = CocoaMQTT(clientID: UIDevice.current.name, host: hostAddress, port: 1883)
		
		// Add in a line
		displayClearRect(x: screenWidth * 0.055, y: screenHeight * 0.175, w: screenWidth * 0.9, h: 1, color: UIColor.black)
		
		// Deal with the getHostIP function --> when the user taps, close the keyboard
		let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)
		
	}
	// end: func viewDidLoad
	
	
	// ==============================================================================================
	// MARK: func displayClearRect
	//
	// A function to display a rectangle that clears the date and information text to display new
	// text on top of it
	//
	// Arguments--
	// x:			The x position of the rectangle
	//
	// y:			The y position of the rectangle
	//
	// w:			The width of the rectangle
	//
	// h:			The height of the rectangle
	//
	// font:		The font size of the retangle
	//
	// Returns--
	// None
	//
	func displayClearRect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: UIColor) {
		
		let rect = CGRect(x: x, y: y, width: w, height: h)
		let view = UIView(frame: rect)
		view.backgroundColor = color

		self.view.addSubview(view)
		
	} // end: func displayClearRect
	
	
	// ==============================================================================================
	// MARK: func displayText
	//
	// A function to display text on the phone screen
	//
	// Arguments--
	// x:		The x position of the text
	//
	// y:		The y position of the text
	//
	// w:		The width of the text box
	//
	// h:		The height of the text box
	//
	// color:	The color of the text
	//
	// Returns--
	//
	// None
	//
	func displayText(x: Int, y: Int, w: Int, h: Int, msg: String, color: UIColor) {
				
		let textRect: CGRect = CGRect(x: x, y: y, width: w, height: h)
		let textLabel: UILabel = UILabel(frame: textRect)
		textLabel.text = msg
		textLabel.textAlignment = .left
		textLabel.font = UIFont(name: "Gill Sans", size: 15)
		textLabel.textColor = color
		self.view.addSubview(textLabel)
		
	} // end: func displayText
	
	
	// ====================================================================================================
	// MARK: func decodeIncomingResponse
	//
	// Decodes messages sent from the raspberry pi or other clients and returns only the message (optional -
	// certain clients can also be ignored)
	//
	// Arguments--
	//
	// entireMsg:					the entire incoming message (with message ID, payload, client, etc)
	//
	// OPTIONAL - "ignoreClient":	an optional name of a client to ignore
	//
	// Returns--
	//
	// msg:							the payload of any not-ignored messages
	//
	func decodeIncomingResponse(entireMsg: String, ignoreClient: String? = nil) -> [String] {
		
		// Init an empty hash an a list of the key/value pairs
		let msgElements = entireMsg.split(separator: ";")
		var msgHash: [String:String] = [:]
		
		// Place the keys and values into the hash from above
		for (i) in msgElements {
			// Get the keys and values
			let keyValue = i.split(separator: ":")
			let key = keyValue[0]
			let value = keyValue[1]
			// Add them to the hash
			msgHash[String(key)] = String(value)
		}
		
		// Return the response information
		return [String(msgHash["ID"]!), String(msgHash["client"]!), String(msgHash["payload"]!), String(msgHash["operation"]!)]
		
	}
	// end: func decodeIncomingResponse
	
	
	// ====================================================================================================
	// MARK: func publishOutgoingRequest
	//
	// Publish an outgoing message formatted in an acceptable way
	//
	// Arguments--
	//
	// msgID:		the ID of the message being sent
	//
	// clientName:	the name of the client publishing the message
	//
	// payload:		the contents of the message
	//
	// operation:	the request or response
	//
	// Returns--
	//
	// None
	//
	func publishOutgoingRequest(msgID: String, clientName: String, payload: String, operation: String) {
		let newMsg = "ID:" + msgID + ";client:" + clientName + ";payload:" + payload + ";operation:" + operation
		mqttClient.publish(rpi_torpi, withString: newMsg)
	}
	// end: func publishOutgoingRequest

	
	// ====================================================================================================
	// MARK: func getHostIP
	//
	// Allows the user to enter the IP of the host RPI in a textbox
	//
	// Arguments--
	//
	// sender:		the instance of the UITextField
	//
	// Returns--
	//
	// None
	//
	@IBAction func getHostIP(_ sender: UITextField) {
		let newIP = "\(String(describing: sender.text))"
		hostAddress = newIP.components(separatedBy: "\"")[1] // Get the new IP
		UserDefaults.standard.setValue(hostAddress, forKey: "hostAddress")
		mqttClient = CocoaMQTT(clientID: UIDevice.current.name, host: hostAddress, port: 1883) // Try to connect to the new address
	}
	// end: func getHostIP
	
	
	// ====================================================================================================
	// MARK: func connectionSwitch
	//
	// Handles the user changing the state of the GPIO pin 40 switch
	//
	// Arguments--
	//
	// sender:		the instance of the UISwitch
	//
	// Returns--
	//
	// None
	//
	@IBAction func connectionSwitch(_ sender: UISwitch) {
		
		// If the switch is already on
		if sender.isOn {
			// Connect to the server
			mqttClient.connect()
			
			// Clear any previous status message
			self.displayClearRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, color: UIColor.white)
			// Tell the user they have connected
			self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: 90, h: 15, msg: "Connected", color: UIColor.green)
			
			if (hostAddress == "") {
				// Clear any previous status message
				self.displayClearRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, color: UIColor.white)
				// Tell the user there is no host address
				self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: 120, h: 15, msg: "No host address", color: UIColor.red)
				// Turn off the switch
				sender.setOn(false, animated: true)
			}
			
			// If the client disconnected
			mqttClient.didDisconnect = { mqtt, error in
				// Get the error message to display as the status if needed
				var errorMsg = "\(String(describing: error))"
				let errorMsgArray = errorMsg.components(separatedBy: "\"")
				if (errorMsgArray.count > 1) { errorMsg = errorMsgArray[1] }
				
				// Turn off the switch
				sender.setOn(false, animated: true)
	
				// Clear any previous status message
				self.displayClearRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, color: UIColor.white)
				// Tell the user the disconnection status
				if (error == nil) {
					// If the client disconnected on their own with the button
					self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: 90, h: 15, msg: "Disconnected", color: UIColor.black)
				}
				else {
					// If the client was forcefully disconnected
					self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: Int(self.screenWidth), h: 15, msg: errorMsg, color: UIColor.red)
				}
			}
			
		}
		else { // Else if the switch is not on (it is off)
			// Disconnect from the server
			mqttClient.disconnect()
		}
		
	}
	// end: func connectionSwitch
	
	
	// ====================================================================================================
	// MARK: func requestData
	//
	// Handles message sent by the RPI to the iOS device
	//
	// Arguments--
	//
	// sender:		the instance of the UIButton
	//
	// Returns--
	//
	// None
	//
	@IBAction func requestData(_ sender: UIButton) {
		
		// Subscribe to messages coming from the raspberry pi
		mqttClient.subscribe(rpi_fromrpi)
		// Request the plant data
		publishOutgoingRequest(msgID: "0", clientName: "\(UIDevice.current.name)", payload: "all", operation: "REQ_plantSensorData")
		
		// Print the plant data
		mqttClient.didReceiveMessage = { mqtt, message, id in
			let msg = self.decodeIncomingResponse(entireMsg: message.string!)
			
			if (msg[2] == "data requested" && msg[1] == "Host-RPI3B+") {
				self.displayText(x: Int(self.screenWidth * 0.5), y: Int(self.screenHeight * 0.5), w: 90, h: 20, msg: "got data", color: UIColor.black)
			}
		}
		
	}
	// end: func requestData
	
	
	// ====================================================================================================
	// MARK: func addPlant
	//
	// Handles adding a new plant and plant sensors
	//
	// Arguments--
	//
	// sender:		the instance of the UIButton
	//
	// Returns--
	//
	// None
	//
	@IBAction func addPlant(_ sender: UIButton) {
		
		// Create a new alert controller and specify the title and message
		let alertController = UIAlertController(title: "New Plant", message: "Enter plant and sensor details", preferredStyle: .alert)
		
		// Add in an action for the confirm button and code to run when this button is pressed
		let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
			
			// Get the text from the input boxes
			let plantName = alertController.textFields?[0].text
			let sensorID = alertController.textFields?[1].text
			
			print("New plant added with name \(String(describing: plantName)) and sensor ID \(String(describing: sensorID))")
			
		}
		
		// Cancel button does nothing
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		// Add text fields
		alertController.addTextField { (textField) in
			textField.placeholder = "Plant name"
		}
		alertController.addTextField { (textField) in
			textField.placeholder = "Sensor ID/port"
		}
		
		// Add the buttons
		alertController.addAction(confirmAction)
		alertController.addAction(cancelAction)
		
		// Show the alert
		self.present(alertController, animated: true, completion: nil)
				
	}
	// end: func addPlant
	
}
// end: class ViewController
