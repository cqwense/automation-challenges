#!/bin/bash

# deploy.sh

# this script makes the assumption you have ssh keys setup - if not,
# you will be typing your password far too many times for comfort, and
# WAY to many times for large deployment scenarios.

# Basic Steps:
#
# 1) find the template file, and read into CONTENTS variable
# 2) foreach hostname given to deploy.sh, attempt to connect via ssh and return
#    the remote output of `facter -p widget`
# 3a) If connection/config is successful, write updated CONTENTS value to 
#     /etc/widgetfile
# 3b) If connection fails, record hostname for failure reporting.
#
# 4) Output Summary

# 1) we assume template file is in the same directory as deploy.sh, if not 
#    found we exit.  This can be expanded later.

TEMPLATE="template.file"
HOMEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
FILE="$HOMEDIR/$TEMPLATE"

if [ ! -r "$FILE" ]
then
{
	echo "Failed to read template file - exiting"
	exit 1
}
fi

# variablize the file, because reasons.
CONTENTS=$( < "$FILE" )

#2) Some assumed commands from $PATH - if not found we report and exit

which ssh > /dev/null 2>/dev/null
if [ $? -ne 0 ]
then
{ 
	echo "ssh executable not in path - exiting"
	exit 1
}
fi

# set the remote command to get our replacement line
REMOTECMD="facter -p widget"

# set the line/string to be replaced
OLD="widget_type X"

# get hostnames from command line of deploy.sh to conect too
HOSTNAMES=( "$@")

# we need to report counts of successful vs failed.  We will create two
# empty arrays and populate them with data based on the success of the 
# reset of the script.

PASS=()
FAIL=()

for i in "${HOSTNAMES[@]}"
do
	echo "Deploying On $i ..."
	REPLACE="$(ssh  $i "${REMOTECMD}" 2>/dev/null)"
	
	# ssh is brilliant, and return code of the local ssh command will 
	# be the return code of the remote command.  Bless you ssh.

	# 3) Now that we know we can connect, and we have the remote hosts's
	# value from facter -p widget, we can start to alter the CONTENTS
	# variable to be in line with our remote target's configuration.

	# First things first - lets make sure facter -p widget returned 
	# *something* -- heavy valid response checking could go here 
	# at a later date - but for now, facter's output is pretty simple
	# if it returns a valid exit code, we'll assume either "all is well"
	# or it could be an empty value ( widget option not set ).  This 
	# is the reason we make two connections via ssh - this can later be 
	# streamlined into one connection with a longer commaned past 
	# to the remote system.

	if [ $? -eq 0 ] 
	then
	{
	
		if [[ -z $REPLACE ]]
		then
		{
			#DEBUG echo "Invalid facter value from $i"
			FAIL+=("$i")
			continue
		}
		fi
		
		# Build a variable to hold our remote hosts correct 
		# config file.

		WIDGETFILE=$(echo "${CONTENTS}" | 
		sed  "s/${OLD}/widget_type\ ${REPLACE}/")
		
		# and finally place the updated file values on the 
		# remote host.

		ssh $i "echo \"${WIDGETFILE}\" > /etc/widgetfile"

		if [ $? -eq 0 ] 
		then
		{
			#DEBUG echo "SUCCESS on $i"
			PASS+=("$i")
		}
		else
		{
			#DEBUG echo "something went wrong placing file on $i"
			FAIL+=("$i")
			continue
		}
		fi
	}
	else
	{
		#DEBUG echo "failed to conenct OR run facter on $i"
		FAIL+=("$i")
		continue
	}
	fi
done

# Meat and Potatoes are done - now for each of the PASS and FAIL 
# arrays, we echo the count/total - and just for kicks
# we also list the hostnames of each passed and failed.

echo -e "Summary:\n-----------------------\n"

echo -e "Passed: ${#PASS[*]} \n"
for i in ${PASS[*]}
do 
	echo -n "$i " 
done

echo -e "\n-------\n\n"

echo -e "Failed: ${#FAIL[*]} \n"
for i in ${FAIL[*]}
do
	echo -n "$i "
done

#echo blank new line to not have prompt folloiwng output
echo "" 

# ToDo:
#
# 1) the PASS and FAIL arrays could be made associative, which would allow
# the summary output to more easily provide reasonings behind failures ( not 
# terribly important for the PASS array )
#
# 2) some redundancy code in the echo's - could be cleaned up with functions.
