import requests
import pandas as pd
import numpy as np
import csv
import unicodedata
from bs4 import BeautifulSoup
# import matplotlib.pyplot as plt

def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return "".join([c for c in nfkd_form if not unicodedata.combining(c)])


#create cpi table
cpiDict = {}
with open('cpi.csv', 'r') as cpi:
    csv_reader = csv.reader(cpi)
    count = 0
    for line in csv_reader:
        if count != 0:
            year = int(line[0])
            equiv100bucks = float(line[1])
            cpiDict[year] = equiv100bucks
        count += 1

url="https://hoopshype.com/salaries/players/"

dfs = []
for i in range(1990, 2023):
        newUrl = url + f"{i}-{i+1}/"
        r = requests.get(newUrl,timeout=100)
        r_html = r.text

        soup = BeautifulSoup(r_html, 'html.parser')
        salary_table = soup.find('table')
        length=len(salary_table.find_all("td"))

        player_names=[salary_table.find_all("td")[j].text.strip() for j in range(5,length,4)]
        seas = [i + 1 for _ in range(5,length,4)]
        sals=[salary_table.find_all("td")[j].text.strip() for j in range(6,length,4)]

        adjust = cpiDict[i]
        currmoney = cpiDict[2022]
        adj2023 = [(currmoney * (int(j.replace('$','').replace(',',''))/adjust))//1 for j in sals]

        df_dict={'player_names':player_names,
        'season':seas,
        'salaries':sals,
        'adj': adj2023
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

with open('Player_Totals.csv', 'r') as csvfile:
    csv_reader = csv.reader(csvfile)

    with open('new_player_totals.csv', 'w') as file:
        csv_writer = csv.writer(file)
        for line in csv_reader:
            line[3] = remove_accents(line[3])
            csv_writer.writerow(line)
