# Challenge 2

Create a service that publish events to a Kafka topic. Create another service that reads events from Kafka. Host all of it in AKS.

# Tools
We need Docker Desktop 
```powershell
 winget install Docker.DockerDesktop
 winget install -e --id Microsoft.AzureCLI
 winget install -e --id Helm.Helm
 winget install -e --id Kubernetes.kubectl
 winget install --id=Derailed.k9s  -e
```

# Run Kafka locally

I use [Strimzi Kafka](https://strimzi.io/).

It consist of two containers zookeeper and kafka. 
Create a docker-compose.yaml file:

```dockerfile
version: '2'

services:

  zookeeper:
    image: quay.io/strimzi/kafka:0.37.0-kafka-3.5.1
    command: [
        "sh", "-c",
        "bin/zookeeper-server-start.sh config/zookeeper.properties"
      ]
    ports:
    - "2181:2181"
    environment:
      LOG_DIR: /tmp/logs

  kafka:
    image: quay.io/strimzi/kafka:0.37.0-kafka-3.5.1
    command: [
      "sh", "-c",
      "bin/kafka-server-start.sh config/server.properties --override listeners=$${KAFKA_LISTENERS} --override advertised.listeners=$${KAFKA_ADVERTISED_LISTENERS} --override zookeeper.connect=$${KAFKA_ZOOKEEPER_CONNECT}"
    ]
    depends_on:
    - zookeeper
    ports:
    - "9092:9092"
    environment:
      LOG_DIR: "/tmp/logs"
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
```

And start the two containers with:

```powershell
cd src
docker-compose up
``` 

This starts both containers. Kafka is now accessible externally from `localhost:9092`. 

# Create Publisher Service

The worker template is used to publish an event every second.

```powershell
dotnet new solution --name challenge2
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

I added the consumer logic to the [worker](src/consumer/Worker.cs) class. 

The GroupId property is interesting from a Kafka perspective. When an event is processed, the Kafka server is informed (automatically or with with `.Commit(...)`) that this GroupId has processed the event. When restarting the application the Kakfa server can then inform the client from what offset to continue. If the application is restarted with a different GroupId then all events is reprocessed. 

# Create Containers for services and run locally

Create `Dockerfile` files with inspiration from [here](https://learn.microsoft.com/en-us/dotnet/core/extensions/cloud-service?pivots=cli):
* [Dockerfile](src/producer/Dockerfile) for producer.
* [Dockerfile](src/consumer/Dockerfile) for consumer.

Update [docker-compose.yaml](docker-compose.yaml) with reference to the two containers (and change the 'KAFKA_ADVERTISED_LISTENERS' setting). Here the producer:

```dockerfile
producer:
    build: ./producer/
    depends_on:
    - kafka
    environment:
      "KafkaHost": "kafka:9092"
```

The `build` command points to a folder with a `Dockerfile` and builds the container when needed.  
`environment` sets environment variables and the c# application check the environment variable before `appsettings.json`. 

Start all 4 containers with 
```powershell
docker-compose up
```
And the consumer receives the messages send from the producer:
![Screenshot1](doc/screenshot1.png)

# Create ACR and AKS 

I use Bicep to describe what resources that I need ([main.bicep](iac/main.bicep)) and have two powershell scripts to create ([iac-deploy.ps1](iac/iac-deploy.ps1)) and delete all the resources ([iac-cleanup.ps1](iac/iac-cleanup.ps1)). 

```powershell
az login
az account set --subscription "<subscription name>"
cd iac
./iac-deploy.ps1
```



# Create the producer container 
Create a [Dockerfile](./src/producer/Dockerfile).

```powershell
# Build image and put into the local container registry
docker build -t challenge2-producer-image -f Dockerfile .

# Create container
docker create --name challenge2-producer challenge2-producer-image

# Run it (will fail because Kafka is not running)
docker run -it --rm challenge2-producer-image
```

# Push to producer container registry

```powershell
$registryName = "<registry name>"

az login
az acr login --name "$registryName"  --expose-token

# Tag container image (create alias)
docker tag challenge2-producer-image "$registryName.azurecr.io/challenge2/challenge2-producer-image"

docker push "$registryName.azurecr.io/challenge2/challenge2-producer-image"
```

# Create and push the consumer container

Just do the same as above for the consumer. 

```powershell
# Build image and put into the local container registry
docker build -t challenge2-consumer-image -f Dockerfile .

# Create container
docker create --name challenge2-consumer challenge2-consumer-image

# Run it (will fail because Kafka is not running)
docker run -it --rm challenge2-consumer-image

# Tag container image (create alias)
docker tag challenge2-consumer-image "$registryName.azurecr.io/challenge2/challenge2-consumer-image"

docker push "$registryName.azurecr.io/challenge2/challenge2-consumer-image"

```


# Create a helm chart for the application

I follow this [how to](https://helm.sh/docs/chart_template_guide/getting_started/).

```powershell
helm create mychart
```

Replace `image.repository` with `challenge2acr.azurecr.io/challenge2/challenge2-producer-image`
# Deploy the application helm chart

```powershell
helm install producer .\src\producer\producer-chart\
helm install producer .\src\consumer\consumer-chart\
```


# Deploy Kafka 

Use of Helm: https://helm.sh/docs/intro/quickstart/

Install Kafka with Helm: https://strimzi.io/blog/2018/11/01/using-helm/. 

```powershell
helm repo add strimzi https://strimzi.io/charts/
helm install strimzi/strimzi-kafka-operator --generate-name
```

# Configure Kafka and the Applications

The applications are running. Kafka is runnnig. They cannot communicate because they are not configured. 