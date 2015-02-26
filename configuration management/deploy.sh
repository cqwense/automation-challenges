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

function USAGE()
{
cat << ENDOFHELP
Usage:
-------

deploy.sh 
  -H "host1 host2 host3"
  -u USERNAME
  -c "COMMAND"
  -b "TEXT"
  -a "TEXT"
  -f FILE
  -r "TEXT"
  -o PATH/FILE

-H : Required : Hosts which to deploy too
-u : Optional : ssh username to use, defaults to current username

-c : Required : Command string to execute on remote machine 
		who's output will be used to replace the string
		specified by -r.
-b : Optional : Any text desired to be prepended to output from -c.
-a : Optional : Any text desired to be appened to output from -c.

-f : Required : /path/to/file to use as template.
-r : Required : String in -f to be replaced by -c -b -a.

-o : Optional : Filepath on remote server to place new file
		default is ~/widgetfile

Ex:

./deploy.sh -H "localhost" -f template.file -o "/etc/widgetfile" \
-c "facter -p widget" -r "widget_type X" -b "widget_type " -u root
ENDOFHELP

exit 1
}

while getopts ":H:u:f:o:c:r:b:a:h" opt; do
	case $opt in 
		H)
		HOSTNAMES="$OPTARG"
		;;

		u)
		SSHUSER="$OPTARG"
		;;

		c)
		REMOTECMD="$OPTARG"
		;;

		f)
		if [ ! -r "$OPTARG" ]
		then
		{
			echo "Failed to read template file - exiting."
			exit 1
		}
		fi
		CONTENTS=$( < "$OPTARG" ) >&2
		;;

		o)
		OUTPATH="$OPTARG"
		;;

		r)
		OLD="$OPTARG"
		;;

		b)
		BEFORE="$OPTARG"
		;;

		a)
		AFTER="$OPTARG"
		;;

		h)
		USAGE
		;;

		\?)
		echo "Invalid option -$OPTARG" >&2
		exit 1
		;;

		:)
		echo "Option -$OPTARG requires an argument."
		;;
	esac
done

# Make sure we got required info
if [ -z "${HOSTNAMES}" ]
then
{
	echo "Not given any hostnames - exiting."
	exit 1
}
fi

if [ -z "${CONTENTS}" ]
then
{
	echo "Read no data from template file specified - exiting."
	exit 1
}
fi

if [ -z "${REMOTECMD}" ]
then
{
	echo "No remote command specified - exiting."
	exit 1
}
fi

# if SSHUSER wasn't given on the command line, use `whoami`
if [ -z ${SSHUSER} ]
then
{
	SSHUSER=`whoami`
}
fi

# if OUTPATH wasn't given on the command line, use ~/
if [ -z ${OUTPATH} ]
then
{
	OUTPATH="~/widgetfile"
}
fi

# set the line/string to be replaced
if [ -z "${OLD}" ]
then
{
	# default for the sake of this script
	OLD="widget_type X"
	# default if I were going to expand this further
	#OLD="#DEPLOYREPLACE"
}
fi
	
############ DEPRECATED ###########

#TEMPLATE="template.file"
#HOMEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#FILE="$HOMEDIR/$TEMPLATE"

#if [ ! -r "$FILE" ]
#then
#{
#	echo "Failed to read template file - exiting"
#	exit 1
#}
#fi

# variablize the file, because reasons.
#CONTENTS=$( < "$FILE" )


# get hostnames from command line of deploy.sh to conect too
#HOSTNAMES=( "$@")

################################


# we need to report counts of successful vs failed.  We will create two
# empty arrays and populate them with data based on the success of the 
# reset of the script.

PASS=()
FAIL=()

for i in ${HOSTNAMES}
do
	echo "Deploying On $i ..."
	REPLACE="$(ssh  $SSHUSER@$i "${REMOTECMD}" 2>/dev/null)"
	
	# ssh is brilliant, and return code of the local ssh command will 
	# be the return code of the remote command.  Bless you ssh.

	# 3) Now that we know we can connect, and we have the remote hosts's
	# value from REMOTECMD, we can start to alter the CONTENTS
	# variable to be in line with our remote target's configuration.

	# Bit of work to validate the REMOTECMD output.  This 
	# is the reason we make two connections via ssh - this can later be 
	# streamlined into one connection with a longer commaned past 
	# to the remote system. But I have other code to write.

	if [ $? -eq 0 ] 
	then
	{
	
		if [[ -z $REPLACE ]]
		then
		{
			#DEBUG echo "Invalid REMOTECMD value from $i"
			FAIL+=("$i")
			continue
		}
		fi
		
		# Build a variable to hold our remote hosts correct 
		# config file.
		
		# If -b or -a were given on the command line, this
		# will add them to the -c output
		REPLACE=${BEFORE}${REPLACE}${AFTER}
		
		WIDGETFILE=$(echo "${CONTENTS}" | 
		sed  "s/${OLD}/${REPLACE}/")
		
		# if the REMOTECMD output doesn't play 
		# friendly with sed - then we want to fail and 
		# continue the loop
		if [ $? -ne 0 ]
		then
		{
			FAIL+=("$i")
			continue
		}
		fi

		# and finally place the updated file values on the 
		# remote host.

		ssh $SSHUSER@$i "echo \"${WIDGETFILE}\" > ${OUTPATH}"

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
		#DEBUG echo "failed to conenct OR run REMOTECMD on $i"
		FAIL+=("$i")
		continue
	}
	fi
done

# 4) Meat and Potatoes are done - now for each of the PASS and FAIL 
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
