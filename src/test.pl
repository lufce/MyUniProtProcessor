my %hs = (A => "1,2,3", B => "4,5,6");

&test(\%hs);

sub test{
	$hashRef = shift;
	my $res;
	
	my @region = split(",",$$hashRef{A});
	$res = @region;
	print $res;
}