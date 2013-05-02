package Dirs;
use strict;
use File::Basename;
use Cwd;

require Exporter;

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter DynaLoader);

#@EXPORT_OK = (  );
@EXPORT = ( qw(&my_dir &conf_dir &log_dir &tunnel_dir &images_dir &unison_dir) );
$VERSION = '0.02';

sub my_dir() {
	my $dir=dirname($0);
	if ($dir eq ".") {
		$dir=getcwd();
	} elsif ($dir eq "..") {
		$dir=getcwd()."/..";
	}
	return $dir;
}

sub conf_dir() {
	my $dir=$ENV{HOME}."/.perlshare";
	return $dir;
}

sub unison_dir() {
	return $ENV{HOME}."/.unison";
}

sub log_dir() {
	return conf_dir();
}

sub images_dir() {
	return my_dir()."/images";
}

1;
