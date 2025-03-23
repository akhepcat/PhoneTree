#!/usr/bin/perl -t
package Common;
use Exporter; # 'import';

our @EXPORT = qw($VERSION $DEBUG $USE_SQLITE $dbfile dprint );

our $VERSION     = '1.00';

our $DEBUG=1;

our $USE_SQLITE=1;
our $dbfile="/srv/http/www.akhepcat/db/status.sql";

sub dprint(@) {
	my @out=shift;
	
	print(@out) if ($DEBUG > 0);
}

1;
