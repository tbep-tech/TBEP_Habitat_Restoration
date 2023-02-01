* Clear log and output windows;

dm'log;clear;output;clear';

* Set location of input databases;
%let nm1=HabRes;
%let nm2=GPRAcomb;
%let loc=F:\.shortcut-targets-by-id\1jYjIgneYtTSpOc7mJxc0luTPyv-QCGjj\TBEP_GENERAL\01_Program_Guidance\HMPU_2020\Tracking_HMPU\;
*Habitat Restoration database;
%let file1=HabitatRestorationTampaBay.csv;
*GPRA database, 2006-2022;
%let file2=GPRAformatted.csv;
**************************************************************************
Data imports
*************************************************************************;
*Import full habitat restoration data file;
PROC IMPORT
DATAFILE="&loc.&file1"
OUT=WORK.&nm1
DBMS=csv
REPLACE;
run;
*Import GPRA data (2006-2022);
PROC IMPORT 
OUT=WORK.&nm2
		DATAFILE="&loc.&file2"
		DBMS=csv
		REPLACE;
Run;
