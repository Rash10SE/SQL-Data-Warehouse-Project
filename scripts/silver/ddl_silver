/*
===============================================================================
SILVER LAYER - DDL: CREATE TABLES
===============================================================================

Purpose:
    This script creates the required tables in the Silver Layer of the
    Data Warehouse.

Description:
    - Drops existing Silver Layer tables if they already exist.
    - Creates new tables with standardized column names and appropriate
      data types.
    - Prepares the database structure for cleaned and transformed data.
    - Adds a metadata column (dwh_create_date) to track when records
      are loaded into the Data Warehouse.

Tables Created:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

Metadata:
    - dwh_create_date:
        Automatically stores the date and time when a record is inserted.
        Uses DEFAULT GETDATE() to capture the loading timestamp.

Technical Details:
    - IF OBJECT_ID() checks whether a table already exists.
    - DROP TABLE removes existing tables before recreation.
    - NVARCHAR is used for Unicode-compatible text storage.
    - DATE and DATETIME2 are used for date and timestamp values.
    - No primary keys or additional constraints are defined.

Important Notes:
    - The Silver Layer stores cleaned, standardized, and transformed data.
    - Data cleansing and transformation logic will be implemented during
      the loading process.
    - Existing data is removed whenever this DDL script is executed.

===============================================================================
*/

-- SILVER LAYER || DDL CREATE TABLES
-- CREATE TABLE cust_info
IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- Metadata-Spalte: sie stammt nicht aus der Quelldatei, sie gehöhrt nur zum DWH. Sie speichert automatisch wann eine Zeile ins DWH geladen wurde.
);

-- CREATE TABLE prd_info
IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- CREATE TABLE sales_details
IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- CREATE TABLE cust_az12
IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- CREATE TABLE loc_a101
IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- CREATE TABLE px_cat_g1v2
IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
