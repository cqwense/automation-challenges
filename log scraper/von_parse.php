<?php

# Ahhh PHP - where millions of other script kiddies have already done 
# what I need.  ( I just gone done with the bash script )
# I downloaded this one from another github project, and am including
# it in my fork for guaranteed compatability - this could just as easily
# be done via pear/composer/yum(?) whatever

require_once("./log-parser-master/src/Kassner/LogParser/Factory.php");
require_once("./log-parser-master/src/Kassner/LogParser/FormatException.php");
require_once("./log-parser-master/src/Kassner/LogParser/LogParser.php");

# No sooner am I happy to be back in PHP than I am reminded of this 
# little gem.  In case its not set in your global php config either:
date_default_timezone_set('America/New_York');

# An Object! At Last!
$parser = new \Kassner\LogParser\LogParser();

# This is supposed to be the default expected apache format via Kassner/LogParser
# but I had to declare it manually - weird but not my problem atm.

$parser->setFormat('%h %l %u %t "%r" %>s %O "%{Referer}i" \"%{User-Agent}i"');

# make this an option via cmd line arguments later
$lines = file('./puppet_access_ssl.log', 
		FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);


# Since we're reporting and not just outputting we'll
# create some variables/arrays to hold values for us later.
# in the long wrong these would become subclass models.

$sshd = array();
$sshd['Access'] = 0;
$sshd['not200'] = 0;

$not200 = array();
$not200['count'] = 0;

$putUnderReport = array();

# Now we iterate through the lines of our object, checking for 
# requested information and populating our report variables/arrays
# We could later expand thess to be a subclass methods.
foreach ($lines as $line)
{ 
	# creates a parsed line object
	$entry = $parser->parse($line);
	
	# REGEX! - find sshd_config access and save data
	$sshdString = "\/production\/file_metadata\/modules\/ssh\/sshd_config";
	if(preg_match("/$sshdString/", $entry->request))
	{ 
		$sshd['Access']++;
		if ($entry->status != 200)
			$sshd['not200']++;
	}
	
	# Easy-Peasy status check for "not status 200 request"
	if( $entry->status != 200)
		$not200['count']++;

	# REGEX! - find PUT calls under the /dev/report directory
	$underReportString = "PUT\ \/dev\/report\/";
	if(preg_match("/^$underReportString/", $entry->request))
		@$putUnderReport["$entry->host"]++ ;
}

# putting echo's in here for now - I make things work, making them
# pretty comes later.  This is personal preference, and I find
# it keeps me from having to dev too many http/css pages. 

echo "sshd_config was accessed " . $sshd['Access'] . " times\n";
echo "of those " . $sshd['not200'] . " did not result in a 200 status code.\n";

echo "\n----\n\n";

echo "There were " . $not200['count'] . " instances of a non 200 status from All Records\n";

echo "\n----\n\n";

echo "PUT Reqeusts under /dev/reports totaled " . count($putUnderReport) . "\n";
echo "(Ex: Requests - Host)\n\n";

foreach($putUnderReport as $ip => $count)
{
	echo $count . " - " . $ip ."\n";
}

?>
