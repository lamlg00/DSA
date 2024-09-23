import ballerina/grpc;
import ballerina/io;

service shoppingService on new grpc:Listener(8080) {

    // In-memory storage for products and order processing
    map<Product> products = {};
    map<stream<string>> carts = {};
    string[] orders;

    // Add a new product
    resource function addProduct(AddProductRequest req) returns AddProductResponse {
        Product product = { name: req.name, description: req.description, price: req.price,
                            stock_quantity: req.stock_quantity, sku: req.sku, status: req.status };
        products[req.sku] = product;
        return { product_code: req.sku };
    }

    // Update an existing product
    resource function updateProduct(UpdateProductRequest req) returns UpdateProductResponse {
        if (products.hasKey(req.sku)) {
            Product product = { name: req.name, description: req.description, price: req.price,
                                stock_quantity: req.stock_quantity, sku: req.sku, status: req.status };
            products[req.sku] = product;
            return { message: "Product updated successfully." };
        } else {
            return { message: "Product not found." };
        }
    }

    // Remove a product
    resource function removeProduct(RemoveProductRequest req) returns RemoveProductResponse {
        if (products.remove(req.sku)) {
            return { products: products.values() };
        } else {
            return { products: [] };
        }
    }

    // List available products
    resource function listAvailableProducts(ListAvailableProductsRequest req) returns ListAvailableProductsResponse {
        Product[] availableProducts = [];
        foreach var product in products.values() {
            if (product.status) {
                availableProducts.push(product);
            }
        }
        return { products: availableProducts };
    }

    // Search for a product by SKU
    resource function searchProduct(SearchProductRequest req) returns SearchProductResponse {
        if (products.hasKey(req.sku)) {
            return { product: products[req.sku], message: "Product found." };
        } else {
            return { product: {}, message: "Product not available." };
        }
    }

    // Add to cart
    resource function addToCart(AddToCartRequest req) returns AddToCartResponse {
        if (!carts.hasKey(req.user_id)) {
            carts[req.user_id] = [];
        }
        carts[req.user_id].push(req.sku);
        return { message: "Product added to cart." };
    }

    // Place an order
    resource function placeOrder(PlaceOrderRequest req) returns PlaceOrderResponse {
        if (carts.hasKey(req.user_id)) {
            string orderId = "order-" + string(orders.length() + 1);
            orders.push(orderId);
            carts.remove(req.user_id);
            return { order_id: orderId };
        } else {
            return { order_id: "No items in cart." };
        }
    }
    // Create users
    resource function createUsers(stream<CreateUserRequest> userRequests) returns CreateUserResponse {
        // Process each user creation request
        return { message: "Users created." };
    }
}