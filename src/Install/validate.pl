#!/usr/bin/perl -t
use lib "..";
use Includes::Common;

if ($Common::DEBUG >0) {
        Common::dprint("INFO: debugging on\n");
	use Data::Dumper;
}

use DBI;
my $db;
my $errs = 0;

if (! length($Common::sqlfile) ) {
    die("Error: sqlfile not defined or imported correctly from Includes::Common.pm\n");
}

$db = DBI->connect("dbi:SQLite:dbname=$Common::sqlfile","","", { AutoCommit => 1, RaiseError => 1, PrintError => 1 } );

# Check to make sure all the tables exist
Common::dprint("in check_init_db\n");

foreach my $table ("users", "emails", "authids", "privileges", "contacts", "groups", "membership", "invites", "campaign") {
    my $sth = $db->prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='$table';");
    $sth->execute();

    if ($sth->fetchrow_array) {
        Common::dprint("Table '$table' exists.\n");
    } else {
        Common::dprint("Table '$table' does NOT exist!\n");
        $errs ++;
    }
}

if ($errs > 0) {
    print("ERROR: one or more tables is missing from the database\n");
}

Common::dprint("leaving check_init_db\n");

exit($db->disconnect);
