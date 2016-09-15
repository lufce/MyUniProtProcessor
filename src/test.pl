my $df = "../data/rev/ID-GNDE_rev_uniprot-all.txt";
#my $rf = "../result/testcount.txt";
my $count = 0;

open DF, $df or die;
open RF, ">../result/testcount.txt";

while(<DF>){
	$count++;
}

print RF $count;

close DF; close RF;