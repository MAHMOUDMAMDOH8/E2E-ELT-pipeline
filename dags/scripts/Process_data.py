import glob
import logging
import pandas as pd
from scripts.Utils.db_utils import *

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def process_green_trip(host, db_name, user, password):
    parquet_files = glob.glob('./Green_trip_files/*.parquet')
    conn, engine = create_connection(host, db_name, user, password)

    if conn:
        logging.info('Start transforming Green Trip data...')
        data_frames = []
        processed_files = []

        for file in parquet_files:
            file_name = file.split('/')[-1]  

            if is_file_processed(conn, file_name):
                logging.info(f'File {file_name} has already been extracted before . Skipping......')
                continue

            logging.info(f'Processing file {file_name}...')
            df = pd.read_parquet(file)
            data_frames.append(df)
            processed_files.append(file_name)


        if data_frames:
            data_frames = pd.concat(data_frames, ignore_index=True)
            logging.info(f'Green trip dataframe with {len(data_frames)} rows')
            return data_frames, processed_files
        return None, []

def process_yellow_trip(host, db_name, user, password):
    parquet_files = glob.glob('./yellow_trip_files/*.parquet')
    conn, engine = create_connection(host, db_name, user, password)

    if conn:
        logging.info('Start transforming Yellow Trip data...')
        data_frames = []
        processed_files = []

        for file in parquet_files:
            file_name = file.split('/')[-1]

            if is_file_processed(conn, file_name):
                logging.info(f'File {file_name} has already been extracted before . Skipping......')
                continue

            logging.info(f'Processing file {file_name}...')
            df = pd.read_parquet(file)
            data_frames.append(df)
            processed_files.append(file_name)


        if data_frames:
            data_frames = pd.concat(data_frames, ignore_index=True)
            data_frames = data_frames.drop(columns=['Airport_fee'], errors='ignore')  
            logging.info(f'Yellow trip dataframe with {len(data_frames)} rows')
            return data_frames, processed_files
        return None, []

