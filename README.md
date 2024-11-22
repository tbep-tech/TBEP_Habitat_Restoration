# TBEP_Habitat_Restoration

This dataset contains a comprehensive list of habitat restoration projects conducted in Tampa Bay and its watershed from 1971 to the present. Records prior to 2006 were compiled during the Tampa Bay Estuary Program's Habitat Master Plan Update (HMP, 2020). Since 2006, habitat restoration data are reported to the Tampa Bay Estuary Program by regional partners and submitted each year to the US Environmental Protection Agency (EPA) through the National Estuary Program Online Reporting Tool (NEPORT) to conform to the Government Performance and Results Act (GPRA). The dataset includes information on each project including name, date, location, restoration activity, habitat type, partner responsible for the project, and approximate coverage. The dataset is updated annually.

The archived dataset is available on KNB at: <https://doi.org/10.5063/F11Z42VZ>

Please see the [sas](https://github.com/tbep-tech/TBEP_Habitat_Restoration/tree/sas) branch for the original SAS code used to clean and merge the two data sources.

The workflow for updating data in this repository that then updates multiple downstream products is shown below.  

```mermaid
flowchart TD
    A[TBEP Partners] -->|Annual Data Entry| B[Smartsheet]
    B --> C[USEPA NEPORT]
    B --> D[GitHub: TBEP_Habitat_Restoration]
    D -->|Update| E[restoration.csv]
    E -->|Import| F[GitHub: habitat-report-card]
    F -->|Generate| G[Quarto HTML]
    G -->|Push| F
    G -->|Manual Extract| H[Habitat Report Card PDF]
    C -->|Approval| I[Final Data]
    E -->|"Email (After Final)"| J[USF Water Atlas]
    E -->|"Run Scripts (After Final)"| K[Data Package with Metadata]
    K -->|Submit| L[KNB Data Archive]
    I -->|Final Corrections| B
    
    classDef repo fill:#427355,stroke:#333,stroke-width:2px
    classDef system fill:#958984,stroke:#333,stroke-width:2px
    classDef file fill:#004F7E,stroke:#333,stroke-width:2px
    classDef output fill:#00806E,stroke:#333,stroke-width:2px
    
    class D,F repo
    class B,C,J,L system
    class E,K file
    class G,H output
```    
