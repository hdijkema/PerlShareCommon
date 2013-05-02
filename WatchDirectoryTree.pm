package PerlShareCommon::WatchDirectoryTree;
use IO::Select;
use Fcntl;

sub new() {
	my $class=shift;
	my $directory=shift;
	my $obj={};
	bless $obj,$class;
	$obj->{dir}=$directory;
	print "Watching directory $directory\n";
	$obj->{os}=$^O;
	if ($obj->{os} eq "darwin") {
		require Mac::FSEvents;
		my $fs=Mac::FSEvents->new( 
			{
				path 		=> $directory,
				latency 	=> 2,
			}
		);
		my $fh=$fs->watch();
		$obj->{fh}=$fh;
		$obj->{fs}=$fs;
	} else {
		open my $fh,"inotifywait -r -m -e close_write -e moved_to -e moved_from -e create -e delete --format \"dir=%w\" '$directory' 2>&1 |";
		my $of=select($fh); $| = 1;select($of);
		$flags = '';
		fcntl($fh, F_GETFL, $flags) or die "Couldn't get flags for HANDLE : $!\n";
		$flags |= O_NONBLOCK;
		fcntl($fh, F_SETFL, $flags) or die "Couldn't set flags for HANDLE: $!\n";
		$obj->{fh}=$fh;
	}
	
	return $obj;
}

sub get_directory_changes() {
	my $self=shift;
	my @dirs=();
	my $dir=$self->{dir};
	
	if ($self->{os} eq "darwin") { # OS X
		my $fh=$self->{fh};
		my $fs=$self->{fs};
		my $sel = IO::Select->new($fh);
  		while ( $sel->can_read(0) ) {
      		my @events = $fs->read_events();
      		for my $event ( @events ) {
      			my $p=$event->path();
      			$p=~s/[\/\\]*$//;
      			push @dirs,$p;
      		}
  		}
  		if (scalar(@dirs)==0) {
  			return undef;
  		} else {
  			return \@dirs;
  		}
	} else { # linux
		my $fh=$self->{fh};
		my $sel=IO::Select->new($fh);
		my %events;
		my $i=0;
		my $buf="";
		if ($sel->can_read(0)) {
			while($sel->can_read(0.1)) {
				my $d;
				while (my $l=sysread($fh,$d,1024)) {
					$buf.=$d;
				}
			}
			my @lines=split /\n/,$buf;
			foreach my $line (@lines) {
				print "line($dir)=$line\n";
				if ($line=~/^dir=/) {
					my ($key,$path)=split(/=/,$line);
					$path=~s/[\/\\]+$//;
					$events{$path}=$i;
					#print "got directory $path ($i)\n";
					$i+=1;
				}
			}
		}
		my @dirs=sort { $events{$a} cmp $events{$b} } (keys %events);
		if (scalar(@dirs)==0) {
			return undef;
		} else {
			#foreach my $dir (@dirs) {
			#	print STDERR "changed directory: $dir\n";
			#}
			return \@dirs;
		}
	}
}


1;
