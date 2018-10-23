#!/bin/bash

declare -a commands=(	"shutdown"
						"emulationstation"
						"kodi"
						"desktop"
					)

if [ ! -f /sys/class/gpio/gpio3/value ]; then
        echo 3 > /sys/class/gpio/export
fi

function checkGpio() {
	read gpio3Value < /sys/class/gpio/gpio3/value
}

function waitPush() {

	SECONDS=0

	while [[ $SECONDS < 2 ]]
	do
		checkGpio

		if [[ $gpio3Value == 0 ]]
		then
			return 1
		fi
	done

	return 0
}

function whilePush() {
	while [[  $gpio3Value == 0 ]]
        do
                checkGpio
        done
}

while :
do
	checkGpio

	if [[ $gpio3Value == 0 ]] 
	then
        C=-1
		while [[  $gpio3Value == 0 ]]
		do
			C=$[C+1]
			if [[ $C == ${#commands[@]} ]]
			then
				C=0
			fi

			echo ${commands[$C]}
			whilePush
			waitPush
		done

		CMD=./scripts/${commands[$C]}.sh
		echo exec $CMD
		$CMD
	fi

	sleep 1s
done

