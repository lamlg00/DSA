import ballerina/http;
import ballerina/io;

// Define the endpoint of the logistics service
final string LOGISTICS_SERVICE_URL = "http://localhost:8080/logistics/scheduleDelivery";

// Struct to hold shipment information
type ShipmentRequest record {
    string shipmentType;
    string pickupLocation;
    string deliveryLocation;
    string preferredTimeSlot;
    Customer customer;
};

type Customer record {
    string firstName;
    string lastName;
    string contactNumber;
};

// Create the HTTP client to communicate with the logistics service
http:Client logisticsClient = check new(LOGISTICS_SERVICE_URL);

public function main() {

    // Get customer input for the shipment
    io:println("Enter shipment type (standard, express, international): ");
    string shipmentType = io:readln();
    
    io:println("Enter pickup location: ");
    string pickupLocation = io:readln();
    
    io:println("Enter delivery location: ");
    string deliveryLocation = io:readln();
    
    io:println("Enter preferred time slot (e.g., 9 AM - 12 PM): ");
    string timeSlot = io:readln();
    
    io:println("Enter your first name: ");
    string firstName = io:readln();
    
    io:println("Enter your last name: ");
    string lastName = io:readln();
    
    io:println("Enter your contact number: ");
    string contactNumber = io:readln();

    // Create a shipment request object
    ShipmentRequest shipmentRequest = {
        type: shipmentType,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        preferredTimeSlot: timeSlot,
        customer: {
            firstName: firstName,
            lastName: lastName,
            contactNumber: contactNumber
        }
    };

    // Send the shipment request to the logistics service
    var response = logisticsClient->post("/", shipmentRequest);

    // Handle the response from the logistics service
    if (response is http:Response) {
        json jsonResponse = check response.getJsonPayload();
        io:println("Shipment request was successfully processed.");
        io:println("Response: ", jsonResponse.toString());
    } else {
        io:println("Failed to contact the logistics service. Error: ", response.toString());
    }
}
