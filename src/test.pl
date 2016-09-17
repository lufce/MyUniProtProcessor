my $a1 ="";
my $a2 ="";

sub AA {
	my $ea = "a";
	return $ea;
}

($a1, $a2) = &AA;

if (defined($a2)){
	print "a1 is $a1\ta2 is $a2\n";
}else{
	print "a1 is $a1\ta2 is undefined\n";
}

