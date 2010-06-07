use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Snarl',
    AUTHOR              => q{Alan Berndt <alan@eatabrick.org>},
    VERSION_FROM        => 'lib/Net/Snarl.pm',
    ABSTRACT_FROM       => 'lib/Net/Snarl.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { 
      COMPRESS  => 'gzip -9f', 
      SUFFIX    => 'gz', 
      TARFLAGS  => '--mode=644 -c -v -f',
    },
    clean               => { FILES => 'Net-Snarl-*' },
);
