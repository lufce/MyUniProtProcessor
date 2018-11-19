### FTの内容やGOの内容、SLの内容などのカタログを作るための関数群。

package MyCM;

use Time::HiRes;
use strict;
use warnings;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::

my $trimed_surfix = "trimmed_";

####

&_test();

sub _test{
	&make_FT_trimmed_file();
	
	my $key_catalog_ref = &make_FT_key_catalog();
	my $key_dsc_hash_ref = make_FT_description_catalog_by_FT_key($key_catalog_ref);
	
	foreach my $key (@$key_catalog_ref){
		my $array_ref = $$key_dsc_hash_ref{$key};
		
		print("KEY:$key\n");
		foreach my $item (@$array_ref){
			print("    $item\n");
		}
	}
	
	print("end\n")
}

####

sub make_FT_trimmed_file{
	
	my $data_dir = MyName::get_data_file_dir();
	my $record_file_name = $trimed_surfix.$MyName::FT_KEY.MyName::get_raw_data_file_name();
	
	open (my $IN, '<', MyName::get_data_file_path($MyName::FT_KEY)) or die($!);
	open (my $OUT, '>', $data_dir.$record_file_name) or die($!);
	
	while(my $line = <$IN>){
		$line = &_del_contents_in_curly_brackets($line);
		$line = &_del_FTId($line);
		
		print($OUT $line);
	}
	
	close ($IN);
	close ($OUT);
}

sub make_FT_description_catalog_by_FT_key{
	#FT Keyを含んだ配列のリファレンスを受け取って、KeyごとのDescriptionを入れた配列のリファレンスを含んだハッシュのリファレンスを返す。
	
	my $key_catalog_ref =shift;
	my @key_catalog = @$key_catalog_ref;
	
	my $data_dir = MyName::get_data_file_dir();
	my $trimmed_file_name = $trimed_surfix.$MyName::FT_KEY.MyName::get_raw_data_file_name();
	
	#TODO これはFTファイルをトリムしたファイルに変えないといけない。
	my $FT_file_path = $data_dir.$trimmed_file_name;
	open (my $IN, '<', $FT_file_path) or die($!);
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($FT_file_path);
	
	#Keyの数だけ独立した空の配列のリファレンスをハッシュに入れていく。
	my %key_contents_hash = ();
	foreach my $key (@key_catalog){
		my @contents = ();
		$key_contents_hash{$key} = \@contents;
	}
	
	while(my $line = <$IN>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ /^FT/){
			my $key = &_getFTKey($line);
			my $dsc = &_getFTDescription($line);
			
			#キーが存在しないならエラーメッセージを吐いて次へ
			if(!exists $key_contents_hash{$key}){
				print("FT Key:$key is not found in key catalog\n");
				next;
			}
			
			my $contents_ref = $key_contents_hash{$key};
			
			if(&_has_overrup_in_array($contents_ref, $dsc)){
				next;
			}else{
				push (@$contents_ref, $dsc);
			}
		}
	}
	
	close ($IN);
	
	return \%key_contents_hash;
}


sub make_FT_key_catalog{
	#FTキーを重複無く含んだソート済みの配列を返す。
	
	my @catalog = ();
	my $FT_file_path = MyName::get_data_file_path($MyName::FT_KEY);
	
	open (my $IN, '<', $FT_file_path) or die($!);
	
	my $objPB = new MyProgressBar;
	$objPB->setAll($FT_file_path);
	
	while(my $line = <$IN>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ /^FT/){
			my $key = &_getFTKey($line);
			
			if(&_has_overrup_in_array(\@catalog, $key)){
				next;
			}else{
				push (@catalog, $key);
			}
		}
	}
	
	close ($IN);
	
	@catalog = sort @catalog;
	
	return \@catalog;
}

################## Common routines

sub _has_overrup_in_array{
	#空の配列を受け取ったり、要素の重複がなかったら0を返す。
	#重複があれば1を返す。
	
	my ($array_ref, $key) = @_;
	
	my $length = @$array_ref;
	if($length == 0 ){
		return 0;
	}
	
	foreach my $item (@$array_ref){
		if($item eq $key){
			return 1;
		}
	}
	
	return 0;
}

sub _del_contents_in_curly_brackets{
	#波括弧とその中身、および波括弧前方の空白を削除する。
	
	my $line = shift;
	$line =~ s/ +\{.+?\}\.//g;
	
	return $line;
}

################## SL routins

sub _del_SUBCELLULAR_LOCATION{
	return substr(shift,22);
}

################## FT routins

sub _del_FTId{
	
	my $line = shift;
	$line =~ s| +/FTId.+?\.||;
	
	return $line;
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
	my $FTDsc = "";
	
	chomp($FTLine);
	
	if(length($FTLine) >= 35){
		$FTDsc = substr($FTLine, 34);
		chomp($FTDsc);
	}
	
	return $FTDsc;
}

1;