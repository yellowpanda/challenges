# Challenge 2

Create a service that publish events to a Kafka topic. Create another service that reads events from Kafka. Host all of it in AKS.

# Tools
We need Docker Desktop 
```powershell
 winget install Docker.DockerDesktop
```

# Run Kafka locally

I use [Strimzi Kafka](https://strimzi.io/).

It consist of two containers zookeeper and kafka. 
To start both containers use Docker Compose and a [docker-compose.yaml](src/docker-compose.yaml): 

```powershell
cd src
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

# Create Consumer Service

```powershell
dotnet new worker --name consumer
dotnet sln add consumer
```

I use the same nuget package as above and use the consumer example described [here](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html). 


```powershell
cd consumer
dotnet add package Confluent.Kafka
```

I added the consumer logic to the [worker](src/producer/Worker.cs) class. 

The GroupId property is interesting from a Kafka perspective. When an event is processed, the Kafka server is informed (automatically or with with `.Commit(...)`) that this GroupId has processed the event. When restarting the application the Kakfa server can then inform the client from what offset to continue. If the application is restarted with a different GroupId then all events is reprocessed. 

# Create Containers for services

# Create ACR and AKS 

# Deploy Kafka and Services 
