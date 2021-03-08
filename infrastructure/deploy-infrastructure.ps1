param
(
    [string] $studentprefix = "sba"
)

#$studentprefix = "sba"
$resourcegroupName = "RG-Lab-fabmedical-" + $studentprefix
$cosmosDBName = "fabmedical-cdb-" + $studentprefix
$webappName = "fabmedical-web-" + $studentprefix
$planName = "fabmedical-plan-" + $studentprefix
$location1 = "westeurope"
$location2 = "northeurope"
$appInsights = "fabmedicalai-" + $studentprefix

$rg = az group create --name $resourcegroupName --location $location1 | ConvertFrom-Json 

#Then create a CosmosDB
az cosmosdb create --name $cosmosDBName `
--resource-group $resourcegroupName `
--locations regionName=$location1 failoverPriority=0 isZoneRedundant=False `
--locations regionName=$location2 failoverPriority=1 isZoneRedundant=True `
--enable-multiple-write-locations `
--kind MongoDB

#Then create a Azure App Service Plan
az appservice plan create --name $planName --resource-group $resourcegroupName --sku S1 --is-linux

#Create a Azure Web App with NGINX container
#az webapp create --resource-group $resourcegroupName --plan $planName --name $webappName -i nginx

az cosmosdb keys list -n $cosmosDBName -g $resourceGroupName --type connection-strings


#docker run -ti -e
#MONGODB_CONNECTION="mongodb://xxx.documents.azure.com:10255/contentdb?ssl=true&replic
#aSet=globaldb" ghcr.io/<yourgithubaccount>/fabrikam-init


az webapp config appsettings set -n $webappName -g $resourcegroupName `
--settings MONGODB_CONNECTION="mongodb://fabmedical-cdb-sba:WirtXJpljGdDIws9wmbmQc2CvYDWUraAHM4Ve9vFLU6Oe5PO9KLc7NS1SUCiS4vPF1Rc3hPHD8pmaaqNZFRbQg==@fabmedical-cdb-sba.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@fabmedical-cdb-sba@"


#Create a Azure App Service Plan
az appservice plan create --name $planName --resource-group $resourcegroupName --sku S1 --is-linux

az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_URL="https://docker.pkg.github.com" --name $($webappName) --resource-group $($resourcegroupName) 
az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_USERNAME="notapplicable" --name $($webappName) --resource-group $($resourcegroupName) 
az webapp config appsettings set --settings DOCKER_REGISTRY_SERVER_PASSWORD="$($env:CR_PAT)" --name $($webappName) --resource-group $($resourcegroupName) 


#Create a Azure Web App with NGINX container
az webapp create `
--multicontainer-config-file docker-compose.yml `
--multicontainer-config-type COMPOSE `
--name $($webappName) `
--resource-group $($resourcegroupName) `
--plan $($planName)

az webapp config container set `
--docker-registry-server-password $($env:CR_PAT) `
--docker-registry-server-url https://docker.pkg.github.com `
--docker-registry-server-user notapplicable `
--multicontainer-config-file docker-compose.yml `
--multicontainer-config-type COMPOSE `
--name $($webappName) `
--resource-group $resourcegroupName 

az extension add --name application-insights
az monitor app-insights component create --app $appInsights --location $location1 --kind web -g $resourcegroupName --application-type web --retention-time 120
