#181029		ver0.1		作り始め。

#FT行の処理についてまとめたパッケージを作るのが目標

use strict;
use warnings;
use Time::HiRes;

package MyFTP;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::
require "Shared_Process.pl"; # MyP::

#my $search_file_path = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";
my $search_file_path = MyName::get_data_file_path($MyName::FT_KEY);

###

###

sub is_transmembrane{
	my $query_key = "TRANSMEM";
	my $converse_dsc = "";
	my ($id_list_ref, $query_dsc) = &MyP::check_argument_2_ID_list_string(@_);
	
	return _get_ft_contents_by_key_and_description($id_list_ref, $query_key, $query_dsc, $converse_dsc)
}

sub is_not_transmembrane{
	my $query_key = "TRANSMEM";
	my $converse_dsc = "not transmembrane region";
	my ($id_list_ref, $query_dsc) = &MyP::check_argument_2_ID_list_string(@_);
	
	return _get_ft_contents_by_key_and_description($id_list_ref, $query_key, $query_dsc, $converse_dsc)
}

sub is_lipidated{
	my $query_key = "LIPID";
	my $converse_dsc = "";
	my ($id_list_ref, $query_dsc) = &MyP::check_argument_2_ID_list_string(@_);
	
	return _get_ft_contents_by_key_and_description($id_list_ref, $query_key, $query_dsc, $converse_dsc)
}

sub _get_ft_contents_by_key_and_description{
	#
	
	my ($query_id_list_ref, $query_key, $query_dsc, $converse_dsc) = @_;
	
	my @matched_id = ();
	my %id_to_code = ();
	
	#open database file
	open my $DB, '<', $search_file_path or die($!);
	
	my $objPB = new MyProgressBar;
	$objPB -> setAll($search_file_path);
	
	#ID行がくるまでループ
	while(my $line = <$DB>){
	
		$objPB -> addNowAndPrint($line);
		
		if($line =~ m/^ID   (.+?) .+?(\d+?) AA./){
			my $this_id = $1;
			my $aa_length = $2;
			
			#もしIDリストが渡されていた場合、見つかったIDがリストに含まれているかを調べる。
			#含まれていなかったら、またIDを探すループに戻る。
			if(ref($query_id_list_ref) eq "ARRAY"){
				if(!&MyP::has_overrup_in_array($query_id_list_ref,$this_id)){
					next;
				}
			}
			
			my @matched_line = ();
			
			#FTのKeyがqueryと一致するものを探す
			while($line = <$DB>){
				
				$objPB -> addNowAndPrint($line);
				
				#タンパク質の最後の行になったらID取得ループに戻る。
				if($line =~ m|^//$|){ last; }
				
				#目的Keyが見つからなかったら次の行に移る。
				if($line !~ m/^FT   $query_key/){ next; }
				
				#目的のKeyが見つかったら、目的のDescriptionを含むかを調べる。
				#目的のDescriptionを含まないなら次の行に移る。(query_dscの前の文字数を27文字にすることで、query_dscに""を渡したときに、Keyだけの検索を行うことができる。)
				if($line !~ m/.{27,}$query_dsc/){ next; }
				
				chomp($line);
				push(@matched_line, $line);
			}
			
			#queryに合致する行があったら、IDリストへの追加と内容をハッシュに登録をする。
			if(@matched_line != 0){
				
				if($converse_dsc eq ""){
					#合致した部分をコード化する場合
					$id_to_code{$this_id} = &_make_ft_code(\@matched_line);
					push(@matched_id,$this_id);
				}else{
					#合致した部分以外をコード化する場合
					$id_to_code{$this_id} = &_make_converse_ft_code(\@matched_line, $aa_length, $converse_dsc);
					push(@matched_id,$this_id);
				}
			}elsif(@matched_line == 0 and $converse_dsc ne ""){
				#合致した行が無かったとしても、モードが合致した部分以外のコード化なら登録作業をする。
				$id_to_code{$this_id} = &_make_converse_ft_code(\@matched_line, $aa_length, $converse_dsc);
				push(@matched_id,$this_id);
			}
		}
	}
	
#	foreach my $id (@matched_id){
#		print("$id : $id_to_code{$id}\n");
#	}
	
	#return \@matched_id, \%id_to_code;
	
	my @answer_pack = (\@matched_id, \%id_to_code);
	return \@answer_pack;
}

sub _make_ft_code{
	#FT行が入った配列を受け取って、"Key1*,Start-End*,Description*;Key2 ..."というフォーマットに変える。
	
	my $matched_line_ref = shift;
	
	my $code ="";
	
	#区切りを入れていく。
	foreach my $line (@$matched_line_ref){
		my $item_ref = &_get_ft_all_items($line);
		
		$code = $code."$$item_ref[0]*,$$item_ref[1]-$$item_ref[2]*,$$item_ref[3]*;"
	}
	
	#文末についている区切り文字*;を消す。
	$code = substr($code, 0, -2);
	
	return $code;
	
}

sub _make_converse_ft_code{
	#FT行が入った配列とタンパク質の長さを受け取って、それ以外の領域を"CONVERSE*,Start-End*,$converse_dsc*;Key2 ..."というフォーマットに変える。
	
	my ($matched_line_ref, $aa_length, $converse_dsc) = @_;
	
	#配列の初期化。
	my @aa;
	for(my $i = 0; $i <= $aa_length + 1; $i++){
		push(@aa, 0);
	}
	$aa[0] = 1;              #配列を1スタートにするので、インデックス0の要素は原則使わない。
	$aa[$aa_length + 1] = 1; #アミノ酸配列が終わったことを示す終了ポインタ扱いの要素。
	
	#FT行に含まれていた部分を1に変える。
	foreach my $line (@$matched_line_ref){
		my $from = &_get_ft_from($line);
		my $to = &_get_ft_to($line);
		
		for (my $i = $from; $i <= $to; $i++){
			$aa[$i] = 1;
		}
	}
	
	#@aaの0の領域をrangeに変換する
	my $code = "";
	my $search_start = 1;
	my ($from, $to);
	for (my $i = 1; $i <= $aa_length + 1; $i++){
		if($search_start and $aa[$i] == 0){
			$from = $i;
			$search_start = 0;
		}elsif( not($search_start) and $aa[$i] == 1){
			$to = $i - 1;
			
			$code = $code."CONVERSE*,$from-$to*,$converse_dsc*;";
			
			$search_start = 1;
		}
	}
	
	#文末についている区切り文字*;を消す。
	$code = substr($code, 0, -2);
	
	return $code;
	
}

sub _get_ft_all_items{
	my $FTLine = shift;
	
	my @FTItems = (&_get_ft_key($FTLine), &_get_ft_from($FTLine), &_get_ft_to($FTLine), &_get_ft_description($FTLine) );
	
	return \@FTItems;
}

sub _get_ft_from{
	my $FTLine = shift;
	
	my $FTFrom = substr($FTLine, 14, 6);
	$FTFrom =~ tr/ //d;
	
	return $FTFrom;
}

sub _get_ft_to{
	my $FTLine = shift;
	
	my $FTTo = substr($FTLine, 21, 6);
	$FTTo =~ tr/ //d;
	
	return $FTTo;
}

sub _get_ft_key{
	my $FTLine = shift;
	
	my $FTKey = substr($FTLine, 5, 8);
	$FTKey =~ tr/ //d;
	
	return $FTKey;
}

sub _get_ft_description{
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