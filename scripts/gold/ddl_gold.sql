/*
===============================================================================
GOLD LAYER: BUILDING VIEWS
===============================================================================
Script Purpose:
    Creates analytical views for the Gold Layer, following a Star Schema
    approach with customer and product dimensions and a sales fact table.

Tables:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales
===============================================================================
*/

-- =============================================================================
-- 1. CUSTOMER DIMENSION
-- =============================================================================

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    lo.cntry AS country,
    ca.bdate AS birthdate,
    CASE
        WHEN ci.cst_gndr = 'n/a' THEN COALESCE(ca.gen, 'n/a')     -- DATA INTEGRATION for 'cst_gndr' & 'gen'
        ELSE ci.cst_gndr
    END AS gender,                 -- CRM is the master for gender information
    ci.cst_marital_status AS marital_status,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 lo
    ON ci.cst_key = lo.cid;


-- =============================================================================
-- 2. PRODUCT DIMENSION
-- =============================================================================

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pi.prd_id) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.prd_cost AS product_cost,
    pi.prd_line AS product_line,
    pi.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pi.prd_start_dt AS start_date
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL;       -- Exclude historical products


-- =============================================================================
-- 3. SALES FACT
-- =============================================================================

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    dp.product_key,                -- Foreign key to product dimension
    dc.customer_key,               -- Foreign key to customer dimension
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers dc
    ON sd.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products dp
    ON sd.sls_prd_key = dp.product_number;
