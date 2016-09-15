###uniprot-all.txt‚Ìs”‚Í@17757632

use Time::HiRes;
require "MyProgressBar.pm";

###

&GNDEExtractor;

###
sub AddEndMarker{
	my $DBFilename ="../data/rev/ID-sq_rev_uniprot-all.txt";
	my $RFilename = "../data/rev/ID-sq_rev_uniprot-all2.txt";
	
	my $objPB = new MyProgressBar;
	   $objPB->setAll($DBFilename);
	
	my $thisIsFirstLine = 1;
	
	open DB, $DBFilename or die "No file";
	open RF, ">", $RFilename;
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			if($thisIsFirstLine){print RF; $thisIsFirstLine = 0;}
			else{print RF "//\n$_";}
		}else{
			print RF;
		}		
	}
	
	print RF "//";
	
	print "end\n";
	close DB;	close RF;
}

sub GNDEExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	my $ResultFileName = "../data/rev/ID-GNDE_rev_uniprot-all.txt";
	my $routineName = "GNDEExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^GN|^DE/){
			print RF;
		}elsif(m/^\/\//){
			print RF;
		}		
	}
	print "$routineName ends.\t";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub FTExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">../data/rev/ID-FT_rev_uniprot-all.txt";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^FT/){
			print RF;
		}elsif(m/^\/\//){
			print RF;
		}		
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub sqExtractor{
#This subroutine extracts only amino acid sequences below the SQ line.
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	$sequence="sq   ";
	open RF, ">../data/rev/ID-sq_rev_uniprot-all.txt";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^SQ/){
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m|^//|){
					print RF "$sequence\n";
					$sequence="sq   ";
					last;
				}else{
					$_ =~ tr/ //d;
					chomp($_);
					$sequence = $sequence.$_
				}
			}
		}elsif(m/^\/\//){
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub CCExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">../data/rev/ID-CC_rev_uniprot-all.txt";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^CC/){
			print RF;
		}elsif(m/^\/\//){
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub SLExtractor{
### This subroutine extracts SUBCELLULAR LOCATION in CC Lines.

	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">../data/rev/ID-SL_rev_uniprot-all.txt";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^CC   -!- SUBCELLULAR LOCATION/){
			print RF;
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/^CC   ------/){
					last;
				}elsif(!m/-!-/){
					print RF;
				}elsif(m/^CC   -!- SUBCELLULAR LOCATION/){
					print RF;
				}else{
					last;
				}
			}
		}elsif(m/^\/\//){
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub GOExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/rev_uniprot-all.txt";	
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">../data/rev/ID-GO_rev_uniprot-all.txt";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^DR   GO/){
			print RF;
		}elsif(m/^\/\//){
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub GOContentExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/ID-GO_rev_uniprot-all.txt";
	my $ResultFileName = "GOContetnts.txt";	
	
	my @buf;
	my @contents=();
	my $content;
	my $location;
	my $exist;
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^DR/){
			@buf = split(";");
			if($buf[2] =~ m/^ C/){
				$location = substr($buf[2],3);
				
				$exist = 0;
				foreach $content (@contents){
					if($location eq $content){
						$exist = 1;
						last;
					}
				}
				
				if($exist == 0){
					push (@contents, $location);
				}
			}
		}
	}
	
	foreach $content (@contents){
		print RF "$content\n";
	}
	
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub FTKeyExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/ID-FT_rev_uniprot-all.txt";
	my $ResultFileName = "FT_Keys.txt";	
	
	my @keys=();
	my $thisKey;
	my $key;
	my $exist;
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^FT/){
			$thisKey = substr($_,5,8);
			$thisKey =~ tr/ //d;
			
			if($thisKey eq ""){next;}
			
			$exist = 0;
			foreach $key (@keys){
				if($key eq $thisKey){
					$exist = 1;
					last;
				}
			}
			
			if($exist == 0){
				push (@keys, $thisKey);
			}
		}
	}
	
	foreach $key (@keys){
		print RF "$key\n";
	}
	
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub FTLipidFeaturesExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = "../data/rev/ID-FT_rev_uniprot-allFlat.txt";
	my $ResultFileName = "FT_Lipid_Features2.txt";	
	
	my @features=();
	my $thisFeature;
	my $feature;
	my $exist;
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^FT   LIPID/){
			$thisFeature = substr($_,34);
			$thisFeature =~ m/(.+?)[\.;]/;
			$thisFeature = $1;
			if($thisFeature eq ""){next;}
			
			$exist = 0;
			foreach $feature (@features){
				if($feature eq $thisFeature){
					$exist = 1;
					last;
				}
			}
			
			if($exist == 0){
				push (@features, $thisFeature);
			}
		}
	}
	
	foreach $feature (@features){
		print RF "$feature\n";
	}
	
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub FTOneLiner{
### This subroutine makes each Kye of FT one line.

	my $startTime = Time::HiRes::time();
	
	my $DBFilename = "../data/rev/ID-FT_rev_uniprot-all.txt";
	my $RFilename = "../data/rev/ID-FT_rev_uniprot-allFlat.txt";
	
	my $workingLine="";
	my $nextLine;
	my $workingKey;
	my $nextKye;
	
	my $objPB = new MyProgressBar;
	$objPB -> setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">", $RFilename;
	
	while(<DB>){
		$objPB->countAndPrint;
		
		if(m/^ID/){print RF;}
		elsif(m/^\/\//){print RF;}
		else{
			$workingLine = $_;
			
			while(<DB>){
				$objPB->countAndPrint;
				
				if(m/^\/\//){
					print RF $workingLine;
					print RF;
					last;
				}
				
				$workingKey = substr($_,5,8);
				$workingKey =~ tr/ //d;
				
				if($workingKey eq ""){
					chomp($workingLine);
					$nextLine = substr($_,34);
					
					if(substr($workingLine,-1) eq "-"){
						$workingLine = $workingLine.$nextLine;
					}else{
						$workingLine = $workingLine." ".$nextLine;
					}
				}else{
					print RF $workingLine;
					$workingLine = $_;
				}
			}
		}
		
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}