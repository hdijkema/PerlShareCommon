package PerlShareCommon::Dirs;
use strict;
use File::Basename;
use Cwd;
use PerlShareCommon::Cfg;
use File::HomeDir;

require Exporter;

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter DynaLoader);

#@EXPORT_OK = (  );
@EXPORT = ( qw(&global_conf &global_conf_dir &pub_sshkey &sshkey &my_dir &perlshare_dir &conf_dir &log_dir &tunnel_dir &images_dir &unison_dir) );
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

sub global_conf_dir() {
  my $os = $^O;
  if ($os=~/^MSWin/) {
    return $ENV{APPDATA}."/.perlshare";
  } else {
    return $ENV{HOME}."/.perlshare";
  }
}

sub global_conf() {
  my $cfg_file = global_conf_dir()."/config.ini";
  return $cfg_file;
}

sub conf_dir($) {
  my $share = shift;
	return perlshare_dir($share)."/.perlshare";
}

sub unison_dir($) {
  my $share = shift;
	return perlshare_dir($share)."/.unison";
}

sub log_dir() {
	return global_conf_dir();
}

sub images_dir() {
	return my_dir()."/images";
}

sub perlshare_dir($) {
  my $share = shift;
  my $os = $^O;
  my $home = File::HomeDir->my_home;
  if ($os=~/^MSWin/) {
    $home = File::HomeDir->my_documents;
  }
  return "$home/$share";
}

sub sshkey($) {
  my $share = shift;
  return conf_dir($share)."/perlshare_key";
}

sub pub_sshkey($) {
  my $share = shift;
  return sshkey($share).".pub";
}

1;
