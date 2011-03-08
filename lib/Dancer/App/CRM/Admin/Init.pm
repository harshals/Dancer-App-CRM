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
use Dancer::Plugin::Email;

# ABSTRACT: Things to do when starting a new client 

before sub {
	
};

get '/init/:username/:application' => sub {
	
	my $db = schema('master');
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

get '/email/:to'  => sub {

	my $msg = vars->{msg} || 'kissing my ass';
	my $subject = vars->{subject} || 'kiss my ass';

	my $output = email {
            to => 'harshal@mki.in',
            subject => $subject,
            message => $msg,
            from => 'info@adhril.com'
	};
	
	
	return { message => ($output) ? "Sent OK" : "Sorry ! try again" };
};

get '/register' => sub {
	
	template 'register';
};

post '/register' => sub {
	
	my $username = params->{'username'};
	my $password = params->{'password'};

	my $db = schema('master');
	
	my $user_rs = $db->resultset("User");

	if ( $user_rs->search({ 'username' => $username })->count) {
		
		return template 'register' , { message => "Username already Exists" };
	}
	
	my $user = $user_rs->find_or_create( { 	username => $username, 
											password => $password, 
											question_id => params->{'question_id'} || 1,
											answer => params->{'answer'},
											first_name => params->{'first_name'},
											last_name => params->{'last_name'},
											company => params->{'company'}
									});
	my $name = params->{'name'};

	## send an email
	
	email {
            to => $username,
            subject => "Thank you for registering with Adhril",
            message => <<DATA
			
Thank you for registeration. You have regisereted using

Username : $username
Password : $password

Kindly visit /login to move further.

Adhril.

DATA
	};

	$user_rs->create({ username => $username, password => $password });

	template 'login';
};

get '/forgot_password' => sub {

	template 'forgot_password';
};


post '/forgot_password' => sub {
	
	my $db = schema('master');
	
	my $user_rs = $db->resultset("User");

	if ( $user_rs->search({ 'username' => params->{'username'} })->count) {
		
		my $user = $user_rs->search({ 'username' => params->{'username'} })->first;

		if ($user->question_id eq params->{'question_id'} && $user->answer eq params->{'answer'}) {
			
			$user->password(params->{'password'});

			$user->update;
			
			return template 'login', { message => 'Password changed successfully'};
		} else {

			return template 'forgot_password', { message => "Answer does not match ."  };
		}

	}else {
		
		return template 'forgot_password', { message => "No such user found."  };
	}
};



1;


