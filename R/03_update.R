library(datapack)
library(dataone)
library(here)

# authenticate
token <- Sys.getenv('dataone_token')
options(dataone_token = token)

# prod node for KNB
cn <- CNode('PROD')
mn <- getMNode(cn, 'urn:node:KNB')

# verify credentials authenticated
echoCredentials(cn)

d1c <- D1Client(cn, mn)
packageId <- "resource_map_urn:uuid:e729d64f-bf8b-46c5-8c9c-3b486ae8d4ba"
packageId <- "resource_map_doi:10.5063/F11Z42VZ"

# download complete data package
pkg <- getDataPackage(d1c, identifier = packageId, lazyLoad = TRUE, quiet = FALSE)

# update dataset ------------------------------------------------------------------------------

# get id of data file
newfl <- here('restoration.csv')
objId <- selectMember(pkg, name="sysmeta@fileName", value='restoration.csv')

# update data file
pkg <- replaceMember(pkg, objId, replacement = 'restoration.csv', mediaType = "text/csv")

# update metadata -----------------------------------------------------------------------------

# see https://cran.r-project.org/web/packages/dataone/vignettes/v06-update-package.html

metadataId <- selectMember(pkg, name="sysmeta@formatId", value="eml://ecoinformatics.org/eml-2.1.1")

nameXpath <- '//abstract[text()="The US Environmental Protection Agency (EPA) is required to conform to the Government Performance and Results Act (GPRA). Data for habitat restoration are submitted each year through the National Estuary Program Online Reporting Tool (GPRA/NEPORT), as reported by the Tampa Bay Estuary Program. This dataset is a comprehensive list of restoration projects in Tampa Bay and its watershed from 1971 to present as reported through GPRA/NEPORT.  The dataset includes information on the project name, date, location, restoration activity, habitat type, partner responsible for the project, and approximate coverage.  The dataset is updated annually."]'

newAbstract <- 'Data include habitat restoration projects conducted in Tampa Bay and its watershed from 1971 to the present. Records prior to 2006 were compiled during the Tampa Bay Estuary Program’s Habitat Master Plan Update (HMP, 2020). Since 2006, habitat restoration data are reported to the Tampa Bay Estuary Program by regional partners and submitted each year to the US Environmental Protection Agency (EPA) through the National Estuary Program Online Reporting Tool (NEPORT) to conform to the Government Performance and Results Act (GPRA). The dataset includes information on the project name, date, location, restoration activity, habitat type, partner responsible for the project, and approximate coverage.  The dataset is updated annually.'

pkg <- updateMetadata(pkg, metadataId, xpath = nameXpath, replacement = newAbstract)

# update package ------------------------------------------------------------------------------

uploadDataPackage(d1c, pkg, public = TRUE, quiet = FALSE)
