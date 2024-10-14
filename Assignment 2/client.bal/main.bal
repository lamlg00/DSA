import ballerina/io;

// Define the shipment request and customer records
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

public function main() {
    // Get user input
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

    // Output the shipment request for debugging purposes
    io:println("Shipment Request: ", shipmentRequest.toString());
}
