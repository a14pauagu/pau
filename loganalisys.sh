#!/bin/bash
#lflogin.reg
#ficheros:
#	-lflogins.tmp: linias keyword + ip
#	-susp_lines.log: ip d'intents erronis
#	-atack_attempts.log
log=$1
if [ ! -e "${log}" ]; then
    echo "no s'ha trobat el fitxer ${log}" >&2
    exit 1
fi
rm susp_lines.log
awk '{ print $6, $(NF - 3) }' $log > lflogins.tmp #amb log original $7, $11; amb log editat $1, $2.
counter=0
p=Failed
touch susp_lines.log
while read parameter; do #una row per cada linia
	counter=$((counter + 1))
	pass=$(sed -n ${counter}p ./lflogins.tmp | awk '{ print $1 }') #extreu paraula clau
	ip=$(sed -n ${counter}p ./lflogins.tmp | awk '{ print $2 }') #extreu 2a dada del parametre
	if [[ "$pass" == "$p" ]]; then #comprova que el parametre conté la paraula clau: password
		if [[ "$ip" == *"."*"."*"."* ]]; then
			echo "${parameter}" | awk '{ print $2 }' >> susp_lines.log
		else
			continue
		fi
	else
		continue
	fi
done < lflogins.tmp
# substituir linies entre bucles
sort susp_lines.log | uniq -c | sort -gr > atack_attempts.log
counter=1
cat atack_attempts.log > lflogins.tmp
echo $SECONDS
echo "Count,IP,Location" > atack_attempts.log
while read ips; do
	ip=$(sed -n ${counter}p lflogins.tmp | awk '{ print $2 }')
	gip=$(geoiplookup "${ip}" | awk '{ print $5,$6 }')
	interc=$(sed -n ${counter}p lflogins.tmp | awk '{ print $1 }' )
	if [[ $interc -gt 9 ]]; then
		echo ${interc}','${ip}','${gip} >> atack_attempts.log
	else
		counter=$((counter + 1))
		continue
	fi
	counter=$((counter + 1))
done < lflogins.tmp
rm lflogins.tmp
echo $SECONDS
exit 1

