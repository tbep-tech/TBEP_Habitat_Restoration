* Clear log and output windows;

dm'log;clear;output;clear';

* Set location of input database;
%let nm1=HabRes;
%let nm2=GPRAcomb;
%let loc=F:\.shortcut-targets-by-id\1jYjIgneYtTSpOc7mJxc0luTPyv-QCGjj\TBEP_GENERAL\01_Program_Guidance\HMPU_2020\Tracking_HMPU\;
*Habitat Restoration database;
%let file1=HabitatRestorationTampaBay.csv;
*GPRA database, 2006-2022;
%let file2=GPRAformatted.csv;
*station imports for mapping (only need for BRUVs);
*Import diversity data;
PROC IMPORT
DATAFILE="&loc.&file1"
OUT=WORK.&nm1
DBMS=csv
REPLACE;
run;
PROC IMPORT 
OUT=WORK.&nm2
		DATAFILE="&loc.&file2"
		DBMS=csv
		REPLACE;
Run;
