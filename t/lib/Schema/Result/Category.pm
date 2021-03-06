package Schema::Result::Category;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
extends qw/DBICx::Hybrid::Result/;

__PACKAGE__->table("category");
__PACKAGE__->add_columns(

		"category", { data_type => "VARCHAR(100)", is_nullable => 0 },
);

__PACKAGE__->add_base_columns;

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint([qw/category/]);

__PACKAGE__->has_many(
  "author_category",
  "Schema::Result::AuthorCategories",
  { "foreign.category_id" => "self.id" },
);

__PACKAGE__->many_to_many( "authors" => "author_category", "author");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-13 21:11:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:obZUGgvkve3e6mzPk8GEEg

sub extra_columns {
    
    my $self = shift;

    return qw//;
};
# You can replace this text with custom content, and it will be preserved on regeneration


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
