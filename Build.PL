use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    license        => 'perl',
    dynamic_config => 0,
    dist_abstract  => 'XXX',

    build_requires     => {
        'Test::More'      => '0.98',
        'Test::Requires'  => '0.06',
        'Test::Exception' => 0,
    },
    configure_requires => { 'Module::Build' => '0.38' },
    requires           => {
        perl              => '5.008001',
        Mouse             => 0,
        'Path::Class'     => 0,
        'Try::Tiny'       => 0,
        'List::MoreUtils' => 0,
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Parse/Crontab',
    module_name => 'Parse::Crontab',

    # script_files => [''],

    test_files           => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    create_makefile_pl => 'traditional',
    create_readme      => 1,
    create_license     => 1,
);
$build->create_build_script;
