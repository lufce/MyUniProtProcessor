###uniprot-all.txtの行数は　17757632

package MyLE;

use Time::HiRes;
require "MyProgressBar.pm";

my $species = "human";
our $dataDir = "../data/$species/rev/";
our $listDir = "../cont_list/$species/rev/";
#my $raw_textfile_name = "rev_uniprot-all.txt";
my $raw_textfile_name = "uniprot_test_doc.txt";
my $raw_textfile_path = $dataDir.$raw_textfile_name;
###

&SQ_Extractor;

###

sub AddEndMarker{
	my $DBFilename =$MyLE::dataDir."ID-sq_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-sq_rev_uniprot-all2.txt";
	my $routinName = "AddEndMarker";
	
	my $objPB = new MyProgressBar;
	
	my $thisIsFirstLine = 1;
	
	print "$routineName starts\n";
	
	open DB, $DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
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
	
	print "$routineName ends\n";
	close DB;	close RF;
}

sub GNDEExtractor{
	my $startTime = Time::HiRes::time();
#	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";
	my $DBFilename = $MyLE::dataDir."181101_rev_uniprot_human_all.txt";	
	my $ResultFileName = $MyLE::dataDir."ID-GNDE_rev_uniprot-all.txt";
	my $routineName = "GNDEExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName" or die "Can not create the result file.";
	
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
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub FTExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-FT_rev_uniprot-all.txt";
	my $routineName = "FTExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
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
	print "$routineName ends.\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub sqExtractor{
#This subroutine extracts only amino acid sequences below the SQ line.
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-sq_rev_uniprot-all.txt";
	my $routineName = "sqExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	$sequence="sq   ";
	
	open RF, ">$ResultFileName";
	
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
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub CCExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-CC_rev_uniprot-all.txt";
	my $routineName = "CCExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
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
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub SLExtractor{
### This subroutine extracts SUBCELLULAR LOCATION in CC Lines.

	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";	
	my $ResultFileName = $MyLE::dataDir."ID-SL_rev_uniprot-all.txt";
	my $routineName = "SLExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
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
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub GOExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-GO_rev_uniprot-all.txt";
	my $routineName = "GOExtractor";
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($DBFilename);
	
	open DB,$DBFilename or die "No file";
	
	open RF, ">$ResultFileName";
	
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
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub GOContentExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."ID-GO_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::listDir."GOContetnts.txt";
	my $routineName = "GOContentExtractor";
	
	my @buf;
	my @contents=();
	my $content;
	my $location;
	my $exist;
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";

	$objPB->setAll($DBFilename);

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
	
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub FTKeyExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."ID-FT_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::listDir."FT_Keys.txt";	
	my $routineName = "FTKeyExtractor";
	
	my @keys=();
	my $thisKey;
	my $key;
	my $exist;
	
	print "$routineName starts\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName" or die "Cannot Create a Result File.";
	
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
	
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub FTLipidFeaturesExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."ID-FT_rev_uniprot-allFlat.txt";
	my $ResultFileName = $MyLE::listDir."FT_Lipid_Features.txt";
	my $routineName = "FTLipidFeaturesExtractor";
	
	my @features=();
	my $thisFeature;
	my $feature;
	my $exist;
	
	print "$routineName starts\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
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
	
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub FTOneLiner{
### This subroutine makes each Kye of FT one line.

	my $startTime = Time::HiRes::time();
	
	my $DBFilename = $MyLE::dataDir."ID-FT_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-FT_rev_uniprot-allFlat.txt";
	my $routineName = "FTOneLiner";
	
	my $workingLine="";
	my $nextLine;
	my $workingKey;
	my $nextKye;
	
	print "$routineName starts.\n";
	
	my $objPB = new MyProgressBar;
	
	open DB,$DBFilename or die "No file";
	
	$objPB -> setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){print RF;}
		elsif(m/^\/\//){print RF;}
		else{
			$workingLine = $_;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
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
	print "$routineName ends\n";
	close DB;	close RF;
	
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub GNDE_Extractor{
	my $code_name = "GNDE";
	my $regex = "^GN|^DE";
	
	&_Line_Code_Extractor($code_name, $regex);
}

sub FT_Extractor{
	my $code_name = "FT";
	my $regex = "^FT";
	
	&_Line_Code_Extractor($code_name, $regex);
}

sub CC_Extractor{
	my $code_name = "CC";
	my $regex = "^CC";
	
	&_Line_Code_Extractor($code_name, $regex);
}

sub GO_Extractor{
	my $code_name = "GO";
	my $regex = "^DR   GO";
	
	&_Line_Code_Extractor($code_name, $regex);
}

sub SQ_Extractor{
	my $code_name = "SQ";
	my $regex = "^ ";
	
	&_Line_Code_Extractor($code_name, $regex);
}

sub _Line_Code_Extractor{

	(my $code_name, my $regex) = @_;
	my $ResultFileName = $dataDir."ID-${code_name}_$raw_textfile_name";
	
	my $startTime = Time::HiRes::time();
	print "${code_name}_Extractor starts.\n";
	
	open my $DB, $raw_textfile_path or die "No file";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($raw_textfile_path);
	
	open my $RF, ">$ResultFileName";
	
	while(<$DB>){
		$objPB->addNowAndPrint($_);
		
		if($code_name eq "SQ"){
			&_Extract_Processor_SQ($_, $DB, $RF,$regex);
		}else{
			&_Extract_Processor_Simple($_, $RF,$regex);
		}
	}
		
	close $DB;
	close $RF;
	
	print "${code_name}_Extractor ends.\n";
	printf("%0.3f\n",Time::HiRes::time - $startTime); 
}

sub _Extract_Processor_Simple{
	(my $line, my $RF, my $regex) = @_;
	
	if($line =~ m/^ID/){
		print $RF $line;
	}elsif($line =~ m/$regex/){
		print $RF $line;
	}elsif($line =~ m|^//$|){
		print $RF $line;
	}
	
	return;
}

sub _Extract_Processor_SQ{
	(my $line, my $DB, my $RF, my $regex) = @_;
	
	my $seq;
	
	if($line =~ m/^ID/){
		print $RF $line;
		return;
	}elsif($line !~ m/$regex/){
		return;
	}
	
	$seq = $line;
	chomp($seq);
	
	while(<$DB>){
		if(m|^//|){
			last;
		}
		
		$seq = $seq.$_;
		chomp($seq);
		
	}
	
	$seq =~ tr/ //d;
	print $RF "$seq\n";
	
	return;
	
}

sub _Extract_Processor_SL{
	(my $line, my $DB, my $RF, my $regex) = @_;
	
	if($line =~ m/^ID/){
		print $RF $line;
		return;
	}elsif($line !~ m/$regex/){
		return;
	}else{
		print $RF $line;
	}
	
	while(<$DB>){
		if(m/$regex|^CC       /){
			print $RF;
		}else{
			last;
		}
	}
	
	print $RF "//\n";
	return;
}

1;