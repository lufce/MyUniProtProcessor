#181029		ver0.1		作り始め。

#FT行の処理についてまとめたパッケージを作るのが目標

use strict;
use warnings;
use Time::HiRes;

require "MyProgressBar.pm";

my $SerchFileName = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";

sub getFTContentsByKey{
	#
	
	
}

sub _getFTFrom{
	my $FTLine = shift;
	
	my $FTFrom = substr($FTLine, 14, 6);
	$FTFrom =~ tr/ //d;
	
	return $FTFrom;
}

sub _getFTTo{
	my $FTLine = shift;
	
	my $FTTo = substr($FTLine, 21, 6);
	$FTTo =~ tr/ //d;
	
	return $FTTo;
}

sub _getFTKey{
	my $FTLine = shift;
	
	my $FTKey = substr($FTLine, 5, 8);
	$FTKey =~ tr/ //d;
	
	return $FTKey;
}

sub _getFTDescription{
	# If there is no description, this subroutin returns "".
	
	my $FTLine = shift;
	my $FTDesc = "";
	
	if(length($FTLine) >= 35){
		$FTDesc = substr($FTLine, 34);
		chomp($FTDesc);
	}
	
	return $FTDesc;
}

sub _getFTAllItems{
	my $FTLine = shift;
	
	my @FTItems = (&_getFTKey($FTLine), &_getFTFrom($FTLine), &_getFTTo($FTLine), &_getFTDescription($FTLine) );
	
	return \@FTItems;
}

1;