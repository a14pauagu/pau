#!/bin/bash
#discrimina root de noroot
if [[ "${UID}" -eq 0 ]]
then
	#Inputs, demana al usuari les dades requerides per crear l'usuari nou.
	read -p "Nombre de usuario en el sistema: " username
	read -p "Primer nombre del usuario: " fnuser
	read -p "Contraseña: " password
	#Creació del usuari i assigna contrasse
	useradd -c "${fnuser}" -m ${username} 
	#Comprova usuari
	cat /etc/passwd | grep ${username}
	#Dona pass
	echo "${username}:${password}" | chpasswd
	#comprova pass
	cat /etc/shadow | grep ${username} 
	#Obliga a cambiar pass en el proper login
	passwd -e ${username}
	#Mostra les dades del usuari
	echo "Tu username es: $username"
	echo "Tu password es: $password"
	echo "La maquina anfitrió es: "`hostname`
else
  echo "Aquest script s'ha d'executar en root"
fi


