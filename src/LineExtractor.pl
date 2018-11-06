#	181106	ver 0.9	とりあえず完成。

package MyLE;

use Time::HiRes;
require "MyProgressBar.pm";
require "DataFileName.pl";

my $dataDir = DFName::get_data_file_dir();
#my $catalogDir = "../contents_catalog_list/$species/rev/";
#my $raw_textfile_name = "rev_uniprot-all.txt";
my $raw_textfile_name = DFName::get_raw_data_file_name();
#my $raw_textfile_name = "181101_rev_uniprot_human_all.txt";
my $raw_textfile_path = $dataDir.$raw_textfile_name;

#コードはハッシュにして保守しやすくしよう。
#TODO この辺の名前とかディレクトリだけのperlファイルを作って参照したほうがいいのかもしれない。
#my %code_list =(
#    'GNDE' => "GMDE",
#    'FT' => "FT",
#    'CC' => "CC",
#    'GO' => "GO",
#    'SQ' => "SQ",
#    'SL' => "SL");

###

sub main{
	&All_Extractor();
}

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

sub GOContentExtractor{
	my $startTime = Time::HiRes::time();
	my $DBFilename = $MyLE::dataDir."ID-GO_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::catalogDir."GOContetnts.txt";
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

sub All_Extractor{
	&GNDE_Extractor();
	&FT_Extractor();
	&CC_Extractor();
	&GO_Extractor();
	&SQ_Extractor();
	&SL_Extractor();
}

sub GNDE_Extractor{
	my $code_name = DFName::get_GNDE_code_name();
	my $regex = "^GN|^DE";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
}

sub FT_Extractor{
	my $code_name = DFName::get_FT_code_name();
	my $regex = "^FT";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
	&_Flatten_Extracted_Text_Template($code_name);
}

sub CC_Extractor{
	my $code_name = DFName::get_CC_code_name();
	my $regex = "^CC";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
}

sub GO_Extractor{
	my $code_name = DFName::get_GO_code_name();
	my $regex = "^DR   GO";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
}

sub SQ_Extractor{
	my $code_name = DFName::get_SQ_code_name();
	my $regex = "^ ";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
}

sub SL_Extractor{
	my $code_name = DFName::get_SL_code_name();
	my $regex = "^CC   -!- SUBCELLULAR LOCATION";
	
	&_Line_Code_Extractor_Template($code_name, $regex);
	&_Flatten_Extracted_Text_Template($code_name);
}

sub _Line_Code_Extractor_Template{

	(my $code_name, my $regex) = @_;
	my $ResultFileName = $dataDir."ID-${code_name}_$raw_textfile_name";
	
	my $startTime = Time::HiRes::time();
	print "${code_name}_Extractor starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($raw_textfile_path);
	
	open (my $DB, '<', $raw_textfile_path) or die $!;
	open (my $RF, '>', $ResultFileName) or die $!;
	
	if($code_name eq DFName::get_SQ_code_name() ){
		&_Extract_Processor_SQ($DB, $RF, $regex, $objPB);
	}elsif($code_name eq DFName::get_SL_code_name() ){
		&_Extract_Processor_SL($DB, $RF, $regex, $objPB);
	}else{
		&_Extract_Processor_Simple($DB, $RF, $regex, $objPB);
	}
		
	close $DB;
	close $RF;
	
	print "${code_name}_Extractor ends. ";
	printf("%0.3f sec.\n",Time::HiRes::time - $startTime); 
}

sub _Extract_Processor_Simple{
	(my $DB, my $RF, my $regex, my $myPB) = @_;
	
	while(my $line = <$DB>){
		
		if(defined($myPB)){
			$myPB->addNowAndPrint($line);
		}
		
		if($line =~ m-^ID|^//$-){
			print $RF $line;
		}elsif($line =~ m/$regex/){
			print $RF $line;
		}
	}
	
	return;
}

sub _Extract_Processor_SQ{
	(my $DB, my $RF, my $regex, my $myPB) = @_;
	
	my $seq;
	
	while(my $line = <$DB>){
		
		if(defined($myPB)){
			$myPB->addNowAndPrint($line);
		}
		
		if($line =~ m/^ID/){
			print $RF $line;
			next;
		}elsif($line !~ m/$regex/){
			next;
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
	}
	
	return;
	
}

sub _Extract_Processor_SL{
	(my $DB, my $RF, my $regex, my $myPB) = @_;
	
	while(my $line = <$DB>){
		
		if(defined($myPB)){
			$myPB->addNowAndPrint($line);
		}
		
		if($line =~ m-^ID|^//$-){
			print $RF $line;
			next;
		}elsif($line !~ m/$regex/){
			next;
		}else{
			print $RF $line;
		}
		
		while($line = <$DB>){
			
			if(defined($myPB)){
				$myPB->addNowAndPrint($line);
			}
			
			if($line =~ m/$regex|^CC       /){
				print $RF $line;
			}else{
				last;
			}
		}
	}
	
	return;
}

sub _Flatten_Extracted_Text_Template{
	my $code_name = shift;
	
	my $open_file_name = "ID-${code_name}_$raw_textfile_name";
	my $recode_file_name = "f-".$open_file_name;
	
	my $startTime = Time::HiRes::time();
	print "Flatten_Extracted_${code_name}_Text starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($dataDir.$open_file_name);
	
	open(my $IN, '<', $dataDir.$open_file_name) or die($!);
	open(my $OUT, '>', $dataDir.$recode_file_name) or die($!);
	
	my $content = "";
	
	if($code_name eq DFName::get_SL_code_name() ){
		_Flattening_Processor_SL($IN, $OUT, $objPB);
	}elsif($code_name eq DFName::get_FT_code_name() ){
		_Flattening_Processor_FT($IN, $OUT, $objPB);
	}
	
	close $IN;
	close $OUT;
	
	unlink($dataDir.$open_file_name);
	rename($dataDir.$recode_file_name, $dataDir.$open_file_name);	
	
	print "Flatten_Extracted_${code_name}_Text ends. ";
	printf("%0.3f sec.\n",Time::HiRes::time - $startTime); 
}

sub _Flattening_Processor_SL{
	(my $IN, my $OUT, my $myPB) = @_;
	
	my $content = "";
	
	while(my $line = <$IN>){
		$myPB->addNowAndPrint($line);
		my $last_word = "";
		
		if($line =~ m/^ID/){
			print($OUT $line);
			next;
			
		}elsif($line =~ m|^//$|){
			if(!$content eq ""){
				chop($content);
				print($OUT "$content\n");
				$content = "";
			}
			print($OUT $line);
			next;
			
		}elsif($line =~ m/^CC   -!- /){
			if(!$content eq ""){
				chop($content);
				print($OUT "$content\n");
				$content = "";
			}	
		}
		
		chomp($line);
		$last_word = substr($line,-1,1);
		$line = substr($line,9);
		if($last_word eq "-"){
			$content = $content.$line;
		}else{
			$content = $content.$line." ";
		}
	}
}

sub _Flattening_Processor_FT{
	(my $IN, my $OUT, my $myPB) = @_;
	
	my $content = "";
	
	while(my $line = <$IN>){
		$myPB->addNowAndPrint($line);
		my $last_word = "";
		
		if($line =~ m/^ID/){
			print($OUT $line);
			next;
			
		}elsif($line =~ m|^//$|){
			if(!$content eq ""){
				chop($content);
				print($OUT "$content\n");
				$content = "";
			}
			print($OUT $line);
			next;
			
		}elsif($line =~ m/^FT   \w/){
			if(!$content eq ""){
				chop($content);
				print($OUT "$content\n");
				$content = "";
			}	
		}else{
			$line = substr($line,34);
		}
		
		chomp($line);
		$last_word = substr($line,-1,1);
		
		if($last_word eq "-"){
			$content = $content.$line;
		}else{
			$content = $content.$line." ";
		}
	}
}

&main();

1;