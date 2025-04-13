{% snapshot customer_snapshot %}

{{
    config(
      file_format="delta",
      location_root="/mnt/silver/customer",
      target_schema="snapshots",
      invalidate_hard_deletes=True,
      unique_key="CustomerID",
      strategy="check",
      check_cols="all"
    )
}}

WITH src_customers AS (
    SELECT 
        CustomerID,
        COALESCE(Email_Name, 'Anonymous') AS EMAIL,
        COALESCE(District, 'Anonymous') AS District,
        COALESCE(City, 'Anonymous') AS City,
        COALESCE(State, 'Anonymous') AS State,
        COALESCE(Region, 'Anonymous') AS Region,
        COALESCE(Country, 'Anonymous') AS Country,
        ZipCode
    FROM {{ source ('salesdata', 'sales') }}  
)

SELECT * FROM src_customers

{% endsnapshot %}
