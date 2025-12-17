EDW Extractor User Guide

A Guide for Using the EDW Extractor v2.0 – LIMITED to Extractor Installation & EDW Connection

1. Overview

The purpose of this guide is to document the installation instructions for the Costing Extractor V2, to test that a successful connection to the Enterprise Data Warehouse (EDW) can be achieved, and ensuring the Extractor process runs to produce output files. While the Extractor v2 has been redeveloped in Python to support both HIE and EDW connections, this testing phase focuses solely on the connection to EDW. This document will be expanded to include usage details in due course.

2. Getting Started – Extractor Installation

2.1 Pre-requisites

Before downloading and running the application, ensure the following requirements are met:

System Requirements:

RAM: Minimum 4 GB, preferably 8 GB.

Processor: Minimum 1GHz.

OS: 64-bit Windows 10 OS.

Disk space: Up to 250GB (Upper limit based on output dataset size, determined by LHD size and data volume).

Driver: ODBC 64bit Driver.

SMTP: Required for receipt of AMHCC flat file (LHDs/SHNs only), though AMHCC data extraction may become available directly from EDW.

Datawarehouse Access:

User access to EDW LRS FLAT schemas (Production environments), known as the State LRS (MOH LRS).

Access is granted via the Data Warehouse Unit (DWU).

Request forms are available at EDW (nsw.gov.au); note that patient level data access is required.

Lead time for access is usually a minimum of 2 weeks.

Costing Collaborative Space Access:

This is the ABM secured network space where the Extractor v2 executable is located.

Access requests should be directed to Kylie Hawkins, Manager, Clinical Cost Data Collections and Standards (kylie.hawkins2@health.nsw.gov.au).

2.2 Download & Unzip Extractor v2 Executable

Navigate to the Costing Collaborative Space > EDW Extractor Testing folder to download the Extractor v2 zip file. This folder also contains this User Guide and a Checklist.

Download the zip file (approx. 250MB) to your desired run location (e.g., D:\).

Unzip the contents. This will create a high-level folder named costing_extractor containing all necessary sub-folders and files.

2.3 Extractor v2 Folder Structure

Upon unzipping, the directory structure typically appears as follows:

costing_extractor

build

extractor

dist

extractor

Build Folder

The ..\costing_extractor\build\extractor folder contains analysis results and additional logs. Its contents can generally be ignored unless debugging is required.

Dist Folder

The ..\costing_extractor\dist\extractor folder contains the executable application, libraries, and binary .dll files required to run the Extractor.

Key files that must not be moved or modified include:

Config File: config.ini (stores details of previous runs to save input parameters).

Logo: hssg_logo.jpg (used for the splash screen).

Important Sub-folders:

Costing: (..\costing_extractor\dist\extractor\Costing)

Contains input files provided by the ABM Costing team and specific LHD input files.

Files include AMHCC_Extract, CriticalCareGroup, DRGStandardWeights, RoundDetails.csv, SNAP_CostingExtract, and others.

Update the RoundDetails.csv parameter file here if needed. Note that some files in this folder are reserved for ABM Costing Team modification only.

ExtractorDB: (..\costing_extractor\dist\extractor\ExtractorDB)

Contains the Extractor database where EDW data is loaded, along with flat files for post-processing.

Staging files here should not be modified.

Output: (..\costing_extractor\dist\extractor\Output)

Populated with generated files upon completion of the Extractor run.

Note: Files are overwritten with each run; copy them to a different location to retain them.

Event Log: (..\costing_extractor\dist\extractor\python_costing_extractor_log.txt)

Generated each run to record processing details and aid in debugging failures.

The log shows timestamps and events such as "STARTING COSTING EXTRACTOR," "Import modules completed," and connection string details.

This file is overwritten each time the application runs.

3. Running the Extractor

Launch: Navigate to ..\costing_extractor\dist\extractor and double-click the extractor application icon (Type: Application, approx. 17,952 KB).

Splash Screen: A screen displaying the NSW Health System Support Group logo will appear indicating the utility is starting.

Start: On the main interface ("Data Extraction Utility for PPM2"), click the Start Extractions button located on the left side.

Validation: The program checks for file presence and verifies that the SNAPRec count matches the SNAP extract files.

If SNAP or AMHCC files are missing, the Extractor will continue without them.

A "SNAP Variance" popup will appear (e.g., "The variance between the SNAP Costing Extract File and the SNAP Report = 0"). Click OK.

Select Source: A "Select Source" popup will appear. Choose EDW and click Select.

Confirmation: You should receive a "Login Success" message stating "Login to EDW is successful".

Important Note on the Console Window:
A black console window will open alongside the application. This window displays errors not captured in the log file. If the application fails, take a screenshot of any error messages in this console window to send to support.

4. Troubleshooting

4.1 Unable to Connect to EDW

Connection failures often stem from missing access to the Production environment (Pre-production access is insufficient) or incorrect ODBC driver setup.

If you receive an error stating "You do not have any 64 bit drivers installed in this machine. Please install 64bit driver to proceed," you must configure the driver.

4.1.1 Configuring ODBC Driver for EDW

Open ODBC Admin: In Windows Search, type "ODBC Data Sources (64-bit)" or "ODBC Administrator" and select the App.

Permissions: If a "System DSN Warning" appears regarding non-Administrative privileges, click OK.

Add DSN: Select the User DSN tab and click Add....

Select Driver: Choose SQL Server from the list of drivers and click Finish.

Configure:

Name: LRS_MOH_PROD

Server: AZMHEDW-P01UDM.NSWHEALTH.NET

Click Next.

Authentication: Select "With Windows NT authentication using the network login ID" and click Next.

If access is denied: You will see a "Connection failed" message (SQL State '28000', Error 18456). Click OK and resolve your EDW access via a SARA ticket.

Database: If authenticated, change the default database to LRS_MOH. Click Next then Finish.

Test: Click Test Data Source.... A successful connection will display "TESTS COMPLETED SUCCESSFULLY!".

Run: When running the Extractor, select ODBC and use the Data Source Name you just configured (LRS_MOH_PROD).

4.2 Slow to Extract Data from EDW

Data extraction may take several hours. This is expected as EDW is a new solution and performance analysis is ongoing.
