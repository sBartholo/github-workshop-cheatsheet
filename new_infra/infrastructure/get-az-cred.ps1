$studentprefix ="sba"
$resourcegroupName = "LAB-fabmedical-rg-" + $studentprefix
$rg = az group show --name $resourcegroupName | ConvertFrom-Json
az ad sp create-for-rbac --name "codetocloud-$studentprefix" --sdk-auth --role contributor --scopes $($rg.id)
