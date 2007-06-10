# style 'across' testing

use Test::More tests => 3;
BEGIN { use_ok( HTML::Tabulate ) }
use Data::Dumper;
use strict;

# Load result strings
my $test = 't8';
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

# Standard (style => 'down')
my $t = HTML::Tabulate->new({
  table => { align => 'center' },
  thtr => { class => 'thtr' },
  tr => { class => 'tr' },
  th => { align => 'center' },
  stripe => '#cccccc',
  labels => 1,
});
my $data = [ [ '123', 'Fred Flintstone', 'CEO', '19710430', ], 
             [ '456', 'Barney Rubble', 'Lackey', '19751212', ],
             [ '789', 'Dino', 'Pet', '19950906', ] ];
my $table;
$table = $t->render($data, {
  fields => [ qw(emp_id emp_name emp_title birth_dt) ],
});
is($table, $result{down}, "result down ok");
# print $table, "\n";

$table = $t->render($data, {
  fields => [ qw(emp_id emp_name emp_title birth_dt) ],
  style => 'across',
});
is($table, $result{across}, "result across ok");
print $table, "\n";



# arch-tag: f6f27931-76f5-4b30-8af1-ff12d56f3050
