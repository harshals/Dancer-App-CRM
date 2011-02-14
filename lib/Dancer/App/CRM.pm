package Dancer::App::CRM;

use Dancer ':syntax';


our $VERSION = '0.1';

## index method, simply list 

load_app 'Dancer::App::CRM::Base';

#setting 'apphandler' => 'PSGI';

#set serializer => 'JSON';

true;

