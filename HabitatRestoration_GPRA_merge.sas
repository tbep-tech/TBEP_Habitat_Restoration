**************************************************************************
Program: HabitatRestoration_GPRA_merge.sas

Purpose: Data cleaning and merge of historical habitat restoration data 
and GPRA data up to 2022. Kept GPRA column names when possible to stay 
consistant with NEPORT EPA database.

Author: Kerry Flaherty Walia;
**************************************************************************;
Clear log and output windows;

dm'log;clear;output;clear';

*Set location of input databases;
%let nm1=HabRes;
%let nm2=GPRAcomb;
%let nm3=matches;
%let loc=F:\.shortcut-targets-by-id\1jYjIgneYtTSpOc7mJxc0luTPyv-QCGjj\TBEP_GENERAL\01_Program_Guidance\HMPU_2020\Tracking_HMPU\Habitat Restoration Data Cleaning\;
*Habitat Restoration database;
%let file1=HabitatRestorationTampaBay.csv;
*GPRA database, 2006-2022;
%let file2=GPRAformatted.csv;
*Matches;
%let file3=GPRA_HabRes_matchup.csv;
*output clean file;
%let clean=Habitat_Restoration_Clean.csv;
**************************************************************************
Data imports
*************************************************************************;
*Import full habitat restoration data file;
PROC IMPORT
DATAFILE="&loc.&file1"
OUT=WORK.&nm1
DBMS=csv REPLACE;
GUESSINGROWS=700;
run;
*Import GPRA data (2006-2022);
PROC IMPORT DATAFILE="&loc.&file2"
OUT=WORK.&nm2
DBMS=csv REPLACE;
GUESSINGROWS=600;		
Run;
*Import matching table;
PROC IMPORT DATAFILE="&loc.&file3"
OUT=WORK.&nm3
DBMS=csv REPLACE;
GUESSINGROWS=600;		
Run;
*** FORMATTING HABITAT RESTORATION DATABASE, SEPARATING INTO PROJECTS 2006-2022 (HABRES2) AND <2006 (HABRES1) FOR MATCHING WITH GPRA DATA;
data habres2; set &nm1;
if Federal_Fiscal_Year > 2005;
if miles=. and feet ne . then do;
miles=feet/5280;
if ID_number='LS-082' then Federal_Fiscal_Year='2019';
if ID_number='R-161' then delete; *project covered in GPRA by R-160;
end;
proc sort data=habres2; by Federal_Fiscal_Year Project_name;
run;
data habres1; set &nm1;
if Federal_Fiscal_Year <=2005;
drop var39 var40 var41 var42;
run;
proc sort data=habres1; by Federal_Fiscal_Year Project_Name ;
run;
data match; set matches;
project_name=habres_project_name;
drop habres_project_name;
run; 
proc sort data=match; by Federal_Fiscal_Year Project_name;
run;
data habres_test; merge habres2 match (in=x); by Federal_Fiscal_Year project_name;
if x;
change_name='YES';
drop project_name;
run;
data habres_correct; set habres_test;
project_name=GPRA_Project_name;
keep GPRA_Project_name Federal_Fiscal_Year change_name ID_number;
run;
proc sort data=habres_correct; by ID_number;
run;
proc sort data=habres2; by ID_number;
run;
data habres3; merge habres2 (in=x) habres_correct; by ID_number;
if x;
if first.ID_number;
if change_name='YES' then do;
Project_name=GPRA_Project_Name;
end;
drop change_name TBEP_notes GPRA_Project_Name;
run;
proc sort data=habres3; by Federal_Fiscal_Year Project_name;
run;
*** FORMATTING GPRA for merging;
data GPRA1; set &nm2;
Acres1=Acres+0;
Miles1=Miles+0;
Latitude1=Latitude+0;
Longitude1=Longitude+0;
Feet1=Feet+0;
drop View_Photos Map Count drop acres miles feet latitude longitude var39 var40 var41 var42;
run;
data GPRA2; set GPRA1;
Acres=Acres1;
Miles=Miles1;
Latitude=Latitude1;
Longitude=Longitude1;
Feet=Feet1;
if feet=0 then feet=.;
if acres=0 then acres=.;
if miles=0 then miles=.;
if miles=. and feet ne . then do;
miles=feet/5280;
end;
drop acres1 miles1 latitude1 longitude1 feet1;
run;
data GPRA; set GPRA2;
if Federal_Fiscal_Year not in (2022);
run;
proc sort; by Federal_Fiscal_Year Project_Name View_Detail;
run;
data GPRA_2022; set GPRA2;
if Federal_Fiscal_Year=2022;
run;
proc sort data=GPRA_2022; by Federal_Fiscal_Year Project_Name View_Detail;
run;
*Clean first merge of databases based on GPRA entries/one to one;
data hab_merge1; merge GPRA (in=x) habres3; by federal_fiscal_year Project_name; if x;
*if id_number ne ' ';
run;
proc sort data=hab_merge1; by View_Detail;
run;
data hab_merge; set hab_merge1; by View_Detail;
if first.View_Detail;
Run;
PROC SORT DATA=hab_merge DUPOUT=hab_merge_NoDupRecs NODUPRECS ; BY federal_fiscal_year project_name ; RUN ;
*unmatched GPRA entries; 
data unmatched_GPRA; merge GPRA (in=x) habres3; by federal_fiscal_year Project_name; if x;
if id_number = ' ';
run;
PROC SORT DATA=unmatched_GPRA DUPOUT=GPRA_NoDupRecs NODUPRECS ; BY federal_fiscal_year project_name ; RUN ;
proc sort data=unmatched_GPRA; by federal_fiscal_year acres;
run;
*habres records not matched in GPRA;
data unmatched_habres; merge GPRA habres3 (in=x); by federal_fiscal_year Project_name; if x;
if view_detail=.;
run;
PROC SORT DATA=unmatched_habres DUPOUT=habres_NoDupRecs NODUPRECS ; BY federal_fiscal_year project_name ; RUN ;
proc sort data=unmatched_habres; by federal_fiscal_year acres;
run;
*Trying to match by acres and miles - zero additional matches;
data hab_merge_acres; merge unmatched_habres unmatched_GPRA (in=x); by Federal_Fiscal_Year acres; if x;
if acres ne .;
if id_number ne ' ';
run;
proc sort data=unmatched_habres; by Federal_Fiscal_Year miles;
run;
proc sort data=unmatched_gpra; by Federal_Fiscal_Year miles;
run;
data hab_merge_miles; merge unmatched_habres unmatched_GPRA (in=x); by Federal_Fiscal_Year miles; if x;
if miles ne . and acres=.;
if id_number ne ' ';
run;
data hab_check1; set hab_merge;
*if generalactivity=' ';
*if generalhabitat=' ';
if primaryhabitat=' ';
run;
data hab_comb; set hab_merge GPRA_2022 habres1;
*working on filling in empty cells;
State_code='FL';
Region='Region 4';
NEP_name='Tampa Bay Estuary Program';
if view_detail in (1575,5558,1581) then primaryhabitat="Non-forested Freshwater Wetlands";
if view_detail =1246 then primaryhabitat="Coastal Uplands";
if view_detail =19602 then primaryhabitat="Intertidal Estuarine (Other)";
if view_detail =3055 then primaryhabitat="Other";
if view_detail=1574 then generalactivity="Restoration";
/*if view_detail=. then do;
view_detail=ID_number;
end;*/
if Habitat_type="Other" then generalhabitat="Other";
if generalactivity=' ' then do;
if Activity_name in ('Establishment','Reestablish','Rehabilitation','Restoration') then generalactivity='Restoration';
else if Activity_name in ('Enhancement','Maintenance') then generalactivity='Enhancement';
end;
if generalhabitat=' ' then do;
if PrimaryHabitat in ('Hard Bottom','Artificial Reefs','Tidal Flats','Seagrasses','Oyster Bars','Low-Salinity Salt Marsh','Intertidal Estuarine (Other)','Mangrove Forests') then generalhabitat='Estuarine';
else if PrimaryHabitat in ('Non-forested Freshwater Wetlands','Forested Freshwater Wetlands') then generalhabitat='Freshwater';
else if PrimaryHabitat in ('Coastal Uplands','Uplands (Non-coastal)') then generalhabitat='Uplands';
else if PrimaryHabitat in ('Living Shorelines','Tidal Tributaries') then generalhabitat='Mix (estuarine and freshwater)';
else if PrimaryHabitat in ('Salt barrens') then generalhabitat='Mix (estuarine and upland)';
*if PrimaryHabitat in () then generalhabitat='Mix (estuarine, freshwater, and upland)';
*if PrimaryHabitat in () then generalhabitat='Mix (freshwater and upland)';
end;
drop Total_Cost TBEP_notes;
run;
proc sort data=hab_comb; by federal_fiscal_year project_name view_detail;
run;

data hab_check; set hab_comb;
*if generalactivity=' ';
*if generalhabitat=' ';
if primaryhabitat=' ';
run;

proc sort; by federal_fiscal_year project_name;
run;
PROC EXPORT data=hab_comb 
    outfile="&loc.&clean"
    dbms=csv
    replace;
run;

