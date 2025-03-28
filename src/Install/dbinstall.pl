#!/usr/bin/perl -t
use lib "..";
use Includes::Common;

if ($Common::DEBUG >0) {
        Common::dprint("INFO: debugging on\n");
}

use DBI;
my $db;
my $errs = 0;

Common::dprint("Starting database schema initialization\n");

if ($Common::USE_SQLITE) {
    Common::dprint("Initializing SQLITE database\n");

    if (! length($Common::sqlfile) ) {
        die("Error: sqlfile not defined or imported correctly\n");
    }

    $db = DBI->connect("dbi:SQLite:dbname=$Common::sqlfile","","", { AutoCommit => 1, RaiseError => 0, PrintError => 0 });

    my $schema = "../../schema/schema.sqlite";
    my $stanza;
    
    open(SCHEMA,"$schema") or die "can't import schemafile ($schema) for db initialization";

    while(<SCHEMA>) {
        chomp;
        
        next if (m/^\s*(--.*?)?$/);

        if (m/^([A-Za-z0-9, \)\(\;]*)\s*?(--.*)?/) {
            $stanza .= $1;
        }

        if (m/^\s*.*?\);/) {
            Common::dprint "Executing SCHEMA: $stanza\n";
            my $ret = $db->do($stanza);
            if (! $ret) {
                $errs ++;
                Common::dprint("ERROR: $DBI::errstr\n");
            }
            $stanza = "";
        }
    }
} else {
    Common::dprint("Initializing PGSQL database\n");

    $db = DBI->connect("dbi:Pg:$Common::pgdb",$Common::pguser,$Common::pgpass, { AutoCommit => 1, RaiseError => 0, PrintError => 0 });

    my $schema = "../../schema/schema.pgsql";
    my $stanza;

    open(SCHEMA,"$schema") or die "can't import schemafile ($schema) for db initialization";

    while(<SCHEMA>) {
        chomp;
        
        next if (m/^\s*(--.*?)?$/);

        if (m/^([A-Za-z0-9, \)\(\;]*)\s*?(--.*)?/) {
            $stanza .= $1;
        }

        if (m/^\s*.*?\);/) {
            Common::dprint "Executing SCHEMA: $stanza\n";
            Common::dprint("PGSQL initialization not implemented yet!\n");
            $stanza = "";
        }
    }
}
    
Common::dprint("leaving init_db\n");
if ($errs > 0) {
    print("ERRORS: $errs occured during database initialization\n");
}
exit($db->disconnect);
