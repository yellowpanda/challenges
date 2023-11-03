
# Challenge

Create a website, put it into a container and host it Kubernetes.

# Create website

Run from powershell:

```powershell
dotnet new solution --name challenge1
dotnet new web --name website --no-https
dotnet sln add website

# Set application url to be the same every time
$json = Convertfrom-json(get-content "website\Properties\launchSettings.json" -raw)
$json.profiles.http.applicationUrl = "http://localhost:8080"
$json.iisSettings.iisExpress.applicationUrl = "http://localhost:8080"
ConvertTo-Json $json -Depth 4 | Out-File "website\Properties\launchSettings.json"

dotnet run --project website 
```

Open the website in a browser http://localhost:8080 and see `Hello World!`


# Create the container
I just follows the [tutorial](https://learn.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=windows&pivots=dotnet-7-0).

First publish the website:
```powershell
dotnet publish -c Release
```

Then create a [Dockerfile](./src/Dockerfile).

```powershell
# Build image and put into the local container registry
docker build -t challenge1-image -f Dockerfile .

# Create container
docker create --name challenge1 challenge1-image

# Run it on on localhost port 8080
docker run -it --rm -p 8080:80 challenge1-image
```

Open the website in a browser http://localhost:8080 and see `Hello World!`


# Create a container registry and AKS in Azure

```powershell
az login
az account set --subscription "<subscription name>"
cd iac
./iac-deploy.ps1
```

# Push to container registry

```powershell
$registryName = "<registry name>"

az login
az acr login --name "$registryName"

# Tag container image (create alias)
docker tag challenge1-image "$registryName.azurecr.io/challenge1/challenge1-image"

docker push "$registryName.azurecr.io/challenge1/challenge1-image"
```

# Run container in AKS
