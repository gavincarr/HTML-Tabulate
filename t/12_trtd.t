# tr/td coderef testing

use Test::More tests => 7;
use HTML::Tabulate 0.25;
use Data::Dumper;
use strict;

# Load result strings
my $test = 't12';
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

# Setup
my $data = [ [ '123', 'Fred Flintstone', 'CEO', '19710430', ], 
             [ '456', 'Barney Rubble', 'Lackey', '19750808', ],
             [ '789', 'Dino', 'Pet' ] ];
my $t = HTML::Tabulate->new({
  fields => [ qw(emp_id emp_name emp_title emp_birth_dt) ],
});
my $table;

# tr sub
$table = $t->render($data, {
  tr => sub { my $r = shift; my $name = lc $r->[1]; $name =~ s! .*!!; { class => $name } },
});
report $table, "trsub";
is($table, $result{trsub}, "tr sub");

# tr attr sub
$table = $t->render($data, {
  tr => {
    class => sub { my $r = shift; my $name = $r->[1]; $name =~ s!\s.*!!; lc $name }, 
  },
});
report $table, "trsub";
is($table, $result{trsub}, "tr attr sub");

# tr attr sub2
$table = $t->render($data, {
  tr => {
    id => sub { my $r = shift; $r->[3] }, 
  },
});
report $table, "trsub2";
is($table, $result{trsub2}, "tr attr sub (undef)");

# th/td attr sub
$table = $t->render($data, {
  labels => 1,
  th => {
    class => sub { my ($d, $r, $f) = @_; $d =~ s/^Emp //; $d =~ s/\s+/_/g; lc $d },
  },
  td => { 
    class => sub { my ($d, $r, $f) = @_; my $class = ($d =~ m/^\d+$/ ? 'digits' : 'alpha'); $class },
  },
});
report $table, "thtdsub";
is($table, $result{thtdsub}, "th/td sub");

# th/td attr sub2 (undef)
$table = $t->render($data, {
  labels => 1,
  th => {
    class => sub { my ($d, $r, $f) = @_; return undef unless $d =~ m/(name|title)/i; $d =~ s/^Emp //; $d =~ s/\s+/_/g; lc $d },
  },
  td => { 
    class => sub { my ($d, $r, $f) = @_; my $class = ($d =~ m/^\d+$/ ? 'digits' : undef ); $class },
  },
});
report $table, "thtdsub2";
is($table, $result{thtdsub2}, "th/td sub2 (undef)");

# fattr sub1
$table = $t->render($data, {
  td => { class => 'td' },
  field_attr => {
    emp_id => { class => sub { my ($d, $r, $f) = @_; reverse $r->[0] } },
    emp_name => { class => sub { my ($d, $r, $f) = @_; lc $r->[2] eq 'ceo' ? 'red' : 'green' } },
  },
});
report $table, "fattrsub1";
is($table, $result{fattrsub1}, "fattr sub1");

# fattr sub2
$table = $t->render($data, {
  field_attr => {
    emp_id => { class => sub { my ($d, $r, $f) = @_; reverse $r->[0] } },
    emp_name => { 
      class => sub { 
        my ($d, $r, $f) = @_; return undef unless $r->[2] eq 'CEO'; 'red'
      },
    },
  },
});
report $table, "fattrsub2";
is($table, $result{fattrsub2}, "fattr sub2 (undef)");

# arch-tag: f26ad97a-f2aa-4e19-b5d1-f970146c5038
