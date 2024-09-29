import logging
import os
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def create_connection(host, db_name, user, password):
    try:
        connection_string = f'postgresql://{user}:{password}@{host}/{db_name}'
        engine = create_engine(connection_string)
        connection = engine.connect()
        logging.info("Connected to PostgreSQL database successfully")
        return connection, engine
    except SQLAlchemyError as error:
        logging.error("Error while connecting to PostgreSQL: %s", error)
        return None, None

def close_connection(connection, engine):
    if connection:
        connection.close()
        logging.info("PostgreSQL connection is closed")
    if engine:
        engine.dispose()
        logging.info("SQLAlchemy engine disposed")

def insert_data(table_name, data_frame, host, db_name, user, password):
    logging.info(f'Loading data into table {table_name}...')
    
    connection, engine = create_connection(host, db_name, user, password)
    
    if connection:
        try:
            data_frame.to_sql(name=table_name, con=engine, if_exists='append', index=False)
            logging.info(f"Data loaded successfully into table {table_name} with {len(data_frame)} rows")
        except SQLAlchemyError as error:
            logging.error(f"Error while inserting data into table {table_name}: {error}")
        finally:
            close_connection(connection, engine)
    else:
        logging.error(f"Failed to connect to the database and load data into table {table_name}")


def is_file_processed(conn, file_name):
    query = text("SELECT 1 FROM processed_files WHERE file_name = :file_name")
    result = conn.execute(query, {'file_name': file_name}).fetchone()
    return result is not None

def mark_file_as_processed(conn, file_name):
    query = text("INSERT INTO processed_files (file_name) VALUES (:file_name)")
    conn.execute(query, {'file_name': file_name})
