package Test::Stub::DBI;
use 5.008005;
use strict;
use warnings;
use parent qw(Exporter);

use Test::Mock::Guard;

our $VERSION = "0.01";

our @EXPORT = qw(stub_dbi);


sub stub_dbi {
    my (%stubbed_method_for) = @_;

    if ( !defined wantarray() ) {
        die "error: call with return value(guard object)";
    }

    my $sth_method_href = defined $stubbed_method_for{sth} ? $stubbed_method_for{sth} : {};
    my $dbh_method_href = defined $stubbed_method_for{dbh} ? $stubbed_method_for{dbh} : {};
    my $dbi_method_href = defined $stubbed_method_for{dbi} ? $stubbed_method_for{dbi} : {};

    my $guard_sth = mock_guard('Test::Stub::DBI::st', $sth_method_href);
    my $guard_dbh = mock_guard('Test::Stub::DBI::db', $dbh_method_href);

    my $guard_dbi = mock_guard('DBI', {
        connect => \&connect,
        %{ $dbi_method_href },
    });

    return [$guard_sth, $guard_dbh, $guard_dbi];
}

sub connect {
    return Test::Stub::DBI::db->new();
}

package Test::Stub::DBI::db;
use strict;
use warnings;

sub new {
    bless {}, shift;
}

sub prepare {
    my ($self, $statement) = @_;
    return Test::Stub::DBI::st->new({ statement => $statement });
}

package Test::Stub::DBI::st;
use strict;
use warnings;

sub new {
    my ($class, $arg) = @_;
    my $self = {
        statement => $arg->{statement},
    };
    bless $self, $class;
}

sub execute {
    my ($self, @params) = @_;
    return 1;
}

sub bind_param {
    my ($self, $num, $param, $type) = @_;
    $self->{params}->[$num-1] = $param;
    return 1;
}


1;
__END__

=encoding utf-8

=head1 NAME

Test::Stub::DBI - stub for DBI

=head1 SYNOPSIS

    use Test::Stub::DBI;
    my $count = 0;
    my $guard = stub_dbi(
        sth => {
            fetchrow_hashref => sub {
                $count++;
                return { id => 10, name => foo } if ( $count == 1 );
                return;
            }
        },
    );
    my $dbh = Test::Stub::DBI->connect();
    ... # call method to be tested which uses fetchrow_hashref

=head1 DESCRIPTION

NOTE: This module is alpha quality and API may be changed in future release.

Test::Stub::DBI is stub for DBI. 

=head1 LICENSE

Copyright (C) Takuya Tsuchida.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=cut

