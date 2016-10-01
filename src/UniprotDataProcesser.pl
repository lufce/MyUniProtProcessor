#160826		ver0.1		作り始め。

use strict;
use warnings;
use Time::HiRes;

require "MyProgressBar.pm";

###
my $resultFileName = "../result/testLocalize.txt";
my $resultIDRef;
my $resultRegionsRef;
my $num;
my $num2;
my $i;


#$resultIDRef = &GO_C_Match('cilium|flagellum|cilia|flagella');
$resultIDRef = &isTransmembrane();
#$resultIDRef = &ProteinMotifMatchWithRegions('[KRQ]V.P.',$resultIDRef);

$num = @$resultIDRef;

open RF, ">$resultFileName";

print RF "$num hits!\n";

for ($i = 0; $i < $num; $i++){
	print RF "$$resultIDRef[$i]\n";
}

close RF;

print "finish";

#######################################

sub ID_to_RecName{
#This routine translates ID array into RecName array.

	my $RefFilename = "../data/rev/ID-GNDE_rev_uniprot-all.txt";
	my @RecName;
	my $routineName = "ID_to_RecName";
	
	my $id = shift;
	my $objPB = new MyProgressBar;
	   $objPB->setAll($RefFilename);
	
	#if ID is not entered, kill the script.
	unless(defined($id)){ die "ID is not entered in $routineName"; }

	print "$routineName starts.\n";

	open DB, $RefFilename;
	
	foreach my $thisId (@$id){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/$thisId/){
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					
					if(m/DE   RecName:/){
						push(@RecName , $_);
						last;
					}elsif(m/\/\//){
						last;
					}
				}
				
				last;
			}
		}
	}
	
	close DB;
	
	print "$routineName ends.\n";
	
	return @RecName;
}

sub isTransmembrane{
	my $routineName = "isTransmembrane";

	print "$routineName starts.\n";

	my $matchedIDref = &_FTFlatFramework($routineName,'TRANSMEM',\@_,5);	#need (parentalRoutineName, FTKey, argumentReference, judgeMode)

	print "$routineName ends.\n";
	
	return $matchedIDref;
}

sub SLMatch{
	my $SerchFileName = "../data/rev/ID-SL_rev_uniprot-allT5.txt";
	my $routineName = "SLMatch";
	
	my $num;		#The number of arguments
	my $thisId;
	my $idRef;		#Reference of the array of ID
	my $query;		#Keyword of localization
	
	my @matchedID;
	
	my $objPB = new MyProgressBar;
	   $objPB->setAll($SerchFileName);
	
	print "$routineName starts.\n";
	
	#check arguments
	($query,$idRef,$num) = &_argumentCheck1(\@_ , $routineName);

	open DB, $SerchFileName;

	if($num == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					
					if(m/^\/\//){
						last;
					}elsif(m/$query/){
						push(@matchedID, $thisId)
					}
				}
			}
		}
	}else{
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/\/\//){
							last;
						}elsif(m/$query/){
							push(@matchedID, $thisId);
						}
					}
					last;
				}
			}
		}
	}
	close DB;
	
	print "$routineName ends.\n";
	
	return \@matchedID;
}

sub GO_C_Match{
	my $SerchFileName = "../data/rev/ID-GO_rev_uniprot-all.txt";
	my $routineName = "GO_C_Match";
	
	my $num;		#The number of arguments
	my $thisId;
	my $idRef;		#Reference of the array of ID
	my $query;		#Keyword of localization
	
	my @matchedID;
	
	my $objPB = new MyProgressBar;
	   $objPB->setAll($SerchFileName);
	
	print "$routineName starts.\n";
	
	#check arguments
	($query,$idRef,$num) = &_argumentCheck1(\@_ , $routineName);
	
	open DB, $SerchFileName;

	if($num == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					
					if(m/^\/\//){
						last;
					}elsif(m/; C:/){
						if(m/$query/){
							push(@matchedID, $thisId);
							last;
						}
					}
				}
			}
		}
	}else{
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/\/\//){
							last;
						}elsif(m/; C:/){
							if(m/$query/){
								push(@matchedID, $thisId);
								last;
							}
						}
					}
					last;
				}
			}
		}
	}
	close DB;
	
	print "$routineName ends.\n";
	
	return \@matchedID;
}

