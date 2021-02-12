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



// Import libraries
import UIKit // Basic UIKit (UI elements such as switches and buttons)
import CocoaMQTT // MQTT server support


// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// class ViewController
//
class ViewController: UIViewController {
	
	
	// Instace of CocoaMQTT as mqttClient
	//
	// host:		the IP address of the host device (in this case the RP3B+)
	// port:		the port used by the host (1883 is standard for MQTT)
	// clientID:	the name of the client requesting to connect --> UIDevice.current.name is the name
	//				of the user's phone (eg "Bob's iPhone")
	let mqttClient = CocoaMQTT(clientID: UIDevice.current.name, host: "172.20.8.47", port: 1883)

	
	// ====================================================================================================
	// func viewDidLoad
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
	
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		
	}

	
	// ====================================================================================================
	// func gpio40Switch
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
	@IBAction func gpio40Switch(_ sender: UISwitch) {
		
		// If the switch is already on
		if sender.isOn {
			// Publish a "topic" called "rpi/gpio" with the value "on"
			mqttClient.publish("rpi/to", withString: "on")
		}
		else { // Else if the switch is not on (it is off)
			// Publish a "topic" called "rpi/gpio" with the value "off"
			mqttClient.publish("rpi/to", withString: "off")
		}
		
	}
	// end: func gpio40Switch
	
	
	// ====================================================================================================
	// func connectButton
	//
	// Handles the user pressing the connect button
	//
	// Arguments--
	//
	// sender:		the instance of the UIButton
	//
	// Returns--
	//
	// None
	//
	@IBAction func connectButton(_ sender: UIButton) {
		// Connect to the server
		mqttClient.connect()
	}
	// end: func connectButton
	
	
	// ====================================================================================================
	// func disconnectButton
	//
	// Handles the user pressing the disconnect button
	//
	// Arguments--
	//
	// sender:		the instance of the UIButton
	//
	// Returns--
	//
	// None
	//
	@IBAction func disconnectButton(_ sender: UIButton) {
		mqttClient.disconnect() // Disconnect from the server
	}
	// end: func disconnectButton
	
	
	// ====================================================================================================
	// func printMessages
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
	@IBAction func printMessages(_ sender: UIButton) {
		
		// Subscribe to messages
		mqttClient.subscribe("rpi/from")
		// Request the plant data
		mqttClient.publish("rpi/from", withString: "requestPlantData")
		
		// Print any messages
		mqttClient.didReceiveMessage = { mqtt, message, id in
			print("Message received in topic \(message.topic) with payload \(message.string!)")
		}
		
	}
	// end: func printMessages
	
	
}
// end: class ViewController

