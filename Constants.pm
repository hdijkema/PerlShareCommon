package PerlShareCommon::Constants;
use strict;

require Exporter;

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter DynaLoader);

#@EXPORT_OK = (  );
@EXPORT = ( qw(&user_agent) );
$VERSION = '0.02';

sub user_agent() {
  return "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Win32)";
}

1;
