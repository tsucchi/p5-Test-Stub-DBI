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

    my $guard_sth = mock_guard('Test::Stub::DBI::st', $sth_method_href);
    my $guard_dbh = mock_guard('Test::Stub::DBI::db', {
        prepare => sub { Test::Stub::DBI::st->new() },
        %{ $dbh_method_href },
    });

    return [$guard_sth, $guard_dbh];
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

package Test::Stub::DBI::st;
use strict;
use warnings;

sub new {
    bless {}, shift;
}



1;
__END__

=encoding utf-8

=head1 NAME

Test::Stub::DBI - It's new $module

=head1 SYNOPSIS

    use Test::Stub::DBI;

=head1 DESCRIPTION

Test::Stub::DBI is ...

=head1 LICENSE

Copyright (C) Takuya Tsuchida.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takuya Tsuchida E<lt>takuya.tsuchida@gmail.comE<gt>

=cut

