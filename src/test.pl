sub test1{
	my @id = (1,2,3);
	print "@id in subroutine test1\n";	
	return \@id;
}

sub test2{
	my $id2 = shift;
	
	print "@$id2 in subroutin test2\n";
}

my $idp = &test1;
&test2($idp);

print "@$idp in parental routin\n";