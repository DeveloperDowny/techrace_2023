import csv
import keyboard
import requests

filepath = "./sample_data_with_format.csv"
file = open(filepath)
reader = csv.reader(file)
no_lines = len(list(reader))
file.close()

file1 = open(filepath)
reader1 = csv.reader(file1)

header = next(reader1)

# the server endpoint is /game/add_clue
# url of the server running locally and forwarded using ngrok
url = "https://b5c0-150-242-199-116.in.ngrok.io/game/add_clue"

for i in range(no_lines):
    row = next(reader1)

#design payload
    cid = row[1]
    clue = row[2]
    if(row[3] == ''):
        clue_type = 't'
    else:
        clue_type = row[3]
    hint_1 = row[4]
    if (row[5] == ''):
        hint_1_type = 't'
    else:
        hint_1_type = row[5]
    hint_2 = row[6]
    if (row[7] == ''):
        hint_2_type = 't'
    else:
        hint_2_type = row[7]
    lat = row[8]
    long = row[9]
    guess_list = []
    for i in range(10, len(row)):
        if(row[i] != ''):
            guess_list.append(row[i])

    payload = {
        "cid": f"{row[1]}{row[0]}",
        "clue": clue,
        "clue_type": clue_type,
        "hint_1": hint_1,
        "hint_1_type": hint_1_type,
        "hint_2": hint_2,
        "hint_2_type": hint_2_type,
        "lat": lat,
        "long": long,
        "guess_options": guess_list
    }
    print()
    print(payload)
    print()
    keyboard.wait('enter') # check if payload is correct
    response = requests.post(url, json=payload)
    print(response.text)
    keyboard.wait('enter') # check if response is correct