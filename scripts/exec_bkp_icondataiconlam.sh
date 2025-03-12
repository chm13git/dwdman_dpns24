#!/bin/bash -l

################################################################################
##   Descricao:
##   Backup dos dados recebidos diarimente do DWD (recortes para rodada do ICON 
##   sam e ICON ant
##
##    Uso:
##   ./script {HH} {GRID}
## 
##  Modificado por Ten Neris
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
   dirdpns24="/home/dwdman/dwdinput/data_ant${HH}"
   dirdpns24_bkp="/home/dwdman/backup/icon4iconlam/bkp_ant${HH}"
   rsyncdir42="admbackup@dpns42:/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
   mntdir42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
   filename="icon4iconlamant_"
   ndaystokeep=1
   ;;
   sam)
   dirdpns24="/home/dwdman/dwdinput/data_sam${HH}"
   dirdpns24_bkp="/home/dwdman/backup/icon4iconlam/bkp_sam${HH}"
   rsyncdir42="admbackup@dpns42:/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
   mntdir42="/mnt/nfs/dpns42/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
   filename="icon4iconlamsam_"
   ndaystokeep=1
   ;;
esac

#
echo "================================="
echo  Organiza dados no diretorio de backup
echo "================================="
#

nmax=720
sleeptime=30
ntent=1
flag=1

while [ $flag -eq 1 ];do

	echo "================================="
	echo "Checando data dos dados - Tentativa $ntent"
	echo "================================="
	echo
	echo "Copiando dados para ${dirdpns24_bkp}..."
	echo
	cp ${dirdpns24}/i* ${dirdpns24_bkp}

	cd  ${dirdpns24_bkp}/
	bzip2 -d icon_new.bz2		# unzipping
	data=`cat icon_new | head -1`	# catching data DATE
	bzip2 -z icon_new		# rezipping
	
	if [ $data -eq $datacorrente ];then
		echo " Dados com data atual. Os arquivos serao zipados!"
		echo
		echo "Targeando..."
		echo 
		tar -cf ${filename}${datacorrente}${HH}.tar `ls ig?ff0???0000.bz2 icon_new.bz2` 
		#echo "Bunzipando..."
		#echo
		#bzip2 -z ${filename}${datacorrente}${HH}.tar
		flag=0
	else
		echo " WARNING! Dados com data diferente da corrente ($datacorrente)."
		echo "Esperando 30s para reiniciar o processo..."
		echo
		rm ${dirdpns24_bkp}/i*
		ntent=$((ntent+1))
		sleep $sleeptime
	fi

	if [ $ntent -gt $nmax ];then
		echo "FATAL ERROR! Esperei por 6 horas mas os dados corretos nao chegaram."
		echo "Abortando script de backup do ICONLAM $HH $GRID!"
		exit 2
	fi
done

echo
echo removendo os arquivos no diretorio backup
echo
rm icon_new.bz2
echo
echo " Transferindo os dados para dpns42..."
echo
rsync -av --ignore-existing ${dirdpns24_bkp}/*.tar.bz2 ${rsyncdir42}/
echo
echo "============================================================="
echo " Verificando os arquivos antigos "
echo " e apagando se a data for maior do que ${ndaystokeep} dia(s)"
echo "============================================================="
echo

time /home/dwdman/scripts/limpar_bkp_icon4iconlam.sh $HH $GRID

date
echo "Fim do script de backup ICONLAM $HH $GRID."
#
