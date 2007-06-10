# Simple dataset handling

use Test::More tests => 8;
BEGIN { use_ok( HTML::Tabulate ) }
use strict;

# Load result strings
my $test = 't1';
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

my $t = HTML::Tabulate->new();

# Simple hashref
my $d = { emp_id => '123', name => 'Fred Flintstone', title => 'CEO' };
is($t->render($d), $result{fred}, 'simple hashref');

# Nested arrayrefs
$d = [ [ '123', 'Fred Flintstone', 'CEO' ] ];
is($t->render($d), $result{fred}, 'nested arrayrefs1');
$d = [ [ '123', 'Fred Flintstone', 'CEO' ], [ '456', 'Barney Rubble', 'Lackey' ] ];
is($t->render($d), $result{fredbarney}, "nested arrayrefs2");
$d = [ [ '123', 'Fred Flintstone', 'CEO' ], 
       [ '456', 'Barney Rubble', 'Lackey' ],
       [ '789', 'Wilma Flintstone   ', 'CFO' ], 
       [ '777', 'Betty Rubble', '' ], ];
is($t->render($d), $result{fbwb}, "nested arrayrefs4");

# Nested hashrefs
$d = [ { emp_id => '123', name => 'Fred Flintstone', title => 'CEO' } ];
is($t->render($d), $result{fred}, "nested hashrefs1");
$d = [ { emp_id => '123', name => 'Fred Flintstone', title => 'CEO' }, 
       { emp_id => '456', name => 'Barney Rubble', title => 'Lackey' }, ];
is($t->render($d), $result{fredbarney}, "nested hashrefs2");
$d = [ { emp_id => '123', name => 'Fred Flintstone', title => 'CEO' }, 
       { emp_id => '456', name => 'Barney Rubble', title => 'Lackey' },
       { emp_id => '789', name => 'Wilma Flintstone   ', title => 'CFO' },
       { emp_id => '777', name => 'Betty Rubble', title => '' }, ];
is($t->render($d), $result{fbwb}, "nested hashrefs4");




# arch-tag: 7ae7c6d8-938a-4b25-a061-c8bf1700a8b1
