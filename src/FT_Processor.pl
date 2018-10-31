#181029		ver0.1		作り始め。

#FT行の処理についてまとめたパッケージを作るのが目標

use strict;
use warnings;
use Time::HiRes;

package ft_process;

require "MyProgressBar.pm";

#my $SerchFileName = "../data/human/rev/ID-FT_rev_uniprot-allFlat.txt";
my $SerchFileName = "../data/human/rev/ID-FT_rev_uniprot-allFlatTest.txt";

sub get_FT_Contents_By_Key_And_Description{
	#
	(my $query_key, my $query_dsc, my $key) = @_;
	
	my $objPB = new MyProgressBar;
	
	my @matched_id = ();
	my %id_to_code = ();
	
	#open database file
	open DB, $SerchFileName or die($!);
	
	$objPB -> setAll($SerchFileName);
	
	#ID行がくるまでループ
	while(<DB>){
	
		$objPB -> nowAndPrint($.);
		
		if(m/^ID   (.+?) /){
			my $this_id = $1;
			my @matched_line = ();
			
			#FTのKeyがqueryと一致するものを探す
			while(<DB>){
				
				$objPB->nowAndPrint($.);
				
				#タンパク質の最後の行になったらID取得ループに戻る。
				if(m|^//$|){ last; }
				
				#目的Keyが見つからなかったら次の行に移る。
				if(!m/^FT   $query_key/){ next; }
				
				#目的のKeyが見つかったら、目的のDescriptionを含むかを調べる。
				#目的のDescriptionを含まないなら次の行に移る。(query_dscの前の文字数を27文字にすることで、query_dscに""を渡したときに、Keyだけの検索を行うことができる。)
				if(!m/.{27,}$query_dsc/){ next; }
				
				chomp;
				push(@matched_line,$_);
			}
			
			#queryに合致する行があったら、IDリストへの追加と内容をハッシュに登録をする。
			if($#matched_line != -1){
				
				if( defined($key) ){
					$id_to_code{$this_id} = &_make_FT_Code(\@matched_line, $key);
				}else{
					$id_to_code{$this_id} = &_make_FT_Code(\@matched_line);
				}
				
				push(@matched_id,$this_id);	
			}
		}
	}
	
	for (@matched_id){
		print("$_ : $id_to_code{$_}\n");
	}
	
	return \@matched_id, \%id_to_code;
}

sub decode_FT_Code{
	#デコードに失敗すると-1を返す。
	
	my $code = shift;
	
	(my $key_buf, my $pos_buf, my $dsc_buf) = split(/\*;/, $code);
	
	#どれかひとつでも未定義の変数があればエラーとして-1を返す。
	if(!defined($key_buf) or!defined($pos_buf) or !defined($dsc_buf)){ return -1; }
	
	my @key = split(/\*,/, $key_buf);
	my @start_end = split(/\*,/, $pos_buf);
	my @dsc = split(/\*,/, $dsc_buf);
	
	#key, pos, dscの情報の数は一致するはず。しなかったらエラーを返す。
	if($#start_end != $#dsc){return -1;}
	if($#start_end != $#key){return -1;}
	if($#dsc != $#key){return -1;}
	
	my @pos = ();
	foreach my $item (@start_end){
		my @each_end = split(/\.\./, $item);
		push(@pos,\@each_end);
	}
	
	return \@key, \@pos, \@dsc;
}

sub _make_FT_Code{
	#FT行が入った配列を受け取って、Keyでまとめて"$key*;$pos_buf*;$dsc_buf"というフォーマットに変える。
	
	my $matched_line_ref = shift;
	
	my $key_buf = "";
	my $pos_buf = "";
	my $dsc_buf = "";
	
	#positionについて開始位置と終了位置の間を".."で区切る。
	#position同士やdescription同士を"*,"で区切る
	foreach my $line (@$matched_line_ref){
		my $item_ref = &_getFTAllItems($line);
		
		$key_buf = $key_buf."$$item_ref[0]*,";
		$pos_buf = $pos_buf.sprintf("%d..%d*," , $$item_ref[1], $$item_ref[2]);
		$dsc_buf = $dsc_buf."$$item_ref[3]*,";
	}
	
	#文末についている区切り文字*,を消す。
	$key_buf = substr($key_buf, 0, -2);
	$pos_buf = substr($pos_buf, 0, -2);
	$dsc_buf = substr($dsc_buf, 0, -2);
	
	#keyとposition、descriptionの間を*;で区切って返す。
	return "$key_buf*;$pos_buf*;$dsc_buf";
	
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