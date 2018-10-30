my $RefFilename = "../data/human/rev/ID-sq_rev_uniprot-all.txt";
my $routineName = "ID_to_AllContents";

print "$routineName starts.\n";


open DB, $RefFilename;

$declared_length = "";
$count_length    = "";

$matched_entry   = 0;
$unmatched_entry = 0;
$total_entry     = 0;

$readID  = 0;
$isTitin = 0;

while(<DB>){
	if(m/\s+(\d+) AA/){
		$declared_length = $1;
		$readID = 1;
		
		if($declared_length == 34350){
			$isTitin = 1;
		}
	}elsif(m/^sq   (.+)$/){
		$count_length = length($1);
		$AAsequence = $1;
		if($isTitin){
			print "$count_length\n$AAsequence\n";
			$isTitin = 0;
		}
		
		if(readID){
			$total_entry++;
			$readID = 0;
			
			if($declared_length == $count_length){
				$matched_entry++;
			}else{
				$unmatched_entry++;
			}
		}
	}
}

print "Total:$total_entry\nMatch:$matched_entry\nUnmat:$unmatched_entry\n";



close DB;

print "$routineName ends.\n";
