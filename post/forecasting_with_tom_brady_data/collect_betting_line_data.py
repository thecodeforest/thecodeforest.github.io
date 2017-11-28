import urllib2
from bs4 import BeautifulSoup
import re
import pandas as pd
import sys
import os.path
base_url = "https://www.teamrankings.com/nfl/odds-history/results/"
output_location = os.path.join(sys.argv[1], sys.argv[2])
opener = urllib2.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0')]
page = BeautifulSoup(opener.open(base_url), 'html.parser')
table_data = page.find_all("tr", {"class": "text-right nowrap"})
betting_lines = []
for line in table_data:
    line_list = str(line).splitlines()
    try:
        betting_lines.append([re.search('<td>(.*)</td>', line_list[1]).group(1),
                              line_list[4].split(">")[1].split("<")[0]])
    except:
        betting_lines.append([None, None])

historic_lines_df = pd.DataFrame(betting_lines)
historic_lines_df.columns = ['spread', 'win_pct']
historic_lines_df.to_csv(output_location, index = False)