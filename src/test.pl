# 使い方
# MyFTP::isTransmembrane()などが返すものは(ID配列のリファレンス, データコードハッシュのリファレンス)という配列のリファレンスである。
# my $answer = MyFTP::isTransmembrane();としたとして
# ID配列の長さ                my $len  = @{$$answer[0]};
# ID配列の要素にアクセス      my $ele  = $$answer[0][$i];
# IDのデータコードにアクセス  my $code = $$answer[1]{ $$answer[0][$i] }; 

#TODO やり残し
#SL行のトリム処理と探索用関数の整備
#GO行のトリム処理と探索用関数の整備
#Catalog_Maker.plの完成
#Line Extractorの_simple_line_code_extractorの高速化。


require "FT_Processor.pl";
require "Shared_Process.pl";
require "Merge_Processor.pl";
require "SQ_Processor.pl";

#my $transmem_ref = &MyFTP::is_transmembrane();
#my ($transmem_id_ref, $transmem_code_ref) = ($$transmem_ref[0], $$transmem_ref[1]);
#
#my $id_length = @{$$transmem_ref[0]};
#
#for(my $i = 0; $i < $id_length; $i++){
#	my ($key_ref, $ft_range_ref, $dsc_ref) = &MyP::decode_ft_code( $$transmem_ref[1]{ $$transmem_ref[0][$i] } );
#	
#	my $dsc_length = @$dsc_ref;
#	
#	print("$$transmem_ref[0][$i]\n");
#	for(my $j = 0; $j < $dsc_length; $j++){
#		print("\t$$key_ref[$j] : $$ft_range_ref[$j] : $$dsc_ref[$j]\n");
#	}
#}
#print("$id_length hits!\nend");

my @process;

push( @process, &MySQP::motif_search("LL.Y"));
push( @process, &MyFTP::is_transmembrane($process[0][0]) );
push( @process, &MyFTP::is_not_transmembrane($process[1][0]) );
push( @process, &MyMerge::range_partial_inclusion($process[0], $process[2]) );
#push( @process, &MySQP::get_peptide_by_code($process[2][0],$process[2][1]) );

foreach my $id (@{$process[3][0]}){
	print("$id\n");
	#print("$process[1]{$id}\n");
}
my $len = @{$process[3][0]};
print("$len hits\n");
