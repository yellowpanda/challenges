param(
    [Parameter(Mandatory = $true)]
    $ressourceGroupName
)

az group delete --name $ressourceGroupName --yes
if(!$?) {exit 1}