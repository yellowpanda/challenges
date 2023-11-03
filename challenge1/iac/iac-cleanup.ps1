$ressourceGroupName = $Env:ressourceGroupName
if ($null -eq $ressourceGroupName) {
    write-host "Please add ressourceGroupName as en environment variable:" 
    write-host "`$Env:ressourceGroupName = ""challenge1""" 
    exit 1
}
Write-Host "Ressource Group = $ressourceGroupName"

az group delete --name $ressourceGroupName --yes
