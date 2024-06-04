#!/bin/bash -xl

################################################################################
############
##   Nome: exec_limp_bkpeados.sh
## 
##   Descricao:
##   
##   Remocao de arquivos ja copiados para dpns32 e com mais de 2 dias
##
##    Uso:
##   ./exec_limp_bkpeados.sh {HH} {DIR}
## 
##  Autor 
##  1(T) Leandro                 
##  Alteracoes	1T(T)Alana
##		1T(T)Renata Sena e 1T(T)Neris
##		CT(T)Neris - 18SET2021
##
################################################################################
#

if [ $# -ne 2 ] 
then
   echo
   echo "Voce deve entrar com o horario de referencia (00 ou 12) e "
   echo " e diretorio para remocao (wind, iconatl, icondata_ant, icondata_met5)"
   echo
  exit 12
fi

HH=$1
DIR=$2
dtk=1	# days to keep

case ${DIR} in
   iconatl)
   dirdpns24_bkp="/home/dwdman/icondata/atl${HH}"
   ;;
   wind)
   dirdpns24_bkp="/home/dwdman/icondata/wind${HH}"
   ;;
   icondata_ant)
   dirdpns24_bkp="/home/dwdman/backup/icondata/antartica"
   #dirdpns42="/data2/backup/backup_icon/bkp_input_icondata_ant"
   dirdpns42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icondata_ant"
   ;;
   icondata_met5)
   dirdpns24_bkp="/home/dwdman/backup/icondata/metarea5"
   #dirdpns42="/data2/backup/backup_icon/bkp_input_icondata_met5"
   dirdpns42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icondata_met5"
   ;;
esac

echo $dirdpns24_bkp
for arq in `find $dirdpns24_bkp -mtime +${dtk}`
do
tam=`ls -ltr $arq | awk '{ print $5 }'`
num=`echo $arq | grep -o "/" | wc -l`
num=$((num+1))
nome=`echo $arq | cut -f${num} -d"/"`

   if [ -e ${dirdpns42}/${nome} ]
   then
       tam2=`ls -ltr ${dirdpns42}/${nome} | awk '{ print $5 }'`
       dif=`echo "scale=2; ($tam2 - $tam) * 1000 / $tam " | bc`
       dif=`echo "scale=2; sqrt ( $dif * $dif ) " | bc `
       
       if [ $dif -lt 2 ]
       then
           echo "check 1 - removendo  $arq"
		rm $arq
       else
           echo "check 2 - copiando $arq para dpns33, pois o tamanho estava inferior ao local..."
           cp $arq ${dirdpns42}
       fi
    else
       echo "check 3 - copiando $arq para dpns33..."
       cp $arq ${dirdpns42}
    fi

done

