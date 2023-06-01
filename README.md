# TBEP_Habitat_Restoration

This project merged data in the master Habitat Restoration Database (HabitatRestorationTampaBay.csv) pulled together during the Habitat Master Plan Update (2020) and restoration projects entered through NEPORT for GPRA reporting from 2006-2021 (n=521, GPRAformatted.csv). The SAS program (HabitatRestoration_GPRA_merge.sas) creates a cleaned database in which column names were converted to GPRA formatting for consistency, and a few columns were added to crosswalk the restoration projects into the ESA HMPU. ESA categories are incorporated into general activity, general habitat, PrimaryHabitat, and SecondaryHabitat columns. A summary of the column name changes is found in 

After merging 2006-2021 data, 2022 GPRA records (n=39) and pre-2006 Habitat Restoration records (n=195) were added for a total of 755 records in the cleaned database (Habitat_Restoration_Clean.csv).

Unmatched Habitat Restoration records (n=39) were omitted.
