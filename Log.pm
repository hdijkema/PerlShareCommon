package PerlShareCommon::Log;
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
  elsif ($minimum_severity eq "info") { $ok = 1; }
  elsif ($minimum_severity eq "warn") { $ok = 1; }
  elsif ($minimum_severity eq "error") { $ok = 1; }
  
  if ($ok) {
    $SEVERITY = $minimum_severity;
  } else {
    die "Severity must be one of 'debug', 'info', 'warn' or 'error'";
  }
}

sub do_log($$) {
  my $severity = shift;
  my $message = shift;
  $message=~s/\s*$//;
  
  my $str = sprintf("%s:%s:%s", 
                    strftime("%Y-%m-%d %H:%M:%S", localtime),
                    $severity,
                    $message
                    );
  
  if (defined($LOG_FH)) {
    print $LOG_FH "$str\n";
    print "$str\n";
  } else {
    print "$str\n";
  }
}

sub do_logl($$) {
  my $type = shift;
  my @lines = split(/[\r\n]+/,shift);
  foreach my $line (@lines) {
    do_log($type, $line);
  }
}

sub log_info($) {
  do_logl("info ", shift);
}

sub log_error($) {
  do_logl("error", shift);
}

sub log_warn($) {
  do_logl("warn ", shift);
}

sub log_debug($) {
  do_logl("debug", shift);
}

1;


