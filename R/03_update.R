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
packageId <- "urn:uuid:eee9d916-8be7-4feb-8bda-58491bf58b82"

# download complete data package
pkg <- getDataPackage(d1c, identifier = packageId, lazyLoad = FALSE, quiet = FALSE)

# update dataset ------------------------------------------------------------------------------

# get id of data file
newfl <- here('restoration.csv')
objId <- selectMember(pkg, name="sysmeta@fileName", value='restoration.csv')

# import old data
origObj <- getMember(pkg, objId)
origData <- getData(origObj)  # This will work
origDF <- read.csv(text=rawToChar(origData))

# update data file
pkg <- replaceMember(pkg, objId, replacement = 'restoration.csv', mediaType = "text/csv")

# import new data
objId <- selectMember(pkg, name="sysmeta@fileName", value='restoration.csv')
updtObj <- getMember(pkg, objId)
updtData <- getData(updtObj)  # This will work
updtDF <- read.csv(text=rawToChar(updtData))

# verify a difference
cat("Original dimensions:", dim(origDF), "\n")
cat("Updated package dimensions:", dim(updtDF), "\n")

# update metadata -----------------------------------------------------------------------------

# see https://cran.r-project.org/web/packages/dataone/vignettes/v06-update-package.html

# get the metadata object identifier
metadataId <- selectMember(pkg, name="sysmeta@formatId", value="https://eml.ecoinformatics.org/eml-2.2.0")

# get old date
metadataBytes <- getData(pkg, metadataId)
metadata_xml <- xml2::read_xml(metadataBytes)
dtold <- xml2::xml_find_all(metadata_xml, "//temporalCoverage/rangeOfDates/endDate/calendarDate")

# define the XPath to the end date element
endDateXpath <- "//temporalCoverage/rangeOfDates/endDate/calendarDate"

# define the new end date value
newEndDate <- "2024-12-31"

# update the metadata using updateMetadata function
pkg <- updateMetadata(pkg, metadataId, xpath=endDateXpath, replacement=newEndDate)

# get new date
metadataId <- selectMember(pkg, name="sysmeta@formatId", value="https://eml.ecoinformatics.org/eml-2.2.0")
metadataBytes <- getData(pkg, metadataId)
metadata_xml <- xml2::read_xml(metadataBytes)
dtnew <- xml2::xml_find_all(metadata_xml, "//temporalCoverage/rangeOfDates/endDate/calendarDate")

# verify differenct
cat("Old end date:", xml2::xml_text(dtold), "\n")
cat("New end date:", xml2::xml_text(dtnew), "\n")

# update package ------------------------------------------------------------------------------

uploadDataPackage(d1c, pkg, public = TRUE, quiet = FALSE)
