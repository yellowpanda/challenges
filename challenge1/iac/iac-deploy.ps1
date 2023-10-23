
$ressourceGroupName = "rth-challenge1"

# Create a resource group
az group create --name $ressourceGroupName --location westeurope --output none

# Deploy the bicep file
az deployment group create --resource-group $ressourceGroupName --template-file main.bicep --name "main" --output none

# Extract the container name
az deployment group show -g $ressourceGroupName -n "main" --query properties.outputs.containerRegistryName.value

