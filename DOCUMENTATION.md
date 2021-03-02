# Plant-Tracker Documentation

------------------------------

# Terminology

Reponse: refers to a message sent by the host RPI to a client iOS device

Request: refers to a message sent by any client iOS device to the host RPI (requests are always followed up by responses)

ID/message ID: a numerical message ID, currently not used

Client: any iOS device connected or trying to connect to the server

Client name: a name or ID given to each client to differentiate them

Operation: a specific string sent or received (also known as requests and responses) to ease the tranfer of data (see "Operation Tags" below)

Payload: Any additional information that comes with a request or response


# Transactions

Transactions include both messages back and forth between a client iOS device the RPI host.

Both the "subscriber.py" and "ViewController.swift" files have two functions to handle message I/O. On the RPI, these are called "decodeIncomingRequest" and "publishOutgoingResponse." On any iOS device, they are called "decodeIncomingResponse" and "publishOutgoingRequest"


# Formatting Operations

Requests and responses (operations) are made up of four elements: a message ID, client name, payload, and a request or response tag.

The expected format for a request or response is:

```
"ID:<id here>;sender:<sender of message>;receiver:<intended receiver of message>;payload:<payload here>;operation:<request or response tag here>"
```

The keys are case sensitive (id is not the same as ID and will throw an error). There should be no spaces between semicolons or colons (however if a payload has spaces, that is acceptable). Keys and their values should be seperated by colons (:) and different sets of keys/values should be seperated by semicolons (;)

Because the operation key is just "operation," request operations are titled with the prefix "REQ_" and response operations are titled with the prefix "RES_"


# Request and Response Tags

When sending a request of response, one of a number of "tags" can be used. On the server-side, requests with specific tags with call different functions. Response tags will always follow the format "RES_<name of the request tag>" (for example, a request tag of "test" would be followed with "RES_test")

A list of the tags and their meanings is:

```
Request : "REQ_plantSensorData" // A request that asks the server for sensor information about the plants. The payload included in a transaction with this request can specify which plant should be updated

Response : "RES_plantSensorData" // A response that is attached to a message with plant data. This response follows the request "REQ_plantData." The payload includes the data for all plants or a single specified plant

Request	: "REQ_numPlants" // Asks for the number of plants the user has

Response : "RES_numPlants" // Returns the number of plants the user has

Request : "REQ_plantInfoOnStatup" // Asks the server for information about each plant, such as name, sensor IDs, etc

Response : "RES_plantInfoOnStartup" // Returns information about a particular plant

Request : "REQ_addNewPlant" // Add a new plant with its name and sensor information

Request : "REQ_deletePlant" // Deletes an existing plant
```


# Operation Errors

If a request of response is invalid for any reason, and error with be thrown. Both the server and iOS side have error handling functions. Errors are sent back to the initial sender with the format:

```
"ID:<message id>;sender:<sender of message>;receiver:<intended receiver of message>;payload:<previous message that caused an error>;operation:<error tag>"
```

A list of error tags are their meanings is:

```
"ERR_hashLength" // There were either too few or too many arguments in the transaction message

"ERR_missingVals" // There were more keys than values in the hash

"ERR_missingKeys" // There were more values than keys in the hash

"ERR_invalidOpTag" // There was an invalid operation tag

"ERR_noPlantDataToRequest" // A client requested plant data but no such data existed

"ERR_tooManyPlants" // Somehow the user has too many plants and they could not all be displayed

"ERR_cannotDeletePlant" // There was an issue with deleting a plant (most likely it did not exist)

"ERR_invalidPlantSensorID" // The sensor identifier the user entered was not found or is invalid

"ERR_plantNameTaken" // The user is trying to add a plant whose name is already taken
```


# Adding Plants

When adding plants, reading, or writing an user's json file, there is an expected format to be followed:

```
"[{"Sensors": "test id", "Name": "test name"}, {"Sensors": "id", "Name": "plant"}]"
```

As the line above shows, each plant for any given user is a dictionary (or hash) and all of the plants for any given user are inside an array. The datastructer goes: an array of plants, each a hash with keys and values about information about that plant (such as name, sensor amount, sensor ids, etc)


# Functions

A list of functions for the iOS app and their purpose can be found below:

"Utility" functions--
```
viewDidLoad	   // build-in iOS function, completes some initially setup on launch

displayRect    // Displays a rectangle of a specified color, position, and size

displayText    // Displays a text message

convertStringToDictionary    // Converts a JSON string into a dictionary

displayMoistureBar    // Displays a colored bar to give the user an idea of the plant's water at a glance

refreshPlantsDisplayed    // Refreshes the plants

displayPlantsOnScreen    // Displays boxes with plant info

handleTap    // Handles taping on the plants
```

"Operation" functions--
```
RES_plantSensorData    // Processes the plant sensor data

RES_numPlants    // Processes the number of plants

RES_plantInfoOnStartup    // Gets basic plant information when the app starts
```

"Storyboard" and "Server" functions--
```
operationError    // Throws an error

popupError    // Show a popup alert with an error message

publishOutgoingRequest    // Publishes a new request message

decodeIncomingResponse    // Processes an incoming response message

getHostIP    // A textbox which the user can enter a new host IP into

connectionSwitch    // The switch the user uses to connect and disconnect from the server

requestData    // Tied to the "Update Plant Data" button; gets updated sensor data

addPlant    // Tied to the "Add Plant" button; adds a new plant

plantSettings    // Alter information about a plant or delete the plant completely
```


A list of functions for the host.py script can be found below:

"Operation" functions--
```
REQ_plantSensorData    // Returns plant sensor data to the requesting client

REQ_numPlants    // Returns the number of plants to the requesting client

REQ_plantInfoOnStartup    // Returns basic plant info to the requesting cleint

REQ_addNewPlant    // Processes adding a new plant

REQ_deletePlant    // Deletes a plant
```

"Server" functions--
```
connectionStatus    // Connects and subscribes the python script to the actual server

operationError    // Throws an error

publishOutgoingResponse    // Publishes a new response message

decodeIncomingRequest    // Processes an incoming request message
```


A list of functions for the sensors.py script can be found below

"Operation" functions--
```
readSensor    // Reads the data from a given sensor
```
