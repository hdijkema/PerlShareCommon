package PerlShareCommon::WatchDirectoryTree;
use strict;
use IO::Select;
use Fcntl;
use PerlShareCommon::Log;

sub new() {
	my $class=shift;
	my $directory=shift;
	my $obj={};
	bless $obj,$class;
	$obj->{dir}=$directory;
	
	log_info("Watching directory $directory");
	  
	$obj->{os}=$^O;
	if ($obj->{os} eq "darwin") {
	  log_debug("FSEvents for mac OS X");
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
	  log_debug("inotifywait for linux");
		my $pid = open my $fh,"inotifywait -r -m -e close_write -e moved_to -e moved_from -e create -e delete --format \"dir=%w\" '$directory' 2>&1 |";
		my $of = select($fh); $| = 1;select($of);
		my $flags = '';
		fcntl($fh, F_GETFL, $flags) or die "Couldn't get flags for HANDLE : $!\n";
		$flags |= O_NONBLOCK;
		fcntl($fh, F_SETFL, $flags) or die "Couldn't set flags for HANDLE: $!\n";
		$obj->{fh} = $fh;
		$obj->{pid} = $pid;
	}
	
	log_info("Created watcher");
	
	return $obj;
}

sub DESTROY() {
  my $self = shift;
  my $pid = $self->{pid};
  my $fh = $self->{fh};
  close($fh);
  log_debug("pid = $pid");
  if (defined($pid)) {
    kill 15, $pid;
  }
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
				log_debug("line($dir)=$line");
				if ($line=~/^dir=/) {
					my ($key,$path)=split(/=/,$line);
					$path=~s/[\/\\]+$//;
					$events{$path}=$i;
					log_debug("got directory $path ($i)");
					$i+=1;
				}
			}
		}
		my @dirs=sort { $events{$a} cmp $events{$b} } (keys %events);
		if (scalar(@dirs)==0) {
			return undef;
		} else {
			return \@dirs;
		}
	}
}


1;
