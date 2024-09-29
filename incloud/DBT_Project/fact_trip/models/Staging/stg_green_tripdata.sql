{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
    -- Add row number partition to handle potential duplicates
    row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
  from {{ source('staging','green_trip') }}  
  where vendorid is not null and trip_distance > 0 and passenger_count > 0
)

select
    -- Identifiers
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    
    -- Vendor ID with mapped description
    {{ dbt.safe_cast("vendorid", api.Column.translate_type("integer")) }} as vendorid,
    {{ map_vendor("vendorid") }} as vendor_description,

    -- Rate code with mapped description
    {{ dbt.safe_cast("ratecodeid", api.Column.translate_type("integer")) }} as ratecodeid,
    {{ map_rate_code("ratecodeid") }} as rate_code_description,

    -- Pickup and Dropoff location IDs
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- Timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- Store and forward flag with mapped description
    store_and_fwd_flag,
    {{ map_store_and_fwd_flag("store_and_fwd_flag") }} as store_and_fwd_flag_description,

    -- Trip info
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    {{ dbt.safe_cast("trip_type", api.Column.translate_type("integer")) }} as trip_type,
    {{ map_trip_type("trip_type") }} as trip_type_description,

    -- Payment info with mapped descriptions
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    coalesce({{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }}, 0) as payment_type,
    {{ map_payment_type("payment_type") }} as payment_type_description

from tripdata
where rn = 1  


{% if var('is_test_run', default=true) %}
  limit 100
{% endif %}
