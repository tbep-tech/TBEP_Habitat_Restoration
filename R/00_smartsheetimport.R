# remotes::install_github('fawda123/rsmartsheet'))
library(rsmartsheet)
library(dplyr)

# smartsheet import ---------------------------------------------------------------------------

smrkey <- Sys.getenv("smartsheets_key")
set_smartsheet_api_key(smrkey)

gpraraw <- get_sheet_as_csv('TBEP_NEPORT_Restoration_Data') %>% 
  textConnection %>% 
  read.table(sep = ',', header = T, na.strings = 'N/A')

# select only status 'Entered'
# rename existing columns to those in restoration.csv
# create placeholder columns in restoration.csv not present
# convert PrimaryHabitat to correct HMPU fields (should be some misc entries)
# create GeneralHabitat from PrimaryHabitat
# remove Miles for debris removal maintenace
# select columns in correct order
gpra <- gpraraw %>% 
  filter(Status == 'Entered') %>% 
  rename(
    Federal_Fiscal_Year = Federal.Fiscal.Year,
    Project_Name = Project.Name,
    Project_Description = Project.Description,
    Habitat_Description = Brief.Habitat.Description,
    Habitat_Type = Habitat.Type,
    Restoration_Technique = Restoration.Technique,
    Donated_Land = Donated.Land.at.no.cost,
    Total_Project_Cost = Total.Project.Cost,
    Project_Benefits = Project.Benefits,
    GeneralActivity = Activity,
    Lead_Implementer = Lead.Partner.Implementer,
    Partners = Other.Partners,
    Main_Funding_Source = Main.Funding.Source,
    Site_Owner = Site.Ownership,
    Miles = Linear.Miles,
    Feet = Linear.Feet,
    PrimaryHabitat = Primary.Habitat
  ) %>% 
  mutate(
    Region = 'Region 4',
    State_Code = 'FL',
    NEP_Name = 'Tampa Bay Estuary Program',
    Data_Unavailable = NA_character_,
    Last_Updated_Date = NA_character_,
    NEP_Comments = NA_character_,
    HQ_Comments = NA_character_,
    HQ_Status = NA_character_,
    Region_Status = NA_character_,
    Author = NA_character_,
    Submitter_Email = NA_character_,
    SecondaryHabitat = NA_character_,
    EPA_Section_320 = NA_real_,
    ID_Number = NA_character_,
    Activity_Name = GeneralActivity,
    PrimaryHabitat = case_when(
      PrimaryHabitat %in% c('Agriculture/Ranch Land/Riparian', 'Agriculture/Ranch Land', 'Forest/Woodland', 'Grassland') ~ 'Uplands (Non-coastal)',
      PrimaryHabitat %in% c('Shell Bottom') ~ 'Oyster Bars', 
      PrimaryHabitat %in% c('Forested Wetland') ~ 'Forested Freshwater Wetlands',
      T ~ PrimaryHabitat
    ),
    GeneralHabitat = case_when(
      PrimaryHabitat %in% c("Artificial Reefs", "Intertidal Estuarine (Other)", 
                            "Seagrasses", "Mangrove Forests", "Tidal Flats", 
                            "Tidal Tributaries", "Oyster Bars", 
                            "Living Shorelines") ~ "Estuarine",
      PrimaryHabitat %in% c("Non-forested Freshwater Wetlands", 
                            "Forested Freshwater Wetlands") ~ "Freshwater",
      PrimaryHabitat %in% c("Coastal Uplands", "Uplands (Non-coastal)") ~ "Uplands", 
      T ~ 'Mixed'
    ), 
    Miles = case_when(
      GeneralActivity %in% 'Maintenance' & Restoration_Technique %in% 'Debris Removal' ~ NA_real_,
      T ~ Miles
    )
  ) %>%
  select(
    View_Detail, 
    Federal_Fiscal_Year, 
    Region, 
    State_Code, 
    NEP_Name, 
    Project_Name, 
    Project_Description, 
    Habitat_Description, 
    Habitat_Type, 
    Restoration_Technique, 
    Donated_Land, 
    Data_Unavailable, 
    Total_Project_Cost, 
    Project_Benefits, 
    Activity_Name, 
    Lead_Implementer, 
    Partners, 
    Main_Funding_Source, 
    Site_Owner, 
    Last_Updated_Date, 
    NEP_Comments, 
    HQ_Comments, 
    HQ_Status, 
    Region_Status, 
    Author, 
    Submitter_Email, 
    PrimaryHabitat, 
    SecondaryHabitat, 
    EPA_Section_320, 
    Acres, 
    Miles, 
    Latitude, 
    Longitude, 
    Feet, 
    ID_Number, 
    GeneralHabitat,
    GeneralActivity, 
    BeforePhotoCredit, 
    BeforePhotoCaption, 
    DuringPhotoCredit, 
    DuringPhotoCaption, 
    AfterPhotoCredit, 
    AfterPhotoCaption
  )

# add to pre-smartsheet entries ---------------------------------------------------------------

# read original
orig <- read.csv(here::here('data-raw/restoration-noedit.csv'), stringsAsFactors = F)  

# add smartsheet to original
restoration <- bind_rows(orig, gpra)

write.csv(restoration, here::here('restoration.csv'), row.names = F)
