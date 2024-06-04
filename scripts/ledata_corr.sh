#!/bin/bash
#
#  script ledata_corr.sh
#
#  leitura da data-corrente
#
#  CF Costa Neves 17FEV2005
#  Atualização:30JAN06 para ser usado na DPN5 - CT NILZA BARROS 
# Atualizacao: 24MAI2010 - Colocar os dois scripts de data num so - CF Luiz CLaudio
# Atualizacao: 27NOV2023 - Removidos arquivos nao utilizados (dia, MES etc) - CT Neris
#               
# ---------------------------------------------------------
# Passo 1: Verifica a hora de referencia
if [ $# -ne 1 ]
then
     echo "Entre com o horario de referencia (00 ou 12)!!!!!"
     exit
fi
HH=$1
#
# ---------------------------------------------------------
# Passo 2: Cria arquivos
#
rm -f ~/datas/datacorrente$HH
#
#  le data corrente e copia para arquivo
#
date +%Y%m%d > ~/datas/datacorrente$HH
cat ~/datas/datacorrente$HH
#
# fim
