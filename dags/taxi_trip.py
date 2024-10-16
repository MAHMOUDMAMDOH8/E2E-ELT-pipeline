from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.utils.task_group import TaskGroup
from airflow.operators.bash import BashOperator
from scripts.Process_data import *
from scripts.Load_data import *
import logging

default_args = {
    'owner': 'Mahmoud',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
}

dag = DAG(
    'Taxi_trip_pipeline',
    default_args=default_args,
    description='E2E Taxi Trip Pipeline',
    schedule_interval='*/15 * * * *',
    start_date=days_ago(1),
    catchup=False,
)

def load_credentials():
    return {
        "host": "172.20.0.3",
        "db_name": 'nyc_taxi_trip',
        "user": 'airflow',
        "password": 'airflow'
    }

def extract_green_date(ti):
    try:
        logging.info('Data extraction for green trip started')
        db_credentials = load_credentials()
        green_trip_df, processed_files,archive = process_green_trip(**db_credentials)
        logging.info('Data extraction for green trip done')
        if green_trip_df is not None:
            ti.xcom_push(key='green_trip_df', value=green_trip_df)
            ti.xcom_push(key='processed_files_green', value=processed_files)
            ti.xcom_push(key='archive_green',value = archive)
            logging.info(f'Pushed green trip data with {len(green_trip_df)} rows to XCom')
        else:
            logging.warning("No data found for green trip")
    except Exception as e:
        logging.error("Error in green trip extraction", exc_info=True)

def extract_yellow_date(ti):
    try:
        logging.info('Data extraction for yellow trip started')
        db_credentials = load_credentials()
        yellow_trip_df, processed_files,archive = process_yellow_trip(**db_credentials)
        logging.info('Data extraction for yellow trip done')
        if yellow_trip_df is not None:
            ti.xcom_push(key='yellow_trip_df', value=yellow_trip_df)
            ti.xcom_push(key='processed_files_yellow', value=processed_files)
            ti.xcom_push(key='archive_yellow',value = archive)
            logging.info(f'Pushed yellow trip data with {len(yellow_trip_df)} rows to XCom')
        else:
            logging.warning("No data found for yellow trip")
    except Exception as e:
        logging.error("Error in yellow trip extraction", exc_info=True)

def load_green_trip_def(ti):
    try:
        db_credentials = load_credentials()
        green_trip_df = ti.xcom_pull(task_ids='extraction_layer.extract_green_date', key='green_trip_df')
        if green_trip_df is not None:
            logging.info(f'Loading green trip data started with {len(green_trip_df)} rows')
            load_green_trip(green_trip_df, **db_credentials)
            logging.info('Loading green trip data done')
        else:
            logging.error("No data found for green trip")
    except Exception as e:
        logging.error("Error in loading green trip data", exc_info=True)

def load_yellow_trip_def(ti):
    try:
        db_credentials = load_credentials()
        yellow_trip_df = ti.xcom_pull(task_ids='extraction_layer.extract_yellow_date', key='yellow_trip_df')
        if yellow_trip_df is not None:
            logging.info(f'Loading yellow trip data started with {len(yellow_trip_df)} rows')
            load_yellow_trip(yellow_trip_df, **db_credentials)
            logging.info('Loading yellow trip data done')
        else:
            logging.error("No data found for yellow trip")
    except Exception as e:
        logging.error("Error in loading yellow trip data", exc_info=True)

def mark_files_as_processed(ti):
    try:
        db_credentials = load_credentials()
        conn, engine = create_connection(**db_credentials)

        processed_files_green = ti.xcom_pull(task_ids='extraction_layer.extract_green_date', key='processed_files_green')
        processed_files_yellow = ti.xcom_pull(task_ids='extraction_layer.extract_yellow_date', key='processed_files_yellow')

        if processed_files_green:
            for file_name in processed_files_green:
                mark_file_as_processed(conn, file_name)
            logging.info(f'Marked green trip files as processed.')

        if processed_files_yellow:
            for file_name in processed_files_yellow:
                mark_file_as_processed(conn, file_name)
            logging.info(f'Marked yellow trip files as processed.')

        logging.info('All files marked as processed successfully.')

    except Exception as e:
        logging.error("Error in marking files as processed", exc_info=True)

def archiving(ti):
    try:
        archive_green = ti.xcom_pull(task_ids='extraction_layer.extract_green_date', key='archive_green')
        archive_yellow = ti.xcom_pull(task_ids='extraction_layer.extract_yellow_date', key='archive_yellow')

        if archive_green:
            move_files_to_archive(archive_green)
            logging.info("Files archive_green successfully.")
        else:
            logging.warning("No files to archive_green.")
        if archive_yellow:
            move_files_to_archive(archive_yellow)
            logging.info("Files archive_yellow successfully.")
        else:
            logging.warning("No files to archive_yellow.")

    except Exception as e:
        logging.error("Error in archiving files", exc_info=True)


with dag:
    with TaskGroup('extraction_layer') as extraction_group:
        extract_green_date_task = PythonOperator(
            task_id='extract_green_date',
            python_callable=extract_green_date,
            provide_context=True
        )

        extract_yellow_date_task = PythonOperator(
            task_id='extract_yellow_date',
            python_callable=extract_yellow_date,
            provide_context=True
        )

    with TaskGroup('load_layer') as load_group:
        load_green_trip_task = PythonOperator(
            task_id='load_green_trip',
            python_callable=load_green_trip_def,
            provide_context=True
        )

        load_yellow_trip_task = PythonOperator(
            task_id='load_yellow_trip',
            python_callable=load_yellow_trip_def,
            provide_context=True
        )

    mark_files_as_processed_task = PythonOperator(
        task_id='mark_files_as_processed',
        python_callable=mark_files_as_processed,
        provide_context=True
    )
    move_files_to_archive_task = PythonOperator(
        task_id = 'move_files_to_archive',
        python_callable = archiving,
        provide_context = True
    )
    
    # Create the DBT staging layer task group
    with TaskGroup('dbt_transformation_layer') as dbt_staging_group:
        models = ['green_trip', 'yellow_trip', 'zone_lookup']
        dbt_run_tasks = []
        for model in models:
            dbt_run_task = BashOperator(
                task_id=f'dbt_run_model_{model}',
                bash_command=f'dbt run --profiles-dir /opt/***/DBT_Project  --project-dir /opt/***/dbt_trip --models {model}',
                dag=dag,
            )
            dbt_run_tasks.append(dbt_run_task)
    
    dbt_run_fact_trip = BashOperator(
        task_id='dbt_run_model_fact_trip',
        bash_command='dbt run --profiles-dir /opt/***/DBT_Project  --project-dir /opt/***/dbt_trip --models Fact_trips'
    )

   
    extract_green_date_task >> load_green_trip_task >> mark_files_as_processed_task
    extract_yellow_date_task >> load_yellow_trip_task >> mark_files_as_processed_task
    mark_files_as_processed_task >> move_files_to_archive_task >> dbt_staging_group >> dbt_run_fact_trip