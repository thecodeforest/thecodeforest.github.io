import urllib2
from bs4 import BeautifulSoup
import re

def find_best_bars():
    base_url = 'http://www.oregonlive.com/dining/index.ssf/2014/10/portlands_100_best_bars_bar_ta.html'
    page = urllib2.urlopen(base_url)
    soup = BeautifulSoup(page, 'html.parser')
    bar_descriptors = soup.find_all("div",class_ = 'entry-content')
    bar_descriptors = str(bar_descriptors).split("<p>")
    bar_descriptors
    bar_list = []
    for entry in bar_descriptors:
        try:
            bar_name = re.search('<strong>(.*)</strong>', entry)\
                                                          .group(1)

            bar_address = re.search('<em>(.*).', entry)\
                                                 .group(1)\
                                                 .split(",")[0]\
                                                 .split(";")[0]
            bar_list.append([bar_name, bar_address])
        except Exception as e:
            print(e)
    # check to make sure first letter of address is a digit
    bar_list = [x for x in bar_list if x[1][0].isdigit()]
    bar_list = map(lambda x: [x[0], x[1] + " Portland, OR"], bar_list)
    best_bars_dict = {x[0] : x[1] for x in bar_list}
    return(best_bars_dict)