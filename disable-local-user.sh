#!/bin/bash
#usuari hostname i port(si no especifica es 3306 sino entre 1024 65535),
#opcionalment t comprova connexió
#define sintaxis del scrip
#1- root sino exit 1
#2- usage
#3-diable/expire acc by default
#4- opcions: -d delete | -r del home directory | -a archivo de los directorios /home/
usage() { echo "Usage: $0 [-d elimina usuaris donats] [-r elimina directori home del usuari] [-a genera log que conte tots els directoris /home/] [llista dusuaris]" 1>&2; exit 1;}
if [[ "${UID}" -eq 0 ]]
then
	while getopts "dra" o; do
		case "${o}" in
			d)
				delete=1
				;;
			r)
				home=1
				;;
			a)
				lhome=1
				;;
			*)
				usage
				;;
		esac
	done
	#ajusta el contador de  arguments
	shift $((OPTIND - 1))
	for parameter in $@; do
		if [[ $parameter == "-"? ]]; then
			echo "Sha detectat una bandera entre els arguments, skip"
		else
			if [[ -z $delete && -z $home && -z $lhome ]]; then
##bloqueja usuari
				passwd "${parameter}" -l
			else
				if id -u "${parameter}"; then
					echo "Operació sobre ${parameter}"
				else
					continue
				fi
                                uid=$(id -u "$parameter")
				if [[ uid -lt 1001 ]]; then
					echo "no es permet eliminar usuaris amb uid inferior o igual a 1000"
					continue
				fi
				if [[ -n ${delete} ]]; then
					userdel "${parameter}"
					echo "Usuari ${parameter} eliminat"
				fi
				if [[ -n ${home} ]]; then
					rm -r /home/"${parameter}"
					echo "Directori del usuari ${parameter} eliminat"
				fi
			fi
		fi
	done
	if [[ -n ${lhome} ]]; then
		if [[ -d /archive/ ]]; then
			ls /home/ > /archive/user_home.log
			echo "sha general un nou log actualitzat, pots trobarlo a /archive/"
		else
			mkdir /archive
			ls /home/ > /archive/user_home.log
			echo "sha creat el directori /archive/ i sha generat el fitxer user_home.log"
		fi
	fi
else
	echo "Aquest programa sha dexecutar com a root."
	exit 1
fi
