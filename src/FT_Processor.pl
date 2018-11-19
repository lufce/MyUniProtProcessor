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

sub isTransmembrane{
	my $query_key = "TRANSMEM";
	my ($id_list_ref, $query_dsc) = &MyP::_check_argument1(@_);
	
	return get_FT_Contents_By_Key_And_Description($id_list_ref, $query_key, $query_dsc)
}

sub isLipidated{
	my $query_key = "LIPID";
	my ($id_list_ref, $query_dsc) = &MyP::_check_argument1(@_);
	
	return get_FT_Contents_By_Key_And_Description($id_list_ref, $query_key, $query_dsc)
}

sub get_FT_Contents_By_Key_And_Description{
	#
	
	my ($query_id_list_ref, $query_key, $query_dsc) = @_;
	
	my @matched_id = ();
	my %id_to_code = ();
	
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
				if(!&MyP::_has_overrup_in_array($query_id_list_ref,$this_id)){
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
				
				chomp;
				push(@matched_line, $line);
			}
			
			#queryに合致する行があったら、IDリストへの追加と内容をハッシュに登録をする。
			if($#matched_line != -1){
				
				$id_to_code{$this_id} = &_make_Data_Code(\@matched_line);
				push(@matched_id,$this_id);	
			}
		}
	}
	
	foreach my $id (@matched_id){
		print("$id : $id_to_code{$id}\n");
	}
	
	return \@matched_id, \%id_to_code;
}

sub _make_Data_Code{
	#FT行が入った配列を受け取って、"Key1*,Start*,End*,Description*;Key2 ..."というフォーマットに変える。
	
	my $matched_line_ref = shift;
	
	my $code ="";
	
	#positionについて開始位置と終了位置の間を".."で区切る。
	#position同士やdescription同士を"*,"で区切る
	foreach my $line (@$matched_line_ref){
		my $item_ref = &_getFTAllItems($line);
		
		$code = $code."$$item_ref[0]*,$$item_ref[1]*,$$item_ref[2]*,$$item_ref[3]*;"
	}
	
	#文末についている区切り文字*;を消す。
	$code = substr($code, 0, -2);
	
	return $code;
	
}

sub decode_FT_Code{
	#"Key1*,Start*,End*,Description*;Key2 ..."というコードを受け取って、Key配列、Start配列、End配列、Description配列を返す。
	#デコードに失敗すると-1を返す。
	
	my $code = shift;
	
	my @items = split(/\*;/, $code);
	
	my @key = ();
	my @start = ();
	my @end = ();
	my @dsc = ();
	
	foreach my $i (@items){
		my @buf = split(/\*,/, $i);
		
		push(@key, $buf[0]);
		push(@start, $buf[1]);
		push(@end, $buf[2]);
		push(@dsc, $buf[3]);
	}
	
	#key, start, end, dscの情報の数は一致するはず。しなかったらエラーを返す。
	if($#key != $#start or $#key != $#end or $#key != $#dsc){return -1;}
	if($#start != $#end or $#start != $#dsc){return -1;}
	if($#end != $#dsc){return -1;}
	
	return \@key, \@start, \@end, \@dsc
}

sub _getFTAllItems{
	my $FTLine = shift;
	
	my @FTItems = (&_getFTKey($FTLine), &_getFTFrom($FTLine), &_getFTTo($FTLine), &_getFTDescription($FTLine) );
	
	return \@FTItems;
}

sub _getFTFrom{
	my $FTLine = shift;
	
	my $FTFrom = substr($FTLine, 14, 6);
	$FTFrom =~ tr/ //d;
	
	return $FTFrom;
}

sub _getFTTo{
	my $FTLine = shift;
	
	my $FTTo = substr($FTLine, 21, 6);
	$FTTo =~ tr/ //d;
	
	return $FTTo;
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