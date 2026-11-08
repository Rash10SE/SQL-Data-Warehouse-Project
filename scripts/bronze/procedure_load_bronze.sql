/*
===============================================================================
BRONZE LAYER - LOAD DATA (FULL LOAD: TRUNCATE & INSERT)
===============================================================================

Purpose:
    This stored procedure loads raw data from CRM and ERP source files into
    the corresponding Bronze Layer tables.

Procedure:
    bronze.load_bronze

Loading Strategy:
    - Full Load (TRUNCATE & INSERT).
    - Existing data is removed using TRUNCATE TABLE before each load.
    - New data is imported from CSV files using BULK INSERT.
    - The first row (column headers) is skipped during import.

Execution Flow:
    1. Initialize batch and individual table load timestamps.
    2. Load CRM source tables:
       - bronze.crm_cust_info
       - bronze.crm_prd_info
       - bronze.crm_sales_details
    3. Load ERP source tables:
       - bronze.erp_cust_az12
       - bronze.erp_loc_a101
       - bronze.erp_px_cat_g1v2
    4. Calculate and display the loading duration for each table.
    5. Calculate and display the total batch execution time.
    6. Handle potential errors using TRY...CATCH.

Performance Optimization:
    - BULK INSERT is used for efficient bulk data loading.
    - TABLOCK is applied to improve loading performance.

Error Handling:
    - TRY...CATCH captures errors during the loading process.
    - Error messages are displayed using ERROR_MESSAGE().

Execution:
    EXEC bronze.load_bronze;

Important Notes:
    - The procedure performs a full reload every time it is executed.
    - Existing data is permanently removed before inserting new records.
    - No data cleansing or transformations are performed in the Bronze Layer.
    - Source CSV files must be accessible from the SQL Server environment.

===============================================================================
*/


-- BRONZE LAYER || LOAD SCRIPTS || FULL-LOAD (TRUNCATE INSERT)
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME -- to calculate the load duration.
    BEGIN TRY -- Handling Errors
        PRINT '=================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=================================================';
        PRINT '-------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------------------';

        SET @batch_start_time = GETDATE();

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
            FROM '/sql/dwh_project/01_datasets/source_crm/cust_info.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK -- Um die Leistung zu verbessern, wird die Tabelle während des Ladens gesperrt.
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
            FROM '/sql/dwh_project/01_datasets/source_crm/prd_info.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
            FROM '/sql/dwh_project/01_datasets/source_crm/sales_details.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        PRINT '-------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
            FROM '/sql/dwh_project/01_datasets/source_erp/cust_az12.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
            FROM '/sql/dwh_project/01_datasets/source_erp/loc_a101.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
            FROM '/sql/dwh_project/01_datasets/source_erp/px_cat_g1v2.csv'
            WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
            );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';

        SET @batch_end_time = GETDATE();
        PRINT 'Loading Bronze Layer is Completed!'
        PRINT 'Total Load Duration is: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds.'

    END TRY
    BEGIN CATCH
        PRINT '=================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR MESSAGE!' + ERROR_MESSAGE();
        PRINT '=================================================';
    END CATCH
END;
GO
EXEC bronze.load_bronze;
