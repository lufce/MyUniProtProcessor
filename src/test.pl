my @ID = ("a", "b");
my %HS = (A => "AA", B => "BB");
my $qu = "tes";
my $pa = "-all";

&test_Routine($pa, \@ID, \%HS, $qu);

sub test_Routine{
	my $rn = "test_Routine";
	
	(my $rp, my $rh, my $ri, my $rq, my $rnum, my $rmode ) = &_argumentCheck2_2(\@_, $rn);
	
	print "mode is $rmode";
}

sub _argumentCheck2_2{
	#return ($para, $hashRef, $idRef, $query, $num, $mode)
	
	my $checkArg = shift;
	my $routineName = shift;
	
	my $num = @$checkArg;
	
	my $mode;
	my $query;
	my $idRef;
	my $hashRef;
	my $para;
	
	#sort arguments
	for(my $i = 0 ; $i < $num ; $i++){
		if( ref($$checkArg[$i]) eq ""){
			if( $$checkArg[$i] =~ m/-all|-part/i){
				$para = $$checkArg[$i];
				
			}elsif( $$checkArg[$i] eq "" or !defined($$checkArg[$i])){
				die "The arguments[$i] of the subroutine '$routineName' is not proper.";
				
			}else{
				$query = $$checkArg[$i];
				
			}
		}elsif( ref($$checkArg[$i]) eq "ARRAY" ){
			$idRef = $$checkArg[$i];
			
		}elsif( ref($$checkArg[$i]) eq "HASH" ){
			$hashRef = $$checkArg[$i];
		}else{
			die "The arguments[$i] of the subroutine '$routineName' is not proper.";
		}
	}
	
	if(defined($idRef)){
		print "idRef is defined.\n";
	}
	if(defined($hashRef)){
		print "hashRef is defined.\n";
	}
	if(defined($query)){
		print "query is defined.\n";
	}
	if(defined($para)){
		print "para is defined.\n";
	}
	print "num is $num.\n";
	
	#define the mode. The difinition of the mode is based on 'ÝŒvˆÄ.docx' .
	if( $num == 0 ){
		$mode = 1;
		
	}elsif( $num == 1 and defined($idRef)){
		$mode = 2;
		
	}elsif( $num == 1 and defined($query)){
		$mode = 3;
		
	}elsif( $num == 2 and defined($idRef) and defined($query)){
		$mode = 4;
		
	}elsif( $num == 3 and defined($idRef) and defined($hashRef) and defined($para)){
		$mode = 5;
		
	}elsif( $num == 4 and defined($idRef) and defined($hashRef) and defined($query) and defined($para)){
		$mode = 6;
	
	}else{
		die "Failure of defining the mode in the subroutine $routineName. The number of arguments is $num.";
	
	}
	
	return ($para, $hashRef, $idRef, $query, $num, $mode);
}