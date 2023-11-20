import csv
import unicodedata

def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return "".join([c for c in nfkd_form if not unicodedata.combining(c)])

with open('Player_Totals.csv', 'r') as csvfile:
    csv_reader = csv.reader(csvfile)

    with open('new_player_totals.csv', 'w') as file:
        csv_writer = csv.writer(file)
        for line in csv_reader:
            line[3] = remove_accents(line[3])
            csv_writer.writerow(line)
