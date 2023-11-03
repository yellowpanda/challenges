

$ressourceGroupName = $Env:ressourceGroupName
if ($null -eq $ressourceGroupName) {
    write-host "Please add ressourceGroupName as en environment variable:" 
    write-host "`$Env:ressourceGroupName = ""challenge1""" 
    exit 1
}
Write-Host "Ressource Group = $ressourceGroupName"

# Create a resource group
az group create --name $ressourceGroupName --location westeurope --output none

# Deploy the bicep file
az deployment group create --resource-group $ressourceGroupName --template-file main.bicep --name "main" --output none

# Extract the container name
az deployment group show -g $ressourceGroupName -n "main" --query properties.outputs.containerRegistryName.value

