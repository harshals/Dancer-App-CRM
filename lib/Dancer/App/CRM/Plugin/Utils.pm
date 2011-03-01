
package Dancer::App::CRM::Plugin::Utils;


use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin;
use DBIx::Class;
use DBIx::Class::Schema::Loader;
DBIx::Class::Schema::Loader->naming('v7');

# ABSTRACT: custom schema class

my $my_schemas = {};

register my_schema => sub {
	
	my $schema = schema('db');


	return $schema;
};

register my_schema2 => sub {

	my $name = shift;
	
	my $application_id = session('app_id');

	die "The request path is " . request->path
		unless $application_id;

    return $my_schemas->{$application_id} if $my_schemas->{$application_id};

	my $application = schema('master')->resultset("Application")->find(session('app_id'));

	## borrow generic options of master db

	die "The generic schema for master db is not configured"
		unless $application->schema_class ;

	my $dbname = $application->db_name;
	
    my @conn_info =  ("dbi:SQLite:dbname=t/var/$dbname");
    
    my $db_prefix = setting('db_prefix');

    # pckg should be deprecated
    my $schema_class = "DB::" . $application->schema_class;

	$schema_class =~ s/-/::/g;
	eval "use $schema_class";
	if ( my $err = $@ ) {
			die "error while loading $schema_class : $err";
	}
	$my_schemas->{$application_id} = $schema_class->connect(@conn_info);

	return $my_schemas->{$application_id};
};

register_plugin;

1;

__END__
