#160825		ver1.0		完成。

use strict;
use warnings;

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

sub addNowAndPrint{
	my $self = shift;
	my $now = shift;
	
	&addNow($self,$now); &printProgressBar($self);
}

sub setNow{
	my $self = shift;
	my $now = shift;
	$self->{now} = $now;
}

sub addNow{
	my $self = shift;
	my $now = shift;
	$self->{now} += length($now);
	
	if($now =~ m/\n$/){
		$self->{now}++;
	}
}

sub setAll{
	#When setting is failed, return 0.
	
	my ($self, $all) = @_;

	if($all =~ m/\A\d+\Z/){
		$self->{all}=$all;
		$self->{now}=0;
		return 1;
	}else{
		if(-f $all){
			$self->{all} = -s $all;
			$self->{now}=0;
			return 1;
		}else{
			return 0;
		}
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
			{
				local $| = 1;
				print "*" x $progress . "." x (10-$progress) . "\r";
				#print "\n";
			}
			
			$self->{former} = $progress;
			
			if($progress == 10){
				print "\n";
			}
			
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