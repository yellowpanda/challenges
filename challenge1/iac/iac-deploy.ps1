

$ressourceGroupName = $Env:ressourceGroupName
if ($null -eq $ressourceGroupName) {
    write-host "Please add ressourceGroupName as en environment variable:" 
    write-host "`$Env:ressourceGroupName = ""challenge1""" 
    exit 1
}
Write-Host "Ressource Group = $ressourceGroupName"

$userEmail = $Env:userEmail
if ($null -eq $userEmail) {
    write-host "Please add userEmail as en environment variable:"
    write-host "`$Env:userEmail = ""email@email.com""" 
    exit 1 
}
Write-Host "User email = $userEmail"

$userName = $userEmail.Split("@")[0]
Write-Host "User name for AKS = $userName" 

$userObjectId = az ad user show --id $userEmail --query "id"

# Create a resource group
az group create --name $ressourceGroupName --location westeurope --output none

# Deploy the bicep file
az deployment group create --resource-group $ressourceGroupName --template-file main.bicep --name "main" --output none  --parameters userObjectId=$userObjectId

# Extract the container name
az deployment group show -g $ressourceGroupName -n "main" --query properties.outputs.containerRegistryName.value

