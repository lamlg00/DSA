import ballerina/grpc;
import ballerina/io;

// Define the necessary request and response types
type AddProductRequest record {
    string name;
    string description;
    float price;
    int stock_quantity;
    string sku;
    boolean status;
};

type AddProductResponse record {
    string product_code;
};

type ListProductsResponse record {
    Product[] products;
};

type Product record {
    string product_code;
    string name;
    string description;
    float price;
    int stock_quantity;
    string sku;
    boolean status;
};

type SearchProductRequest record {
    string query;
};

type UpdateProductRequest record {
    string product_code;
    string name;
    string description;
    float price;
    int stock_quantity;
    boolean status;
};

public function main() {
    // Create a gRPC client for the shopping service
    grpc:Client shoppingClient = check grpc:Client.create("shoppingService", "http://localhost:8080");

    // Prepare the request to add a product
    AddProductRequest addProductReq = {
        name: "Laptop",
        description: "Gaming Laptop",
        price: N$ 15 000.00,
        stock_quantity: 10,
        sku: "LAP123",
        status: true
    };

    // Call the addProduct method and handle the response
    AddProductResponse addProductRes = check shoppingClient->addProduct(addProductReq);

    // Print the product code returned from the service
    io:println("Added Product Code: ", addProductRes.product_code);

    // Additional client operations
    // Example: Listing products
    ListProductsResponse listRes = check shoppingClient->listProducts();
    io:println("Products List: ", listRes.products);

    // Example: Searching for a product
    SearchProductRequest searchReq = { query: "Laptop" };
    Product[] searchResults = check shoppingClient->searchProduct(searchReq);
    io:println("Search Results: ", searchResults);

    // Example: Updating a product
    UpdateProductRequest updateReq = {
        product_code: addProductRes.product_code,
        name: "Gaming Laptop - Updated",
        description: "High-performance Gaming Laptop",
        price: N$ 16 000.00,
        stock_quantity: 5,
        status: true
    };
    check shoppingClient->updateProduct(updateReq);
    io:println("Product updated successfully.");
}