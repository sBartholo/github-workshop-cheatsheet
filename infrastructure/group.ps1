param
(
    [string] $studentprefix = "sba"
)

$resourcegroupName = "RG-Lab-fabmedical-" + $studentprefix
$cosmosDBName = "fabmedical-cdb-" + $studentprefix
$webappName = "fabmedical-web-" + $studentprefix
$planName = "fabmedical-plan-" + $studentprefix
$location1 = "westeurope"
$location2 = "northeurope"
$appInsights = "fabmedicalai-" + $studentprefix

$rg = az group create --name $resourcegroupName --location $location1 | ConvertFrom-Json 

az ad sp create-for-rbac --name "codetocloud-$studentprefix" --sdk-auth --role contributor --scopes $($rg.id)
