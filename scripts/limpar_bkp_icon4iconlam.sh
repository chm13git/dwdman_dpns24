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
   echo "Entre com o horario de referencia (00 ou 12) e "
   echo "grade (sam ou ant)"
   echo
  exit 12
fi

HH=$1
GRID=$2
datacorrente=`cat /home/dwdman/datas/datacorrente${HH}`

case ${GRID} in
   ant)
   dirdpns24="/backup/dwdinput/data_ant${HH}"
   dirdpns24_bkp="/backup/icon4iconlam/bkp_ant${HH}"
#   dirdpns33="/mnt/nfs/dpns33/data1/backup/backup_icon/backup_icondata_ant"
   rsyncdir42="admbackup@dpns42:/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
   mntdir42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
   filename="icon4iconlamant_"
   ndaystokeep=1
   ;;
   sam)
   dirdpns24="/backup/dwdinput/data_sam${HH}"
   dirdpns24_bkp="/backup/icon4iconlam/bkp_sam${HH}"
#   dirdpns33="/mnt/nfs/dpns33/data1/backup/backup_icon/backup_icondata_met5"
   rsyncdir42="admbackup@dpns42:/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
   mntdir42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
   filename="icon4iconlamsam_"
   ndaystokeep=1
   ;;
esac

echo "============================================================="
echo " Verificando os arquivos antigos "
echo " e apagando se a data for maior do que ${ndaystokeep} dia(s)"
echo "============================================================="
echo
for arq in `find $dirdpns24_bkp -mtime +${ndaystokeep}`;do
        tam=`ls -ltr $arq | awk '{ print $5 }'`
        num=`echo $arq | grep -o "/" | wc -l`
        num=$((num+1))
        nome=`echo $arq | cut -f${num} -d"/"`
        echo "Checando se $arq existe..."
        echo

   if [ -e ${mntdir42}/${nome} ];then
       tam2=`ls -ltr ${mntdir42}/${nome} | awk '{ print $5 }'`
       dif=`echo "scale=2; ($tam2 - $tam) * 1000 / $tam " | bc`
       dif=`echo "scale=2; sqrt ( $dif * $dif ) " | bc `

       if [ $dif -lt 2 ]; then
                echo "OK! Tamanho dentro do esperado."
                echo "Removendo $arq..."
                echo
                rm $arq
       else
                echo "WARNING! Tamanho inferior ao esperado."
                echo "Copiando $arq para $rsyncdir42..."
                echo
                rsync -av $arq ${rsyncdir42}
       fi
    else
        echo "WARNING! Arquivo $arq nao encontrado."
        echo "Copiando $arq para $rsyncdir42..."
        echo
        rsync -av $arq ${rsyncdir42}
    fi
done
date
echo "Fim do script de backup ICONLAM $HH $GRID."
#
