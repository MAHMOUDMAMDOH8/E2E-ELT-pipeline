from scripts.Process_data import *
from scripts.Utils.db_utils import *
import pandas as pd
import logging
import datetime as datetime

logging.basicConfig(filename='load_data.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_green_trip(data_frames, host, db_name, user, password):
    try:
        logging.info('Loading green trip data...')
        logging.info(f'green trip with {len(data_frames)}rows')

        Taxi_Dtype = {
            'VendorID': pd.Int64Dtype(),
            'passenger_count': pd.Int64Dtype(),
            'trip_distance': float,
            'RatecodeID': pd.Int64Dtype(),
            'store_and_fwd_flag': str,
            'PULocationID': pd.Int64Dtype(),
            'DOLocationID': pd.Int64Dtype(),
            'payment_type': pd.Int64Dtype(),
            'fare_amount': float,
            'extra': float,
            'mta_tax': float,
            'tip_amount': float,
            'tolls_amount': float,
            'improvement_surcharge': float,
            'total_amount': float,
            'congestion_surcharge': float
        }

        data_frames = data_frames.astype(Taxi_Dtype)
        data_frames['lpep_pickup_datetime'] = pd.to_datetime(data_frames['lpep_pickup_datetime'])
        data_frames['lpep_dropoff_datetime'] = pd.to_datetime(data_frames['lpep_dropoff_datetime'])

        # Insert the data into the green_trip table
        insert_data('green_trip', data_frames, host, db_name, user, password)
        logging.info('Green trip data loaded successfully')
    except Exception as e:
        logging.error(f'Error loading green_trip: {str(e)}')


def load_yellow_trip(data_frames, host, db_name, user, password):
    try:
        logging.info('Loading yellow trip data...')
        logging.info(f'yellow  trip with {len(data_frames)}rows')

        Taxi_Dtype = {
            'VendorID': pd.Int64Dtype(),
            'passenger_count': pd.Int64Dtype(),
            'trip_distance': float,
            'RatecodeID': pd.Int64Dtype(),
            'store_and_fwd_flag': str,
            'PULocationID': pd.Int64Dtype(),
            'DOLocationID': pd.Int64Dtype(),
            'payment_type': pd.Int64Dtype(),
            'fare_amount': float,
            'extra': float,
            'mta_tax': float,
            'tip_amount': float,
            'tolls_amount': float,
            'improvement_surcharge': float,
            'total_amount': float,
            'congestion_surcharge': float
        }

        data_frames = data_frames.astype(Taxi_Dtype)
        data_frames['tpep_pickup_datetime'] = pd.to_datetime(data_frames['tpep_pickup_datetime'])
        data_frames['tpep_dropoff_datetime'] = pd.to_datetime(data_frames['tpep_dropoff_datetime'])

        # Insert the data into the yellow_trip table
        insert_data('yellow_trip', data_frames, host, db_name, user, password)
        logging.info('Yellow trip data loaded successfully')
    except Exception as e:
        logging.error(f'Error loading yellow_trip: {str(e)}')



