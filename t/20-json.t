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

ok(setting('serializer' => 'JSON'), "serializer JSON loaded");

set 'show_errors' => 1;

set 'log' => 'debug';

set 'traces' => 1;

my $response = dancer_response GET => '/api/Task', { params => { _s => 4 , _pl => 10, _p => 1  } }	;

#diag($response->content);

#response_content_like [ GET => '/api/Book/3' ], qr/Overridden/;

## testing for routes in base methods 



done_testing;



