#160825		ver1.0		完成。

package MyProgressBar;

sub new{
	my $class = shift;
	
	my $self = {
		now => 0,
		all => undef,
		former => -1
	};
	
	return bless $self, $class;
}

sub nowAndPrint{
	my $self = shift;
	my $now = shift;
	
	&setNow($self,$now); &printProgressBar($self);
}

sub setNow{
	my $self = shift;
	my $now = shift;
	$self->{now} = $now;
}

sub setAll{
	#When setting is failed, return 0.
	
	my ($self, $all) = @_;
	$fileLine=0;

	if($all =~ m/\A\d+\Z/){
		$self->{all}=$all;
		return 1;
	}else{
		open FN, $all or return 0;
		while(<FN>){ $fileLine++; }
		close FN;
		$self->{all} = $fileLine;
		
		return 1;
	}
}

sub printProgressBar{
	my $self = shift;
	my $progress;

	if (defined($self->{all})){
		$progress = int( $self->{now} *10 / $self->{all} );
		
		if($progress == $self->{former}){
			return;
		}else{
			print "■" x $progress;
			print "□" x (10-$progress);
			print "\n";
			
			$self->{former} = $progress;
			
			return;
		}
		
	}else{
	#if the value of 'all' is undefined, print 'all is not set.', and then 
	#'0.1' is assigned in 'former' not to print the message again.
		if($self->{former} == 0.1){
			return;
		}else{
			print "all is not set.\n";
			$self->{former} = 0.1;
			return;
		}
	}
}

1;