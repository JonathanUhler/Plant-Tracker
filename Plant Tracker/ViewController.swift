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


// TO-DO--
//
// 1) Add in message ID functionality; when a request is sent, it is given a message ID and the response to that request is given the same message ID


// Import libraries
import UIKit // Basic UIKit (UI elements such as switches and buttons)
import CocoaMQTT // MQTT server support


// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// MARK: struct PlantBox
//
struct PlantBox {
	
	// Basic information about a plant
	var plantName: String = ""
	var plantSensors: [[String:Any]] = [["":""]] // Sensor information (moisture level, temperature, sensor ID, plant name the sensor belongs to)
	
	// Dimensions and location of the plant's box
	var boxX: CGFloat = 0
	var boxY: CGFloat = 0
	var boxW: CGFloat = 0
	var boxH: CGFloat = 0
	
	// The plant box as a UIView
	var newPlantBox: UIView = UIView()
	var boxView: UIView = UIView()
	
	// Information about the device size
	let screenRect = UIScreen.main.bounds
	lazy var screenWidth = screenRect.size.width
	lazy var screenHeight = screenRect.size.height
	
	let lightModeColor = UIColor.white
	let darkModeColor = UIColor.black
	var darkModeEnabled = ViewController.darkModeEnabled
	
	
	// ====================================================================================================
	// MARK: func addPlantBox
	//
	// Creates a new plant box
	//
	// Arguments--
	//
	// None
	//
	// Returns--
	//
	// None
	//
	mutating func addPlantBox() {

		// Display a box
		addRect(x: boxX, y: boxY, w: boxW, h: boxH, color: (darkModeEnabled) ? darkModeColor : lightModeColor)
		// Display the name of the plant
		addText(x: boxX + screenWidth * 0.03, y: boxY, w: boxW * 0.45, h: boxH, msg: "\(plantName)", color: (darkModeEnabled) ? lightModeColor : darkModeColor, fontSize: 20)
		
	}
	// end: func addPlantBox


	// ==============================================================================================
	// MARK: private func addRect
	//
	// A function to add a rectangular box to the plant box UIView
	//
	// Arguments--
	//
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
	//
	// None
	//
	private mutating func addRect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: UIColor) {
		
		newPlantBox = UIView(frame: CGRect(x: x, y: y, width: w, height: h)) // Define the limits of the box
		newPlantBox.layer.borderWidth = 3 // Set the border thickness
		newPlantBox.layer.borderColor = (darkModeEnabled) ? lightModeColor.cgColor : darkModeColor.cgColor // Set the border color
		newPlantBox.backgroundColor = color // Set the background color of the box (everything within the border)
		
		boxView.addSubview(newPlantBox) // Save the new box UIView

	} // end: func addRect


	// ==============================================================================================
	// MARK: private func addText
	//
	// A function to add text to the plant box UIView
	//
	// Arguments--
	//
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
	private func addText(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, msg: String, color: UIColor, fontSize: CGFloat) {

		let textRect: CGRect = CGRect(x: x, y: y, width: w, height: h)
		let textLabel: UILabel = UILabel(frame: textRect)
		textLabel.text = msg
		textLabel.textAlignment = .left
		textLabel.font = UIFont(name: "Gill Sans", size: fontSize)
		textLabel.textColor = color
		
		boxView.addSubview(textLabel)

	} // end: func displayText
	
}
// end: struct PlantBox




// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// MARK: class ViewController
//
class ViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Init Class Variables
	// App version
	let PlantTrackerVersion = "pre-5.6.0"
	
	// Get the screen dimensions
	let screenRect = UIScreen.main.bounds
	lazy var screenWidth = screenRect.size.width
	lazy var screenHeight = screenRect.size.height
	
	// Declare the topics used to send and receive data
	let rpi_torpi = "rpi/torpi"
	let rpi_fromrpi = "rpi/fromrpi"
	
	// Server information
	let clientName = UIDevice.current.identifierForVendor!.uuidString
	let hostName = "Host-RPI3B+"
	var hostAddress = ""
	
	// Create various datastructure
	var plantJSON = [] as Array // Plant datastructure
	var sensorJSON = [] as Array<Dictionary<String, Any>> // Sensor datastructure
	var tapGestureList = [] as Array<ArgumentTapGestureRecognizer> // Tap gesture location datastructure
	
	var pendingPlantDataRequests = 0 // Makes sure the plant boxes are only displayed once all the plant data has arrived form the server
	let maxPlants = 7 // Maximum number of plants the user can have
	let maxPlantName = 15 // Maximum character length a plant can be named
	
	let lightModeColor = UIColor.white
	let darkModeColor = UIColor.black
	static var darkModeEnabled = (UITraitCollection.current.userInterfaceStyle == .dark) ? true : false
	
	// Storyboard elements
	@IBOutlet weak var hostIPTextBox: UITextField!
	
	
	// Instace of CocoaMQTT as mqttClient
	//
	// host:		the IP address of the host device (in this case the RP3B+)
	// port:		the port used by the host (1883 is standard for MQTT)
	// clientID:	the name of the client requesting to connect
	var mqttClient: CocoaMQTT = CocoaMQTT(clientID: UIDevice.current.identifierForVendor!.uuidString, host: "", port: 1883)
	
	
	
	// ====================================================================================================
	// MARK: func traitCollectionDidChange
	//
	// Updates dark mode settings
	//
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		ViewController.darkModeEnabled = !ViewController.darkModeEnabled
	}
	// end: func traitCollectionDidChange
	
	
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
		hostIPTextBox.text = hostAddress
		self.hostIPTextBox.delegate = self
		mqttClient = CocoaMQTT(clientID: UIDevice.current.identifierForVendor!.uuidString, host: hostAddress, port: 1883)
		
		// Constantly pay attention to incoming messages and decode them
		mqttClient.didReceiveMessage = { mqtt, message, id in
			self.decodeIncomingResponse(entireMsg: message.string!)
		}
		
		// Display the app version
		displayText(x: screenWidth * 0.35, y: screenHeight * 0.18, w: screenWidth, h: 15, msg: "Version: \(PlantTrackerVersion)", color: (ViewController.darkModeEnabled) ? lightModeColor : darkModeColor, fontSize: 15)
		
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
	func displayRect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: UIColor) {
		let rect = CGRect(x: x, y: y, width: w, height: h)
		let view = UIView(frame: rect)
		view.backgroundColor = color
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
	// MARK: func convertStringToDictionary and func convertStringToArray
	//
	// Converts a string in the format of a dictionary to a dictionary using JSON serialization
	//
	// Arguments--
	//
	// test:				the string to be converted
	//
	// Returns--
	//
	// json:				an optional dictionary/array
	//
	func convertStringToDictionary(text: String) -> [String:AnyObject]? {
		if let data = text.data(using: .utf8) {
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
				return json
			}
			catch {
				print("ERR func convertStringToDictionary: unable to convert string (check string formatting)")
			}
		}
		return nil
	}
	
	
	func convertStringToArray(text: String) -> [String]? {
		if let data = text.data(using: .utf8) {
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String]
				return json
			}
			catch {
				print("ERR func convertStringToArray: unable to convert string (check string formatting)")
			}
		}
		return nil
	}
	// end: func convertStringToDictionary and func convertStringToArray
	
	
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
		self.displayRect(x: self.screenWidth * 0.05, y: self.screenHeight * 0.205, w: self.screenWidth * 0.9, h: self.screenHeight * 0.7, color: (ViewController.darkModeEnabled) ? darkModeColor : lightModeColor)
		// Refresh the plant data
		self.plantJSON = []
		tapGestureList = []
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
		
		// Get the current number of plants
		let numPlants = plantJSON.count
		
		for i in 0...numPlants - 1 {
			// For each plant, create a new instance of the PlantBox class and assign each of an user's plants a plant "box"
			if let dictionary = plantJSON as? [[String:Any]] {
				var plantBox = PlantBox() // Create a new instance of the PlantBox class
				plantBox.plantName = dictionary[i]["Name"] as! String // Set the plant's name
				plantBox.plantSensors = sensorJSON // Set the plant's sensor info
				plantBox.boxX = screenWidth * 0.05 // Set the box's x position
				plantBox.boxY = (screenHeight * 0.21) + (CGFloat(i) * (screenHeight * 0.1)) // Set the box's y position
				plantBox.boxW = screenWidth * 0.9 // Set the box's width
				plantBox.boxH = screenHeight * 0.09 // Set the box's height
				
				let tapGesture = ArgumentTapGestureRecognizer(target: self, action: #selector(handleTap(singleTap:))) // Create a new tap recognizer
				tapGesture.x = plantBox.boxX // Set the x position of the tap box
				tapGesture.y = plantBox.boxY // Set the y position of the tap box
				tapGesture.w = plantBox.boxW // Set the width of the tap box
				tapGesture.h = plantBox.boxH // Set the height of the tap box
				tapGesture.plantInfo = (plantJSON[i] as? [String:Any])! // Set the data for the tap box to inherit
				
				plantBox.addPlantBox() // Run the main function of the PlantBox class to add the new plant box
				view.addGestureRecognizer(tapGesture) // Add the tap gesture recognizer
				self.view.addSubview(plantBox.boxView) // Add the new plant box to the view
				tapGestureList.append(tapGesture) // Add the tap gesture for each plant to the list
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

			// Define the point the user tapped the screen
			let pointOfTap = singleTap.location(in: self.view)

			// Search though each valid tap region to figure out which one the user tapped in
			for i in tapGestureList {
				// Define the boundary of a plant's box
				let plantBox = CGRect(x: i.x!, y: i.y!, width: i.w!, height: i.h!)
				
				// If the tap was within the plant box
				if (plantBox.contains(pointOfTap)) {

					// Create the message that is displayed (this is what actually contains the sensor readings)
					var sensorDetailMsg = ""

					// Fill in the description for the popup alert which includes the sensor values and information
					// Everything in this conditional if-else is about generating the message based on the sensor values
					// Make sure the user has updated the sensors
					if (sensorJSON.count > 0) {

						// Add in information about the sensors as a message
						for j in 0...sensorJSON.count - 1 { // For every sensor of a single given plant

							// Add a message (the sensor name/ID and its value) to the alert for each sensor
							if (i.plantInfo!["Name"] as! String == sensorJSON[j]["plant"] as! String) {
								// Add sensor data to the messsage
								let msgAddition = "\n\(String(describing: sensorJSON[j]["sensor"]!)) - Moisture: \(sensorJSON[j]["moisture"] ?? "no value"), Temp: \(sensorJSON[j]["temperature"] ?? "no value")°F"
								sensorDetailMsg.append(msgAddition) // Add each sensor and its value to the total message
							}

						}
					}
					else {
						sensorDetailMsg.append("\nNo data. Try pressing \'Update Plant Data\' first")
					}
					
					// Add everything into a popup alert and display it
					// Add in the title and message
					let addPlantAlert = UIAlertController(title: "\(i.plantInfo!["Name"]!) Details", message: sensorDetailMsg, preferredStyle: .alert)

					// Add in an action for the confirm button and code to run when this button is pressed
					let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
						self.plantSettings(plantInfo: i.plantInfo!) // Call a seperate settings function below
					}
					// Cancel button does nothing
					let okayAction = UIAlertAction(title: "Okay", style: .cancel) { (_) in }

					// Add the buttons
					addPlantAlert.addAction(settingsAction)
					addPlantAlert.addAction(okayAction)

					// Show the alert
					self.present(addPlantAlert, animated: true, completion: nil)

					break;
				}
			}
		}
	}
	// end: func handleTap
	
	
	// ====================================================================================================
	// MARK: RES_plantSensorData
	//
	func RES_plantSensorData(msg: [String:String]) {
		// Display the points on the moisutre bars that show where the plant's overall moisture is
		var numPlants = plantJSON.count
		
		// Store the sensor data in a variable
		var sensorDataAsStr = msg["payload"]
		// Format the string so that the convertStringToDictionary function can convert it into a dictionary
		sensorDataAsStr = sensorDataAsStr?.replacingOccurrences(of: "--", with: ":"); sensorDataAsStr = sensorDataAsStr?.replacingOccurrences(of: "\'", with: "\"")
		let sensorDataAsDict = convertStringToDictionary(text: sensorDataAsStr!)
		
		// If the user rapidly clicks the update button, only keep 1 reading for each plant and discard duplicate plant readings
		if (sensorJSON.count > 0) {
			for h in 0...sensorJSON.count - 1 {
				if (sensorDataAsDict!["plant"] as! String == sensorJSON[h]["plant"] as! String) {
					return
				}
			}
		}
		
		// Turn the data from a string into an array
		sensorJSON.append(sensorDataAsDict!)
		
		// Exit the method if the user has 0 plants to avoid a crash
		if (numPlants <= 0) { return }
		
		// Ignore any plants that are after the cap
		if (numPlants > maxPlants) {
			publishOutgoingRequest(msgID: "0", sender: "\(clientName)", receiver: "\(hostName)", payload: "", operation: "ERR_tooManyPlants")
			numPlants = maxPlants // Set the number of plants to be displayed to the maximum
		}
		
		// Display each plant and its information
		for i in 0...numPlants - 1 {
			// Get the name of expected plant
			let plantInfo = plantJSON as? [[String:Any]]
			
			// Get the sensor data for the right plant
			var sensorToDisplay: Int = 0
			let sensorArray = convertStringToArray(text: plantInfo![i]["Sensors"] as! String); let numSensors = sensorArray!.count // Get the number of sensors for the current plant
			
			// Go through each sensor to find out if it should be displayed or not
			for j in 0...sensorJSON.count - 1 {
				// If the name of the plant the user is looking at matches the name of a sensor, store that sensor value to display
				if (plantInfo![i]["Name"] as! String == sensorJSON[j]["plant"] as! String) {
					sensorToDisplay += sensorJSON[j]["moisture"] as! Int
				}
			}
			
			// Get the average value across all sensors for a given plant
			sensorToDisplay = sensorToDisplay / numSensors
			
			let numWidth = floor(log10(Double(sensorToDisplay))) + 1 // Figure out how wide the displayed number will be in order to shift it slightly
			// Prevent data values from stacking
			displayRect(x: screenWidth * 0.5, y: (screenHeight * 0.22) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.4, h: screenHeight * 0.06, color: (ViewController.darkModeEnabled) ? darkModeColor : lightModeColor)
			// Display the sensor data
			displayText(x: screenWidth * CGFloat((0.69 - (numWidth / 110))), y: (screenHeight * 0.205) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.4, h: screenHeight * 0.05, msg: "\(sensorToDisplay)", color: (ViewController.darkModeEnabled) ? lightModeColor : darkModeColor, fontSize: 15)
			
			// Display the moisture bar
			displayMoistureBar(x: screenWidth * 0.5, y: (screenHeight * 0.26) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.4, h: screenHeight * 0.005)
			// Display the dot on the moisture bar
			displayRect(x: (screenWidth * 0.5) + (CGFloat(sensorToDisplay) * (screenWidth * 0.039)), y: (screenHeight * 0.254) + (CGFloat(i) * (screenHeight * 0.1)), w: screenWidth * 0.01, h: screenWidth * 0.03, color: (ViewController.darkModeEnabled) ? lightModeColor : darkModeColor)
		}
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
		newPlant = newPlant.replacingOccurrences(of: "--", with: ":"); newPlant = newPlant.replacingOccurrences(of: "\'", with: "\"")
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
			"ERR_tooManyPlants"			:	"You have reached the maximum of \(maxPlants) plants",
			"ERR_cannotDeletePlant"		:	"Something went wrong when trying to delete a plant",
			"ERR_addPlantSensorNumIssue":	"The number of sensors you entered was invalid",
			"ERR_invalidPlantSensorID"	:	"The sensor identifier you entered was invalid. One or more plants could not be updated",
			"ERR_plantNameTaken"		:	"The name you are trying to enter is already taken by another plant",
			"ERR_plantNameTooLong"		:	"The name of the plant you are trying to add exceeds the maximum of \(maxPlantName) characters",
			"ERR_kickedForSpam"			:	"You have been forcefully disconnected from the server for spam. Please do not send so many messages!"
		]
		
		if (errorCode == "ERR_kickedForSpam") {
			mqttClient.disconnect();
		}
		
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
		var errMsg = entireMsg.replacingOccurrences(of: ";", with: "||")
		errMsg = errMsg.replacingOccurrences(of: ":", with: "--")
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
			"ERR_plantNameTaken"		:	popupError,
			"ERR_plantNameTooLong"		:	popupError,
			"ERR_kickedForSpam"			:	popupError,
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
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let newIP = "\(String(describing: hostIPTextBox.text))"
		hostAddress = newIP.components(separatedBy: "\"")[1] // Get the new IP
		UserDefaults.standard.setValue(hostAddress, forKey: "hostAddress")
		mqttClient = CocoaMQTT(clientID: clientName, host: hostAddress, port: 1883) // Try to connect to the new address
		
		self.view.endEditing(true)
		return false
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
			displayRect(x: screenWidth * 0.17, y: screenHeight * 0.13, w: screenWidth, h: 15, color: (ViewController.darkModeEnabled) ? darkModeColor : lightModeColor)
			// Tell the user they have connected
			displayText(x: screenWidth * 0.17, y: screenHeight * 0.13, w: 90, h: 15, msg: "Connected", color: UIColor.green, fontSize: 15)
			
			if (hostAddress == "") {
				// Clear any previous status message
				displayRect(x: screenWidth * 0.17, y: screenHeight * 0.13, w: screenWidth, h: 15, color: (ViewController.darkModeEnabled) ? darkModeColor : lightModeColor)
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
				self.displayRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: self.screenWidth, h: 15, color: (ViewController.darkModeEnabled) ? self.darkModeColor : self.lightModeColor)
				// Tell the user the disconnection status
				if (error == nil) {
					// If the client disconnected on their own with the button
					self.displayText(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: 90, h: 15, msg: "Disconnected", color: (ViewController.darkModeEnabled) ? self.lightModeColor : self.darkModeColor, fontSize: 15)
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
				self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "\(plantName!)--\(sensors)", operation: "REQ_addNewPlant")
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
		let deleteAction = UIAlertAction(title: "Delete Plant", style: .destructive) { (_) in
			// Delete the plant
			self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "\(plantInfo["Name"]!)", operation: "REQ_deletePlant")
			
			// Refresh plant data
			self.refreshPlantsDisplayed()
		}
		
		// Save button saves any new plants data
		let saveAction = UIAlertAction(title: "Save Changes", style: .default) { [self] (_) in
			// Change the plant's info
			self.publishOutgoingRequest(msgID: "0", sender: "\(self.clientName)", receiver: "\(self.hostName)", payload: "\(plantInfo["Name"]!),\(plantSettingsAlert.textFields![0].text!)", operation: "REQ_editPlant")
			
			// Refresh plant data
			self.refreshPlantsDisplayed()
		}
		
		// Cancel button does nothing
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		// Add in the textboxes for sensor details and name change
		plantSettingsAlert.addTextField { (textField) in
			textField.placeholder = "Plant name"
			textField.text = "\(String(describing: plantInfo["Name"]!))"
		}
		
		// Add the buttons
		plantSettingsAlert.addAction(deleteAction)
		plantSettingsAlert.addAction(saveAction)
		plantSettingsAlert.addAction(cancelAction)
		
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
