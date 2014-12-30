use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'KelpX::Sweet',
    VERSION_FROM    => 'lib/KelpX/Sweet.pm',
    ABSTRACT        => 'Kelp with extra sweeteners',
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' },
    DISTNAME        => 'KelpX-Sweet',
    EXE_FILES       => [ 'bin/kelpx-sweet' ],
    PREREQ_PM       => {
        'Moo'       => 0,
        'Kelp'      => 0,
        'true'      => 0,
        'Text::ASCIITable' => 0,
    },        
);
