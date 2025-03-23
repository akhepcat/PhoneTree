#!/usr/bin/perl -t
use lib "..";
use Includes::Common;

# -no_debug  in prod, -debug in testing
if ($Common::DEBUG >0) {
        Common::dprint("INFO: debugging on\n");
#	use CGI qw(:standard :Carp -debug);
#	use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
	use Data::Dumper;
#} else {
#	use CGI qw(:standard :Carp -no_debug);
#	use CGI::Carp;
}

use DBI;
my $dbfile = $Common::dbfile;
my $db;

sub check_init_db() {
    my $errs = 0;

    # Check to make sure all the tables exist
    Common::dprint("in check_init_db\n");

    foreach my $table ("users", "emails", "authids", "privileges", "contacts", "groups", "membership", "invites", "campaign") {
        my $sth = $db->prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
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
}

if (! length($dbfile) ) {
    die("Error: dbfile not defined or imported correctly from local.inc\n");
}
$db = DBI->connect("dbi:SQLite:dbname=$dbfile","","", { RaiseError => 1, AutoCommit => 1 });
check_init_db();

exit($db->disconnect);
