#181115		ver0.1		作り始め。

#各Processorで現れる共通の処理をまとめたもの。

use strict;
use warnings;

package MyP;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::

sub _check_argument1{
	#引数が文字列か配列のリファレンスかを判断して、返す。
	#中身が無い引数に関しては空の文字列を返す。	
	
	my $arg_num = @_;
	
	my ($id_list_ref, $query);
	
	if($arg_num > 2){
		die ("$!\n"."Too many arguments./n")
		
	}elsif($arg_num == 2){
		
		$id_list_ref = 
				  ref($_[0]) eq "ARRAY" ? $_[0] 
				: ref($_[1]) eq "ARRAY" ? $_[1]
				                        : "";
				                        
		$query   = ref($_[0]) eq "ARRAY" ? $_[1] : $_[0];
		
	}elsif($arg_num == 1){
		
		$id_list_ref = ref($_[0]) eq "ARRAY" ? $_[0] : "";
		$query   = ref($_[0]) eq "ARRAY" ? "" : $_[0];
		
	}else{
		
		$id_list_ref = "";
		$query = "";
		
	}
	
	return $id_list_ref, $query;
	
}

sub _check_argument_ID_list{
	#引数が配列のリファレンスかを調べる。	
	
	my $arg = shift;
	
	if(ref($arg eq "ARRAY")){
		return $arg;
	}else{
		return "";
	}
}

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