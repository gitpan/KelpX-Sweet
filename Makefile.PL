use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'KelpX::Sweet',
    VERSION_FROM    => 'lib/KelpX/Sweet.pm',
    ABSTRACT        => 'Kelp with extra sweeteners',
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' },
    DISTNAME        => 'KelpX-Sweet',
    EXE_FILES       => [ 'bin/kelpx-sweet' ],
    TEST_REQUIRES   => {
        'Test::More' => 0,
        'Kelp::Test' => 0,
        'Kelp::Module::Template::Toolkit' => 0,
        'DBIx::Class' => 0,
    },

    PREREQ_PM       => {
        'Moo'       => 0,
        'Kelp'      => 0,
        'true'      => 0,
        'Text::ASCIITable' => 0,
        'Module::Find' => 0,
    },        
);
