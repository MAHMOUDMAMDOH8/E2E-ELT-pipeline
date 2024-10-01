{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *,
        CAST("VendorID" AS INTEGER) AS vd,
        CAST("RatecodeID" AS INTEGER) AS RCode,
        CAST("store_and_fwd_flag" AS VARCHAR) AS store_F,
        CAST("payment_type" AS INTEGER) AS payment,
        CAST("trip_type" AS INTEGER) AS trip_t,
        ROW_NUMBER() OVER (PARTITION BY "VendorID", lpep_pickup_datetime) AS rn 
    FROM {{ source('Staging', 'green_trip') }}
    WHERE "VendorID" IS NOT NULL 
      AND trip_distance > 0 
      AND passenger_count > 0
),
green_trips AS (
    SELECT
        -- Identifiers
        ROW_NUMBER() OVER (ORDER BY "VendorID", "lpep_pickup_datetime") AS tripid,
        
        -- Vendor ID with mapped description
        {{ adapter.quote("VendorID") }} AS vendorid,
        {{ map_vendor("vd") }} AS vendor_description,

        -- Rate code with mapped description
        {{ adapter.quote("RatecodeID") }} AS ratecodeid,
        {{ map_rate_code("RCode") }} AS rate_code_description,

        -- Trip type code with mapped description
        {{ adapter.quote("trip_type") }} AS trip_type,
        {{ map_trip_type("trip_t") }} AS trip_type_description,

        -- Pickup and Dropoff location IDs
        {{ adapter.quote("PULocationID") }} AS pickup_locationid,
        {{ adapter.quote("DOLocationID") }} AS dropoff_locationid,

        -- Timestamps
        {{ adapter.quote("lpep_pickup_datetime") }} AS pickup_datetime,
        {{ adapter.quote("lpep_dropoff_datetime") }} AS dropoff_datetime,

        -- Store and forward flag with mapped description
        {{ adapter.quote("store_and_fwd_flag") }},
        {{ map_store_and_fwd_flag('store_F') }} AS store_and_fwd_flag_description,

        -- Trip info
        {{  adapter.quote("passenger_count") }} AS passenger_count,
        {{ adapter.quote("trip_distance") }} AS trip_distance,

        -- Payment info with mapped descriptions
        {{ adapter.quote("fare_amount") }} AS fare_amount,
        {{ adapter.quote("extra") }} AS extra,
        {{ adapter.quote("mta_tax") }} AS mta_tax,
        {{ adapter.quote("tip_amount") }} AS tip_amount,
        {{ adapter.quote("tolls_amount") }} AS tolls_amount,
        {{ adapter.quote("improvement_surcharge") }} AS improvement_surcharge,
        {{ adapter.quote("total_amount") }} AS total_amount,
        {{ adapter.quote("payment_type") }} AS payment_type,
        {{ map_payment_type("payment") }} AS payment_type_description

    FROM source
    WHERE rn = 1
)
SELECT * FROM green_trips

{% if var('is_test_run', default=true) %}
  LIMIT 100
{% endif %}
