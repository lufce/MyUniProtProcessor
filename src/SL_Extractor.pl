package MySLE;

use Time::HiRes;
require "MyProgressBar.pm";

my $species = "human";
our $dataDir = "../data/$species/rev/";

###
&SLExtractor;
###

sub SLExtractor{
### This subroutine extracts SUBCELLULAR LOCATION in CC Lines.

	my $startTime = Time::HiRes::time();
	my $DBFilename = $MySLE::dirData."ID-CC_rev_uniprot-all.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-all.txt";
	my $routineName = "SLExtractor";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^ID/){
			print RF;
		}elsif(m/^\/\//){
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
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub SLOneLiner{
### This subroutine makes SL one line.

	my $startTime = Time::HiRes::time();
	
	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-all.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allT1.txt";
	my $routineName = "SLOneLiner";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^CC/){
			chomp;
			$workingLine = $_;
			
			while(<DB>){
				$objPB->nowAndPrint($.);
				
				if(m/-!-/){
					print RF "$workingLine\n";
					chomp;
					$workingLine = $_;
				}elsif(m/^CC/){
					chomp;
					$workingLine = $workingLine." ".substr($_,9);
				}else{
					print RF "$workingLine\n";
					print RF;
					last;
				}
			}
		}else{
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub SLReplacer{
### This subroutine makes SL lines instead of "CC   -!- SUBCELLULAR LOCATION: ".

	my $startTime = Time::HiRes::time();
	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-allT1.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allT2.txt";
	my $routineName = "SLReqlacer";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/^CC   -!- SUBCELLULAR LOCATION: /){
			print RF "SL   ".substr($_,31);
		}else{
			print RF;
		}
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub DeleteBracket{
### This subroutine deletes brackets{} containing references.

	my $startTime = Time::HiRes::time();

	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-allT2.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allT3.txt";
	my $routineName = "DeleteBracket";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		s/ {.+?}//g;
		
		print RF;
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub DeleteNote{
### This subroutine deletes "Note=" and its contents.

	my $startTime = Time::HiRes::time();

	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-allT3.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allT4.txt";
	my $routineName = "DeleteNote";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		s/ Note=.+//g;
		
		print RF $_;
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub TakeNote{
### This subroutine writes the contents of "Note=".

	my $startTime = Time::HiRes::time();
	my $fileLine = 0;
	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-allT3.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allTakeNote.txt";
	my $routineName = "TakeNote";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		if(m/(Note=.+\.)/){
			print RF $1."\n";
		}

	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}

sub DeleteColon{
### This subroutine deletes "Note=" and its contents.

	my $startTime = Time::HiRes::time();

	my $DBFilename = $MySLE::dirData."ID-SL_rev_uniprot-allT4.txt";
	my $ResultFileName = $MySLE::dirData."ID-SL_rev_uniprot-allT5.txt";
	my $routineName = "DeleteColon";
	
	my $objPB = new MyProgressBar;
	
	print "$routineName starts.\n";
	
	open DB,$DBFilename or die "No file";
	
	$objPB->setAll($DBFilename);
	
	open RF, ">$ResultFileName";
	
	while(<DB>){
		$objPB->nowAndPrint($.);
		
		s/^SL   .+: /SL   /g;
		
		print RF $_;
	}
	print "end\n";
	close DB;	close RF;
	
	printf("%0.3f",Time::HiRes::time - $startTime); 
}