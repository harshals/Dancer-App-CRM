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

set 'show_errors' => 1;

set 'log' => 'debug';

set 'traces' => 1;

response_status_is    [ GET => '/' ], 200,   "GET / is found";

response_content_like [ GET => '/' ], qr/Hello World/;

## pagination tests

my $task_content = {
		'1' => {
                    'task_status' => 'Success',
                    '_id' => '02985B28-3836-11E0-999D-8CDC1E1865CA',
                    'name' => 'call_Jorge',
                    'place' => undef,
                    'description' => 'Discuss_china_strategy',
                    'due_date' => '2011-02-14',
                    'assigned_to' => '4',
                    'assigned_by' => '2',
                    'id' => '1',
                    'log' => undef,
                    'category' => undef
                  },
           '2' => {
                    'task_status' => 'Incomplete',
                    '_id' => '029A37E0-3836-11E0-94EA-8CDC1E1865CA',
                    'name' => 'meet_nancy',
                    'place' => undef,
                    'description' => 'Discuss_logistics',
                    'due_date' => '2011-02-14',
                    'assigned_to' => '4',
                    'assigned_by' => '2',
                    'id' => '2',
                    'log' => undef,
                    'category' => undef
                  }
	};


my $response = dancer_response GET => '/api/Task', { params => { _s => 7 , _pl => 2, _p => 1, _ik=> 'id' } }	;

#diag Dumper($response->content->{'data'});

is_deeply($response->content->{'data'}, $task_content, "Returned correct data structure");

my %single_task = map { $_ => $task_content->{2}->{$_} } (grep  { defined $task_content->{2}->{$_} } keys %{ $task_content->{2}} );

$response = dancer_response GET => '/api/Task/2', { params => { _s => 8 ,  _ik=> 'id' } }	;

is_deeply($response->content->{'data'}, \%single_task, "Returned 2nd correct data structure");

$response = dancer_response GET => '/api/Task', { params => { _s => 8 , _pl => 3, _p => 1 , Task=> { task_status => 'Success' } } }	;

is (scalar(@{ $response->content->{data} })  , 3 , "Found three successfully completed tasks");

$response = dancer_response GET => '/api/Task/custom/completed_tasks', { params => { _s => 8 , _pl => 3, _p => 1  } }	;

is (scalar(@{ $response->content->{data} })  , 3 , "same result using custom query route");

$single_task{'description'} = "My new Description";

$response = dancer_response POST => '/api/Task/2', { params => { Task => \%single_task   } }	;

is ($response->content->{data}->{'description'}   ,  "My new Description", "Just updated a task with new description");

$response = dancer_response DELETE => '/api/Task/2'	;

is ($response->content->{message}   ,  "Object Deleted", "Object successfully deleted");

delete $single_task{'id'};

$response = dancer_response PUT => '/api/Task', { params => {  Task => \%single_task } }	;

diag Dumper($response);

#response_status_is    [ GET => '/api/Task/2' ], 500,   "Object not found";

my $new_response ;

eval {
	$new_response = dancer_response GET => '/api/Task/2', { params => { _s => 8 ,  _ik=> 'id' } }	;
};
if ($@) {

diag Dumper($new_response);
}

#response_content_like [ GET => '/api/Book/3' ], qr/Overridden/;

## testing for routes in base methods 



done_testing;



