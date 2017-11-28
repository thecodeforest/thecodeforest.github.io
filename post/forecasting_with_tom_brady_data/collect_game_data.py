from urllib import urlopen
import re
import pandas as pd
from bs4 import BeautifulSoup
import sys
import os.path
base_url = 'http://www.footballdb.com/teams/nfl/new-england-patriots/teamvsteam?opp='
game_data = []
n_teams = 32
output_location = os.path.join(sys.argv[1], sys.argv[2])
for team_number in range(1, n_teams + 1, 1):
    page  = str(BeautifulSoup(urlopen(base_url + str(team_number)), 
                              'html.parser').findAll("table"))
    for row in [x.split("<td>") for x in page.split("row")]:
        try:
            game_date, outcome = str(re.findall('gid=(.*)', row[4])).split(">")[:2]
            game_data.append([game_date[2:10], outcome[0]])
        except:
            continue
game_data_df = pd.DataFrame(game_data)
game_data_df.columns = ['date', 'outcome']
game_data_df.to_csv(output_location,  index = False)
