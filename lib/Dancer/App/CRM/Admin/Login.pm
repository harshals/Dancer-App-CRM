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

get '/register' => sub {
	
	template 'register';
};

post '/register' => sub {
	
	my $master = schema('master');
	my $user_rs = $master->resultset("User");

	## check if username exists or not
	
	if ($user_rs->search({'username' => params->{'username' } })->count) {
			
		template 'register' , { 'status'=> 0, 'message' => "username already exists" };
	}else {

	}

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
	my $user;

	if ( $user = $master->resultset('User')->authenticate({ request->params })) {
     	
        session "user_id" => $user->id;

		my $application = $user->application;
		
        session app_id => $application->id;
		
		session app_name => $application->name;
     			
        redirect flash('requested_path') || '/';

    } else {
        redirect '/login?failed=1';
    }

};

1;
