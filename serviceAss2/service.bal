import ballerina/http; 
import ballerina/io;
import ballerinax/kafka;
import ballerinax/mongodb;

configurable string kafkaHost = "kafka:29092";
configurable string mongodbHost = "mongodb://mongodb:27017";

// Kafka producer configuration
kafka:ProducerConfiguration producerConfig = {
    bootstrapServers: [kafkaHost],
    clientId: "logistics-producer"
};

// Kafka consumer configuration for multiple topics
kafka:ConsumerConfiguration consumerConfig = {
    bootstrapServers: [kafkaHost],
    groupId: "logistics-consumer",
    topics: ["standard-delivery", "express-delivery", "international-delivery", "logistics-service"]
};

// MongoDB configuration for logisticsDB
mongodb:ClientConfiguration mongoConfig = {
    connection: {
        host: mongodbHost,
        database: "logisticsDB"
    }
};

// HTTP service to receive customer requests
service / on new http:Listener(8080) {
    resource function post request(@http:Payload json payload) returns json|error {
        // Create Kafka producer and send request to relevant Kafka topic
        kafka:Producer producer = check new (kafkaHost, producerConfig);
        // Determine the appropriate topic based on shipment type
        string topic = check getTopic(payload);
        // Send the request to the respective topic
        check producer->send({
            topic: topic,
            value: payload
        });

        // Provide response to customer
        json response = {
            "message": "Request received and forwarded to processing",
            "trackingId": generateTrackingId(),
            "estimatedDeliveryTime": "To be determined"
        };
        return response;
    }
}

// Main function to listen to Kafka topics and process requests
public function main() returns error? {
    kafka:Consumer consumer = check new (consumerConfig);
    mongodb:Client mongo = check new (mongoConfig);
    while true {
        kafka:ConsumerRecord[] records = check consumer->pollPayload(1);
        foreach var record in records {
            json payload = check record.value.ensureType();
            check processRequest(payload, mongo, record.topic);
        }
    }
}

// Function to determine the Kafka topic based on the shipment type
function getTopic(json payload) returns string|error {
    string shipmentType = check payload.shipmentType.ensureType(string);
    
    match shipmentType {
        "standard" => { return "standard-delivery"; }
        "express" => { return "express-delivery"; }
        "international" => { return "international-delivery"; }
        _ => { return "logistics-service"; } // Default topic for unknown types
    }
}

// Function to process the request and store relevant data in MongoDB
function processRequest(json payload, mongodb:Client mongo, string topic) returns error? {
    // Store customer information, shipment details, and schedule based on the topic
    map<json> shipmentData = {
        "customerName": check payload.customerInfo.firstName.ensureType(string) + " " + check payload.customerInfo.lastName.ensureType(string),
        "contactNumber": check payload.customerInfo.contactNumber.ensureType(string),
        "shipmentType": check payload.shipmentType.ensureType(string),
        "pickupLocation": check payload.pickupLocation.ensureType(string),
        "deliveryLocation": check payload.deliveryLocation.ensureType(string),
        "preferredTimeSlots": check payload.preferredTimeSlots.ensureType(json[]),
        "status": "Pending"
    };
    
    // Insert the shipment details into the MongoDB collection "shipments"
    check mongo->insert(shipmentData, "shipments");
    io:println("Shipment data inserted into MongoDB");

    // Update delivery schedule and tracking information based on external service (simplified example)
    check updateDeliverySchedule(shipmentData, mongo, topic);
}

// Function to update delivery schedules and send responses with tracking info
function updateDeliverySchedule(map<json> shipmentData, mongodb:Client mongo, string topic) returns error? {
    // Simulate delivery schedule update
    string trackingId = generateTrackingId();
    json deliverySchedule = {
        "trackingId": trackingId,
        "shipmentType": shipmentData["shipmentType"],
        "status": "Scheduled",
        "estimatedDeliveryTime": "3-5 business days"  // Example for standard delivery
    };
    
    // Insert the delivery schedule into MongoDB collection "deliverySchedules"
    check mongo->insert(deliverySchedule, "deliverySchedules");
    io:println("Delivery schedule updated and stored in MongoDB");

    // Send the updated tracking and delivery information back to customer (optional)
    // You could add a Kafka producer or HTTP response here
}

// Function to generate a unique tracking ID for shipments
function generateTrackingId() returns string {
    // Simple tracking ID generation (you can improve this logic as needed)
    return "TRK" + check int:toString(time:currentTime().unixTime());
}
