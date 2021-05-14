import requests,pathlib
from datetime import date
import pandas as pd

data_dir = pathlib.Path(__file__).parent.absolute().joinpath('data')

def main():
    today = date.today()
    now=today.strftime("%Y-%m-%d")

    query="query?f=json&returnGeometry=false&outFields=*&where=1=1"

    url_list={"countydata":"https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_county_condensed_data",
        "trends":"https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_trends_data",
        "vaccination":"https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data"}

    for slug, u in url_list.items():
        url = u+query
        j=requests.get(url)
        data = j.json()
        df = pd.json_normalize(data["features"])
        df.columns = df.columns.str.replace("attributes.","")
    

        df.to_csv(data_dir.joinpath(f"{slug}-{now}.csv"),index=False)
        df.to_csv(data_dir.joinpath(f"{slug}-latest.csv"),index=False)

if __name__ == "__main__":
    main()
