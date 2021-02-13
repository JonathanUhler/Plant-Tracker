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
//	pre-1.0.0	2/10/21			First working version of Plant Tracker
//
//	pre-2.0.0	2/11/21			Changes in this version:
//									-Added app icons
//									-Added printMessage function and button to request plant data from RPI
//									-Changed layout of elements in the storyboard
//
// pre-2.1.0	2/12/21			Changes in this version:
//									-Added displayClearRect and displayText functions
//									-Added a method of pinging the server to ensure a connection was made



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
	
	
	
	// Instace of CocoaMQTT as mqttClient
	//
	// host:		the IP address of the host device (in this case the RP3B+)
	// port:		the port used by the host (1883 is standard for MQTT)
	// clientID:	the name of the client requesting to connect --> UIDevice.current.name is the name
	//				of the user's phone (eg "Bob's iPhone")
	let mqttClient = CocoaMQTT(clientID: UIDevice.current.name, host: "172.20.8.47", port: 1883)

	
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
	func displayClearRect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
		
		let rect = CGRect(x: x, y: y, width: w, height: h)
		let view = UIView(frame: rect)
		view.backgroundColor = UIColor.white

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
	// None
	//
	func displayText(x: Int, y: Int, w: Int, h: Int, msg: String, color: UIColor) {
				
		let textRect: CGRect = CGRect(x: x, y: y, width: w, height: h)
		let textLabel: UILabel = UILabel(frame: textRect)
		textLabel.text = msg
		textLabel.textAlignment = .center
		textLabel.font = UIFont(name: "Gill Sans", size: 15)
		textLabel.textColor = color
		self.view.addSubview(textLabel)
		
	} // end: func displayText

	
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
			// Wait for a connection to be established
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
				// Ping the server to make sure it is working
				self.mqttClient.subscribe(self.rpi_fromrpi)
				self.mqttClient.publish(self.rpi_torpi, withString: "ping")
				
				var pingAcknowledged = false

				// If the ping was acknowledged
				self.mqttClient.didReceiveMessage = { mqtt, message, id in
					if (message.string! == "pingAcknowledged") {
						pingAcknowledged = true
					}
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
					if (pingAcknowledged) {
						// Clear any previous status message
						self.displayClearRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: 120, h: 15)
						// Tell the user they have connected
						self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: 90, h: 15, msg: "Connected", color: UIColor.green)
						// Unsubscribe from the "from" stream
						self.mqttClient.unsubscribe(self.rpi_fromrpi)
						return
					}
					else {
						// Clear any previous status message
						self.displayClearRect(x: self.screenWidth * 0.17, y: self.screenHeight * 0.13, w: 120, h: 15)
						// If the ping was not acknowledged
						self.displayText(x: Int(self.screenWidth * 0.17), y: Int(self.screenHeight * 0.13), w: 120, h: 15, msg: "Unable to connect!", color: UIColor.red)
					}
				})
			})
		}
		else { // Else if the switch is not on (it is off)
			// Disconnect from the server
			mqttClient.disconnect()
			
			// Clear any previous status message
			displayClearRect(x: screenWidth * 0.17, y: screenHeight * 0.13, w: 120, h: 15)
			displayText(x: Int(screenWidth * 0.17), y: Int(screenHeight * 0.13), w: 90, h: 15, msg: "Disconnected", color: UIColor.black)
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
		mqttClient.publish(rpi_torpi, withString: "requestPlantData")
		
		// Print any messages
		mqttClient.didReceiveMessage = { mqtt, message, id in
			self.displayText(x: Int(self.screenWidth * 0.5), y: Int(self.screenHeight * 0.5), w: 90, h: 20, msg: "got data", color: UIColor.black)
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
		
	}
	// end: func addPlant
	
	
}
// end: class ViewController

