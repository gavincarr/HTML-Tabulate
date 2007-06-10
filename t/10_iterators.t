# iterator testing - DBIx::Recordset and Class::DBI iterators
# 
# uses the mysql 'test' database, if available
#

use Test::More tests => 4;
use HTML::Tabulate;
use Data::Dumper;
use strict;

# Load result strings
my $test = 't10';
my %result = ();
$test = "t/$test" if -d "t/$test";
die "missing data dir $test" unless -d $test;
opendir DATADIR, $test or die "can't open directory $test";
for (readdir DATADIR) {
  next if m/^\./;
  open FILE, "<$test/$_" or die "can't read $test/$_";
  { 
    local $/ = undef;
    $result{$_} = <FILE>;
  }
  close FILE;
}
close DATADIR;

my $t = HTML::Tabulate->new({
  fields => [ qw(emp_id emp_name emp_title emp_birth_dt) ],
  table => { border => 0, class => 'table' },
  thtr => { class => 'thtr' },
  tr => { class => 'tr' },
  labels => 1,
  null => '-',
});

my $dbh;
SKIP: {
  my $tests1 = 2;
  my $tests2 = 2;

  eval { require DBI };
  skip "DBI not installed", $tests1+$tests2 if $@;
  eval { require DBD::mysql };
  skip "DBD::mysql not installed", $tests1+$tests2 if $@;
 
  # Setup test data
  $dbh = eval { DBI->connect("DBI:mysql:test") };
  skip "unable to connect to mysql test db", $tests1+$tests2 unless ref $dbh;
  eval { $dbh->do("drop table if exists emp_tabulate") };
  eval { $dbh->do(qq(
    create table emp_tabulate (
      emp_id integer unsigned auto_increment primary key,
      emp_name varchar(255),
      emp_title varchar(255),
      emp_birth_dt date
    )
  )) };
  skip "unable to create emp_tabulate test table", $tests1+$tests2 if $@;
  eval { $dbh->do(qq(
    insert into emp_tabulate values(123, 'Fred Flintstone', 'CEO', '1971-04-30')
  )) };
  skip "emp_tabulate insert1 failed", $tests1+$tests2 if $@;
  eval { $dbh->do(qq(
    insert into emp_tabulate values(456, 'Barney Rubble', 'Lackey', '1975-08-04')
  )) };
  skip "emp_tabulate insert2 failed", $tests1+$tests2 if $@;
  eval { $dbh->do(qq(
    insert into emp_tabulate values(789, 'Dino  ', 'Pet', null)
  )) };
  skip "emp_tabulate insert3 failed", $tests1+$tests2 if $@;

  # DBIx::Recordset
  SKIP: {
    eval { require DBIx::Recordset };
    skip "DBIx::Recordset not installed", $tests1 if $@;

    my $set = eval { DBIx::Recordset->SetupObject({
      '!DataSource' => 'dbi:mysql:test',
      '!Table' => 'emp_tabulate',
      '!PrimKey' => 'emp_id',
    }) };
    skip "DBIx::Recordset employee retrieve failed", $tests1 if $@;
    $set->Select;

    # Render1
    my $table = $t->render($set);
#   print $table, "\n";
    is ($table, $result{render1}, "DBIx::Recordset render1 okay");

    # Render2 (across)
    $table = $t->render($set, { style => 'across' });
#   print $table, "\n";
    is ($table, $result{render2}, "DBIx::Recordset render2 okay");
  }

  SKIP: {
    # Class::DBI setup
    eval { require Class::DBI };
    if ($@) {
      skip "Class::DBI not installed", $tests2;
    }
    else {
      # Define a temp Class::DBI Employee class
      eval qq(
        package Employee;
        use base 'Class::DBI';
        __PACKAGE__->set_db('Main', 'dbi:mysql:test');
        __PACKAGE__->table('emp_tabulate');
        __PACKAGE__->columns(Essential => qw(emp_id emp_name emp_title emp_birth_dt));
        );
    }
  
    package main;
    my $iter = eval { Employee->retrieve_all };
    skip "Class::DBI employee retrieve failed", $tests2 if $@;
 
    # Render1
    my $table = $t->render($iter);
#   print $table, "\n";
    is ($table, $result{render1}, "Class::DBI render1 okay");

    # Render2 (across)
    $table = $t->render($iter, { style => 'across' });
#   print $table, "\n";
    is ($table, $result{render2}, "Class::DBI render2 okay");
  }

  eval { $dbh->do("drop table if exists emp_tabulate") };
}

$dbh->disconnect if ref $dbh;


# arch-tag: 19421229-ab05-4f79-b3d8-6fb2039a3d15

