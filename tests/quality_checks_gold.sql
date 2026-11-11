/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity and
    consistency of the Gold Layer. It includes checks for:
    - Duplicate surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Data model connectivity between sales and dimension tables.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
    - All checks should return no results if the data is valid.
===============================================================================
*/


-- =============================================================================
-- Checking 'gold.dim_customers'
-- =============================================================================

-- Check for duplicate customer keys
-- Expectation: No results

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers dc
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold.dim_products'
-- =============================================================================

-- Check for duplicate product keys
-- Expectation: No results

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products dp
GROUP BY product_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold.fact_sales'
-- =============================================================================

-- Check referential integrity between fact and dimension tables
-- Expectation: No results

SELECT
    sd.order_number,
    sd.customer_key,
    sd.product_key
FROM gold.fact_sales sd
LEFT JOIN gold.dim_customers dc
    ON sd.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
    ON sd.product_key = dp.product_key
WHERE dc.customer_key IS NULL
   OR dp.product_key IS NULL;
