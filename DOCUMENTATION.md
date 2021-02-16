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

Request	: "REQ_plantInfoOnStartup" // Requests information such as the number of plants, plant names, etc. when the iOS app first connects

Response : "RES_plantInfoOnStartup" // Gives some basic infomation about the plants (no sensor information) to the iOS client
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
""
```
