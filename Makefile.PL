use inc::Module::Install;

name 'Geo-Hash-XS';
all_from 'lib/Geo/Hash/XS.pm';

test_requires 'Test::More' => '0.84';
use_ppport;
cc_warnings;
cc_src_paths 'xs';

WriteAll;