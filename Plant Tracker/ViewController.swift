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
// Revision History (see CHANGELOG.md for full history)
//
// PRE-RELEASES
//
//	version		  date					changes
//  -------		--------		-----------------------
// pre-3.2.0	2/15/21			Changes in this version:
//									-Added error handling on the server and iOS side
//									-Updated documentation
//
// pre-3.3.0	2/15/21			Changes in this version:
//									-Fixed issues with the server-side data structure
//									-Changed the way responses are handled within the app
//									-Documentation changes
//
// pre-3.4.0	2/15/21			Changes in this version:
//									-Changed host name in a comment (for M.U.)
//									-Fixed error checking
//
// pre-3.4.1	2/16/21			Changes in this version:
//									-Changed name of python file subscriber.py -> host.py
//									-Documentation changes
//									-Began implementation of add plant button


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
	let hostName = "Host-RPI3B+"
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
		
		let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)
		
		// Constantly pay attention to incoming messages and decode them
		mqttClient.didReceiveMessage = { mqtt, message, id in
			self.decodeIncomingResponse(entireMsg: message.string!)
		}
		
		// Add in a line
		displayClearRect(x: screenWidth * 0.055, y: screenHeight * 0.175, w: screenWidth * 0.9, h: 1, color: UIColor.black)
		
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
	// MARK: RES_plantSensorData
	//
	func RES_plantSensorData(msg: [String]) {
		// Print the plant data
		self.displayText(x: Int(self.screenWidth * 0.5), y: Int(self.screenHeight * 0.5), w: 90, h: 20, msg: msg[3], color: UIColor.black)
	}
	// end: func RES_plantSensorData
	
	// ====================================================================================================
	// MARK: RES_plantInfoOnStartup
	//
	func RES_plantInfoOnStartup(msg: [String]) {
		// Prints info like num of plants, plant names, etc
		print("RES_plantInfoOnStartup")
	}
	// RES_plantInfoOnStartup
	
	
	// ====================================================================================================
	// MARK: func operationError
	//
	// Handle errors with message formatting
	//
	// Arguments--
	//
	// error:		the error to throw
	//
	// msg:		the message that caused the error
	//
	// Returns--
	//
	// None
	//
	func operationError(error: String, msg: String) {
		publishOutgoingRequest(msgID: "0", sender: UIDevice.current.name, receiver: hostName, payload: msg, operation: error)
	}
	//

	
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
	func publishOutgoingRequest(msgID: String, sender: String, receiver: String, payload: String, operation: String) {
		let newMsg = "ID:" + msgID + ";sender:" + sender + ";receiver:" + receiver + ";payload:" + payload + ";operation:" + operation
		mqttClient.publish(rpi_torpi, withString: newMsg)
	}
	// end: func publishOutgoingRequest
	
	
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
	func decodeIncomingResponse(entireMsg: String, ignoreClient: String? = nil) {
		
		// Create an error message for if one is needed
		var errMsg = entireMsg.replacingOccurrences(of: ";", with: "|")
		errMsg = errMsg.replacingOccurrences(of: ":", with: "-")
		// Init an empty hash an a list of the key/value pairs
		let msgElements = entireMsg.split(separator: ";")
		var msgHash: [String:String] = [:]
		
		// Place the keys and values into the hash from above
		for (i) in msgElements {
			// Get the keys and values
			let keyValue = i.split(separator: ":")
			
			// Check for missing keys or values
			if (keyValue.count > 2) {
				operationError(error: "ERR_missingKeys", msg: errMsg)
				return
			}
			else if (keyValue.count < 2) {
				operationError(error: "ERR_missingVals", msg: errMsg)
				return
			}
			
			let key = keyValue[0]
			let value = keyValue[1]
			// Add them to the hash
			msgHash[String(key)] = String(value)
		}
		
		// Make sure there is the required number of elements in the hash
		if (msgHash.count != 5) {
			operationError(error: "ERR_hashLength", msg: errMsg)
			return
		}
		
		// Create a dictionary of all valid operation tags
		let responseTagHash = [
			"RES_plantSensorData"	:	RES_plantSensorData,
			"RES_plantInfoOnStartup":	RES_plantInfoOnStartup
		]
		
		// Ignore errors about error to prevent bouncing back
		let dropErr = [
			"ERR_hashLength"		:	-1,
			"ERR_missingVals"		:	-2,
			"ERR_missingKeys"		:	-3,
			"ERR_invalidOpTag"		:	-4,
		]
		
		if (msgHash["receiver"] == UIDevice.current.name) {
			// Check if the operation tag is valid
			if (responseTagHash.keys.contains(msgHash["operation"]!)) {
				// Print the new message for debug
				print("New operation \(String(describing: msgHash["operation"])) with payload \"\(String(describing: msgHash["payload"]))\". Sender: \(msgHash["sender"]!), Receiver: \(msgHash["receiver"]!), with ID \(String(describing: msgHash["ID"]))")
				// If the tag was valid, call its associated function
				responseTagHash[msgHash["operation"]!]!([String(msgHash["ID"]!), String(msgHash["sender"]!), String(msgHash["receiver"]!), String(msgHash["payload"]!), String(msgHash["operation"]!)])
			}
			// Print any errors that were received
			else if (dropErr.keys.contains(msgHash["operation"]!)) {
				print("New ERROR \(String(describing: msgHash["operation"])) with payload \"\(String(describing: msgHash["payload"]))\". Sender: \(msgHash["sender"]!), Receiver: \(msgHash["receiver"]!), with ID \(String(describing: msgHash["ID"]))")
			}
			else { // If the operation tag wasn't valid, throw an error
				operationError(error: "ERR_invalidOpTag", msg: errMsg)
				return
			}
		}
		
	}
	// end: func decodeIncomingResponse

	
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
		publishOutgoingRequest(msgID: "0", sender: "\(UIDevice.current.name)", receiver: "\(hostName)", payload: "all", operation: "REQ_plantSensorData")
		
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
			self.publishOutgoingRequest(msgID: "0", sender: "\(UIDevice.current.name)", receiver: "\(self.hostName)", payload: "\(String(describing: plantName)),\(String(describing: sensorID))", operation: "REQ_addNewPlant")
			
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
