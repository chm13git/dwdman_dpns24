#!/home/dwdman/miniconda3/bin/python

# Script created by Alana in April 2024 for downloading and interpolating ICON13km Model data.
import requests
import os
import sys
from datetime import date
from datetime import datetime
import time
import subprocess

# Main script execution
if len(sys.argv) < 3:
    print('Insufficient arguments. Usage:')
    print('download_dwdinput.py HH AREA')
    sys.exit(1)

HH = sys.argv[1]
AREA = sys.argv[2]
date = date.today().strftime('%Y%m%d')
#date = "20250326"
username = 'nwp_brasn'
password = 'CLqDqTNDrlUKy_BL'
HOMEDirectory = '/home/dwdman/scripts'
#DataDir = f"/home/operador/metview/scripts/dwdinput/{date}/data_{AREA}{HH}"
DataDir = f"/home/dwdman/dwdinput/data_{AREA}{HH}"
base_url = f"https://data.dwd.de/data/{date}/data_{AREA}{HH}"
os.makedirs(DataDir, exist_ok=True)

os.chdir(DataDir)

#file_names = [
#    "icon_new.bz2"     , "igfff00000000.bz2", "igfff00030000.bz2", "igfff00060000.bz2", 
#    "igfff00090000.bz2", "igfff00120000.bz2", "igfff00150000.bz2", "igfff00180000.bz2", 
#    "igfff00210000.bz2", "igfff01000000.bz2", "igfff01030000.bz2", "igfff01060000.bz2", 
#    "igfff01090000.bz2", "igfff01120000.bz2", "igfff01150000.bz2", "igfff01180000.bz2", 
#    "igfff01210000.bz2", "igfff02000000.bz2", "igfff02030000.bz2", "igfff02060000.bz2", 
#    "igfff02090000.bz2", "igfff02120000.bz2", "igfff02150000.bz2", "igfff02180000.bz2", 
#    "igfff02210000.bz2", "igfff03000000.bz2", "igfff03030000.bz2", "igfff03060000.bz2", 
#    "igfff03090000.bz2", "igfff03120000.bz2", "igfff03150000.bz2", "igfff03180000.bz2", 
#    "igfff03210000.bz2", "igfff04000000.bz2", "igfff04030000.bz2", "igfff04060000.bz2", 
#    "igfff04090000.bz2", "igfff04120000.bz2", "igfff04150000.bz2", "igfff04180000.bz2", 
#    "igfff04210000.bz2", "igfff05000000.bz2"
#]

file_names = [
    "igfff00000000.bz2", "igfff00030000.bz2", "igfff00060000.bz2",
    "igfff00090000.bz2", "igfff00120000.bz2", "igfff00150000.bz2", "igfff00180000.bz2",
    "igfff00210000.bz2", "igfff01000000.bz2", "igfff01030000.bz2", "igfff01060000.bz2",
    "igfff01090000.bz2", "igfff01120000.bz2", "igfff01150000.bz2", "igfff01180000.bz2",
    "igfff01210000.bz2", "igfff02000000.bz2", "igfff02030000.bz2", "igfff02060000.bz2",
    "igfff02090000.bz2", "igfff02120000.bz2", "igfff02150000.bz2", "igfff02180000.bz2",
    "igfff02210000.bz2", "igfff03000000.bz2", "igfff03030000.bz2", "igfff03060000.bz2",
    "igfff03090000.bz2", "igfff03120000.bz2", "igfff03150000.bz2", "igfff03180000.bz2",
    "igfff03210000.bz2", "igfff04000000.bz2", "igfff04030000.bz2", "igfff04060000.bz2",
    "igfff04090000.bz2", "igfff04120000.bz2", "igfff04150000.bz2", "igfff04180000.bz2",
    "igfff04210000.bz2", "igfff05000000.bz2"
]


def download_file(base_url, filename, min_file_size=78717419, max_attempts=180):
    for attempt in range(1, max_attempts + 1):
        response = requests.get(base_url, auth=(username, password), stream=True)
        if response.status_code == 200:
            total_size = int(response.headers.get('content-length', 0))
            if total_size < min_file_size:
                print(f'File size is too small ({total_size} bytes). Attempt {attempt}/{max_attempts}. Retrying in 60 seconds...')
            else:
                with open(filename, 'wb') as f:
                    for data in response.iter_content(chunk_size=1024):
                        f.write(data)
                print(f'Download successful: {filename}')
                return filename
        else:
            print(f'Error downloading file (attempt {attempt}/{max_attempts}). Status code: {response.status_code}. Retrying in 60 seconds...')
        time.sleep(60)
    print(f'Failed to download the file after several attempts: {filename}')
    return None

for file_name in file_names:
    file_url = f"{base_url}/{file_name}"
    now = datetime.now()
    print(now.strftime("%Y-%m-%d %H:%M:%S")) 
    print(f'Downloading: {file_url}')
    download_file(file_url, os.path.join(DataDir, file_name))



