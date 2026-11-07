/*
===============================================================================
  Script:       init_database.sql
  Description:  Initializes the SQL Data Warehouse environment.
                Creates the DataWarehouseProject database and the three schemas
                required for the Medallion Architecture.

  Database:     DataWarehouseProject

  Schemas:
      - bronze: Stores raw data from source systems (ERP and CRM).
      - silver: Stores cleaned, standardized, and transformed data.
      - gold:   Stores business-ready data for reporting and analytics.

  Author:       Rachid Ez-Ziani
  Created:      07.11.2026
===============================================================================
*/

-- Switch to the system database to create the new database
USE master;
GO

-- Create the Data Warehouse database
CREATE DATABASE DataWarehouseProject;
GO

-- Switch to the newly created database
USE DataWarehouseProject;
GO

-- Create Bronze Layer: Raw data
CREATE SCHEMA bronze;
GO

-- Create Silver Layer: Cleaned and transformed data
CREATE SCHEMA silver;
GO

-- Create Gold Layer: Business-ready data for analytics
CREATE SCHEMA gold;
GO
