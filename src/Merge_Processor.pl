#181120		ver0.1		作り始め。

#複数のID配列や連想配列の和集合や積集合などを返す
#ID配列はすべてソートされている前提である。

use strict;
use warnings;
use Time::HiRes;

package MyMerge;

require "MyProgressBar.pm";
require "File_and_Directory_catalog.pl";  # MyName::
require "Shared_Process.pl"; # MyP::

###

###

sub id_union{
	#和集合を返す。ID配列はすべてソートされている前提である。
	
	my ($ref1, $ref2) = MyP::check_argument_2_ID_lists(@_);
	
	my $index1 = 0;
	my $index2 = 0;
	my @union = ();
	
	while($index1 < @$ref1 and $index2 < @$ref2){
		my $id1 = $$ref1[$index1];
		my $id2 = $$ref2[$index2];
		
		if($id1 eq $id2){
			push(@union, $id1);
			$index1++;
			$index2++;
			
		}elsif($id1 lt $id2){
			push(@union, $id1);
			$index1++;
		}else{
			push(@union, $id2);
			$index2++;
		}
	}
	
	#残りの要素を@unionに入れていく。
	while($index1 < @$ref1){
		push(@union, $$ref1[$index1]);
		$index1++;
	}
	
	while($index2 < @$ref2){
		push(@union, $$ref2[$index2]);
		$index2++;
	}
	
	return \@union;
}

sub id_intersection{
	#積集合を返す。ID配列はすべてソートされている前提である。
	
	my ($ref1, $ref2) = MyP::check_argument_2_ID_lists(@_);
	
	my $index1 = 0;
	my $index2 = 0;
	my @intersection = ();
	
	while($index1 < @$ref1 and $index2 < @$ref2){
		my $id1 = $$ref1[$index1];
		my $id2 = $$ref2[$index2];
		
		if($id1 eq $id2){
			push(@intersection, $id1);
			$index1++;
			$index2++;
			
		}elsif($id1 lt $id2){
			$index1++;
		}else{
			$index2++;
		}
	}
	
	return \@intersection;
}

sub id_deselection{
	#第一引数のIDリストから第二引数のIDリストと一致したものを除いた配列を返す。
	
	my ($ref1, $ref2) = MyP::check_argument_2_ID_lists(@_);
	
	my @deselected = ();
	my $match_ref = &id_intersection($ref1, $ref2);
	
	#一致する要素が無いならそのまま返す。
	if (@$match_ref == 0){
		return $ref1;
	}
	
	my $index1 = 0;
	my $index2 = 0;
	
	while($index1 < @$ref1 and $index2 < @$match_ref){
		my $id1 = $$ref1[$index1];
		my $id2 = $$match_ref[$index2];
		
		if($id1 eq $id2){
			
			$index1++;
			$index2++;
			
		}else{
			push(@deselected, $id1);
			$index1++;
		}
	}
	
	while($index1 < @$ref1){
		push(@deselected, $$ref1[$index1]);
		$index1++;
	}
	
	return \@deselected;
}

sub _has_overlap_between_ranges{
	
	my ($start1, $end1, $start2, $end2) = MyP::check_argument_4_numeric(@_);
	
	if($start1 > $end2){return 0;}
	if($start2 > $end1){return 0;}
	return 1;
}

sub _is_included_in_latter_range{
	#第一引数の範囲が第二引数の範囲に含まれている
	
	my ($start1, $end1, $start2, $end2) = MyP::check_argument_4_numeric(@_);
	
	if($start1 < $start2 ){return 0;}
	if($end1 > $end2 ){return 0;}
	return 1;
}

sub _get_range_in_ft_data_code{
	
	my ($id_list_ref, $code_hash_ref) = MyP::check_argument_2_ID_list_hash(@_);
	
	my %id2range;
	
	foreach my $id (@$id_list_ref){
		my $code = $$code_hash_ref{$id};
		
		my $range_ref = MyP::get_range_from_ft_code($code);
		
		$id2range{$id} = $range_ref;
	}
	
	return \%id2range;
}

sub _get_range_in_sq_data_code{
	
	my ($id_list_ref, $code_hash_ref) = MyP::check_argument_2_ID_list_hash(@_);
	
	my %id2range;
	
	foreach my $id (@$id_list_ref){
		my $code = $$code_hash_ref{$id};
		
		my ($start,$end) = MyP::decode_sq_code($code);
		
		my @range = ($start, $end);
		$id2range{$id} = \@range;
	}
	
	return \%id2range;
}