#!/bin/sh
if [ "$4" = "" ]; then
	if [ $# -ne 2 ]; then # If 2 inputs after execution
		echo "usage: $0 [-n N] (-c|-2|-r|-F|-t|-f) <filename>"
		exit 1
	fi
else
	if [ $# -ne 4 ]; then # Else if 4 inputs after execution (needed for output limit)
		echo "usage: $0 [-n N] (-c|-2|-r|-F|-t|-f) <filename>"
		exit 1
	fi
fi

check_filename() # Check if filename present
{
	if [ "$1" = "" -o "$1" = "-" ]; then # If filename not entered
		echo "Please enter filename."
		break
	else
		echo "Filename entered: $1"
	fi
}

check_commonip() # Show most common occuring ip
{
	if [ "$2" != "" ]; then # set VAR_A to limit number of output
		VAR_A="$2"
	else
		VAR_A=1000 # if no value is put in set to 1000
	fi

	cat $1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -r | uniq -c | sort -nr -k 1,1 | head -n $VAR_A # cat output of filename, grep all IPs only, sort in reverse order, prefix lines by number of occurance, sort numeric reverse with a keydef on 1,1, limit output to VAR_A
}

check_mostsuccess() # Check most successfull packages ip
{
	if [ "$2" != "" ]; then # See previous comment on check_commonip()
		VAR_A="$2"
	else
		VAR_A=1000
	fi
	cat $1 | grep -P "( |$)200( |$)" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -r | uniq -c | sort -nr -k 1,1 | head -n $VAR_A # cat output of filename, grep with perl regex for space200space, grep only IP with regex, sort reverse, prefix lines occurance, sort numeric reverse keydef 1,1, limit output to VAR_A
}

check_mostcodes()
{
	if [ "$2" != "" ]; then
		VAR_A="$2"
	else
		VAR_A=1000
	fi
	cat $1 | grep -E "( |$)[0-9]+( |$)" | awk '{print $1,$9}' | sort -r | uniq -c | sort -nr -k 1,1 | head -n $VAR_A
}

check_mosterror()
{
	if [ "$2" != "" ]; then
		VAR_A="$2"
	else
		VAR_A=100000000
	fi
	cat $1 | grep -E "( |$)[4][0-9][0-9]( |$)" | awk '{print $1,$9}' | sort -r | uniq -c | sort -nr -k 1,1 | head -n $VAR_A
}

check_mostdata()
{
	if [ "$2" != "" ]; then
		VAR_A="$2"
	else
		VAR_A=1000000000000
	fi
	cat $1 | grep -E "(\b([0-9]{1,3}\.){3}[0-9]{1,3}\b)" | grep -vE '( |$)\-( |$)\"' | awk '{print $1,$10}' | uniq -c | awk '{ mult = $1 * $3; print $2, mult }' | awk '{arr[$1]+=$2} END {for (i in arr) {print i, arr[i]}}' | sort -nr -k2,2 | head -n $VAR_A
}

case $1 in
	-n)
		check_filename $4
		;;
	-c)
		check_filename $2
		check_commonip $2
		;;
	-2)
		check_filename $2
		check_mostsuccess $2
		;;
	-r)
		check_filename $2
		check_mostcodes $2
		;;
	-F)
		check_filename $2
		check_mosterror $2
		;;
	-t)
		check_filename $2
		check_mostdata $2
		;;
	*)
		;;
esac

case $3 in
	-c)
		check_commonip $4 $2
		;;
	-2)
		check_mostsuccess $4 $2
		;;
	-r)
		check_mostcodes $4 $2
		;;
	-F)
		check_mosterror $4 $2
		;;
	-t)
		check_mostdata $4 $2
		;;
	*)
		;;
esac
