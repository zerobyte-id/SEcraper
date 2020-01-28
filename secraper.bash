#!/bin/bash

QUERY="${1}"
FILESAVE="se-craper-result.txt"

echo '  ___ ___                            ';
echo ' / __| __|__ _ _ __ _ _ __  ___ _ _  ';
echo ' \__ \ _|/ _| `_/ _` | `_ \/ -_) `_| ';
echo ' |___/___\__|_| \__,_| .__/\___|_|   ';
echo ' by zerobyte.id      |_|  V. 2020.02 ';
echo ' ------ SEARCH ENGINE SCRAPER ------ ';
echo '';

if [[ -z ${QUERY} ]]; then
	echo "ERROR: Query is empty"
	echo "HINT: bash $0 \"QUERY HERE\""
	exit
fi

function urlencode() {
	python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" "$1"
}

##### SEARCH.YAHOO.COM #####
PAGE="1"
i=0
while true
do
	((i++))
	YAHOO_SEARCH=$(curl -sk "https://search.yahoo.com/search?p=$(urlencode "${QUERY}")&b=${PAGE}")
	echo " ======= YAHOO PAGE ${i} ======="
	for URLs in $(echo "${YAHOO_SEARCH}" | grep -Po '<a class=" ac-algo fz-l ac-21th lh-24" href="\K.*?(?=")')
	do
		echo " => ${URLs}"
		echo "${URLs}" >> ${FILESAVE}
	done
	PAGE=$(echo "${YAHOO_SEARCH}" | grep -Po '<a class="next" href="(.*?)b=\K.*?(?=\&)')
	if [[ ! -n ${PAGE} ]]; then
		break
	fi
done

##### BING.COM #####
PAGE="1"
i=0
while true
do
	((i++))
	LASTPAGE=${PAGE}
	BING_SEARCH=$(curl -sk "https://www.bing.com/search?q=$(urlencode "${QUERY}")&first=${PAGE}&FORM=PORE")
	PAGE=$(echo "${BING_SEARCH}" | grep -Po 'title="Next page" href="(.*?)first=\K.*?(?=\&)')
	echo " ======= BING PAGE ${i} ======="
	for URLs in $(echo "${BING_SEARCH}" | grep -Po '<h2><a href="\K.*?(?=")')
	do
		echo " => ${URLs}"
		echo "${URLs}" >> ${FILESAVE}
	done
	if [[ ! -n ${PAGE} ]]; then
		break
	elif [[ ${PAGE} -gt ${LASTPAGE} ]]; then
		break
	fi
done

##### ASK.COM #####
PAGE="1"
i=0
while true
do
	((i++))
	ASK_SEARCH=$(curl -sk "https://www.ask.com/web?o=0&l=dir&qo=pagination&q=$(urlencode "${QUERY}")&qsrc=998&page=${PAGE}")
	PAGE=$(echo "$ASK_SEARCH" | grep -B1 '<li class="PartialWebPagination-next">Next' | grep -Po '<a href="(.*?)page=\K.*?(?=")')
	if [[ ! -n ${PAGE} ]]; then
		break
	fi
	echo " ======= ASK PAGE ${i} ======="
	for URLs in $(echo "${ASK_SEARCH}" | grep -Po "target=\"_blank\" href='\K.*?(?=')")
	do
		echo " => ${URLs}"
		echo "${URLs}" >> ${FILESAVE}
	done
done
