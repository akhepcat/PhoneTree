#!/usr/bin/perl -t
use lib "..";
use Includes::Common;

if ($Common::DEBUG >0) {
        Common::dprint("INFO: debugging on\n");
	use Data::Dumper;
}

use DBI;

my $db;
my $errs;
my $sql;

Common::dprint("Starting initialization of primary admin\n");

if ($Common::USE_SQLITE) {
    Common::dprint("Connecting to SQLITE database\n");

    if (! length($Common::sqlfile) ) {
        die("Error: sqlfile not defined or imported correctly\n");
    }

    $db = DBI->connect("dbi:SQLite:dbname=$Common::sqlfile","","", { AutoCommit => 1, RaiseError => 0, PrintError => 0 });
} else {
    Common::dprint("Connecting to PgSQL database\n");
    $db = DBI->connect("dbi:Pg:$Common::pgdb",$Common::pguser,$Common::pgpass, { AutoCommit => 1, RaiseError => 0, PrintError => 0 });
}

if ( length($DBI::errstr) ) {
    die("ERROR: " . $DBI::errstr);
}

Common::dprint("Connected to db okay, checking for existing admin users...\n");

$sql="SELECT u.username FROM users, privileges LEFT JOIN users u, privileges p on u.privs = p.privs WHERE p.isadmin = 1;";

my $sth = $db->prepare($sql);
$sth->execute();

if ( length($DBI::errstr) ) {
    die("ERROR: " . $DBI::errstr);
}

while (my $row=$sth->fetchrow_array) {
    print("Admin user: $row\n");
}

Common::dprint("Completed search of Admin user\n");

exit($db->disconnect);
