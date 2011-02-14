#
#===============================================================================
#
#         FILE:  10-dancer.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  02/14/2011 15:09:36 IST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More ;
use Dancer::Test;
use Dancer qw/:syntax/;
use Data::Dumper;
use TestApp;

setting('skip_authentication', 1);

set plugins => {
    DBIC => {
        master => {
            dsn =>  "dbi:SQLite:dbname=t/var/master.db",
            schema_class => 'Master'
        },
		db => {
            dsn =>  "dbi:SQLite:dbname=t/var/small.db",
            schema_class => 'Schema'
        },
    }
    
};

set serializer => '';

response_status_is    [ GET => '/' ], 200,   "GET / is found";

response_content_like [ GET => '/' ], qr/Hello World/;

my $response = dancer_response GET => '/api/Book';

diag Dumper($response);

response_content_like [ GET => '/api/Book' ], qr/Overridden/;

## testing for routes in base methods 



done_testing;



