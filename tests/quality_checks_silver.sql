/*
===============================================================================
SILVER LAYER - DATA QUALITY CHECKS
===============================================================================

Purpose:
    Performs data quality checks across the Silver Layer to ensure
    data consistency, accuracy, and standardization.

Checks Include:
    - NULL values and duplicate primary keys.
    - Unwanted spaces in text columns.
    - Data standardization and consistency.
    - Invalid dates and date ranges.
    - Data consistency between related columns.

Usage:
    Execute this script after loading the Silver Layer.
    Investigate any unexpected results and resolve data quality issues.

Note:
    Queries marked with "Expected: No Results" should return no records.

===============================================================================
*/

-- ============================================================================
-- 1. CRM_CUSTOMER INFORMATION
-- ============================================================================

-- Check for NULL or Duplicate Customer IDs
-- Expected: No Results
SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for Unwanted Spaces
-- Expected: No Results
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);


-- Check Customer Marital Status Standardization
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


-- ============================================================================
-- 2. CRM_PRODUCT INFORMATION
-- ============================================================================

-- Check for NULL or Duplicate Product IDs
-- Expected: No Results
SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for Unwanted Spaces in Product Names
-- Expected: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULL or Negative Product Costs
-- Expected: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Check Product Line Standardization
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


-- Check for Invalid Product Date Ranges
-- Expected: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ============================================================================
-- 3. CRM_SALES DETAILS
-- ============================================================================

-- Check for Invalid Sales Dates in Bronze Layer
-- Expected: No Invalid Dates
SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- Check for Invalid Order, Shipping, and Due Date Sequences
-- Expected: No Results
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- Check Sales Consistency (Sales = Quantity * Price)
-- Expected: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


-- ============================================================================
-- 4. ERP_CUSTOMER INFORMATION
-- ============================================================================

-- Check for Invalid Birth Dates
-- Expected: Birthdates between 1924-01-01 and Today
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- Check Gender Standardization
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- ============================================================================
-- 5. ERP_LOCATION INFORMATION
-- ============================================================================

-- Check Country Standardization
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ============================================================================
-- 6. ERP_PRODUCT CATEGORY INFORMATION
-- ============================================================================

-- Check for Unwanted Spaces
-- Expected: No Results
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


-- Check Maintenance Standardization
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;


-- ============================================================================
-- END OF DATA QUALITY CHECKS
-- ============================================================================
