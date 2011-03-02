package Dancer::App::CRM::Base;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::FlashMessage;
use Dancer::Plugin::Memcached;
use Data::Dumper;
use Plack::Middleware::Debug::DBIC::QueryLog;
use Jemplate::Runtime;
use File::Find::Rule;


use Dancer::App::CRM::Plugin::Utils;

our $VERSION = '0.1';

# ABSTRACT: Base class for database routes 

## index method, simply list 


load_app 'Dancer::App::CRM::Admin::Login';
load_app 'Dancer::App::CRM::Admin::Init';

#setting 'apphandler' => 'PSGI';

#set serializer => 'JSON';

sub authenticate {

	my $app_id = shift;
	debug "Authenticate $app_id :" . request->path_info ;
	
	if (request->path_info !~ m{^/(login|init)}) {
		
		if (!session('user_id') || session('app_id') ne $app_id) {

			flash requested_path => request->path_info;
			request->path_info('/login');

		} else {

			## check to connect to right schema 

			my $schema = my_schema;       

			$schema->init_debugger(request->env->{+Plack::Middleware::Debug::DBIC::QueryLog::PSGI_KEY});

			if (exists request->params->{model}) {

				my $sources = join(',', $schema->sources);
				my $model = request->params->{'model'};

				unless ( $sources =~ m/$model/) {

					send_error("model [ $model ] cannot be found");
				}
			}

		}

	}else {

		## do something if login or logout is accessed

	}

}

before sub {
	
	var serialize_options => [
	
		request->params->{_s} || 8, ## serializer option no.
		request->params->{_ik} || undef ## serializer index key
	];
	
	var search_attributes => {

	 	page 	=> 	request->params->{_p} || undef , ## page_no
	 	rows	 => request->params->{_pl} || 10,
	 	order_by => request->params->{_ob} || undef  ## order by
	};
	
	my $schema = my_schema;

	$schema->user(1);
	$schema->debug(1);
	$schema->env(request->env);
	#$schema->init_debugger(request->env->{+Plack::Middleware::Debug::DBIC::QueryLog::PSGI_KEY});
	return 1 if config->{skip_authentication};

	my $app_id = request->params->{'app_id'};
	
	return send_error("Application ID cannot be found") unless $app_id;	

	&authenticate($app_id);
	
	
};


## get list of all items


any '/api/:model' => sub {

    my $model = request->params->{'model'};
	my $schema = my_schema;

	return { data => $schema->resultset($model)	->look_for(undef, vars->{search_attributes})
												->from_cgi_params(request->params->{$model})
												->serialize(@{ vars->{serialize_options} } ) , message => "" };
	
};

## predefined or saved search

get '/api/:model/search/:search_id' => sub {
	

    my $model = request->params->{'model'};
	my $schema = my_schema;
	my $search_id = request->params->{'search_id'};


	return { data => $schema->resultset($model)	->look_for
												->serialize(@{ vars->{serialize_options} } ) , message => "" };
};


## fire custom queries

get '/api/:model/custom/:query' => sub {

	my $model = request->params->{'model'};
	my $schema = my_schema;
	
	my $query = request->params->{'query'};

	if ($schema->resultset($model)->can($query)) {

		return { data => $schema->resultset($model)	->look_for(undef, vars->{search_attributes})
													->$query(request->params->{$model})
													->serialize(@{ vars->{serialize_options} } ) , message => "" };
	}else {
		
		send_error("Unkown query > $query ");
	}
	
};

#get single item

get '/api/:model/:id' => sub {

    my $model = request->params->{'model'};
	my $id = request->params->{'id'};
	my $schema = my_schema;

	#my $schema = my_schema('db');
	
	my $row = ($id eq 'new' ) ? $schema->resultset($model)->fetch_new() :$schema->resultset($model)->fetch($id);

	return { data => $row->serialize(@{ vars->{serialize_options} } ), message => "" };
	
};

# update single item

post '/api/:model/:id' => sub {
	
	my $model = request->params->{'model'};
	my $id = request->params->{'id'};
	my $schema = my_schema;
	
	my $row = $schema->resultset($model)->fetch($id);

	return ( { data => {}, error => "row not found" }) unless $row;

	$row->save(request->params->{$model});
	
	return { data => $row->serialize(@{ vars->{serialize_options} } ), message => '' };
};

# delete a single item
del '/api/:model/:id' => sub {
	
	my $model = request->params->{'model'};
	my $id = request->params->{'id'};
	my $schema = my_schema;
	
	my $row = $schema->resultset($model)->fetch($id);

	return ( { data => {}, error => "row not found" }) unless $row;

	$row->remove;
	
	return { data => $row->serialize(@{ vars->{serialize_options} } ), message => 'Object Deleted' };
};


# create new item

put '/api/:model' => sub {
	
	my $model = request->params->{'model'};
	my $id = request->params->{'id'};
	my $schema = my_schema;
	
	my $row = $schema->resultset($model)->fetch_new;

	return ( { data => {}, error => "row not found" }) unless $row;

	$row->save(request->params->{$model});
	
	return { data => $row->serialize(@{ vars->{serialize_options} } ), message => '' };
};


any 'error' => sub {
	
	my $schema = my_schema;
	my $error = Dancer::Error->new(
       	code    => 501,
       	message => vars->{error}
   	);
   	$error->render;
};


after sub {
	
	my $response = shift;
	
	#debug Dumper($response);
};


true;

