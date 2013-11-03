#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Stub::DBI;
use Try::Tiny;

subtest 'stub_sth', sub {
    my $count = 0;
    my $guard = stub_dbi(
        sth => {
            fetchrow_arrayref => sub { 
                $count++;
                return [0] if ( $count == 1 );
                return [1] if ( $count == 2 );
                return;
            }
        },
    );
    my $dbh = Test::Stub::DBI->connect();
    my $sth = $dbh->prepare('SELECT * FROM SOME_TABLE');
    $sth->execute();
    is_deeply( $sth->fetchrow_arrayref, [0] );
    is_deeply( $sth->fetchrow_arrayref, [1] );
    is( $sth->fetchrow_arrayref, undef );
};

subtest 'stub_dbh', sub {
    my $count = 0;
    my $guard = stub_dbi(
        dbh => {
            prepare => sub { die "prepare failed" },
        },
    );
    my $dbh = Test::Stub::DBI->connect();
    try {
        my $sth = $dbh->prepare('SELECT * FROM SOME_TABLE');
        fail 'exception expected';
    } catch {
        like( $_, qr/^prepare failed/ );
    };
};



done_testing();
