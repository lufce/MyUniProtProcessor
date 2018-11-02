#require "FT_Processor.pl";
#
#(my $id_ref, my $code_ref) = &ft_process::get_FT_Contents_By_Key_And_Description("","PDB:4DNK");
#
#my $id_length = @$id_ref;
#
#for(my $i =0; $i < $id_length; $i++){
#	(my $key_ref, my $start_ref, my $end_ref, my $dsc_ref) = &ft_process::decode_FT_Code( $$code_ref{ $$id_ref[$i] } );
#	
#	$dsc_length = @$dsc_ref;
#	for(my $j = 0; $j < $dsc_length; $j++){
#		print("$$key_ref[$j] : $$start_ref[$j]-$$end_ref[$j] : $$dsc_ref[$j]\n");
#	}
#}

$dir = "../data/human/rev/";
$f_name = "uniprot_test_doc.txt";

open my $FN, $dir.$f_name or die $!;


$count = 0;
while(<$FN>){
	$count++;
	print;
	
	if($count >= 960){last;}
}

&test($FN);

sub test{
	$FN2 = shift;
	
	print "in subroutin!\n";
	
	while(<$FN2>){
		print;
	}
}