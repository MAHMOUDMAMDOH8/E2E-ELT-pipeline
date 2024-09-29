FROM apache/airflow:2.9.1-python3.9

USER root


RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


USER airflow


RUN pip install --upgrade pip


RUN mkdir -p /opt/airflow/incloud/DBT_Project/fact_trip/logs && chown -R airflow /opt/airflow/incloud/DBT_Project/fact_trip


ENV PYTHONPATH=/opt/airflow/dags/scripts


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY dags /opt/airflow/dags
COPY scripts /opt/airflow/scripts
