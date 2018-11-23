#181115		ver0.1		作り始め。

#アミノ酸配列の処理についてまとめたパッケージを作るのが目標

use strict;
use warnings;

package MySQP;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::
require "Shared_Process.pl"; # MyP::

#my $search_file_path = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";
my $search_file_path = MyName::get_data_file_path($MyName::SQ_KEY);

my @aa_one_letter = ("A","C","D","E","F","G","H","I","K","L","M","N","P","Q","R","S","T","V","W","Y");

###
my ($id_ref, $range_ref) = &motif_search("LL.YKH");
my @id_list = @$id_ref;
my $num = @id_list;

foreach my $id (@id_list){
	print("$id: $$range_ref{$id}\n");
}
print("$num\n");

###

sub motif_search{
	my ($query_id_list_ref, $query) = MyP::check_argument_2_ID_list_string(@_);
	
	if($query eq ""){
		#モチーフが指定されていなかったら、配列全体を取得すると解釈する。
		$query = "[A-Z]+";
	}
	
	my @matched_id = ();
	my %matched_range =();
	
	#open database file
	open my $DB, '<', $search_file_path or die($!);
	
	my $objPB = new MyProgressBar;
	$objPB -> setAll($search_file_path);
	
	#ID行がくるまでループ
	while(my $line = <$DB>){
	
		$objPB -> addNowAndPrint($line);
		
		if($line =~ m/^ID   (.+?) /){
			my $this_id = $1;
			
			#もしIDリストが渡されていた場合、見つかったIDがリストに含まれているかを調べる。
			#含まれていなかったら、またIDを探すループに戻る。
			if(ref($query_id_list_ref) eq "ARRAY"){
				if(!&MyP::has_overrup_in_array($query_id_list_ref,$this_id)){
					next;
				}
			}
			
			#配列を取得してモチーフを持つか調べる。
			my $seq = <$DB>;
			
			$objPB -> addNowAndPrint($seq);
			
			chomp($seq);
			my $range = "";
			while($seq =~ m/$query/g){
				#SQデータコード。start-endでそれを","で区切る
				
				$range = $range.sprintf("%d-%d,", length($`)+1, length($`.$&) );
			}
			
			unless($range eq ""){
				push(@matched_id, $this_id);
				
				chop($range);
				$matched_range{$this_id} = $range;
			}
		}
	}			
	
	close $DB;
	
	return \@matched_id, \%matched_range;
	
}


sub count_aa{
	
	#open database file
	open my $DB, '<', $search_file_path or die($!);
	
	#record file
	my $record_path = MyName::get_data_file_dir() . "aa_count.csv";
	open my $RF, '>', $record_path or die($!);
	
	#初期化。アミノ酸の１文字表記をカンマ区切りで一行目に入れていく。
	my $temp = "";
	for(my $i = 0; $i < 20; $i++){
		$temp = $temp.$aa_one_letter[$i].",";
	}
	chop($temp);
	$temp = $temp."\n";
	print $RF $temp;
	
	my $objPB = new MyProgressBar;
	$objPB -> setAll($search_file_path);
	
	while(my $line = <$DB>){
		
		$objPB -> addNowAndPrint($line);
		
		if($line =~ m/^ID/){
			#ID行に興味はないので次へ。
			next;
		}
		
		# 1stメチオニンを除く
		$line = substr($line,1);
		
		$temp = "";
		for(my $i = 0; $i < 20; $i++){
			#各アミノ酸について、文字数をカウントしていく。
			my $count = 0;
			$count = (() = $line =~ /$aa_one_letter[$i]/g);
			$temp = $temp."$count,";
		}
		
		chop($temp);
		$temp = $temp."\n";
		print $RF $temp;
		
	}
	
	close $DB;
	close $RF;
}