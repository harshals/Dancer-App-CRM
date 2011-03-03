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

set logger => 'file';

set serializer => '';

set 'show_errors' => 1;

set 'log' => 'debug';

set 'traces' => 1;

set 'show_errors' => 1;

response_status_is    [ GET => '/' ], 200,   "GET / is found";

response_content_like [ GET => '/' ], qr/Hello World/;

## pagination tests

my $task_content = {

   '1' => {
			'task_status' => 'Completed',
			'name' => 'call_Jorge',
			'place' => undef,
			'description' => 'Discuss_china_strategy',
			'due_date' => '2011-02-14',
			'assigned_to' => 4,
			'assigned_by' => 2,
			'id' => 1,
			'log' => undef,
			'category' => undef
		  },
   '2' => {
			'task_status' => 'Incomplete',
			'name' => 'meet_nancy',
			'place' => undef,
			'description' => 'Discuss_logistics',
			'due_date' => '2011-02-14',
			'assigned_to' => 4,
			'assigned_by' => 2,
			'id' => 2,
			'log' => undef,
			'category' => undef
		  }
};


my $response = dancer_response GET => '/api/Task', { params => { _s => 7 , _pl => 2, _p => 1, _ik=> 'id' } }	;

delete $response->content->{'data'}->{$_}->{_id} foreach (1,2);

is_deeply($response->content->{'data'}, $task_content, "Returned correct data structure");

my %single_task = map { $_ => $task_content->{2}->{$_} } (grep  { defined $task_content->{2}->{$_} } keys %{ $task_content->{2}} );

$response = dancer_response GET => '/api/Task/2', { params => { _s => 8 ,  _ik=> 'id' } }	;

delete $response->content->{'data'}->{_id} ;
is_deeply($response->content->{'data'}, \%single_task, "Returned 2nd correct data structure");

$response = dancer_response GET => '/api/Task', { params => { _s => 8 , _pl => 3, _p => 1 , Task=> { task_status => 'Completed' } } }	;

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

ok(defined $response->content->{data}->{id}   ,  "New task successfully created");

$response = dancer_response GET => '/api/Enumeration/custom/for', { params => {  Enumeration => [ 'Task', 'task_status'  ]  } }	;


#ok(defined $response->content->{data}->{id}   ,  "New task successfully created");
#response_status_is    [ GET => '/api/Task/2' ], 500,   "Object not found";

diag Dumper($response);

my $new_response ;

SKIP: {
	eval { dancer_response GET => '/api/Task/2', { params => { _s => 8 ,  _ik=> 'id' } } }	;

	skip "Can't find 2nd task ..it must be deleted", 1 if $@;

}



#response_content_like [ GET => '/api/Book/3' ], qr/Overridden/;

## testing for routes in base methods 



done_testing;



