#
#===============================================================================
#
#         FILE:  TestApp.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  02/14/2011 15:29:55 IST
#     REVISION:  ---
#===============================================================================

package TestApp;
use strict;
use warnings;

use Dancer qw(:syntax);

load_app 'Dancer::App::CRM';

get '/' => sub {
	
	return "Hello World";
};

get '/api/Book' => sub {
	
	return "Overridden !"
};

1;


