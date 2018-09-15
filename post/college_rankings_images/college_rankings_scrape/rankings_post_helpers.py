import pandas as pd
import urllib3
from bs4 import BeautifulSoup
import re
import ast

HTTP = urllib3.PoolManager()

def test_globe():
    print('i have access to this variable')
    print(HTTP)

# def collect_payscale_info():
#     base_url = 'https://www.payscale.com/college-salary-report/bachelors?page=101'
#     page = urllib2.urlopen(base_url)
#     soup = BeautifulSoup(page, 'html.parser')
#     all_colleges = str(soup).split("var collegeSalaryReportData = ")[1].split('},{')
#     college_list = []
#     for i in all_colleges:
#     	try:
#     		college_list.append(ast.literal_eval("{" + i.replace("[{", "") + "}"))
#     	except Exception as e:
#     		print(e)
#     college_df = pd.DataFrame(college_list)
#     return(college_df)

# def collect_college_ranks(college_df):
#     base_url = 'https://www.forbes.com/colleges/'
#     rank_list = []
#     count = 1
#     for college_name in college_df['college_name']:
#         print(str(round(count/float(len(college_df['college_name'])) * 100, 2)) + '% Complete')
#         try:
#             tmp_url = base_url + college_name.lower().replace(" ", "-") + "/"
#             page = urllib2.urlopen(tmp_url)
#             soup_str = str(BeautifulSoup(page, 'html.parser'))
#             college_rank = re.search(r'class="rankonlist">#(.*?) <a href="/top-colleges/list/"', 
#                                      soup_str).group(1)
#             rank_list.append([college_name, college_rank])
#         except Exception as e:
#             rank_list.append([college_name, None])
#             print(e)
#         count += 1
#     rank_df = pd.DataFrame(rank_list)
#     rank_df = rank_df.rename(columns={rank_df.columns[0]: "college_name",
#                                       rank_df.columns[1]: "rank"
#                                   })
#     return(rank_df)