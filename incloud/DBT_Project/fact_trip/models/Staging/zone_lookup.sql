{{
    config(materialized='view')
}}

WITH zone AS (
    SELECT
        locationid,
        borough,
        zone,
        service_zone
    FROM {{ source('Staging', 'zone_lookup') }}  
)
SELECT * FROM zone