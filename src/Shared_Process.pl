#181115		ver0.1		作り始め。

#各Processorで現れる共通の処理をまとめたもの。

use strict;
use warnings;

package MyP;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::

sub check_argument_2_ID_list_string{
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

sub check_argument_2_ID_list_hash{
	
	my $num = @_;
	
	if($num != 2){
		die ("The numeber of arguments is illegal.")
	}
	
	my ($arg1, $arg2) = @_ ;
	
	my $id_list_ref = ref($arg1) eq "ARRAY" ? $arg1
	                : ref($arg2) eq "ARRAY" ? $arg2
	                                        : "";
	my $hash_ref = ref($arg1) eq "HASH" ? $arg1
	             : ref($arg2) eq "HASH" ? $arg2
	                                    : "";
	
	if($id_list_ref eq "" and $hash_ref eq ""){
		die("No id list and hash.");
	}elsif($id_list_ref eq ""){
		die("No id list.");
	}elsif($hash_ref eq ""){
		die("No hash.");
	}
	
	return ($id_list_ref, $hash_ref);
}

sub check_argument_1_ID_list{
	#引数が配列のリファレンスかを調べる。	
	
	my $arg = shift;
	
	if(ref($arg) eq "ARRAY"){
		return $arg;
	}else{
		return "";
	}
}

sub check_argument_2_ID_lists{
	#引数が配列のリファレンスかを調べる。	
	
	my $num = @_;
	
	if($num != 2){
		die ("The numeber of arguments is illegal.")
	}
	
	my ($arg1, $arg2) = @_ ;
	
	if(ref($arg1) eq "ARRAY" and ref($arg2) eq "ARRAY"){
		return ($arg1, $arg2);
	}elsif(ref($arg1) eq "ARRAY" or ref($arg2) eq "ARRAY"){
		die ("Either argument is not an array reference.");
	}else{
		die ("No arguments are an array reference.");
	}
}

sub check_argument_4_numeric{
	#引数が4つで、全部数値か調べる。
	
	my $num = @_;
	
	if($num != 4){
		die ("The numeber of arguments is illegal.")
	}
	
	foreach my $item (@_){
		if($item !~ m/^\d+$/){
			die("Non-numeric argument exists.")
		}
	}
	
	return @_;
}

sub has_overrup_in_array{
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

sub decode_ft_code{
	#"Key1*,Start*,End*,Description*;Key2 ..."というコードを受け取って、Key配列、Start配列、End配列、Description配列を返す。
	#デコードに失敗すると-1を返す。
	
	my $code = shift;
	my @items = split(/\*;/, $code);
	
	my @key = ();
	my @range = ();
	my @dsc = ();
	
	foreach my $i (@items){
		my @buf = split(/\*,/, $i);
		
		push(@key, $buf[0]);
		push(@range, $buf[1]);
		push(@dsc, $buf[2]);
	}
	
	return \@key, \@range, \@dsc;
}

sub get_range_from_ft_code{
	my $code = shift;
	my @items = split(/\*;/, $code);
	
	my @range = ();
	
	foreach my $i (@items){
		my @buf = split(/\*,/, $i);
		
		push(@range, $buf[1]);
	}
	
	return \@range;
}

sub get_dsc_from_ft_code{
	my $code = shift;
	
	my @items = split(/\*;/, $code);
	my @dsc = ();
	
	foreach my $i (@items){
		my @buf = split(/\*,/, $i);
		
		push(@dsc, $buf[2]);
	}
	
	return \@dsc;
}

sub decode_sq_code{
	#SQデータコードを@rangeの配列に分ける
	
	my $code = shift;
	my @range;
	
	@range = split(/,/, $code);
	
	return \@range;
}