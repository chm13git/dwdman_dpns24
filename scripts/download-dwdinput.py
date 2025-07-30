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
if len(sys.argv) < 5:
    print('Insufficient arguments. Usage:')
    print(f'{sys.argv[0]} HH AREA HSTART HSTOP')
    sys.exit(1)

HH = sys.argv[1]
AREA = sys.argv[2]
HSTART = int(sys.argv[3])
HSTOP = int(sys.argv[4])
date = date.today().strftime('%Y%m%d')
#date = "20250704"
username = 'nwp_brasn'
password = 'CLqDqTNDrlUKy_BL'
HOMEDirectory = '/home/dwdman/scripts'
DataDir = f"/home/dwdman/dwdinput/data_{AREA}{HH}" # Diretorio de destino dos dados que serao baixados
base_url = f"https://data.dwd.de/data/{date}/data_{AREA}{HH}" # URL de origem dos dados que serao baixados
os.makedirs(DataDir, exist_ok=True)

os.chdir(DataDir)

file_initial = ["icon_new.bz2"]
min_file_size_initial = 30

div = 24
hstart = HSTART
hstop = HSTOP

file_names=[]

# Loop para criar prog de 0 até 48 com intervalo de 3
for tempo in range(hstart, hstop + 1, 3):  # 49 é limite superior exclusivo
    HH = tempo % div       # Calcula o resto da divisão
    DD = tempo // div  # Calcula o quociente da divisão

    # Exibe os resultados
    filename = f"igfff{DD:02}{HH:02}0000.bz2"
    file_names.append(filename)

print("file_names=",file_names)

min_file_size = 78717419

#def download_file(base_url, filename, min_file_size=78717419, max_attempts=180):
def download_file(base_url, filename, min_file_size, max_attempts=180):
    for attempt in range(1, max_attempts + 1):
        response = requests.get(base_url, auth=(username, password), stream=True)
        if response.status_code == 200:
            total_size = int(response.headers.get('content-length', 0))
            if total_size < min_file_size:
                print(f'File size is too small ({total_size} bytes). Attempt {attempt}/{max_attempts}. Retrying in 60 seconds...')
                time.sleep(60)
            else:
                with open(filename, 'wb') as f:
                    for data in response.iter_content(chunk_size=1024):
                        f.write(data)
                print(f'Download successful: {filename}')
                return filename
        else:
            print(f'Error downloading file (attempt {attempt}/{max_attempts}). Status code: {response.status_code}. Retrying in 60 seconds...')
            time.sleep(60)
        if attempt > max_attempts:
            print(f'Failed to download the file after several attempts: {filename}')
            stop()
    return None

# Baixando o arquivo icon_new.bz2 que tem tamanho muito menor que os outros arquivos
for file_name in file_initial:
    file_url = f"{base_url}/{file_name}"
    now = datetime.now()
    print(now.strftime("%Y-%m-%d %H:%M:%S"))
    print(f'Downloading: {file_url}')
    download_file(file_url, os.path.join(DataDir, file_name), min_file_size_initial)

# Baixando os demais arquivos igfff* para rodar o ICONLAM
for file_name in file_names:
    file_url = f"{base_url}/{file_name}"
    now = datetime.now()
    print(now.strftime("%Y-%m-%d %H:%M:%S")) 
    print(f'Downloading: {file_url}')
    download_file(file_url, os.path.join(DataDir, file_name), min_file_size)

