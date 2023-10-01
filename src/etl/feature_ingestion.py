import datetime
import sqlalchemy
from sqlalchemy import text
import os
import pandas as pd
import argparse
from tqdm import tqdm

def date_range(dt_start, dt_stop, period='daily'):
    date_start = datetime.datetime.strptime(dt_start, '%Y-%m-%d')
    date_stop = datetime.datetime.strptime(dt_stop, '%Y-%m-%d')
    dates = []
    while date_start <= date_stop:
        dates.append(date_start.strftime('%Y-%m-%d'))
        date_start += datetime.timedelta(days=1)
    
    if period == 'daily':
        return dates
    if period == 'monthly':
        return [i for i in dates if i.endswith("01")]

class Ingestor:

    def __init__(self, path, table, key_field):
        self.path = path
        self.engine = self.create_engine()
        self.table = table
        self.key_field = key_field
 
    def create_engine(self):
        return sqlalchemy.create_engine(f"sqlite:///{self.path}")

    def import_query(self, path):
        with open(path, 'r') as open_file:
            return open_file.read()

    def table_exists(self):
        with self.engine.connect() as connection:
            tables = sqlalchemy.inspect(connection).get_table_names()
        return self.table in tables

    def execute_etl(self, query):
        with self.engine.connect() as connection:
            df = pd.read_sql_query(text(query), connection)
        return df

    def insert_table(self, df):
        with self.engine.connect() as connection:
            df.to_sql(self.table, connection, if_exists= 'append', index= False)
            connection.commit()
        return True 

    def delete_table_rows(self, value):
        sql = f"DELETE FROM {self.table} WHERE {self.key_field} = '{value}';"
        with self.engine.connect() as connection: 
            connection.execute(text(sql))
            connection.commit()
        return True

    def update_table_rows(self, raw_query, value):
        if self.table_exists():
            self.delete_table_rows(value)
        df = self.execute_etl(raw_query.format(date=value))
        self.insert_table(df)

def main():
    ETL_DIR = os.path.dirname(os.path.abspath(__file__))
    LOCAL_DEV_DIR = os.path.dirname(ETL_DIR)
    ROOT_DIR = os.path.dirname(LOCAL_DEV_DIR)
    DATA_DIR = os.path.join(ROOT_DIR, 'data')
    DB_PATH = os.path.join(DATA_DIR, 'olist.db')

    parser = argparse.ArgumentParser()
    parser.add_argument("--table", type=str)
    parser.add_argument("--date_start", type=str)
    parser.add_argument("--date_stop", type=str)
    parser.add_argument("--date_period", type=str)
    args = parser.parse_args()

    dates = date_range(args.date_start, args.date_stop, args.date_period)

    ingestor = Ingestor(DB_PATH, args.table, 'dtReference')
    query_path = os.path.join(ETL_DIR, f'{args.table}.sql')
    query = ingestor.import_query(query_path)
    value = '2018-01-02'

    for date in tqdm(dates):
        print(f"Executing ETL for {date}:")
        ingestor.update_table_rows(query, date)

if __name__ == "__main__":
    main()