# Data append testing

use strict;
use Test::More tests => 6;
use HTML::Tabulate;
use Data::Dumper;
use FindBin qw($Bin);

# Load result strings
my %result = ();
my $test = "$Bin/t25";
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

my $print = shift @ARGV || 0;
my $n = 1;
sub report {
  my ($data, $file, $inc) = @_;
  $inc ||= 1;
  if ($print == $n) {
    print STDERR "--> $file\n";
    print $data;
    exit 0;
  }
  $n += $inc;
}

my $d = [ 
  [ '123', 'Fred Flintstone', 'CEO', 'M', 1 ], 
  [ '456', 'Barney Rubble', 'Lackey', 'M', 2 ],
  [ '999', 'Dino', 'Pet', 'M', 0 ],
  [ '888', 'Bam Bam', 'Child', 'M', 0 ],
  [ '789', 'Wilma Flintstone   ', 'CFO', 'F', undef ], 
  [ '777', 'Betty Rubble', '', 'F', undef ],
];
my $t = HTML::Tabulate->new({ 
  fields => [ qw(emp_id emp_name emp_title emp_gender emp_xx) ],
  fields_omit => [ qw(emp_gender emp_xx) ],
});
my $table;
my @append;

# No data_append
$table = $t->render($d);
report $table, "simple1";
is($table, $result{simple1}, "no data_append");

# Empty data_append
$table = $t->render($d, {
  data_append => [],
});
report $table, "simple1";
is($table, $result{simple1}, "empty data_append");

# Single-row data_append
@append = ( pop @$d );
$table = $t->render($d, {
  data_append => \@append,
});
report $table, "simple1";
is($table, $result{simple1}, "single-row data_append");

# Multi-row data_append
unshift @append, pop @$d;
unshift @append, pop @$d;
is(scalar @append, 3, "three rows to data_append");
$table = $t->render($d, {
  data_append => \@append,
});
report $table, "simple1";
is($table, $result{simple1}, "multi-row data_append");

# Hashref rows in data_append
my @append2 = ();
for my $row (@append) {
  my $new_row = {};
  for (qw(emp_id emp_name emp_title emp_gender emp_xx)) {
    $new_row->{$_} = shift @$row;
  }
  push @append2, $new_row;
}
$table = $t->render($d, {
  data_append => \@append2,
});
report $table, "simple1";
is($table, $result{simple1}, "multi-row hashref data_append");

