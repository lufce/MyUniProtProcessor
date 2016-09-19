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

=pod
my $ResultFile = "TestResult.txt";
my $length;

open RF, ">$ResultFile";

my @motifID = &RecNameFullMatch('C.+?orf');
my @RecName = &ID_to_RecName(\@motifID);

$length = @RecName;

for(my $i = 0 ; $i < $length ; $i++){
	print RF "ID   $motifID[$i]\n$RecName[$i]";
}

close RF;
=cut

###

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
	#まだ途中。引数の判定と、連想配列が有った場合の挙動が未実装
	
	my $searchFilename = "../data/rev/ID-FT_rev_uniprot-allFlat.txt";
	my $routineName = "isTransmembrane";

	my $num;		#The number of arguments
	my $thisId;
	my $idRef;		#Reference of the array of ID
	my $query;		#Keyword of localization
	
	my $objPB = new MyProgressBar;
	   $objPB -> setAll($searchFilename);
	
	my @matchedID;
	
	#check arguments
	#($query,$idRef,$num) = &_argumentCheck1(\@_ , $routineName);
	$num=1;
	
	print "$routineName starts.\n";
	
	open DB, $searchFilename;

	if($num == 1){
		while(<DB>){
			$objPB->nowAndPrint($.);
			
			if(m/^ID   (.+?) /){
				$thisId = $1;
				
				while(<DB>){
					$objPB->nowAndPrint($.);
					if(m/^FT   TRANSMEM/){
						push(@matchedID,$thisId);
						last;
					}elsif(m/^\/\//){
						last;
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
						
						if(m/^FT   TRANSMEM/){
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
	}

	close DB;

	print "$routineName ends.\n";
	
	return \@matchedID;
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
	
	if($num == 0){
		$mode = 1;
		return (undef, undef, undef, undef, undef, $num, $mode);
	}elsif($num == 1){
		if(ref($$checkArg[0]) eq ""){
			if($$checkArg[0] eq "" or !defined($$checkArg[0])){
				die "There is no query in the subroutine '$routineName'.";
			}else{
				$mode = 2;
				$query = $$checkArg[0];
				return (undef, undef, undef, undef, $query, $num, $mode);
			}
		}elsif( ref($$checkArg[0]) eq "ARRAY" ){
			$mode = 3;
			$idRef = $$checkArg[0];
			return (undef, undef, undef, $idRef, undef, $num, $mode);
		}else{
			die "The arguments of the subroutine '$routineName' is not proper.";
		}
	}elsif($num == 2){
		if(ref($$checkArg[0] = "ARRAY")){
			$idRef = $$checkArg[0];
			
			if(ref($$checkArg[1] = "HASH")){
				die "I need the parameter '-all' or '-part'.";
			}elsif(ref($$checkArg[1] = "")){
				if($$checkArg[1] =~ m/-all|-part/i ){
					die "I need the hash containing sequence regions.";
				}elsif($$checkArg[1] = ""){
					die "The arguments of the subroutine '$routineName' is not proper.";
				}else{
					$mode = 4;
					$query = $$checkArg[1];
					
					return (undef, undef, undef, $idRef, $query, $num, $mode);
				}
			}
		}elsif(ref($$checkArg[0] = "HASH")){
			$hashRef = $$checkArg[0];
			if(ref($$checkArg[1]) eq "ARRAY"){
				die "I need the parameter '-all' or '-part'.";
			}elsif(ref($$checkArg[1]) eq ""){
				if($$checkArg[1] =~ m/-all|-part/i ){
					die "I need the the ID array.";
				}elsif($$checkArg[1] = ""){
					die "The arguments of the subroutine '$routineName' is not proper.";
				}else{
					$mode = 4;
					$query = $$checkArg[1];
					
					return (undef, undef, undef, $idRef, $query, $num, $mode);
				}
			}else{
				die "The arguments of the subroutine '$routineName' is not proper.";
			}
		}elsif(ref($$checkArg[0]) eq ""){
			if($$checkArg[0] =~ m/-all|-part/i){
				die "The arguments of the subroutine '$routineName' is not proper.";
			}else{
				$query = $$checkArg[0];
				if(ref($$checkArg[1]) eq "ARRAY"){
					$mode = 4;
					$idRef = $$checkArg[1];
					
					return (undef, undef, undef, $idRef, $query, $num, $mode);
				}else{
					die "The arguments of the subroutine '$routineName' is not proper.";
				}
			}
		}elsif($num ==3){
			if(ref($$checkArg[0]) eq ""){
				if($$checkArg[0] =~ m/-all|-part/i){
					$para = $$checkArg[0];
					if(ref($$checkArg[1]) eq "ARRAY"){
						$idRef = $$checkArg[1];
						
						if(ref($$checkArg[2]) eq "HASH"){
							$mode = 5;
							$hashRef = $$checkArg[2];
							
							return ($para, undef, undef, $idRef, $query, $num, $mode);
						}
					}elsif(ref($$checkArg[1]) eq "HASH"){
						$hashRef = $$checkArg[1];
						
						if(ref($$checkArg[2]) eq "ARRAY"){
							$mode = 5;
							$idRef = $$checkArg[2];
							
							return ($para, undef, undef, $idRef, $query, $num, $mode);
						}
					}else{
						die "The arguments of the subroutine '$routineName' is not proper.";
					}
				}elsif(ref($$checkArg[0]) eq "ARRAY"){
					$idRef = $$checkArg[0];
					
					if(ref($$checkArg[1]) eq "HASH"){
						$hashRef = $$checkArg[1];
						
						if($$checkArg[2] =~ m/-all|-part/i){
							$mode = 5;
							$para = $$checkArg[2];
							
							return ($para, undef, undef, $idRef, $query, $num, $mode);
						}
					}elsif($$checkArg[1] =~ m/-all|-part/i){
						$para = $$checkArg[1];
						
						if(ref($$checkArg[2]) eq "HASH"){
							$mode = 5;
							$hashRef = $$checkArg[2];
							
							return ($para, undef, undef, $idRef, $query, $num, $mode);
						}else{
							die "The arguments of the subroutine '$routineName' is not proper.";
						}
					}elsif(ref($$checkArg[0]) eq "HASH"){
						if($$checkArg[1] =~ m/-all|-part/i){
							$para = $$checkArg[1];
						
							if(ref($$checkArg[2]) eq "ARRAY"){
								$mode = 5;
								$idRef = $$checkArg[2];
								
								return ($para, undef, undef, $idRef, $query, $num, $mode);
							}else{
								die "The arguments of the subroutine '$routineName' is not proper.";
							}
						}
					}else{
						die "The arguments of the subroutine '$routineName' is not proper.";
					}
				}elsif(ref($$checkArg[0]) eq "HASH"){
					$hashRef = $$checkArg[0];
				}else{
					die "The arguments of the subroutine '$routineName' is not proper.";
				}
			}
		}else{
			die "The arguments of the subroutine '$routineName' is not proper.";
		}
	}
	

}