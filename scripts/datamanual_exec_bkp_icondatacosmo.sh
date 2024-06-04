#!/bin/bash
set -x
################################################################################
############
##   Nome: exec_bkp_icondata2nexis.sh
## 
##   Descricao:
##   
##   Backup dos dados recebidos diarimente do DWD (recortes para rodada do ICON 
##   metarea e ICON antartica 
##
##    Uso:
##   ./exec_bkp_icondata2nexis.sh {HH} {DIR}
## 
##  Autor Ten Leandro 
##  Modificado por Ten Alana                 
##                                                               
################################################################################
#                                   

if [ $# -ne 2 ] 
then
   echo
   echo "Entre com o horario de referencia (00 ou 12) e "
   echo " e diretorio para remocao (icondata_ant,icondata_met5)"
   echo
  exit 12
fi

HH=$1
DIR=$2
datacorrente=`cat /home/dwdman/datas/datacorrente${HH}`
datacorrente=20210918

case ${DIR} in
   icondata_ant)

   dirdpns24="/home/dwdman/gmedata/dataant${HH}"
   dirdpns24_bkp="/home/dwdman/backup/icondata/antartica"
   dirdpns33="/mnt/nfs/dpns33/data1/backup/backup_icon/backup_icondata_ant"
   filename="iconant_"
   filename2="iconant_"
   cp ${dirdpns24}/* /home/dwdman/backup/icondata/antartica/
   ;;
   icondata_met5)

   dirdpns24="/home/dwdman/gmedata/data${HH}"
   dirdpns24_bkp="/home/dwdman/backup/icondata/metarea5"
   dirdpns33="/mnt/nfs/dpns33/data1/backup/backup_icon/backup_icondata_met5"
   filename="iconmet_"
   filename2="iconmet_"
   cp ${dirdpns24}/* /home/dwdman/backup/icondata/metarea5/
   ;;
esac

#
echo "================================="
echo  Organiza dados no diretorio de backup
echo "================================="
#
cd  ${dirdpns24_bkp}/
bzip2 -d icon_new.bz2
data=`cat icon_new | head -1`

if [ $data -eq $datacorrente ]
   then
   echo " Dados com data atual. Os arquivos serao zipados!"
   bzip2 -z icon_new
   tar -cf ${filename}${datacorrente}${HH}.tar.bz2 `ls ig?ff0???0000.bz2 icon_new.bz2` 
   bzip2 -z ${filename2}${datacorrente}${HH}.tar.bz2
fi
echo
echo removendo os arquivos no diretorio backup
echo
rm icon_new.bz2
rm icon_new
echo
echo " Transferindo os dados para dpns33 ..."
echo
    rsync -av --ignore-existing ${dirdpns24_bkp}/*.tar.bz2 ${dirdpns33}/
echo
echo " Verifica os arquivos antigos "
echo " e apaga se a atualizacao for maior do que 2 dias"
echo
/home/dwdman/scripts/exec_limp_bkpeados.sh $HH $DIR
#
