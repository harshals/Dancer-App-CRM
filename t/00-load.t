#
#===============================================================================
#
#         FILE:  00-load.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  02/14/2011 14:57:55 IST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More ;

use_ok("Dancer::App::CRM");
use_ok("Dancer::App::CRM::Admin::Init");
use_ok("Dancer::App::CRM::Plugin::DBIC");
use_ok("Dancer::App::CRM::Admin::Login");
use_ok("Dancer::App::CRM::Base");

done_testing;




