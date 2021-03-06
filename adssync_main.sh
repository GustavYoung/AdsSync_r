#!/bin/bash
# Actualizacion dummy realtime.
# Version Alpha 0.4 bugfix 001
#
#(C) 2018 Gustavo Santana
#For internal use only
#
#bugs? contact at gus.santana(at)icloud.com
#tput setab [1-7] Set the background colour using ANSI escape
#tput setaf [1-7] Set the foreground colour using ANSI escape
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
white=`tput setaf 7`
bg_black=`tput setab 0`
bg_red=`tput setab 1`
bg_green=`tput setab 2`
bg_white=`tput setab 7`
ng=`tput bold`
reset=`tput sgr0`
#echo "${red}red text ${green}green text${reset}"
configfile='/home/uslu/AdsSync_r/sync.cfg'
configfile_secured='/tmp/sync.cfg'

# Elemento de seguridad previene el envenenamiento del archivo de configuracion
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
    echo "El archivo de configuracion fue alterado, limpiando..." >&2
# Filtrar el contenido peligroso :S :P
    egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
    configfile="$configfile_secured"
fi

# Ahora con todo limpio se puede continuar :)
. "$configfile"
echo "Leyendo configuración" >&2
echo "Version ${red}0.7.22_rpgi${reset}" >&2
echo "Usuario del cliente en FTP:${green} $client_user${reset}" >&2
echo "Velocidad en kb/s: ${green}$ancho_banda${reset}" >&2

currsh=$0
currpid=$$
runpid=$(lsof -t $currsh| paste -s -d " ")
if [[ $runpid == $currpid ]]
then
      touch /home/uslu/AdsSync_r.lock
      RC=1 
      while [[ $RC -ne 0 ]]
      do
      rsync -avh -e "ssh -o StrictHostKeyChecking=no -i /home/uslu/.ssh/id_rsa -p65520" --exclude "*.m3u" --exclude "/home/uslu/ropongi/uploads/genres" --include-from "/home/uslu/gstool/extensions.dll" --partial --bwlimit="$ancho_banda" --delete --progress --log-file=/home/uslu/AdsSync_r/updatelogs/$(date +%Y%m%d)_realt.log uxm3@uxmde.uxmalstream.com:{/home/uxm3/users/$client_user/contenidos/Banners,/home/uxm3/users/$client_user/contenidos/Video_chico,/home/uxm3/users/$client_user/contenidos/Spots_con_audio,/home/uxm3/users/$client_user/contenidos/Spots_sin_audio,/home/uxm3/users/$client_user/contenidos/imagenes-flotantes} /home/uslu/elements/;
      RC=$?
      rm /home/uslu/AdsSync_r/updatelogs/*realt.log
      if [[ $RC -eq 23  ]] || [[ $RC -eq 20 ]]
      then
      sleep 60
      RC=0
      fi
      done
      echo " ";
      echo "Todo listo";
      echo " ";
      rm /home/uslu/AdsSync_r.lock
      exit;
else
    echo -e "\nPID($runpid)($currpid) ::: At least one of \"$currsh\" is running !!!\n"
    false
    exit 1
fi

