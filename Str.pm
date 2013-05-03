package PerlShareCommon::Str;
use strict;

require Exporter;

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter DynaLoader);

#@EXPORT_OK = (  );
@EXPORT = ( qw(&trim) );
$VERSION = '0.02';

sub trim($) {
  my $s = shift;
  $s=~s/^\s+//;
  $s=~s/\s+$//;
  return $s;
}

1;
