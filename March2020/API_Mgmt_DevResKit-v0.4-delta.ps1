# Ref URLs: 
    # https://github.com/Azure/azure-api-management-devops-resource-kit/blob/master/src/APIM_ARMTemplate/README.md#Extractor
    # https://dibranmulder.github.io/2018/12/19/Azure-API-Management-ARM-Cheatsheet/
    # https://github.com/stephaneey/azure-apim-extension
    # https://www.youtube.com/watch?v=4Sp2Qvmg6j8



# ***************************************************************************************************************************
# ***************************************************************************************************************************
# Extract

$subscriptionId = '[your id]'

az login
az account set --subscription $subscriptionId

# reskit-win64-v0.4-delta - Your download path
C:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate.exe extract --help
# Extract an existing API Management instance

# Usage: extract [options]

# Options:
#   --extractorConfig <extractorConfig>                              Config file of the extractor
#   --sourceApimName <sourceApimName>                                Source API Management name
#   --destinationApimName <destinationApimName>                      Destination API Management name
#   --resourceGroup <resourceGroup>                                  Resource Group name
#   --fileFolder <fileFolder>                                        ARM Template files folder
#   --apiName <apiName>                                              API name
#   --mutipleAPIs <mutipleAPIs>                                      Comma-separated list of API names
#   --linkedTemplatesBaseUrl <linkedTemplatesBaseUrl>                Creates a master template with links
#   --linkedTemplatesSasToken <linkedTemplatesSasToken>              
#   --linkedTemplatesUrlQueryString <linkedTemplatesUrlQueryString>  Query string appended to linked templates uris that enables retrieval from private storage
#   --policyXMLBaseUrl <policyXMLBaseUrl>                            Writes policies to local XML files that require deployment to remote folder
#   --policyXMLSasToken <policyXMLSasToken>                          String appended to end of the linked templates uris that enables adding a SAS token or other query parameters
#   --splitAPIs <splitAPIs>                                          Split APIs into multiple templates
#   --apiVersionSetName <apiVersionSetName>                          Name of the apiVersionSet you want to extract
#   --includeAllRevisions <includeAllRevisions>                      Includes all revisions for a single api - use with caution
#   --baseFileName <baseFileName>                                    Specify base name of the template file
#   --serviceUrlParameters <serviceUrlParameters>                    ServiceUrl parameters
#   --paramServiceUrl <paramServiceUrl>                              Parameterize serviceUrl
#   --paramNamedValue <paramNamedValue>                              Parameterize named values
#   --paramApiLoggerId <paramApiLoggerId>                            Specify the loggerId for this api
#   --paramLogResourceId <paramLogResourceId>                        Specify the resourceId for this logger
#   --serviceBaseUrl <serviceBaseUrl>                                Specify the the base url for calling api management
#   -?|-h|--help                                                     Show help information


Break


$apiManagementName = '[your api mgmt instance]'
$rgName = '[your rg where api mgmt instance is provisioned]'
$destinationFolderV04 = 'C:\AppDev\APIMgmt-pepiper-demo-ARM\CoreSampleDemo-Dev-CUS-ARM-Templates-v0.4-delta'
$mutipleAPIs = 'demo-customer-apisvc, demo-sales-apisvc,awsample-cus-befuncapp01'
$policyXMLBaseUrl = '[your Base Url]'

# need to have other parms, but will have some additional overhead with shared entities and ci/cd concurrency management challenges
$splitAPisIntoFiles = $true

# Extracts all APIs (operations, configuration, etc.) into ONE output file:

c:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate.exe extract --sourceApimName $apiManagementName `
                        --destinationApimName $apiManagementName --resourceGroup $rgName `
                        --fileFolder $destinationFolderV04

# Extracts all APIs (operations, configuration, etc.) into Many output files / folders:
c:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate.exe extract --sourceApimName $apiManagementName `
                        --destinationApimName $apiManagementName --resourceGroup $rgName `
                        --fileFolder $destinationFolderV04 --mutipleAPIs $mutipleAPIs --splitAPIs $splitAPisIntoFiles


# ***************************************************************************************************************************

Break


# ***************************************************************************************************************************
# # Try this another way
$apiNames = @('demo-customer-apisvc','demo-sales-apisvc','awsample-cus-befuncapp01')

foreach($apiName in $apiNames)
{

c:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate.exe extract --sourceApimName $apiManagementName `
                        --destinationApimName $apiManagementName --resourceGroup $rgName `
                        --fileFolder $destinationFolderV04 --apiName $apiName
}
Break
# ***************************************************************************************************************************
# ***************************************************************************************************************************


# ***************************************************************************************************************************
# ***************************************************************************************************************************
# Creator 

# reskit-win64-v0.4-delta
$configYML = 'C:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\testAPIconfig-v0.4-delta.yml'
c:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate.exe create --configFile $configYML
 
# reskit-win64-v0.4-delta
c:\AppDev\APIMgmt-pepiper-demo-ARM\APIMgmt_Tools\reskit-win64-v0.4-delta\apimtemplate create --help
# Create an API Management instance from files
# 
# Usage: create [options]
# 
# Options:
#   --configFile <configFile>  Config YAML file location
#   -?|-h|--help               Show help information
#

Break
# ***************************************************************************************************************************
# ***************************************************************************************************************************
