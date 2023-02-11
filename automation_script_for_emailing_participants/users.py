import csv
import string
import random
import keyboard
import requests

filepath = "./sample_participants_data.csv"


def flen(fpath):
    file = open(fpath)
    fileLen = len(list(csv.reader(file)))
    file.close()
    return fileLen

def scrape(reader, fileLen):
    print(fileLen)
    for i in range(fileLen-1):
        row = next(reader)
        t = i+1
        tid = str(t) if t > 99 else "0" + str(t) if t > 9 else "00" + str(t)
        # print(tid)
        password = ''.join(random.choices(string.ascii_letters, k=6))
        player1,player2 = row[2], row[6] #full name
        p1_f, p2_f = player1.split(" ")[0], player2.split(" ")[0]

        #emailfor mailing directly to the user
        email = row[1]

        print(f"Tid: {tid} \nPlayer1: {p1_f} { 'Player2: ' + p2_f if p2_f != '' else ''} \nEmail: {email} Password: {password}\n")

# refer to this to send automated emails
# https://towardsdatascience.com/how-to-distribute-your-data-reports-via-mail-with-a-few-lines-of-code-8df395c72e55

# use the following endpoints to create users
# /users/new_user
# form-data
# {
#     "tid":"tid",
#     "password":"password",
#     "guess_loc_coupon": 0, // or 1
#     "meter_off_coupon": 0, // or 1
#     "freeze_team_coupon": 0, // or 1
# }

if __name__ == "__main__":
    fileLen = flen(filepath)
    file = open(filepath)
    reader = csv.reader(file)
    header = next(reader)
    scrape(reader, fileLen)