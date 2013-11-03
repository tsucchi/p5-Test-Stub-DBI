# NAME

Test::Stub::DBI - stub for DBI

# SYNOPSIS

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

# DESCRIPTION

NOTE: This module is alpha quality and API may be changed in future release.

Test::Stub::DBI is stub for DBI. 

# LICENSE

Copyright (C) Takuya Tsuchida.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takuya Tsuchida <tsucchi@cpan.org>
