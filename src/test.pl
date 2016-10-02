my $RefFilename = "../data/human/rev/ID-GNDE_rev_uniprot-all.txt";
my $routineName = "ID_to_AllContents";

print "$routineName starts.\n";


open DB, $RefFilename;


while(<DB>){
	unless(/^\/\//){print;}
	else{print; last;}
}



close DB;

print "$routineName ends.\n";