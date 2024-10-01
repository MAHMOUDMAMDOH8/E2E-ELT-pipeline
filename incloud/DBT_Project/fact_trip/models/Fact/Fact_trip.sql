{{
    config(materialized='view')
}}

WITH green_trip AS (
    SELECT *, 'green' AS taxi_type FROM {{ ref('green_trip') }}
),
yellow_trip AS (
    SELECT *, 'yellow' AS taxi_type FROM {{ ref('yellow_trip') }}
),
trips AS (
    SELECT *
    FROM green_trip 
    UNION ALL 
    SELECT *
    FROM yellow_trip
),
dim_zones AS (
    SELECT * FROM {{ ref('zone_lookup') }}
    WHERE borough != 'Unknown'
),
renamed AS (
    SELECT 
        t.*, 
        pullz.borough AS pickup_borough, 
        pullz.zone AS pickup_zone, 
        dropz.borough AS dropoff_borough, 
        dropz.zone AS dropoff_zone
    FROM trips t
    JOIN dim_zones pullz ON t.pickup_locationid = pullz.locationid
    JOIN dim_zones dropz ON t.dropoff_locationid = dropz.locationid
)
SELECT * 
FROM renamed
