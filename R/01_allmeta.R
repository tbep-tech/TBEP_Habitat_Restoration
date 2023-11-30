library(EML)
library(emld)
library(tidyverse)
library(readr)

# character columns need definition (in attributes)
# numeric needs unit and numbertype (see EML::get_unitList()$units) (in attributes)
# factors need to be defined (in attribute list)

# same attributes for each file ---------------------------------------------------------------

# get attributes, factors, and col classes

hab <- read_csv('restoration.csv')
attributes <- read_csv('attributes.csv')

fcts <- attributes %>% 
  filter(DataType == 'factor') %>% 
  pull(attributeName) 
factors <- hab %>% 
  select(any_of(fcts)) %>% 
  pivot_longer(everything(), names_to = 'attributeName', values_to = 'code') %>% 
  unique() %>% 
  mutate(
    definition = code,
    attributeName = factor(attributeName, levels = fcts)
  ) %>% 
  filter(code != '') %>% 
  arrange(attributeName, code)

col_classes <- attributes$DataType
attributes <- attributes %>% 
  select(-DataType)
attributeList <- set_attributes(attributes, factors = factors, col_classes = col_classes)

physical <- set_physical("restoration.csv")

restTable <- list(
  entityName = "restoration.csv",
  entityDescription = "Restoration Projects in Tampa Bay and its Watershed",
  physical = physical,
  attributeList = attributeList)  
  
# universal metadata for all files ----------------------------------------

geographicDescription <- "Tampa Bay and its watershed, Florida, USA"

coverage <- set_coverage(
  begin = '1971-01-01',
  end = '2023-12-31',
  geographicDescription = geographicDescription,
  west = -82.83925,
  east = -81.95060,
  north = 28.28700,
  south = 27.23300
)

R_person <- person(given = "Marcus", family = "Beck", email = "mbeck@tbep.org", comment = c(ORCID = "0000-0002-4996-0059"))
mbeck <- as_emld(R_person)
HF_address <- list(
  deliveryPoint = "263 13th Ave South",
  city = "St. Petersburg",
  administrativeArea = "FL",
  postalCode = "33701",
  country = "USA")
publisher <- list(
  organizationName = "Tampa Bay Estuary Program",
  address = HF_address)
contact <- list(
  individualName = mbeck$individualName,
  electronicMailAddress = mbeck$electronicMailAddress,
  address = HF_address,
  organizationName = "Tampa Bay Estuary Program",
  phone = "(727) 893-2765"
)

keywordSet <- list(
  list(
    keywordThesaurus = "Tampa Bay vocabulary",
    keyword = list("enhancement",
                   "GPRA",
                   "protection",
                   "restoration",
                   "watershed"
    )
  ))

title <- "Restoration Projects in Tampa Bay and its Watershed"

abstract <- 'Data include habitat restoration projects conducted in Tampa Bay and its watershed from 1971 to the present. Records prior to 2006 were compiled during the Tampa Bay Estuary Program’s Habitat Master Plan Update (HMP, 2020). Since 2006, habitat restoration data are reported to the Tampa Bay Estuary Program by regional partners and submitted each year to the US Environmental Protection Agency (EPA) through the National Estuary Program Online Reporting Tool (NEPORT) to conform to the Government Performance and Results Act (GPRA). The dataset includes information on the project name, date, location, restoration activity, habitat type, partner responsible for the project, and approximate coverage.  The dataset is updated annually.'

intellectualRights <- 'This dataset is released to the public and may be freely downloaded. Please keep the designated contact person informed of any plans to use the dataset. Consultation or collaboration with the original investigators is strongly encouraged. Publications and data products that make use of the dataset must include proper acknowledgement.'

# combine the metadata
dataset <- list(
  title = title,
  creator = mbeck,
  intellectualRights = intellectualRights,
  abstract = abstract,
  keywordSet = keywordSet,
  coverage = coverage,
  contact = contact,
  dataTable = restTable
)

eml <- list(
  packageId = uuid::UUIDgenerate(),
  system = "uuid", # type of identifier
  dataset = dataset)

# write and validate the file
write_eml(eml, "restorationdat.xml")
eml_validate("restorationdat.xml")
