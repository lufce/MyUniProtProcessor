#	181106	ver 0.9	とりあえず完成。
#TODO FT行など、抜き出すのが増えるたびの、重たい元データファイルを開き直すのは頭のいいやり方では無いと思う。
#     一回、元データファイルを開いたら、行コードごとに対応する記録ファイルに書き込むよなLineExtractorを作るべき。
#     少なくとも、行コードの１回の判定だけで済むような、GNDE,FT,CC,SQExtractorは、１回でできるはず。

package MyLE;

use strict;
use warnings;
use Time::HiRes;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::

my $dataDir = MyName::get_data_file_dir();
my $raw_text_file_name = MyName::get_raw_data_file_name();
my $raw_text_file_path = $dataDir.$raw_text_file_name;

###

&test();

sub test{
	&GNDE_Extractor();
}

###

sub AddEndMarker{
	my $DBFilename =$MyLE::dataDir."ID-sq_rev_uniprot-all.txt";
	my $ResultFileName = $MyLE::dataDir."ID-sq_rev_uniprot-all2.txt";
	my $routineName = "AddEndMarker";
	
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
	my $ResultFileName = "GOContetnts.txt";
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

sub sort_raw_data_text{
	#GO matchやFT matchを行う際に、元のテキストデータがID昇順に並んでいるほうが絶対にいいので、最初にソートしてしまう。

	my @ID_catalog = ();
	my @index = ();
	my @contents = ();
	
	print("sort_raw_data_text starts.\n");
	
	my $raw_data_path = MyName::get_raw_data_file_path();	
	open my $IN , '<', $raw_text_file_path or die $!;
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($raw_text_file_path);
	
	print("collecting IDs ...\n");
	
	while(my $line = <$IN>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m/^ID   (.+?) /){
			push(@ID_catalog, $1)
		}
	}
	close $IN;
	
	print("sorting IDs ...\n");
	
	my @sorted = sort @ID_catalog;
	
	print("making ID index ...\n");
	
	for(my $i = 0; $i <= $#ID_catalog; $i++){
		for (my $j = 0; $j <= $#ID_catalog; $j++){
			if($sorted[$i] eq $ID_catalog[$j]){
				push(@index, $j);
				last;
			}
		}
	}

	print("split raw text ...\n");
	open my $IN2 , '<', $raw_text_file_path or die $!;
	{
		local $/ = "\n//\n";
		@contents = <$IN2>;
	}
	close $IN2;
	
	print("recording sorted raw text ...\n");
	my $record_path = MyName::get_data_file_dir();
	$record_path = $record_path."sorted.txt";
	open my $OUT, '>', $record_path or die $!;
	
	$objPB->setAll($#index);	
	for(my $i = 0; $i <= $#index; $i++){
		$objPB->nowAndPrint($i);
		print $OUT $contents[$index[$i]]
	}
	close $OUT;

	print("sort_raw_data_text ends.\n");
	<STDIN>;
}

sub GNDE_Extractor{
	my $regex = "^GN|^DE";
	
	&_Line_Code_Extractor_Template($MyName::GNDE_KEY, $regex);
}

sub FT_Extractor{
	my $regex = "^FT";
	
	&_Line_Code_Extractor_Template($MyName::FT_KEY, $regex);
	&_Flatten_Extracted_Text_Template($MyName::FT_KEY);
}

sub CC_Extractor{
	my $regex = "^CC";
	
	&_Line_Code_Extractor_Template($MyName::CC_KEY, $regex);
}

sub GO_Extractor{
	my $regex = "^DR   GO";
	
	&_Line_Code_Extractor_Template($MyName::GO_KEY, $regex);
}

sub SQ_Extractor{
	my $regex = "^ ";
	
	&_Line_Code_Extractor_Template($MyName::SQ_KEY, $regex);
}

sub SL_Extractor{
	my $regex = "^CC   -!- SUBCELLULAR LOCATION";
	
	&_Line_Code_Extractor_Template($MyName::SL_KEY, $regex);
	&_Flatten_Extracted_Text_Template($MyName::SL_KEY);
}

sub _Line_Code_Extractor_Template{

	my ($code_key, $regex) = @_;
	my $record_file_path = MyName::get_data_file_path($code_key);
	
	my $startTime = Time::HiRes::time();
	print $code_key."_Extractor starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($raw_text_file_path);
	
	open (my $DB, '<', $raw_text_file_path) or die $!;
	open (my $RF, '>', $record_file_path) or die $!;
	
	if($code_key eq $MyName::SQ_KEY ){
		&_Extract_Processor_SQ($DB, $RF, $regex, $objPB);
	}elsif($code_key eq $MyName::SL_KEY ){
		&_Extract_Processor_SL($DB, $RF, $regex, $objPB);
	}else{
		&_Extract_Processor_Simple($DB, $RF, $regex, $objPB);
	}
		
	close $DB;
	close $RF;
	
	print $code_key."_Extractor ends. ";
	my $endTime = Time::HiRes::time - $startTime;
	print("$endTime sec.\n"); 
}

sub _Extract_Processor_Simple{
	my ($DB, $RF, $regex, $myPB) = @_;
	
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
	my ($DB, $RF, $regex, $myPB) = @_;
	
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
	my ($DB, $RF, $regex, $myPB) = @_;
	
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
	my $code_key = shift;
	
	my $open_file_name = MyName::get_data_file_name($code_key);
	my $recode_file_name = "f-".$open_file_name;
	
	my $startTime = Time::HiRes::time();
	print "Flatten_Extracted_".$code_key."_Text starts.\n";
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($dataDir.$open_file_name);
	
	open(my $IN, '<', $dataDir.$open_file_name) or die($!);
	open(my $OUT, '>', $dataDir.$recode_file_name) or die($!);
	
	my $content = "";
	
	if($code_key eq $MyName::SL_KEY){
		_Flattening_Processor_SL($IN, $OUT, $objPB);
	}elsif($code_key eq $MyName::FT_KEY){
		_Flattening_Processor_FT($IN, $OUT, $objPB);
	}
	
	close $IN;
	close $OUT;
	
	unlink($dataDir.$open_file_name);
	rename($dataDir.$recode_file_name, $dataDir.$open_file_name);	
	
	print "Flatten_Extracted_".$code_key."_Text ends. ";
	printf("%0.3f sec.\n",Time::HiRes::time - $startTime); 
}

sub _Flattening_Processor_SL{
	my ($IN, $OUT, $myPB) = @_;
	
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
	my ($IN, $OUT, $myPB) = @_;
	
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

1;