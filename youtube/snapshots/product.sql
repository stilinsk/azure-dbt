{% snapshot product_snapshot %}

{{
    config(
      file_format="delta",
      location_root="/mnt/silver/product",
      target_schema="snapshots",
      invalidate_hard_deletes=True,
      unique_key="ProductID",
      strategy="check",
      check_cols="all"
    )
}}

WITH src_products AS (
    SELECT 
        ProductID,
        COALESCE(Product, 'Anonymous') AS Product,
        COALESCE(Category, 'Anonymous') AS Category,
        COALESCE(Segment, 'Anonymous') AS Segment
    FROM {{ source('salesdata', 'sales') }}
)

SELECT * FROM src_products

{% endsnapshot %}
