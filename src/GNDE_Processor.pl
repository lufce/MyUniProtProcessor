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

my $CODE_ID2RecName = "ID2RecName";
my $CODE_get_all_ID = "get_all_ID";

###

my $id = &get_all_ID();
my $aaa = &ID2RecName();
my $num = @$id;
for (my $index = 0; $index < $num ; $index++){
	print("$$id[$index]:$$aaa[$index]\n");
}
###

sub get_all_ID{
	&_function_framework($CODE_get_all_ID);
}

sub ID2RecName{
	my $query_id_list_ref= MyP::check_argument_1_ID_list(shift);
	
	if($query_id_list_ref eq ""){
		&_function_framework($CODE_ID2RecName);
	}else{
		&_function_framework($CODE_ID2RecName, $query_id_list_ref);
	}
}

sub RecName_serch{
	
}

sub _function_framework{
	
	my ($process_code, $query_id_list_ref, $query) = @_;
	
	my @contents = ();
	my $search_all = 0;
	my $pointer = 0;
	my $id_num = 0;

	if(defined($query_id_list_ref)){
		$id_num = @$query_id_list_ref;
	}else{
		#ID listが無かったから全IDを検索する。
		$search_all = 1;
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
			
			if(!$search_all and !$$query_id_list_ref[$pointer] eq $this_id){
				#全検索でもなく、調べるべきIDでも無かったら次のIDを探す。
				next;
			}else{
				$pointer++;
			}
			
			if($process_code eq $CODE_ID2RecName){ &_process_ID2RecName($DB, $objPB, \@contents) }
			if($process_code eq $CODE_get_all_ID){ push(@contents, $this_id) }
		}
	}
	
	close $DB;
	return \@contents;
	
}

sub _process_ID2RecName{
	my ( $DB, $objPB, $contents_ref) = @_;
	
	while(my $line = <$DB>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m/DE   RecName: Full=(.+);/){
			my $name = $1;
			$name =~ s/{.+?}//g;
			push(@$contents_ref, $name);
		}
	}
}

sub _process_RecName_serch{
	my ( $DB, $objPB, $contents_ref) = @_;
	
	while(my $line = <$DB>){
		$objPB->addNowAndPrint($line);
		
		if($line =~ m/DE   RecName: Full=(.+);/){
			my $name = $1;
			$name =~ s/{.+?}//g;
			push(@$contents_ref, $name);
		}
	}
}
