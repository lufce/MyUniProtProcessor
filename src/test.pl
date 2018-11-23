require "FT_Processor.pl";
require "Shared_Process.pl";
require "Merge_Processor.pl";

my ($id_ref, $code_ref) = &MyFTP::isTransmembrane();
my $range_hash_ref = MyMerge::_get_range_in_ft_data_code($id_ref, $code_ref);

my $id_length = @$id_ref;

for(my $i =0; $i < $id_length; $i++){
	my $id = $$id_ref[$i];
	my ($key_ref, $start_ref, $end_ref, $dsc_ref) = &MyP::decode_ft_code( $$code_ref{ $id } );
	
	my $ref = $ranges{$id};
	my @range = @$ref;
	
	$dsc_length = @$dsc_ref;
	for(my $j = 0; $j < $dsc_length; $j++){
		print("$$key_ref[$j] : $$start_ref[$j]-$$end_ref[$j] : $$dsc_ref[$j] : $range[$j][0]-$range[$j][1] \n");
	}
}
print("$id_length hits!\nend");