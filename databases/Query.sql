
-- Active: 1718352668152@@172.20.0.3@5432@nyc_taxi_trip@public

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
