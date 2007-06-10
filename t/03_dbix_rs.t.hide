# Base functionality

use Test;
BEGIN { plan tests => 1 };
use HTML::Tabulate;

# Load result strings
my $test = 't1';
my %result = ();
die "missing data dir t/$test" unless -d "t/$test";
opendir DATADIR, "t/$test" or die "can't open t/$test";
for (readdir DATADIR) {
  next if m/^\./;
  open FILE, "<t/$test/$_" or die "can't read t/$test/$_";
  { 
    local $/ = undef;
    $result{$_} = <FILE>;
  }
  close FILE;
}
close DATADIR;

# Base functionality
$d = [ [ '123', 'Fred Flintstone', 'CEO' ], [ '456', 'Barney Rubble', 'Lackey' ] ];
$t = HTML::Tabulate->new();
ok($t->render($d) eq $result{base});
