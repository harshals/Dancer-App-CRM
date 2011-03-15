#
#===============================================================================
#
#         FILE:  Login.pm
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

package Dancer::App::CRM::Admin::Login;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::FlashMessage;

# ABSTRACT: Authentication & Authorization subroutines

before sub {
		
};

get '/logout' => sub {
	
	session $_ => '' foreach qw/user_id app_id app_name id/;

	template 'login';
};

get '/login' => sub {
		
	template 'login', { path => vars->{requested_path} };
};

post '/login' => sub {
	
	my $master = schema('master');

	$master->user(1);

	my $user;

	my $search = {
		username => params->{'username'},
		password => params->{'password'},
		application_id	 => config->{'app_id'}
	};

	if ( $user = $master->resultset('User')->authenticate($search)) {
     	
        session "user_id" => $user->id;

		my $application = $user->application;
		
        session app_id => $application->id;
		
		session app_name => $application->name;
     			
		session login_attempt => 0;
		
		session profile_id => $user->profile_id;
		
    	redirect flash('requested_path') || '/';

    } else {

		session login_attempt => session("login_attempt") + 1;

        template 'login' , { login_attempt => session("login_attempt") };
    }

};

get '/forgot_password' => sub {

	template 'forgot_password';
};


post '/forgot_password' => sub {
	
	my $db = schema('master');
	
	$db->user(1);

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
