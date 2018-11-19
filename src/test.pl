#require "FT_Processor.pl";
#
#(my $id_ref, my $code_ref) = &MyFTP::isTransmembrane();
#
#my $id_length = @$id_ref;
#
#for(my $i =0; $i < $id_length; $i++){
#	(my $key_ref, my $start_ref, my $end_ref, my $dsc_ref) = &MyFTP::decode_FT_Code( $$code_ref{ $$id_ref[$i] } );
#	
#	$dsc_length = @$dsc_ref;
#	for(my $j = 0; $j < $dsc_length; $j++){
#		print("$$key_ref[$j] : $$start_ref[$j]-$$end_ref[$j] : $$dsc_ref[$j]\n");
#	}
#}
#print("$id_length hits!\nend");

@abc = (0,1,2);

print("main_IN : ");
foreach my $i (@abc){
		print("$i\t");
	}
	print("\n");

&tt(\@abc);
print("main_abc: ");
foreach my $i (@abc){
		print("$i\t");
	}
	print("\n");

sub tt{
	$ref = shift;
	
	@ins = @$ref;
	
	$$ref[0] = 3;
	$ins[2] = 5;

	print("sub_ins: ");	
	foreach my $i (@ins){
		print("$i\t");
	}
	print("\n");
	
	print("sub_ref: ");
	foreach my $i (@$ref){
		print("$i\t");
	}
	print("\n");
}