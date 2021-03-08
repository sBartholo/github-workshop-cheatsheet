$studentprefix = "sba"
$resourcegroupName = "LAB-fabmedical-rg-" + $studentprefix
$cosmosDBName = "fabmedical-cdb-" + $studentprefix
$webappName = "fabmedical-web-" + $studentprefix
$planName = "fabmedical-plan-" + $studentprefix
$location1 = "westeurope"
$location2 = "northeurope"

az group create -l $location1 -n $resourcegroupName

#Then create a CosmosDB
az cosmosdb create --name $cosmosDBName `
--resource-group $resourcegroupName `
--locations regionName=$location1 failoverPriority=0 isZoneRedundant=False `
--locations regionName=$location2 failoverPriority=1 isZoneRedundant=True `
--enable-multiple-write-locations `
--kind MongoDB


#Create a Azure App Service Plan
az appservice plan create --name $planName --resource-group $resourcegroupName --sku S1 --is-linux

az cosmosdb keys list -n $cosmosDBName -g $resourceGroupName --type connection-strings

#Create a Azure Web App with NGINX container
az webapp create --resource-group $resourcegroupName --plan $planName --name $webappName -i nginx


az webapp config appsettings set -n $webappName -g $resourcegroupName --settings MONGODB_CONNECTION="mongodb://fabmedical-cdb-sba:PIZYEZq57e8h6FlBt1Knu6BrTCOsTseZsgZJSuxcINQPmW9rx3upA5qJuMoIBVViRQlRz0gQqghXCZyf5yw35Q==@fabmedical-cdb-sba.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@fabmedical-cdb-sba@"

az webapp config container set `
--docker-registry-server-password $($env:CR_PAT) `
--docker-registry-server-url docker.pkg.github.com `
--docker-registry-server-user notapplicable `
--multicontainer-config-file docker-compose.yml `
--multicontainer-config-type COMPOSE `
--name $webappName `
--resource-group $resourcegroupName
