/*
===============================================================================
SILVER LAYER - LOAD DATA (FULL LOAD: TRUNCATE & INSERT)
===============================================================================

Purpose:
    Loads, cleanses, transforms, and standardizes raw data from the Bronze
    Layer into the Silver Layer.

Procedure:
    silver.load_silver

Process:
    - Truncates existing Silver Layer tables before loading.
    - Removes duplicate records and unwanted spaces.
    - Standardizes customer, product, gender, and country values.
    - Handles NULL, invalid, and inconsistent data.
    - Converts and validates date formats.
    - Applies business rules and data quality checks.
    - Calculates individual and total loading durations.

Error Handling:
    - Uses TRY...CATCH to capture and display errors.

Execution:
    EXEC silver.load_silver;

===============================================================================
*/

-- SILVER LAYER || TRUNCATING TABLES & INSERTING DATA
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_date DATETIME, @end_date DATETIME, @batch_start_date DATETIME, @batch_end_date DATETIME
    BEGIN TRY
        PRINT '===============================================================';
        PRINT 'Loading Silver Layer!';
        PRINT '===============================================================';
        PRINT '---------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------';
        SET @batch_start_date = GETDATE();
-- TABLE: crm_cust_info
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info(cst_id,
                                         cst_key,
                                         cst_firstname,
                                         cst_lastname,
                                         cst_marital_status,
                                         cst_gndr,
                                         cst_create_date)
        SELECT cst_id,
               cst_key,
               TRIM(cst_firstname) AS cst_firstname,
               TRIM(cst_lastname)  AS cst_lastname,
               CASE -- Data Normalization/Standardization
                   WHEN TRIM(cst_marital_status) = 'M' THEN 'Married'
                   WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
                   ELSE 'n/a'
                   END                cst_marital_status, -- Normalize Marital Status to readable format.
               CASE
                   WHEN TRIM(cst_gndr) = 'M' THEN 'Male'
                   WHEN TRIM(cst_gndr) = 'F' THEN 'Female'
                   ELSE 'n/a'
                   END                cst_gndr,           -- Normalize Gender Values to readable format.
               cst_create_date
        FROM (SELECT *,
                     ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS WithoutDuplicates -- Remove Duplicates
              FROM bronze.crm_cust_info
              WHERE cst_id IS NOT NULL) t
        WHERE WithoutDuplicates = 1; -- Data Filtering - Select the most recent record per Customer.
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';

-- TABLE: crm_prd_info
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (prd_id,
                                         cat_id,
                                         prd_key,
                                         prd_nm,
                                         prd_cost,
                                         prd_line,
                                         prd_start_dt,
                                         prd_end_dt)
        SELECT prd_id,
               REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')                                            AS cat_id,       -- EXTRACT Category ID
               SUBSTRING(prd_key, 7, LEN(prd_key))                                                    AS prd_key,      -- EXTRACT Product Key
               TRIM(prd_nm)                                                                           AS prd_nm,       -- REMOVE unwanted Spaces
               ISNULL(prd_COST, 0)                                                                    AS prd_cost,     -- Replace NULL-Values with 0
               CASE -- Data Normalization: Make Product Line more readable
                   WHEN TRIM(prd_line) = 'M' THEN 'Mountain'
                   WHEN TRIM(prd_line) = 'R' THEN 'Road'
                   WHEN TRIM(prd_line) = 'S' THEN 'Other Sales'
                   WHEN TRIM(prd_line) = 'T' THEN 'Touring'
                   ELSE 'n/a'
                   END                                                                                   prd_line,
               CAST(prd_start_dt AS DATE)                                                             AS prd_start_dt, -- Data Typ Casting: Change Data typ to DATE
               CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt    -- Data Enrichment: Calculate End Date as One Day before the next Start Date.
        FROM bronze.crm_prd_info;
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';

-- TABLE: crm_sales_details
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details(sls_ord_num,
                                             sls_prd_key,
                                             sls_cust_id,
                                             sls_order_dt,
                                             sls_ship_dt,
                                             sls_due_dt,
                                             sls_sales,
                                             sls_quantity,
                                             sls_price)
        SELECT sls_ord_num,
               sls_prd_key,
               sls_cust_id,
               CASE
                   WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
                   ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) -- We can't cast a INT direct to DATE in SQL SERVER, we have to cast it first to VARCHAR then to DATE.
                   END sls_order_dt,
               CASE
                   WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                   ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
                   END sls_ship_dt,
               CASE
                   WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
                   ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
                   END sls_due_dt,
               CASE
                   WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
                       THEN sls_quantity * ABS(sls_price) -- Sales = Quantity * Price
                   ELSE sls_sales
                   END sls_sales,
               sls_quantity,
               CASE
                   WHEN sls_price <= 0 OR sls_price IS NULL
                       THEN sls_sales / NULLIF(sls_quantity, 0) -- Recalculate Sales if original value are missing or invalid.
                   ELSE sls_price
                   END sls_price
        FROM bronze.crm_sales_details;
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';

        PRINT '---------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------';

-- TABLE: erp_cust_az12
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(cid,
                                         bdate,
                                         gen)
        SELECT CASE
                   WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                   ELSE cid
                   END cid,
               CASE
                   WHEN bdate > GETDATE() THEN NULL
                   ELSE bdate
                   END bdate,
               CASE
                   WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                   WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                   ELSE 'n/a'
                   END gen
        FROM bronze.erp_cust_az12;
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';

-- TABLE: erp_loc_a101
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (cid,
                                         cntry)
        SELECT REPLACE(cid, '-', ''),
               CASE
                   WHEN UPPER(TRIM(cntry)) = 'FRANCE' THEN 'France'
                   WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'Australia'
                   WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'Canada'
                   WHEN UPPER(TRIM(cntry)) = 'UNITED KINGDOM' THEN 'United Kingdom'
                   WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
                   WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
                   WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                   ELSE TRIM(cntry)
                   END cntry -- Normalize and Handling missing or blank Country codes
        FROM bronze.erp_loc_a101;
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';

-- TABLE: erp.px_cat_g1v2
        SET @start_date = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (id,
                                            cat,
                                            subcat,
                                            maintenance)
        SELECT id,
               cat,
               subcat,
               maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_date = GETDATE();
        PRINT 'Load Duration is: ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS NVARCHAR) + ' seconds.';
        SET @batch_end_date = GETDATE();
        PRINT 'The Load of Silver Layer is Completed!';
        PRINT 'Total Load Duration is: ' + CAST(DATEDIFF(SECOND, @batch_start_date, @batch_end_date) AS NVARCHAR) + ' seconds.';
    END TRY
    BEGIN CATCH
        PRINT '===============================================================';
        PRINT 'ERROR OCCURRED DURING THE LOAD OF SILVER LAYER!';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT '===============================================================';
    END CATCH
END;

GO
  
EXEC silver.load_silver;
