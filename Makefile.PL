use 5.005;
use inc::Module::Install;

name            'HTML-Tabulate';
all_from        'Tabulate.pm';

requires        'URI::Escape'       => 0;
requires        'Carp'              => 0;
test_requires   'Test::More'        => 0;

WriteAll;