sub ProteinMotifMatch{
	my $searchFilename = "../data/rev/ID-sq_rev_uniprot-all.txt";
	my $routineName = "ProteinMotifMatch";

	my $num;		#The number of arguments
	my $thisId;
	my $idRef;		#Reference of the array of ID
	my $query;		#Keyword of localization

	my $sequence;
	
	my $objPB = new MyProgressBar;
	   $objPB -> setAll($searchFilename);
	
	my @matchedID;
	
	#check arguments
	($query,$idRef,$num) = &_argumentCheck1(\@_ , $routineName);
	
	print "$routineName starts.\n";
	
	open DB, $searchFilename;

	if($num == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				$objPB->nowAndPrint($.);
				$sequence = <DB>;
				$sequence = substr($sequence,5);
				
				if($sequence =~ m/$query/){ push(@matchedID, $thisId); }
			}
		}
	}else{
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					$objPB->nowAndPrint($.);
					$sequence = <DB>;
					$sequence = substr($sequence,5);
					
					if($sequence =~ m/$query/){ push(@matchedID, $thisId); }
					last;
				}
			}
		}
	}

	close DB;

	print "$routineName ends.\n";

	return \@matchedID;
}

sub ProteinMotifMatchWithRegions{
	my $searchFilename = "../data/rev/ID-sq_rev_uniprot-all.txt";
	my $routineName = "ProteinMotifMatch";

	my $num;		#The number of arguments
	my $thisId;
	my $idRef;		#Reference of the array of ID
	my $query;		#Keyword of localization

	my $sequence;
	
	my $objPB = new MyProgressBar;
	   $objPB -> setAll($searchFilename);
	
	my @matchedID;
	my %matchedRegions;
	my $region;
	
	#check arguments
	($query,$idRef,$num) = &_argumentCheck1(\@_ , $routineName);
	
	print "$routineName starts.\n";
	
	open DB, $searchFilename;

	if($num == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				$objPB->nowAndPrint($.);
				$sequence = <DB>;
				$sequence = substr($sequence,5);
				
				$region = "";
								
				while($sequence =~ m/$query/g){ 
					$region = sprintf("%d,%d,", length($`)+1,length($`.$&));
				}
				unless($region eq ""){
					push(@matchedID,$thisId);
					
					chop($region);
					$matchedRegions{$thisId} = $region;
				}
			}
		}
	}else{
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					$objPB->nowAndPrint($.);
					$sequence = <DB>;
					$sequence = substr($sequence,5);
					
					$region = "";
									
					while($sequence =~ m/$query/g){ 
						$region = sprintf("%d,%d,", length($`)+1,length($`.$&));
					}
					unless($region eq ""){
						push(@matchedID,$thisId);
						
						chop($region);
						$matchedRegions{$thisId} = $region;
					}
					last;
				}
			}
		}
	}

	close DB;

	print "$routineName ends.\n";
	
	return (\%matchedRegions,\@matchedID);
}

sub RecNameFullMatch{
#This routine searches the region "RecName Full=" for a query of a regular expression.

	my $searchFilename = "../data/rev/ID-GNDE_rev_uniprot-all.txt";
	my $routineName = "RecNameFullMatch";
	
	#get the query
	my $motif =	shift;
	
	my $id;
	
	my $objPB = new MyProgressBar;
	   $objPB -> setAll($searchFilename);
	
	my @matchedID  =();
	
	#If motif is not entered, kill the script.エラーログを吐くように改良したい。
	unless(defined($motif)){ die "Motif sequence is not entered in $routineName"; }
	
	print "$routineName starts.\n";
	
	open DB, $searchFilename;
	
	while(<DB>){
		$objPB -> countUp; $objPB -> printProgressBar;
		
		if(m/^ID   (.+?) /){
			$id = $1;
			
			while(<DB>){
				$objPB -> countUp; $objPB -> printProgressBar;
				
				if(m/DE   RecName: Full=(.+);/){
					if($1 =~ m/$motif/){ push(@matchedID, $id); }
					last;
				}
			}
		}
	}

	close DB;

	print "$routineName ends.\n";

	return @matchedID;
}

