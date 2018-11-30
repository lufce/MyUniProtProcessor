#181118		ver0.1		作り始め。

#GE行DE行の処理についてまとめたパッケージを作るのが目標
#_function_frameworkのwhileループの中で、個別の処理に飛ばしている。
#サブルーチンが増えるごとに$CODE_...という変数も増やしていく。
#アンダーバー以降は_function_frameworkを呼び出した関数名と同じにすること。

use strict;
use warnings;

package MyGNDEP;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::
require "Shared_Process.pl"; # MyP::

#my $search_file_path = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";
my $search_file_path = MyName::get_data_file_path($MyName::GNDE_KEY);

my $CODE_id_to_full_RecName = "id_to_full_RecName";
my $CODE_get_all_ID = "get_all_ID";
my $CODE_name_search = "name_search";

###

my @ids = ("1433B_HUMAN","SSPO_HUMAN","SSR3_HUMAN");
my $ans = &id_to_full_RecName(\@ids);
my @k = keys $$ans[1];
my @v = values $$ans[1];
my @a = @{$$ans[0]};
print("@a\n@v");
###

sub get_all_ID{
	return &_function_framework($CODE_get_all_ID);
}

sub id_to_full_RecName{
	my $query_id_list_ref= MyP::check_argument_1_ID_list(shift);
	
	return &_function_framework($CODE_id_to_full_RecName, $query_id_list_ref);
}

sub name_search{
	my ($id_list_ref, $query_name) = &MyP::check_argument_2_ID_list_string(@_);
	
	return &_function_framework($CODE_name_search, $id_list_ref, $query_name);
}

sub _function_framework{
	
	my ($process_code, $query_id_list_ref, $query_name) = @_;
	
	my @matched_id = ();
	my %id_to_code = ();
	
	my $search_all = 0;
	my $pointer = 0;
	my $id_num = 0;

	if($query_id_list_ref eq ""){
		#ID listが無かったから全IDを検索する。
		$search_all = 1;
	}else{
		$id_num = @$query_id_list_ref;
	}
	
	#open database file
	open my $DB, '<', $search_file_path or die($!);
	
	my $objPB = new MyProgressBar;
	$objPB -> setAll($search_file_path);
	
	#ID行がくるまでループ
	
	while(my $line = <$DB>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m/^ID   (.+?) /){
			my $this_id = $1;
			
			if($search_all == 0 and $pointer >= $id_num){
				last;
			}
			
			if($search_all == 0 and $$query_id_list_ref[$pointer] ne $this_id){
				#全検索でもなく、調べるべきIDでも無かったら次のIDを探す。
				next;
			}
			
			$pointer++;
			
			if($process_code eq $CODE_id_to_full_RecName){ &_process_id_to_full_RecName($DB, $objPB, $this_id, \%id_to_code) }
			if($process_code eq $CODE_get_all_ID){ push(@matched_id, $this_id) }
			if($process_code eq $CODE_name_search){ &_process_name_serch($DB, $objPB, $this_id, \@matched_id, \%id_to_code, $query_name) }
		}
	}
	
	close $DB;
	
	if($process_code eq $CODE_id_to_full_RecName){@matched_id = @$query_id_list_ref;}
	
	my @answer_pack = (\@matched_id, \%id_to_code);
	return \@answer_pack;
	
}

sub _process_id_to_full_RecName{
	my ( $DB, $objPB, $this_id, $id_to_code_ref) = @_;
	
	while(my $line = <$DB>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m/^DE   RecName: Full=(.+);/){
			my $name = $1;
			$name =~ s/{.+?}//g;
			$$id_to_code_ref{$this_id} = $name;
			last;
		}
	}
}

sub _process_name_serch{
	my ( $DB, $objPB, $this_id, $matched_id_ref, $id_to_code_ref, $regex) = @_;
	
	my $code = "";
	
	while(my $line = <$DB>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m|//|){
			if($code ne ""){
				$code = substr($code,-2);
				push(@$matched_id_ref, $this_id);
				$$id_to_code_ref{$this_id} = $code;
			}
			
			last;
		}
		
		if($line =~ m/=(.+?);/){
			my $name = $1;
			if($name =~ m/$regex/){
				
				#Simpleデータコードとしてエンコード。
				$code = $code.$name."*,";
			}
		}
	}
}
