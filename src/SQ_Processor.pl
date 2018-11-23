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

#my ($id_ref, $position_ref) = &motif_search("LL.YKH");
#my @id_list = @$id_ref;
#my $num = @id_list;
#
#foreach my $id (@id_list){
#	print("$id: $$position_ref{$id}\n");
#}
#print("$num\n");

###

sub motif_search{
	my ($query_id_list_ref, $query) = MyP::check_argument_2_ID_list_string(@_);
	
	if($query eq ""){
		#モチーフが指定されていなかったら、配列全体を取得すると解釈する。
		$query = "[A-Z]+";
	}
	
	my @matched_id = ();
	my %matched_position =();
	
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
			my $position = "";
			while($seq =~ m/$query/g){
				#Positionコードを作る。Rangeを","で区切る
				
				$position = $position.sprintf("%d-%d,", length($`)+1, length($`.$&) );
			}
			
			unless($position eq ""){
				push(@matched_id, $this_id);
				
				chop($position);
				$matched_position{$this_id} = $position;
			}
		}
	}			
	
	close $DB;
	
	my @answer = (\@matched_id, \%matched_position);
	return \@answer;
	
}

sub get_peptide_by_code{
	my ($query_id_list_ref, $code_ref) = @_;
	
	my %matched_peptide =();
	
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
			
			#配列を取得してrange部分を抜き出す。
			my $seq = <$DB>;
			$objPB -> addNowAndPrint($seq);
			chomp($seq);
			
			my $ranges_ref = &MyP::get_ranges_in_code($$code_ref{$this_id});
			my $peptide = "";
			
			foreach my $range (@$ranges_ref){
				my @both_ends = split(/-/,$range);
				my $temp = substr($seq,$both_ends[0]-1, $both_ends[1]-$both_ends[0]+1);
				$peptide = $peptide."$temp,";
			}
			
			chop($peptide);
			$matched_peptide{$this_id} = $peptide;
		}
	}			
	
	close $DB;
	
	return \%matched_peptide;
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