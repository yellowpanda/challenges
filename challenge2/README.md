# Challenge 2

Create a service that publish events to a Kafka topic. Create another service that reads events from Kafka. Host all of it in AKS.

# Tools
We need Docker Desktop 
```powershell
 winget install Docker.DockerDesktop
```

# Run Kafka locally

I plan to use [Strimzi Kafka](https://strimzi.io/).

I use Docker Compose to start Kafka.

```powershell
docker-compose up
``` 

This starts both containers. Kafka is now accessible from `localhost:9092`. 

# Create Publisher Service

The worker template is used to publish an event every second.

```powershell
dotnet new solution --name challenge1
dotnet new worker --name producer
dotnet sln add producer
```

For the Kafka client I use the Confluent.Kafka nuget package. 
It is described [here](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html).

```powershell
cd producer
dotnet add package Confluent.Kafka
```

I only added a bit of code to the [worker](src/producer/Worker.cs) class.

# Create Subscriber Service

# Create Containers for services

# Create ACR and AKS 

# Deploy Kafka and Services 
