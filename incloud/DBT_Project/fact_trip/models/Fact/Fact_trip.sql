{{
    config(materialized='view')
}}

WITH green_trip AS (
    SELECT * FROM {{ ref('green_trip') }}
),
yellow_trip AS (
    SELECT * FROM {{ ref('yellow_trip') }}
),
trips AS (
    SELECT 
        CAST(vendorid AS INTEGER) AS vendorid, -- Ensure both types match
        CAST(ratecodeid AS INTEGER) AS ratecodeid, -- Ensure both types match
        pickup_locationid,
        dropoff_locationid,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        trip_type  
    FROM green_trip 
    UNION ALL 
    SELECT 
        CAST(vendorid AS INTEGER) AS vendorid,
        CAST(ratecodeid AS INTEGER) AS ratecodeid,
        pickup_locationid,
        dropoff_locationid,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        1 AS trip_type
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
