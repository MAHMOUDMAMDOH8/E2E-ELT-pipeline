{{
    config(materialized='view')
}}

WITH source AS (
    SELECT *,
        CAST("VendorID" AS INTEGER) AS vd,
        CAST("RatecodeID" AS INTEGER) AS RCode,
        CAST("store_and_fwd_flag" AS VARCHAR) AS store_F,
        CAST("payment_type" AS INTEGER) AS payment,
        ROW_NUMBER() OVER (PARTITION BY "VendorID", tpep_pickup_datetime) AS rn
    FROM {{ source('Staging', 'yellow_trip') }}  
    WHERE "VendorID" IS NOT NULL 
      AND trip_distance > 0 
      AND passenger_count > 0
)

SELECT
    -- Identifiers
    ROW_NUMBER() OVER (ORDER BY "VendorID", "tpep_pickup_datetime") AS tripid,
    
    -- Vendor ID with mapped description
    {{ adapter.quote("VendorID") }} AS vendorid,
    {{ map_vendor("vd") }} AS vendor_description,

    -- Rate code with mapped description
    {{ adapter.quote("RatecodeID") }} AS ratecodeid,
    {{ map_rate_code("RCode") }} AS rate_code_description,

    -- Pickup and Dropoff location IDs
    {{ adapter.quote("PULocationID") }} AS pickup_locationid,
    {{ adapter.quote("DOLocationID") }} AS dropoff_locationid,

    -- Timestamps
    {{ adapter.quote("tpep_pickup_datetime") }} AS pickup_datetime,
    {{ adapter.quote("tpep_dropoff_datetime") }} AS dropoff_datetime,

    -- Store and forward flag with mapped description
    {{ adapter.quote("store_and_fwd_flag") }},
    {{ map_store_and_fwd_flag("store_F") }} AS store_and_fwd_flag_description,

    -- Trip info
    {{ adapter.quote("passenger_count") }} AS passenger_count,
    {{ adapter.quote("trip_distance") }} AS trip_distance,

    -- Payment info with mapped descriptions
    {{ adapter.quote("fare_amount") }} AS fare_amount,
    {{ adapter.quote("extra") }} AS extra,
    {{ adapter.quote("mta_tax") }} AS mta_tax,
    {{ adapter.quote("tip_amount") }} AS tip_amount,
    {{ adapter.quote("tolls_amount") }} AS tolls_amount,
    {{ adapter.quote("improvement_surcharge") }} AS improvement_surcharge,
    {{ adapter.quote("total_amount") }} AS total_amount,
    
    -- Payment type and description
    coalesce({{ adapter.quote("payment_type") }}, 0) AS payment_type,
    {{ map_payment_type("payment_type") }} AS payment_type_description,

    -- Adding trip_type column with a constant value of 1
    1 AS trip_type,
    {{ map_trip_type(1) }} AS trip_type_description  -- Creating a trip_type_description for constant value 1

FROM source
WHERE rn = 1  

{% if var('is_test_run', default=true) %}
  LIMIT 100
{% endif %}
