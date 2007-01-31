use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::Ping::External',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'External.pm', # retrieve abstract from module
       AUTHOR     => 'Alexandr Ciornii <alexchorny@'.'gmail.com>') : ()),
    'VERSION_FROM'	=> 'External.pm', # finds $VERSION
    ($ExtUtils::MakeMaker::VERSION ge '6.30_00'? 
     ('LICENSE'		=> 'perl', ) : ()),
    'PREREQ_PM'		=> {
      Socket => 0,
      Carp => 0,
#      perl => '5.4',
    },
);
