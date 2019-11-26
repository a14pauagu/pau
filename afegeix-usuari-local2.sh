#!/bin/bash

#https://github.com/a14pauagu/pau
# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -eq 0 ]]
then
# If the user doesn't supply at least one argument, then give them help.
	if [[ "$#" -gt 0 ]]
	then
		echo "Me encantan tus argumentos"
# The first parameter is the user name.
		u_name=$1

# The rest of the parameters are for the account comments.
		f_name=$2
# Generate a password.
		u_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
# Create the user with the password.
		useradd -m -p ${u_pass} "${u_name}" -c ${f_name}
		c_usu=$(cat /etc/passwd | grep ${u_name}) 
# Check to see if the useradd command succeeded.
		if [[ "${u_name}"="${c_usu}" ]]
		then
			echo "Usuari creat satisfactoriament :)"
		else 
			exit 1
		fi
# Set the password.
		u_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
		echo "${u_name}:${u_pass}" | chpasswd
		c_pass=$(cat /etc/shadow | grep ${u_name})
# Check to see if the passwd command succeeded.
		if [[ "$u_name"="$c_pass" ]]
		then
			echo "Contrassenya modificada satisfactoriament"
		else
			exit 2
		fi
# Force password change on first login.
		passwd -e ${u_name}
# Display the username, password, and the host where the user was created.
		echo "Nom d'usuari: ${u_name}"
		echo "Comentari: ${f_name}"
		echo "Contrassenya: ${u_pass}"

	else
		echo "No tienes argumentos >:("
	fi
else
	echo "No tienes poder aqui >:("	
	exit 1
fi

