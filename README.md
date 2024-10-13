# E2E-ELT-pipeline
![architecture](https://github.com/user-attachments/assets/923710e2-5a94-44db-84a6-6d6b89946437)

## Table of Contents
- [Introduction](#introduction)
- [Tech Stack & Tools](#tech-stack--tools)
- [Assumptions](#assumptions)
- [Pipeline Architecture](#pipeline-architecture)
- [Scripts Overview](#scripts-overview)
  - [db_utils.py](#db_utilspy)
  - [Process_data.py](#process_datapy)
  - [Load_data.py](#load_datapy)
- [Airflow DAG Overview](#airflow-dag-overview)
- [Database Schema](#database-schema)
- [Reporting Layer](#reporting-layer)
- [How to Run the Project](#how-to-run-the-project)

## Introduction
The goal of this project is to build an end-to-end data pipeline for NYC Taxi trip data. The pipeline ingests, stores, and transforms the data in a PostgreSQL-based data warehouse, enabling data analysis and reporting. The project leverages modern tools like Docker, Apache Airflow, dbt, and Power BI for orchestration, transformation, and reporting.

## Tech Stack & Tools
- **Infrastructure**: Docker
- **Data Warehouse**: PostgreSQL
- **Orchestration**: Apache Airflow
- **Data Loader**: Python
- **Transformation**: dbt (Data Build Tool)
- **Serving Layer**: Power BI

## Assumptions
- The database schema follows a star schema design for efficient querying and analysis.
- NYC trip data is assumed to be clean and does not require extensive preprocessing.

## Pipeline Architecture
1. **Data Collection**: The raw NYC taxi trip data (in Parquet format) is collected and stored in directories for Green and Yellow taxis.
2. **Data Processing**: The data is processed, transformed into a DataFrame, and prepared for loading into PostgreSQL tables.
3. **Data Loading**: Processed data is loaded into PostgreSQL tables using Python scripts.
4. **Transformation**: dbt is used to transform the data in the warehouse for downstream analysis.
5. **Serving Layer**: Power BI visualizes the data for analysis.

## Scripts Overview

### db_utils.py
- `create_connection`: Establishes a connection to the PostgreSQL database using SQLAlchemy.
- `close_connection`: Closes the PostgreSQL connection .
- `insert_data`: Inserts a Pandas DataFrame into a PostgreSQL table.
- `is_file_processed`: Checks if a file has already been processed by select data in the `processed_files` table .
- `mark_file_as_processed`: Marks a file as processed by inserting its name into the `processed_files` table.

### Process_data.py
- `process_green_trip`: Processes Green Trip Parquet files, transforms them into a DataFrame, and tracks processed files.
- `process_yellow_trip`: Processes Yellow Trip Parquet files, excluding the `airport_fee` column, and tracks processed files.
- `move_files_to_archive`: Moves processed files to an archive directory after they’ve been successfully loaded into the warehouse.

### Load_data.py
- `load_green_trip`: Loads the processed Green Trip data into the `green_trip` table.
- `load_yellow_trip`: Loads the processed Yellow Trip data into the `yellow_trip` table.

## Airflow DAG Overview

The Airflow DAG orchestrates the steps of the pipeline:
![airflow](https://github.com/user-attachments/assets/9dee2376-5a85-48e1-b265-4c8bd79563ab)

1. **Extraction Layer**:
   - Extracts Green and Yellow trip data from source Parquet files.
   - Pushes data and metadata to Airflow's XCom for downstream processing.
   
2. **Load Layer**:
   - Loads extracted Green and Yellow trip data into corresponding PostgreSQL tables.
   - Prepares the data for further transformations.
   
3. **File Processing Layer**:
   - Marks processed files in the database.
   - Moves files to an archive directory after successful processing.
   
4. **DBT Transformation Layer**:
   - Runs dbt models for Green and Yellow trips, and zone lookups.
   - Final transformation is done using the `Fact_trips` dbt model.

## Database Schema
The database follows a star schema design, optimized for efficient queries and analysis. Fact and dimension tables include:
![Data_modeling](https://github.com/user-attachments/assets/57dccfe2-f6d7-4872-a11b-3095c773d3e7)

- `Dim_veidor`
- `Dim_data`
- `Dim_location`
- `Dim_rate`
- `Dim_paymet`
- `Dim_trip_type`
- `Fact_trips` (aggregated trip data for reporting)

## Reporting Layer
- **Power BI**: Used to visualize key metrics and trends from the NYC Taxi trip data. Reports can be generated from the transformed data in the data warehouse.
![image](https://github.com/user-attachments/assets/7aace305-1946-4acb-8dc4-59e9f728f329)

## How to Run the Project
1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/MAHMOUDMAMDOH8/E2E-ELT-pipeline.git
   cd E2E-ELT-pipeline
   docker compose up --build
   
Open the Airflow UI at http://localhost:8080 then open  the Taxi_trip_pipeline DAG.





   

