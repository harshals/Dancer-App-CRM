#
#===============================================================================
#
#         FILE:  Init.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  01/26/2011 17:55:14 IST
#     REVISION:  ---
#===============================================================================

package Dancer::App::CRM::Admin::Init;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;


get '/init/:username/:application' => sub {
	
	my $db = schema('db');
	my $username = params->{'username'};
	my $application = params->{'application'};
	
	#my %base = ( active => 1, access_read => ",$user," , access_write => ",$user,", status => ",active," , data => '');
	
	$db->user(1);
	my $user = $db->resultset( 'User' )->fetch_new();
	
	$user->save({
		username => $username,
		password => $username,
		application_id => 0,
		profile_id => 0
	});

	my $app = $db->resultset('Application')->fetch_new();
	$app->save({
		
		name => $application,
		admin_id => $user->id,
		expiry => '2011-12-31',
		schema_class => 'Schema',
		db_name => 'small.db',
		revision => 1,
		app_class => 'None'
	});
	
	$user->application_id($app->id);

	$user->update();
	
	return "Application $application created with user $username";
};

1;


