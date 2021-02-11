// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
//  ViewController.swift
//  Plant Tracker
//
//  Created by Jonathan Uhler on 2/8/21.
// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+


// ====================================================================================================
// Revision History
//
// PRE-RELEASES
//
//	version		  date						changes
//  -------		--------			-----------------------
//	pre-1.0.0	2/10/21				First working version of Plant Tracker



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
			mqttClient.publish("rpi/gpio", withString: "on")
		}
		else { // Else if the switch is not on (it is off)
			// Publish a "topic" called "rpi/gpio" with the value "off"
			mqttClient.publish("rpi/gpio", withString: "off")
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
	// sender:		the instance of the UISwitch
	//
	// Returns--
	//
	// None
	//
	@IBAction func connectButton(_ sender: UIButton) {
		mqttClient.connect() // Connect to the server
	}
	// end: func connectButton
	
	
	// ====================================================================================================
	// func disconnectButton
	//
	// Handles the user pressing the disconnect button
	//
	// Arguments--
	//
	// sender:		the instance of the UISwitch
	//
	// Returns--
	//
	// None
	//
	@IBAction func disconnectButton(_ sender: UIButton) {
		mqttClient.disconnect() // Disconnect from the server
	}
	// end: func disconnectButton
	
	
}
// end: class ViewController

