// Kafka consumer configuration for multiple topics
kafka:ConsumerConfiguration consumerConfig = {
    bootstrapServers: [kafkaHost],
    groupId: "logistics-consumer",
    topics: ["standard-delivery", "express-delivery", "international-delivery", "logistics-service"]
};

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
