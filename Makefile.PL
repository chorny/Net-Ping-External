use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Net::Ping::External',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'External.pm', # retrieve abstract from module
       AUTHOR     => 'Alexandr Ciornii <alexchorny@'.'gmail.com>') : ()),
    'VERSION_FROM'	=> 'External.pm', # finds $VERSION
    ($ExtUtils::MakeMaker::VERSION ge '6.31'? 
     ('LICENSE'		=> 'perl', ) : ()),
    'PREREQ_PM'		=> {
      Socket => 0,
      Carp => 0,
#      perl => '5.4',
    },
);
