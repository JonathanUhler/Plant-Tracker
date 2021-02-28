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
// pre-5.0.0	2/28/21			Changes in this version:
//									-Major data structure changes
//									-sensors.py added to read sensor data
//									-Sensor functionality added
//									-Sensor data will display when clicking on a plant
//
// pre-5.0.1	2/28/21			Changes in this version:
//									-Fixed a bug with sensor data being duplicated


// TO-DO--
//
// 1) Add in message ID functionality; when a request is sent, it is given a message ID and the response to that request is given the same message ID
// 2) Fix plant order. When new plants are added, the most recent plant is on the top and all others are below it in order. This does not make sense (the order should just be how they were added or maybe alphabetically)
// 3) Make sensor data display on the moisture bars for each plant
// 4) Allow plants to be edited and the new data to be saved


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
	let clientName = UIDevice.current.name
	let hostName = "Host-RPI3B+"
	var hostAddress = ""
	
	// Create the plant and sensor data-structure
	var plantJSON = [] as Array
	var sensorJSON = [] as Array<Dictionary<String, Any>>
	var pendingPlantDataRequests = 0
	let maxPlants = 7
	
	
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
		displayRect(x: screenWidth * 0.055, y: screenHeight * 0.175, w: screenWidth * 0.9, h: 1, color: UIColor.black, seesTaps: false, plantInfo: ["":""])
		
	}
	// end: func viewDidLoad
	
	
	// ==============================================================================================
	// MARK: func displayRect
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
	func displayRect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: UIColor, seesTaps: Bool, plantInfo:[String:Any]!) {
		
		let rect = CGRect(x: x, y: y, width: w, height: h)
		let view = UIView(frame: rect)
		view.backgroundColor = color
		
		if (seesTaps) {
			let tapGesture = ArgumentTapGestureRecognizer(target: self, action: #selector(handleTap(singleTap:)))
			tapGesture.x = x; tapGesture.y = y; tapGesture.w = w; tapGesture.h = h; tapGesture.plantInfo = plantInfo!
			view.addGestureRecognizer(tapGesture)
		}

		self.view.addSubview(view)
		
	} // end: func displayRect
	
	
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
	func displayText(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, msg: String, color: UIColor, fontSize: CGFloat) {
				
		let textRect: CGRect = CGRect(x: x, y: y, width: w, height: h)
		let textLabel: UILabel = UILabel(frame: textRect)
		textLabel.text = msg
		textLabel.textAlignment = .left
		textLabel.font = UIFont(name: "Gill Sans", size: fontSize)
		textLabel.textColor = color
		self.view.addSubview(textLabel)
		
	} // end: func displayText
	
	
	// ====================================================================================================
	// MARK: func convertStringToDictionary
	//
	// Converts a string in the format of a dictionary to a dictionary using JSON serialization
	//
	// Arguments--
	//
	// test:				the string to be converted
	//
	// Returns--
	//
	// [String:AnyObject]?:	an operational dictionary (the dictionary being returned, if the string could be
	//						converted correctly)
	//
	func convertStringToDictionary(text: String) -> [String:AnyObject]? {
		if let data = text.data(using: .utf8) {
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
				return json
			}
			catch {
				print("func convertStringToDictionary: unable to convert string (check string formatting)")
			}
		}
		return nil
	}
	// end: func convertStringToDictionary
	
	
	// ==============================================================================================
	// MARK: func displayMoistureBar
	//
	// A function to display the moisture bar with a gradient for each plant
	//
	// Arguments--
	// x:			The x position of the bar
	//
	// y:			The y position of the bar
	//
	// w:			The width of the bar
	//
	// h:			The height of the bar
	//
	// font:		The font size of the bar
	//
	// Returns--
	// None
	//
	func displayMoistureBar(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
		// Create the bar
		let bar = CGRect(x: x, y: y, width: w, height: h)
		let barView = UIView(frame: bar)
		barView.backgroundColor = UIColor.clear
		self.view.addSubview(barView)
		// Add the gradient
		let moistureBar = CAGradientLayer()
		moistureBar.startPoint = CGPoint(x: 0.0, y: 0.5) // The start and end point make the gradient horizontal instead of vertical
		moistureBar.endPoint = CGPoint(x: 1.0, y: 0.5)
		moistureBar.frame = barView.bounds
		moistureBar.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor]
		barView.layer.insertSublayer(moistureBar, at: 0)
	} // end: func displayMoistureBar
	
	
	// ====================================================================================================
	// MARK: func refreshPlantsDisplayed
	//
	// Refreshes any plants displayed on the screen when a plant is added, deleted, or edited
	//
	// Arguments--
	//
	// None
	//
	// Returns--
	//
	// None
	//
	func refreshPlantsDisplayed() {
		// Remove any current plants being displayed
		self.displayRect(x: self.screenWidth * 0.05, y: self.screenHeight * 0.23, w: self.screenWidth * 0.9, h: self.screenHeight * 0.7, color: UIColor.white, seesTaps: false, plantInfo: ["":""])
		// Refresh the plant data
		self.plantJSON = []
		self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "", operation: "REQ_numPlants")
	}
	// end: func refreshPlantsDisplayed
	
	
	// ====================================================================================================
	// MARK: func displayPlantsOnScreen
	//
	// Displays boxes with the information for each plant on screen
	//
	// Arguemnts--
	//
	// None
	//
	// Returns--
	//
	// None
	//
	func displayPlantsOnScreen() {
		
		var numPlants = plantJSON.count
		
		// Ignore any plants that are after the cap
		if (numPlants > maxPlants) {
			publishOutgoingRequest(msgID: "0", sender: "\(clientName)", receiver: "\(hostName)", payload: "", operation: "ERR_tooManyPlants")
			numPlants = maxPlants // Set the number of plants to be displayed to the maximum
		}
		
		// Display each plant and its information
		for i in 0...numPlants - 1 {
			// Make sure the compiler is aware that plantJSON is an array of dictionaries (if this is not here, it would be assumed that plantJSON was an array of type 'Any' during runtime)
			if let dictionary = plantJSON as? [[String:Any]] {
				// Init plant info variables
				let plantName = dictionary[i]["Name"]!

				// Display a box
				displayRect(x: screenWidth * 0.05, y: (screenHeight * 0.23) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.9, h: screenHeight * 0.09, color: UIColor.black, seesTaps: false, plantInfo: ["":""])
				displayRect(x: screenWidth * 0.06, y: (screenHeight * 0.235) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.88, h: screenHeight * 0.08, color: UIColor.white, seesTaps: true, plantInfo: dictionary[i])
				// Display the name of the plant
				displayText(x: screenWidth * 0.1, y: (screenHeight * 0.23) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.4, h: screenHeight * 0.09, msg: "\(plantName)", color: UIColor.black, fontSize: 20)
				// Display the moisture bar
				displayMoistureBar(x: screenWidth * 0.5, y: (screenHeight * 0.275) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.4, h: screenHeight * 0.005)
			}
		}
		
	}
	// end: func displayPlantsOnScreen
	
	
	// ==============================================================================================
	// MARK: func handleTap
	//
	// A function that processes the user tapping on a plant's box on the screen
	//
	// Arguments--
	//
	// singleTap:		the tap recognizer
	//
	// Returns--
	//
	// None
	//
	@objc func handleTap(singleTap: ArgumentTapGestureRecognizer) {
		// Once the tap stops, execute any code
		if (singleTap.state == UIGestureRecognizer.State.ended) {
			
			// Define the point the user tapped at
			let pointOfTap = singleTap.location(in: self.view)
			// Define the boundary of a plant box
			let plantBox = CGRect(x: singleTap.x!, y: singleTap.y!, width: singleTap.w!, height: singleTap.h!)

			// If the tap was within the plant box
			if (plantBox.contains(pointOfTap)) {
				
				// Create the message that is displayed (this is what actually contains the sensor readings)
				var sensorDetailMsg = ""
				
				// Make sure the user has updated the sensors
				if (sensorJSON.count > 0) {
					
					// Add in information about the sensors as a message
					for i in 0...sensorJSON.count - 1 { // For every sensor of a single given plant
							
						// Add a message (the sensor name/ID and its value) to the alert for each sensor
						if (singleTap.plantInfo!["Name"] as! String == sensorJSON[i]["plant"] as! String) {
							// Add sensor data to the messsage
							let msgAddition = "\n\(String(describing: sensorJSON[i]["sensor"]!)) - Moisture: \(sensorJSON[i]["moisture"] ?? "no value"), Temp: \(sensorJSON[i]["temperature"] ?? "no value")°F"
							sensorDetailMsg.append(msgAddition) // Add each sensor and its value to the total message
						}
					
					}
				}
				else {
					sensorDetailMsg.append("\nNo data. Try pressing \'Update Plant Data\' first")
				}
				
				// Add in the title and message
				let addPlantAlert = UIAlertController(title: "\(singleTap.plantInfo!["Name"]!) Details", message: sensorDetailMsg, preferredStyle: .alert)
				
				// Add in an action for the confirm button and code to run when this button is pressed
				let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
					self.plantSettings(plantInfo: singleTap.plantInfo!) // Call a seperate settings function below
				}
				// Cancel button does nothing
				let okayAction = UIAlertAction(title: "Okay", style: .cancel) { (_) in }
				
				// Add the buttons
				addPlantAlert.addAction(settingsAction)
				addPlantAlert.addAction(okayAction)
				
				// Show the alert
				self.present(addPlantAlert, animated: true, completion: nil)
				
			}
		}
	}
	// end: func handleTap
	
	
	// ====================================================================================================
	// MARK: RES_plantSensorData
	//
	func RES_plantSensorData(msg: [String:String]) {
		// Store the sensor data in a variable
		var sensorDataAsStr = msg["payload"]
		// Format the string so that the convertStringToDictionary function can convert it into a dictionary
		sensorDataAsStr = sensorDataAsStr?.replacingOccurrences(of: "-", with: ":"); sensorDataAsStr = sensorDataAsStr?.replacingOccurrences(of: "\'", with: "\"")
		// Turn the data from a string into an array
		sensorJSON.append(convertStringToDictionary(text: sensorDataAsStr!)!)
	}
	// end: func RES_plantSensorData
	
	// ====================================================================================================
	// MARK: RES_numPlants
	//
	func RES_numPlants(msg: [String:String]) {
		let numPlants = Int(msg["payload"]!)!
		pendingPlantDataRequests = numPlants
		
		if (numPlants <= 0) {
			return
		}
		
		// Get data for the plants
		for currentPlant in 0...numPlants - 1 {
			publishOutgoingRequest(msgID: "0", sender: "\(clientName)", receiver: "\(hostName)", payload: "\(currentPlant)", operation: "REQ_plantInfoOnStartup")
		}
	}
	// end: RES_numPlants
	
	// ====================================================================================================
	// MARK: RES_plantInfoOnStartup
	//
	func RES_plantInfoOnStartup(msg: [String:String]) {
		
		pendingPlantDataRequests -= 1
		
		// Get the raw data for 1 plant
		var newPlant = msg["payload"]!
		// Format the plant data
		newPlant = newPlant.replacingOccurrences(of: "||", with: ":"); newPlant = newPlant.replacingOccurrences(of: "\'", with: "\"")
		// Convert the plant strings to dictionaries
		let plantDict = convertStringToDictionary(text: newPlant)
		
		// Save the plant in a global array
		plantJSON.append(plantDict!)
		
		// Display all the plants
		if (pendingPlantDataRequests <= 0) {
			self.displayPlantsOnScreen()
		}
		
	}
	// end: RES_plantInfoOnStartup
	
	
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
		publishOutgoingRequest(msgID: "0", sender: clientName, receiver: hostName, payload: msg, operation: error)
	}
	// end: operationError
	
	
	// ====================================================================================================
	// MARK: func popupError
	//
	// Creates a popup alert when an error occurs
	//
	// Arguments--
	//
	// errorCode:		the operation error
	//
	// Returns--
	//
	// None
	//
	func popupError(errorCode: String) {
		// Create a hash of error code descriptions
		let errorCodeDescriptors = [
			"ERR_hashLength"			:	"Internal error - submit an issue",
			"ERR_missingVals"			:	"Internal error - submit an issue",
			"ERR_missingKeys"			:	"Internal error - submit an issue",
			"ERR_invalidOpTag"			:	"Internal error - submit an issue",
			"ERR_noPlantDataToRequest"	:	"You do not have any existing plant data",
			"ERR_tooManyPlants"			:	"You have reached the maximum number of plants",
			"ERR_cannotDeletePlant"		:	"Something went wrong when trying to delete a plant",
			"ERR_addPlantSensorNumIssue":	"The number of sensors you entered was invalid",
			"ERR_invalidPlantSensorID"	:	"The sensor identifier you entered was invalid. One or more plants could not be updated",
		]
		
		// Create a new alert controller and specify the title and message
		let errorAlert = UIAlertController(title: "Error", message: "Code: \(errorCode)\n\n\(errorCodeDescriptors[errorCode]!)", preferredStyle: .alert)
		
		// Add in an action for the confirm button and code to run when this button is pressed
		let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in }
		
		// Add the buttons
		errorAlert.addAction(okayAction)
		
		// Show the alert
		self.present(errorAlert, animated: true, completion: nil)
	}
	// end: popupError

	
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
		for i in msgElements {
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
			"RES_numPlants"			:	RES_numPlants,
			"RES_plantInfoOnStartup":	RES_plantInfoOnStartup,
		]
		
		// Ignore errors about error to prevent bouncing back
		let dropErr = [
			"ERR_hashLength"			:	popupError,
			"ERR_missingVals"			:	popupError,
			"ERR_missingKeys"			:	popupError,
			"ERR_invalidOpTag"			:	popupError,
			"ERR_noPlantDataToRequest"	:	popupError,
			"ERR_tooManyPlants"			:	popupError,
			"ERR_cannotDeletePlant"		: 	popupError,
			"ERR_addPlantSensorNumIssue":	popupError,
			"ERR_invalidPlantSensorID"	:	popupError,
		]
		
		// Process the message: run a function, throw an error, etc
		if (msgHash["receiver"] == clientName || msgHash["sender"] == clientName) {
			// Check if the operation tag is valid
			if (responseTagHash.keys.contains(msgHash["operation"]!)) {
				// Print the new message for debug
				print("New operation \(msgHash["operation"]!) with payload \"\(msgHash["payload"]!)\". Sender: \(msgHash["sender"]!), Receiver: \(msgHash["receiver"]!), with ID \(msgHash["ID"]!)")
				// If the tag was valid, call its associated function
				responseTagHash[msgHash["operation"]!]!(msgHash)
			}
			// Print any errors that were received
			else if (dropErr.keys.contains(msgHash["operation"]!)) {
				print("New ERROR \(msgHash["operation"]!) with payload \"\(msgHash["payload"]!)\". Sender: \(msgHash["sender"]!), Receiver: \(msgHash["receiver"]!), with ID \(msgHash["ID"]!)")
				// Call a function to display the error as a popup alert
				dropErr[msgHash["operation"]!]!(msgHash["operation"]!)
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
		mqttClient = CocoaMQTT(clientID: clientName, host: hostAddress, port: 1883) // Try to connect to the new address
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
			displayRect(x: screenWidth * 0.17, y: screenHeight * 0.13, w: screenWidth, h: 15, color: UIColor.white, seesTaps: false, plantInfo: ["":""])
			// Tell the user they have connected
			displayText(x: screenWidth * 0.17, y: screenHeight * 0.13, w: 90, h: 15, msg: "Connected", color: UIColor.green, fontSize: 15)
			
			if (hostAddress == "") {
				// Clear any previous status message
				displayRect(x: screenWidth * 0.17, y: screenHeight * 0.13, w: screenWidth, h: 15, color: UIColor.white, seesTaps: false, plantInfo: ["":""])
				// Tell the user there is no host address
				displayText(x: screenWidth * 0.17, y: screenHeight * 0.13, w: 120, h: 15, msg: "No host address", color: UIColor.red, fontSize: 15)
				// Turn off the switch
				sender.setOn(false, animated: true)
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
				// Subscribe to messages coming from the raspberry pi
				self.mqttClient.subscribe(self.rpi_fromrpi)
				// Refresh plant data
				self.refreshPlantsDisplayed()
			})
			
			// If the client disconnected
			mqttClient.didDisconnect = { mqtt, error in
				// Get the error message to display as the status if needed
				var errorMsg = "\(String(describing: error))"
				let errorMsgArray = errorMsg.components(separatedBy: "\"")
				if (errorMsgArray.count > 1) { errorMsg = errorMsgArray[1] }
				
				// Turn off the switch
				sender.setOn(false, animated: true)
	
				// Clear any previous status message
				self.displayRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, color: UIColor.white, seesTaps: false, plantInfo: ["":""])
				// Tell the user the disconnection status
				if (error == nil) {
					// If the client disconnected on their own with the button
					self.displayText(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: 90, h: 15, msg: "Disconnected", color: UIColor.black, fontSize: 15)
				}
				else {
					// If the client was forcefully disconnected
					self.displayText(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, msg: errorMsg, color: UIColor.red, fontSize: 15)
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
		
		// Request the plant data
		sensorJSON = []
		publishOutgoingRequest(msgID: "0", sender: "\(clientName)", receiver: "\(hostName)", payload: "all", operation: "REQ_plantSensorData")
		
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
		let addPlantAlert = UIAlertController(title: "New Plant", message: "Enter plant and sensor details", preferredStyle: .alert)
		
		// Add in an action for the confirm button and code to run when this button is pressed
		let confirmAction = UIAlertAction(title: "Continue", style: .default) { (_) in
			// Everything here is an entirely new alert on the second screen of adding a plant where sensor info is added
			// Get the text from the input boxes
			let plantName = addPlantAlert.textFields![0].text
			let numSensors = addPlantAlert.textFields![1].text
			
			// Create a new alert controller and specify the title and message
			let sensorAlert = UIAlertController(title: "New Plant", message: "Enter information about each sensor", preferredStyle: .alert)
			// Add in an action for the confirm button and code to run when this button is pressed
			let saveAction = UIAlertAction(title: "Add Plant", style: .default) { (_) in
				// Get the sensor info into an array
				var sensors = [] as Array
				let sensorsAmt = Int(numSensors!)
				for i in 0...sensorsAmt! - 1 {
					sensors.append(sensorAlert.textFields![i].text!)
				}
				
				// Save the new plant
				self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "\(plantName!)||\(sensors)", operation: "REQ_addNewPlant")
				// Refresh plant data
				self.refreshPlantsDisplayed()
			}
			// Cancel button does nothing
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
			
			// Add text fields
			if (Int(numSensors!) != nil && Int(numSensors!)! < 5 && Int(numSensors!)! > 0) { // Make sure the number of sensors the user entered is valid
				let sensorsAmt = Int(numSensors!)
				for i in 1...sensorsAmt! { // For every sensor the user specified, add a text field
					sensorAlert.addTextField { (textField) in
						textField.placeholder = "Sensor \(i) ID/port" // Label the sensors by their numbers
					}
				}
			}
			else {
				self.popupError(errorCode: "ERR_addPlantSensorNumIssue") // If there was some issue with the number of sensors (it was too large, small, or not a number)
			}
			
			// Add the buttons
			sensorAlert.addAction(saveAction)
			sensorAlert.addAction(cancelAction)
			// Show the alert
			self.present(sensorAlert, animated: true, completion: nil)
		}
		// Cancel button does nothing
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		// Add text fields for the first screen
		addPlantAlert.addTextField { (textField) in
			textField.placeholder = "Plant name"
		}
		addPlantAlert.addTextField { (textField) in
			textField.placeholder = "Number of sensors"
		}
		
		// Add the buttons
		addPlantAlert.addAction(confirmAction)
		addPlantAlert.addAction(cancelAction)
		
		// Show the alert
		self.present(addPlantAlert, animated: true, completion: nil)
				
	}
	// end: func addPlant
	
	
	// ====================================================================================================
	// MARK: func plantSettings
	//
	// Settings for an already added plant (change name, delete plant, etc.)
	//
	// Arguments--
	//
	// plantName:	the name of the plant
	//
	// Returns--
	//
	// None
	//
	func plantSettings(plantInfo: [String:Any]) {
		// Create a new alert controller and specify the title and message
		let plantSettingsAlert = UIAlertController(title: "\(plantInfo["Name"]!) Settings", message: "Edit plant information below", preferredStyle: .alert)
		
		// Add in an action for the confirm button and code to run when this button is pressed
		let deleteAction = UIAlertAction(title: "Delete Plant", style: .default) { (_) in
			// Delete the plant
			self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "\(plantInfo["Name"]!)", operation: "REQ_deletePlant")
			// Refresh plant data
			self.refreshPlantsDisplayed()
		}
		// Save button saves any new plants data
		let saveAction = UIAlertAction(title: "Save", style: .cancel) { (_) in
			//MARK: // Note: Tell the server new plant information was added
		}
		
		// Add in the textboxes for sensor details and name change
		plantSettingsAlert.addTextField { (textField) in
			textField.placeholder = "\(String(describing: plantInfo["Name"]!))"
		}
		
		// Add the buttons
		plantSettingsAlert.addAction(deleteAction)
		plantSettingsAlert.addAction(saveAction)
		
		// Show the alert
		self.present(plantSettingsAlert, animated: true, completion: nil)
	}
	// end: func plantSettings
	
}
// end: class ViewController


// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// MARK: class ArgumentTapGestureRecognizer
//
class ArgumentTapGestureRecognizer: UITapGestureRecognizer {
	// Allows the objc function called by a UITapGuestureRecognizer to have arguments passed to it
	var x: CGFloat?, y: CGFloat?, w: CGFloat?, h: CGFloat?, plantInfo: [String:Any]?
}
// end: class ArgumentTapGestureRecognizer
