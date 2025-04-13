{% snapshot date_snapshot %}

{{
    config(
      file_format="delta",
      location_root="/mnt/silver/date",
      target_schema="snapshots",
      invalidate_hard_deletes=True,
      unique_key="date_id",
      strategy="check",
      check_cols="all"
    )
}}

WITH src_dates AS (
    SELECT 
        *,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id
    FROM 
        {{ source('salesdata', 'sales') }}
    WHERE 
        Date IS NOT NULL -- Filter out rows with null dates
    {% if is_incremental() %}
    AND Date > (SELECT MAX(Date) FROM {{ this }}) -- Replace Date if another column is better
    {% endif %}
)

SELECT 
    date_id,
    Date,
    TO_DATE(Date) AS sales_date
FROM src_dates

{% endsnapshot %}