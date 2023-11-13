# TBEP_Habitat_Restoration

The US Environmental Protection Agency (EPA) is required to conform to the Government Performance and Results Act (GPRA). Data for habitat restoration are submitted each year through National Estuary Program Online Reporting Tool (GPRA/NEPORT), as reported by the Tampa Bay Estuary Program.

This project merged data in the master Habitat Restoration Database (HabitatRestorationTampaBay.csv) pulled together during the Habitat Master Plan Update (HMPU, 2020) and restoration projects entered through NEPORT for GPRA reporting from 2006-2021 (n=521, GPRAformatted.csv). The SAS program (HabitatRestoration_GPRA_merge.sas) creates a cleaned database in which column names were converted to GPRA formatting for consistency, and a few columns were added to designate habitats defined in the HMPU. Additional datafields are incorporated into general activity, general habitat, PrimaryHabitat, and SecondaryHabitat columns. A summary of the column name changes is found here: https://docs.google.com/spreadsheets/d/1Jzo8qJEfRz99e2ES5Fx42FZUognHhXNw/edit?usp=sharing&ouid=102375550280551412077&rtpof=true&sd=true

After merging 2006-2021 data, 2022 (n=39) and 2023 (n=71) GPRA habitat records and pre-2006 Habitat Restoration records (n=195) were added for a total of 826 records in the cleaned database (Habitat_Restoration_Clean.csv).

Unmatched Habitat Restoration records (n=39) were omitted.
