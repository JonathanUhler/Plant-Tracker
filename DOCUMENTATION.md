# Plant-Tracker Documentation

------------------------------

# Terminology

Reponse: refers to a message sent by the host RPI to a client iOS device

Request: refers to a message sent by any client iOS device to the host RPI (requests are always followed up by responses)

ID/message ID: a numerical message ID, currently not used

Client: any iOS device connected or trying to connect to the server

Client name: a name or ID given to each client to differentiate them

Request/response: a specific string sent or received to ease the tranfer of data (see "Requests and Responses" below)

Payload: Any additional information that comes with a request or response


# Transactions

Transactions include both messages back and forth between a client iOS device the RPI host.

Both the "subscriber.py" and "ViewController.swift" files have two functions to handle message I/O. On the RPI, these are called "decodeIncomingRequest" and "publishOutgoingResponse." On any iOS device, they are called "decodeIncomingResponse" and "publishOutgoingRequest"


# Formatting Requests and Responses

Requests and responses are made up of four elements: a message ID, client name, payload, and a request or response tag.

The expected format for a request or response is:

```
// Request
"ID:<id here>;client:<client identifier here>;payload:<payload here>;request:<request tag here>"

// Response
"ID:<id here>;client:<client identifier here>;payload:<payload here>;response:<response tag here>"
```

The keys are not case sensitive (ID is the same as id). There should be no spaces between semicolons or colons (however if a payload has spaces, that is acceptable). Keys and their values should be seperated by colons (:) and different sets of keys/values should be seperated by semicolons (;)


# Request and Response Tags

When sending a request of response, one of a number of "tags" can be used. On the server-side, requests with specific tags with call different functions. Response tags will always follow the format "RES_<name of the request tag>" (for example, a request tag of "test" would be followed with "RES_test")

A list of the tags and their meanings is:

```
Request : "requestPlantData" // A request that asks the server for sensor information about the plants. The payload included in a transaction with this request can specify which plant should be updated

Respnse	: "RES_requestPlantData" // A response that is attached to a message with plant data. This response follows the request "requestPlantData." The payload includes the data for all plants or a single specified plant
```
