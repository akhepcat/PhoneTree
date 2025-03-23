#!/usr/bin/perl -t
use lib "..";
use Includes::Common;

if ($Common::DEBUG >0) {
        Common::dprint("INFO: debugging on\n");
	use Data::Dumper;
}

use DBI;
use Data::UUID::MT;
use Term::ReadKey;
use POSIX;
use Crypt::Bcrypt qw(bcrypt);

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

if ($sth->fetchrow_array) {
    Common::dprint("Admins are already defined\n");
    exit(0);
} else {
    Common::dprint("No admins are defined\n");
}

my($un,$pw,$pw2,$em)="";
my $ug = Data::UUID::MT->new( version => "4s" );
my $nid = $ug->iterator;
my $userid = lc join "-", unpack("H8H4H4H4H12", $nid->() );
my $authid = lc join "-", unpack("H8H4H4H4H12", $nid->() );
my $emailid = lc join "-", unpack("H8H4H4H4H12", $nid->() );
my $privs = lc join "-", unpack("H8H4H4H4H12", $nid->() );
my $salt = substr($userid, -17);
$salt =~ s/-//g;

print("Admin username: ");
while (! length($un)) { 
    $un=ReadLine(0);
}

#ReadMode('noecho');
print("Admin password: ");
$pw=ReadLine(0);
#ReadMode(1);

print("Admin email: ");
while (! length($em)) {
    $em=ReadLine(0);
}
print("\n");

chomp($un); chomp($pw); chomp($em);
my $ts = time;

$sql = "INSERT INTO users ( userid, created, authid, privs, username, emailid ) VALUES ('$userid', '$ts', '$authid', '$privs', '$un', '$emailid');";
$db->do($sql) or die("Error executing >$sql<, " . $DBI::err);

$sql = "INSERT INTO emails ( emailid, timestamp, address, verified ) VALUES ('$emailid', '$ts', '$em', 0);";
$db->do($sql) or die("Error executing >$sql<, " . $DBI::err);

$pw = bcrypt($pw, "2b", 12, $salt);	# always hash using the last (random) 16 bytes of the userid, so it's unique per user

$sql = "INSERT INTO authids ( authid, timestamp, userid, authtype, authdata ) VALUES ('$authid', '$ts', '$userid', 0, '$pw');";
$db->do($sql) or die("Error executing >$sql<, " . $DBI::err);

$sql = "INSERT INTO privileges ( privs, isadmin ) VALUES ('$privs', 1);";
$db->do($sql) or die("Error executing >$sql<, " . $DBI::err);

#Common::dprint($sql);
Common::dprint("Completed initialization of Admin user\n");

exit($db->disconnect);
