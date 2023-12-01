library(dataone)
library(datapack)
library(uuid)
library(here)

# dataone vignettes here https://cran.r-project.org/web/packages/dataone/index.html

# authenticate
token <- Sys.getenv('dataone_token')
options(dataone_token = token)

# prod node for KNB
cn <- CNode('PROD')
mn <- getMNode(cn, 'urn:node:KNB')

# # staging/test node for KNB
#
# # authenticate
# token <- Sys.getenv('dataone_test_token')
# options(dataone_test_token = token)
#
# cn <- CNode('STAGING')
# mn <- getMNode(cn, 'urn:node:mnTestKNB')

# verify credentials authenticated
echoCredentials(cn)

# initiate data package
dp <- new('DataPackage')

# xml metadata file
emlFile <- here('restorationdat.xml')
doi <- generateIdentifier(mn, 'DOI')
metadataObj <- new('DataObject', id = doi, format = 'eml://ecoinformatics.org/eml-2.1.1', filename = emlFile)
dp <- addMember(dp, metadataObj)

# csv file, add to data package
sourceObj <- new('DataObject', format='csv', filename = here('restoration.csv'))
dp <- addMember(dp, sourceObj, metadataObj)

# set my access rules
myAccessRules <- data.frame(subject = 'https://orcid.org/0000-0002-4996-0059', permission = 'changePermission')

# id member node, upload
cli <- D1Client(cn, mn)
packageId <- uploadDataPackage(cli, dp, public = TRUE, accessRules = myAccessRules, quiet = FALSE)
message(sprintf('Uploaded package with identifier: %s', packageId))

##
# # update metadata
# cn <- CNode("PROD")
# mn <- getMNode(cn, "urn:node:KNB")
# sysmeta <- getSystemMetadata(mn, doi)
# sysmeta <- addAccessRule(sysmeta, "public", "read")
# status <- updateSystemMetadata(mn, doi, sysmeta)
