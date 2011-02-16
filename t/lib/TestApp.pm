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

before sub {
	
	var search_attributes => {

	 	page 	=> 	request->params->{_p} || undef , ## page_no
	 	rows	 => request->params->{_pl} || 10,
	 	order_by => request->params->{_ob} || undef  ## order by
	};
	var serialize_options => [
	
		request->params->{_s} || 8, ## serializer option no.
		request->params->{_ik} || undef ## serializer index key
	];


};

get '/' => sub {
	
	return "Hello World";
};

get '/debug' => sub {
	
	return { data =>    vars->{serialize_options}   };
};

1;


