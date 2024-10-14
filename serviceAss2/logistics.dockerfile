# Use the official Ballerina image
FROM ballerina/ballerina:slalpha5

# Copy your Ballerina service file into the container
COPY service.bal /home/ballerina/service.bal

# Set the working directory
WORKDIR /home/ballerina

# Build the Ballerina project
RUN ballerina build service.bal

# Expose the HTTP port (8080) for external access
EXPOSE 8080

# Run the Ballerina service
CMD ["ballerina", "run", "service.bal"]
