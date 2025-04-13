{{
    config(
        materialized = "table",
        file_format = "delta",
        location_root = "/mnt/gold/sales"
    )
}}

WITH fct_sales AS (
    SELECT 
        CustomerID,
        ProductID,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id,
        {{ dbt_utils.generate_surrogate_key(['Date', 'CustomerID', 'ProductID', 'Product', 'CampaignID']) }} AS sales_id,
        Unit_Cost,  
        Unit_Price, 
        CampaignID
    FROM 
        {{ source('salesdata', 'sales') }}
)

SELECT DISTINCT
    fs.sales_id,
    fs.CustomerID,
    fs.ProductID,
    fs.date_id,
    fs.Unit_Cost, 
    fs.Unit_Price, 
    fs.CampaignID
FROM fct_sales fs
INNER JOIN {{ ref('date_snapshot') }} d ON fs.date_id = d.date_id
INNER JOIN {{ ref('product_snapshot') }} p ON fs.ProductID = p.ProductID
INNER JOIN {{ ref('customer_snapshot') }} c ON fs.CustomerID = c.CustomerID;