sub CountID{
#This routine count the number of ID in a search file.

	my $searchFilename = shift;
	my $routineName = "CountID";
	
	my $count=0;
	my $objPB = new MyProgressBar;
	my @matchedID  =();
	
	print "$routineName starts.\n";
	
	$objPB -> setAll($searchFilename);
	
	if(!-e $searchFilename){ die "No search file."}
	
	open DB, $searchFilename;
	
	while(<DB>){
		$objPB -> countUp; $objPB -> printProgressBar;
		
		if(m/^ID/){
			$count++;
		}
	}

	close DB;

	print "$routineName ends.\n";

	return $count;
}

sub _FTFlatFramework{
	#テストランがまだ
	#need (parentalRoutineName, FTKey, argumentReference, judgeMode)
	
	#judgeMode == 0;  FT region is included in region of interest
	#judgeMode == 1;  FT region overlaps region of interest and is included in region2
	#judgeMode == 2;  FT region is out to the N-terminus of region of interest
	#judgeMode == 3;  FT region is out to the C-terminus of region of interest
	#judgeMode == 4;  Both regions do not overlap.
	#judgeMode >= 5;  FT region exchanges region of interest each other. 
	#				  a new judgeMode is the remainder of the value of judgeMode devided by 5
	
	my $searchFilename = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";
	my $routineName = "FTFLatFramework";

	my $mode;		#search mode
	my $num = @_;	#The number of arguments
	my $query;		#asked in FT descriptions
	my $idRef;		#Reference of the array of IDs
	my $hashRef;	#Reference of the hash of AA sequence regions
	my $para;		#"-all" or "-part"
	
	my $parentalRoutineName = shift;
	my $FTKey = shift;		#searching Key in FT Line
	my $argRef = shift;
	my $judgeMode = shift;
	
	my $thisId;
	my $FTDescription;
	
	my $p_from;		#the value of 'From' endpoint in FT line
	my $p_end;		#the value of 'To' endpoint in FT line 
	my @region;
	my $regionSize;
	my $p_region;
	my $matchCount;	#this is used when $para is "-all"
	my @matchRegion;
	
	my $objPB = new MyProgressBar;
	   $objPB -> setAll($searchFilename);
	
	my @matchedID;
	
	print "$routineName starts.";
	
	#check arguments
	if($num != 4){
		die "Arguments error in $routineName called by $parentalRoutineName. ";
	}elsif(!defined($FTKey) or $FTKey eq ""){
		die "Arguments error in $routineName called by $parentalRoutineName. ";
	}elsif( !ref($argRef) eq "ARRAY" ){
		die "Arguments error in $routineName called by $parentalRoutineName. ";
	}
	
	($para, $hashRef, $idRef, $query, $num, $mode) = &_argumentCheck2($argRef , $routineName);
	
	print " Mode is $mode.\n";
	
	#open database file
	open DB, $searchFilename or die($!);
	
	#processor
	if($mode == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					if(m/^FT   $FTKey/){
						push(@matchedID,$thisId);
						last;
					}elsif(m/^\/\//){
						last;
					}
				}
			}
		}
		
	}elsif($mode == 2){
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							push(@matchedID,$thisId);
							last;
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
		
	}elsif($mode == 3){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					
					if(m/^FT   $FTKey/){
						$FTDescription = substr($_, 34);
						
						if($FTDescription =~ m/$query/){
							push(@matchedID,$thisId);
							last;	
						}
					}elsif(m/^\/\//){
						last;
					}
				}
			}
		}
		
	}elsif($mode == 4){
		foreach $thisId (@$idRef){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							$FTDescription = substr($_, 34);
							
							if($FTDescription =~ m/$query/){
								push(@matchedID,$thisId);
								last;	
							}
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
		
	}elsif($mode == 5 and $para eq "-part"){
		foreach $thisId (@$idRef){
			@region = split(",",$$hashRef{$thisId});
			$regionSize = @region;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							$p_from = &_getFTFrom($_);
							$p_end = &_getFTTo($_);
							
							for ($p_region = 0; $p_region < $regionSize; $p_region += 2){
								if(&_JudgePosition($p_from, $p_end, $region[$p_region], $region[$p_region], $judgeMode)){
									push(@matchedID,$thisId);
									last;
								}
							}
							
							if($p_region <= $regionSize){
							#when for-loop is exited using 'last', the value of $p_region is less than ($regionSize + 2) and next ID should be judged.
							#when $p_region is ($regionSize + 2), next FT Line should be judged.
								last;
							}
							
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
		
	}elsif($mode == 5 and $para eq "-all"){
		foreach $thisId (@$idRef){
			@region = split(",",$$hashRef{$thisId});
			$regionSize = @region;
			$matchCount = 0;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							$p_from = &_getFTFrom($_);
							$p_end = &_getFTTo($_);
							
							for ($p_region = 0; $p_region < $regionSize; $p_region += 2){
								
								if($matchRegion[$p_region/2]){
								#if the region has already matched, judge the next region.
									next;
								}
								
								if(&_JudgePosition($p_from, $p_end, $region[$p_region], $region[$p_region], $judgeMode)){
									$matchCount++;
									last;
								}
							}
							
							if($matchCount == $regionSize / 2 ){
							#if all regions are matched
								push(@matchedID, $thisId);
								last;
							}
							
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
		
	}elsif($mode == 6 and $para eq "-part"){
		foreach $thisId (@$idRef){
			@region = split(",",$$hashRef{$thisId});
			$regionSize = @region;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							
							$FTDescription = substr($_, 34);
							
							if($FTDescription !~ m/$query/){
								next;	
							}
							
							$p_from = &_getFTFrom($_);
							$p_end = &_getFTTo($_);
							
							for ($p_region = 0; $p_region < $regionSize; $p_region += 2){
								if(&_JudgePosition($p_from, $p_end, $region[$p_region], $region[$p_region], $judgeMode)){
									push(@matchedID,$thisId);
									last;
								}
							}
							
							if($p_region <= $regionSize){
							#when for-loop is exited using 'last', the value of $p_region is less than ($regionSize + 2) and next ID should be judged.
							#when $p_region is ($regionSize + 2), next FT Line should be judged.
								last;
							}
							
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
		
	}elsif($mode == 6 and $para eq "-all"){
		foreach $thisId (@$idRef){
			@region = split(",",$$hashRef{$thisId});
			$regionSize = @region;
			$matchCount = 0;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/$thisId/){
					while(<DB>){
						$objPB->nowAndPrint($.);
						
						if(m/^FT   $FTKey/){
							
							$FTDescription = substr($_, 34);
							
							if($FTDescription !~ m/$query/){
								next;	
							}
							
							$p_from = &_getFTFrom($_);
							$p_end = &_getFTTo($_);
							
							for ($p_region = 0; $p_region < $regionSize; $p_region += 2){
								
								if($matchRegion[$p_region/2]){
								#if the region has already matched, judge the next region.
									next;
								}
								
								if(&_JudgePosition($p_from, $p_end, $region[$p_region], $region[$p_region], $judgeMode)){
									$matchCount++;
									last;
								}
							}
							
							if($matchCount == $regionSize / 2 ){
							#if all regions are matched
								push(@matchedID, $thisId);
								last;
							}
							
						}elsif(m/^\/\//){
							last;
						}
					}
					last;
				}
			}
		}
	}

	close DB;

	print "$routineName ends.\n";
	
	return \@matchedID;
}

sub _JudgePosition{
	#judgeMode == 0;  region 1 is included in region 2
	#judgeMode == 1;  region 1 overlaps region 2 and is included in region2
	#judgeMode == 2;  region 1 is out to the N-terminus of region 2
	#judgeMode == 3;  region 1 is out to the C-terminus of region 2
	#judgeMode == 4;  Both regions do not overlap.
	#judgeMode >= 5;  region 1 exchanges region 2 each other
	#				  a new judgeMode is the remainder of the value of judgeMode devided by 5
	
	my $p_from1 = shift;
	my $p_to1 = shift;
	my $p_from2 = shift;
	my $p_to2 = shift;
	my $judgeMode = shift;
	my $buf;
	
	if($p_from1 !~ m/^[0-9]$/ or $p_from2 !~ m/^[0-9]$/ or $p_to1 !~ m/^[0-9]$/ or $p_to2 !~ m/^[0-9]$/){
		die "pointer is not numeric";	
	}
	
	if(4 < $judgeMode and $judgeMode < 10){
		$buf = $p_from1;
		$p_from1 = $p_from2;
		$p_from2 = $buf;
		
		$buf = $p_to1;
		$p_to1 = $p_to2;
		$p_to2 = $buf;
		
		$judgeMode = $judgeMode % 5;
	}else{
		die "judgeMode is $judgeMode";
	}
	
	if($judgeMode == 0){
		if($p_from2 <= $p_from1 and $p_to1 <= $p_to2){
			return 1;
		}else{
			return 0;
		}
	}elsif($judgeMode == 1){
		if($p_from2 <= $p_to1 or $p_from1 <= $p_to2){
			return 1;
		}else{
			return 0;
		}
	}elsif($judgeMode == 2){
		if($p_to1 < $p_from2){
			return 1;
		}else{
			return 0;
		}
	}elsif($judgeMode == 3){
		if($p_to2 < $p_from1){
			return 1;
		}else{
			return 0;
		}
	}elsif($judgeMode == 4){
		if($p_to1 < $p_from2 or $p_to2 < $p_from1){
			return 1;
		}else{
			return 0;
		}
	}else{
		die;
	}
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

sub _argumentCheck1{
	my $checkArg = shift;
	my $routineName = shift;
	
	my $num = @$checkArg;
	
	my $query;
	my $idRef;
	
	if($num == 1){
		if(ref($$checkArg[0]) eq ""){
			$query = $$checkArg[0];
			$idRef = undef;
		}else{
			die "The arguments of the subroutine '$routineName' is not proper.";
		}
	}elsif($num == 2){
		if(ref($$checkArg[0]) eq "" and ref($$checkArg[1]) eq "ARRAY"){
			$query = $$checkArg[0];
			$idRef = $$checkArg[1];
		}elsif(ref($$checkArg[1]) eq "" and ref($$checkArg[0]) eq "ARRAY"){
			$query = $$checkArg[1];
			$idRef = $$checkArg[0];
		}else{
			die "The arguments of the subroutine '$routineName' is not proper.";
		}
	}else{
		die "The arguments of the subroutine '$routineName' is not proper.";
	}
	if($query eq ""){ die "There is no query in the subroutine '$routineName'."; }
	
	return ($query,$idRef,$num);
}

sub _argumentCheck2{
	#return ($para, $hashRef, $idRef, $query, $num, $mode)
	
	my $checkArg = shift;
	my $routineName = shift;
	
	my $num = @$checkArg;
	
	my $mode;
	my $query;
	my $idRef;
	my $hashRef;
	my $para;
	
	#sort arguments
	for(my $i = 0 ; $i < $num ; $i++){
		if( ref($$checkArg[$i]) eq ""){
			if( $$checkArg[$i] =~ m/-all|-part/i){
				$para = $$checkArg[$i];
				
			}elsif( $$checkArg[$i] eq "" or !defined($$checkArg[$i])){
				die "The arguments[$i] of the subroutine '$routineName' is not proper.";
				
			}else{
				$query = $$checkArg[$i];
				
			}
		}elsif( ref($$checkArg[$i]) eq "ARRAY" ){
			$idRef = $$checkArg[$i];
			
		}elsif( ref($$checkArg[$i]) eq "HASH" ){
			$hashRef = $$checkArg[$i];
		}else{
			die "The arguments[$i] of the subroutine '$routineName' is not proper.";
		}
	}
	
	#define the mode. The difinition of the mode is based on '設計案.docx' .
	if( $num == 0 ){
		$mode = 1;
		
	}elsif( $num == 1 and defined($idRef)){
		$mode = 2;
		
	}elsif( $num == 1 and defined($query)){
		$mode = 3;
		
	}elsif( $num == 2 and defined($idRef) and defined($query)){
		$mode = 4;
		
	}elsif( $num == 3 and defined($idRef) and defined($hashRef) and defined($para)){
		$mode = 5;
		
	}elsif( $num == 4 and defined($idRef) and defined($hashRef) and defined($query) and defined($para)){
		$mode = 6;
	
	}else{
		die "Failure of defining the mode in the subroutine $routineName. The number of arguments is $num.";
	
	}
	
	return ($para, $hashRef, $idRef, $query, $num, $mode);
}