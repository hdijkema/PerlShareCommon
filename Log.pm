package Dirs;
use strict;
use POSIX qw/strftime/;

require Exporter;

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter DynaLoader);

#@EXPORT_OK = (  );
@EXPORT = ( qw(&log_info &log_error &log_debug &log_warn &log_file) );
$VERSION = '0.02';

my $LOG_FH = undef;
my $SEVERITY = "debug";

sub log_file($) {
  my $file = shift;
  if (defined($LOG_FH)) { close($LOG_FH); }
  open $LOG_FH, ">$file";
}

sub log_severity($) {
  my $minimum_severity = lc(shift);
  
  my $ok = 0;
  if ($minimum_severity eq "debug") { $ok = 1; }
  elsif ($minimum_
  
}

sub do_log($$) {
  my $severity = shift;
  my $message = shift;
  
  my $str = sprintf("%s:%s:%s", 
                    strftime("%Y-%m-%d %H:%M:%S", localtime),
                    $severity,
                    $message
                    );
  
  if (defined($LOG_FH)) {
    print $LOG_FH "$str\n";
  } else {
    print "$str\n";
  }
}

sub log_info($) {
  do_log("info ", @_);
}

sub log_error($) {
  do_log("error", @_);
}

sub log_warn($) {
  do_log("warn ", @_);
}

sub log_debug($) {
  do_log("debug", @_);
}

1;


