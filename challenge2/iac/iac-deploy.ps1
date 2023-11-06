
param(
    [Parameter(Mandatory = $true)]
    $ressourceGroupName
)

# Create a resource group
az group create --name $ressourceGroupName --location westeurope --output none
if(!$?) {exit 1}

# Deploy the bicep file
az deployment group create --resource-group $ressourceGroupName --template-file main.bicep --name "main" --output none
if(!$?) {exit 1}

# Extract the container name
az deployment group show -g $ressourceGroupName -n "main" --query properties.outputs.containerRegistryName.value
if(!$?) {exit 1}
