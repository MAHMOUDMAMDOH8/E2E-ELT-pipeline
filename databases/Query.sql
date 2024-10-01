
-- Active: 1718352668152@@172.20.0.3@5432@nyc_taxi_trip@public
CREATE TABLE IF NOT EXISTS green_trip (
    VendorID INT,
    passenger_count INT,
    trip_distance FLOAT,
    RatecodeID INT,
    store_and_fwd_flag VARCHAR(1),
    PULocationID INT,
    DOLocationID INT,
    payment_type INT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT,
    lpep_pickup_datetime TIMESTAMP,
    lpep_dropoff_datetime TIMESTAMP
);

CREATE TABLE IF NOT EXISTS yellow_trip (
    VendorID INT,
    passenger_count INT,
    trip_distance FLOAT,
    RatecodeID INT,
    store_and_fwd_flag VARCHAR(1),
    PULocationID INT,
    DOLocationID INT,
    payment_type INT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT,
    tpep_pickup_datetime TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP
);

CREATE TABLE IF NOT EXISTS zone_lookup (
    LocationID INT PRIMARY KEY,
    Borough VARCHAR(255),
    Zone VARCHAR(255),
    service_zone VARCHAR(255)
);

CREATE TABLE processed_files (
    id SERIAL PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    processed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
