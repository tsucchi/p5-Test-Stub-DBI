requires 'perl', '5.008005';
requires 'parent';
requires 'Test::Mock::Guard';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'DBI';
    requires 'Try::Tiny';
};

