#!/usr/bin/perl -t
package Common;
use Exporter; # 'import';

our @EXPORT = qw($VERSION $DEBUG $USE_SQLITE $sqlfile $pgdb $pguser $pgpass dprint );

our $VERSION     = '1.00';

our $DEBUG=1;

our $USE_SQLITE=1;

if ($USE_SQLITE == 1) {
	# use a local sqlite3 file-based db
	our $sqlfile="/srv/http/www.akhepcat/db/status.sql";
} else {
	# use Postgres
	our $pgdb="dbname=MyPgDB;host=MyPgHost;port=5432;options=''";
	our $pguser="";
	our $pgpass="";
}

sub dprint(@) {
	my @out=shift;
	
	print(@out) if ($DEBUG > 0);
}

1;
