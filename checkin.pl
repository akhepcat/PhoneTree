#!/usr/bin/perl

use CGI qw(:standard :Carp -debug);  # -no_debug  in prod, -debug in testing
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use DBI;
use Data::Dumper;

my $dbfile="/srv/http/www.akhepcat/db/status.sql";

my $self="https://akhepcat.com/cgi-bin/checkin.pl";
my $DEBUG=1;

my $db = DBI->connect("dbi:SQLite:dbname=$dbfile","","", { RaiseError => 1, AutoCommit => 1 });

sub check_init_db() {

    my $sth = $dbh->prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='contacts'");
    $sth->execute();
    if ($sth->fetchrow_array) {
        # print "Table 'contacts' exists.\n";
        0;
    } else {
        # print "Table 'contacts' does NOT exist!\n";
	my $sql = <<'END_SQL';
CREATE TABLE contacts (
    nick TEXT PRIMARY KEY,
    name TEXT,
    location TEXT,
    phone1 TEXT UNIQUE,
    phone2 TEXT UNIQUE,
    notes TEXT,
);
END_SQL

	$db->do($sql) or die $DBI::errstr;
    
    }

    $sth = $dbh->prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='checkins'");
    $sth->execute();
    if ($sth->fetchrow_array) {
        # print "Table 'checkins' exists.\n";
        0;
    } else {
        # print "Table 'checkins' does NOT exist!\n";
	my $sql = <<'END_SQL';
CREATE TABLE checkins (
    timestamp INTEGER PRIMARY KEY,
    expires INTEGER,
    uuid TEXT UNIQUE,
    nick TEXT,
    success INTEGER
);
END_SQL

	$db->do($sql) or die $DBI::errstr;
    
    }
}


sub add_user() {
    my($nick,$name,$location,$phone1,$phone2,$notes)=@_;

    my $sql = "INSERT INTO CONTACTS $nick, $name, $location, $phone1, $phone2, $notes"
    $db->do($sql) or die $DBI::errstr;
}


sub html_header() {
        print qq(
<html>
<head><title>Emergency Check-in</title></head>
<body>
<h1>Emergency Check-in</h1>
<p>
);
}

sub html_footer() {
    print qq(
</p>
</body>
</html>
    );
}


check_init_db;


my $cgi = CGI->new;
my $args = $cgi->Vars;
my $locked = 0;
my $action =  ($locked==1)?"unlock":"lock";

if ( defined( $args->{'toggle'} ) ) {

#    if ($DEBUG >=1) {
        print $cgi->header();
        html_header();

        print "cgi args were:<br />\n<pre>\n";
        Dumper($args);
        print "</pre>\n";

        print "hopefully, we've toggled to $action<br />\n";
        
#        $locked = status();
        
        print "The current status is:  $locked<br />\n";
        print "System output is: <br >\n";
        print "<pre>$sres\n</pre>\n";
        
#    } else {
#        print $cgi->redirect( $self );
#    }

} else {
    print $cgi->header();
    html_header();
    # Form time!

    # change from 'submit' to 'image', and add a 'src': TYPE="image” SRC="/image.gif” 
    print qq( <form action="$self" method="POST"> \n );
    print qq( <INPUT TYPE="submit" NAME="toggle" VALUE="$action"> \n );
#    print qq( <INPUT TYPE="image" SRC="https://akhepcat.com/imgs/$action.png" ALT="$action" NAME="toggle" VALUE="$action"> \n );
    print qq( </form> \n );

    if ($DEBUG >= 1) {
        print "cgi args were:<br />\n<pre>\n";
        Dumper($args);
        print "</pre>\n";
    }

}

html_footer();
exit($db->disconnect);
