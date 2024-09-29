
{{ 
    config(materialized='view')
}}
with zone as (
    SELECT
      locationid,
      borough,
      zone,
      service_zone
    from {{ source('staging','stg_zone_lookup') }}
)
SELECT * from zone