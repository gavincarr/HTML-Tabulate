# field attribute merge and inheritance testing

use Test::More tests => 5;
BEGIN { use_ok( HTML::Tabulate ) }
use Data::Dumper;
use strict;

# Load result strings
my $test = 't4';
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

# Setup an initial defn
my $t = HTML::Tabulate->new({ 
  field_attr => {
    -defaults => {
      format => sub { uc(shift) },
      align => 'center',
    },
    emp_id => {
      format => "%07d",
    },
  },
});

# Test
my $defn = $t->defn;
ok(ref $defn->{field_attr}, "defn field_attr defined");
ok(ref $defn->{field_attr}->{-defaults} eq 'HASH', "defn -defaults defined");
ok(ref $defn->{field_attr}->{emp_id} eq 'HASH', "defn emp_id defined");

# Render
my $data = [ [ '123', 'Fred Flintstone', 'CEO' ], 
             [ '456', 'Barney Rubble', 'Lackey' ] ];
my $table = $t->render($data, {
  fields => [ qw(emp_id emp_name emp_title) ],
  field_attr => {
    emp_id => {
      link => "emp.html?id=%s",
    },
    emp_name => {
      format => sub { ucfirst(shift) },
    },
    emp_title => {
      align => 'left',
    },
  },
});
# print $table, "\n";
is($table, $result{render1}, "render1 result ok");



# arch-tag: f5552bc9-5784-407e-8f14-12bdbe3a20e8

