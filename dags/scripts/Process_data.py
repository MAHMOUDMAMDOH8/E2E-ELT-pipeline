import glob
import logging
import pandas as pd
import shutil
from scripts.Utils.db_utils import *

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def process_green_trip(host, db_name, user, password):
    parquet_files = glob.glob('./incloud/Staging/Green_trip_files/*.parquet')
    conn, engine = create_connection(host, db_name, user, password)

    if conn:
        logging.info('Start transforming Green Trip data...')
        data_frames = []
        processed_files = []
        archive = []

        for file in parquet_files:
            file_name = file.split('/')[-1]  

            if is_file_processed(conn, file_name):
                logging.info(f'File {file_name} has already been extracted before . Skipping......')
                continue

            logging.info(f'Processing file {file_name}...')
            df = pd.read_parquet(file)
            data_frames.append(df)
            processed_files.append(file_name)
            archive.append(file)


        if data_frames:
            data_frames = pd.concat(data_frames, ignore_index=True)
            logging.info(f'Green trip dataframe with {len(data_frames)} rows')
            return data_frames, processed_files,archive
        return None, [],[]

def process_yellow_trip(host, db_name, user, password):
    parquet_files = glob.glob('./incloud/Staging/yellow_trip_files/*.parquet')
    conn, engine = create_connection(host, db_name, user, password)

    if conn:
        logging.info('Start transforming Yellow Trip data...')
        data_frames = []
        processed_files = []
        archive = []

        for file in parquet_files:
            file_name = file.split('/')[-1]

            if is_file_processed(conn, file_name):
                logging.info(f'File {file_name} has already been extracted before . Skipping......')
                continue

            logging.info(f'Processing file {file_name}...')
            df = pd.read_parquet(file)
            data_frames.append(df)
            processed_files.append(file_name)
            archive.append(file)


        if data_frames:
            data_frames = pd.concat(data_frames, ignore_index=True)
            data_frames = data_frames.drop(columns=['Airport_fee'], errors='ignore')  
            logging.info(f'Yellow trip dataframe with {len(data_frames)} rows')
            return data_frames, processed_files,archive
        return None, [],[]
    

def move_files_to_archive(paths):
    archive_dir = '/opt/airflow/incloud/Staging/archive'
    
    os.makedirs(archive_dir, exist_ok=True)

    for file_path in paths:
        if os.path.exists(file_path):
            try:
                # Construct the destination file path
                dest_path = os.path.join(archive_dir, os.path.basename(file_path))
                shutil.move(file_path, dest_path)  # Copy the file to the archive
                logging.info(f'Moved {file_path} to archive to {dest_path}')
            except Exception as e:
                logging.error(f'Error while moving {file_path}: {e}')  # Use error level for exceptions
        else:
            logging.warning(f'{file_path} does not exist')

