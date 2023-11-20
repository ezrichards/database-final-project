import requests
from bs4 import BeautifulSoup
import pandas as pd
# import matplotlib.pyplot as plt
import numpy as np

url="https://hoopshype.com/salaries/players/"

dfs = []
for i in range(1990, 2022):
        newUrl = url + f"{i}-{i+1}/"
        r = requests.get(newUrl,timeout=100)
        r_html = r.text

        soup = BeautifulSoup(r_html, 'html.parser')
        salary_table = soup.find('table')
        length=len(salary_table.find_all("td"))

        player_names=[salary_table.find_all("td")[j].text.strip() for j in range(5,length,4)]
        seas = [i + 1 for _ in range(5,length,4)]
        sals=[salary_table.find_all("td")[j].text.strip() for j in range(6,length,4)]

        df_dict={'player_names':player_names,
        'season':seas,
        'salaries':sals
        }
        
        salary_df=pd.DataFrame(df_dict)

        print(salary_df)
        dfs.append(salary_df)


# print(salary_table.find_all("td"))

totalDF = pd.DataFrame()
for i in dfs:
        totalDF = pd.concat([totalDF,i])

print(totalDF)
totalDF.to_csv('./salary.csv')

# column1=[salary_table.find_all("td")[i].text.strip() for i in range(10,length,8)]
# column2=[salary_table.find_all("td")[i].text.strip() for i in range(11,length,8)]
# column3=[salary_table.find_all("td")[i].text.strip() for i in range(12,length,8)]
# column4=[salary_table.find_all("td")[i].text.strip() for i in range(13,length,8)]
# column5=[salary_table.find_all("td")[i].text.strip() for i in range(14,length,8)]
# column6=[salary_table.find_all("td")[i].text.strip() for i in range(15,length,8)]
