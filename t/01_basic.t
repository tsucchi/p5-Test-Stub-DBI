#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Stub::DBI;
use Try::Tiny;
use DBI;

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

subtest 'stub_sth with SQL statement', sub {
    my $count = 0;
    my $sql = 'SELECT * FROM SOME_TABLE';
    my $guard = stub_dbi(
        sth => {
            execute => sub {
                my ($self, @params) = @_;
                $count++;
                is( $self->{statement}, $sql );
            },
        },
    );
    my $dbh = Test::Stub::DBI->connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    is( $count, 1);
};

subtest 'stub_sth and bind_param', sub {
    my $count = 0;
    my $sql = 'SELECT * FROM SOME_TABLE WHERE id IN(?, ?)';
    my $params = [100, 200];
    my $guard = stub_dbi(
        sth => {
            execute => sub {
                my ($self, @params) = @_;
                $count++;
                is_deeply( $self->{params}, $params );
            },
        },
    );
    my $dbh = Test::Stub::DBI->connect();
    my $sth = $dbh->prepare($sql);
    $sth->bind_param(1, $params->[0]);
    $sth->bind_param(2, $params->[1]);
    $sth->execute();
    is( $count, 1);
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

subtest 'stub_dbi', sub {
    my $count = 0;
    my $guard = stub_dbi(
        dbi => {
            connect => sub { die "connect failed" },
        },
    );

    try {
        my $dbh = DBI->connect('dbd::dummy');
        fail 'exception expected';
    } catch {
        like( $_, qr/^connect failed/ );
    };
};



done_testing();
