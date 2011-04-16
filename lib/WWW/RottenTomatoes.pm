package WWW::RottenTomatoes;

use URI::Escape;
use Carp qw{croak};
	
use base qw{REST::Client};

our $VERSION = 0.01;

sub new {
    my ( $class, %args ) = @_;

    my $self = $class->SUPER::new(
	host => 'http://api.rottentomatoes.com/api/public/v1.0'
    );
    $self->getUseragent()->agent("perl-WWW-RottenTomatoes/$VERSION");

    bless $self, $class;

    # pass params to object
    for my $key ( keys %args ) {
        $self->{$key} = $args{$key};
    } 

    $self->{params} = '.json?apikey=' . $self->{api_key};
    if ( $self->{pretty_print} eq 'true') {
        $self->{params} .= '&_prettyprint=' . $self->{pretty_print};
    }

    return $self;
}

sub movies_search {
    my ( $self, %args ) = @_;

    if ( !$args{query} ) {
        croak 'movie_search method requires a "query" parameter'
    }

    if ( $args{query} ) { 
        $self->{params} .= '&q=' . uri_escape( $args{query} );
    }
    if ( $args{page} ) {
        $self->{params} .= '&page=' . $args{page};
    }
    if ( $args{page_limit} ) {
        $self->{params} .= '&page_limit=' . $args{page_limit};
    }

    $self->GET( '/movies' . $self->{params} );

    return $self->responseContent;
}

sub lists_directory {
    my ( $self ) = @_;

    $self->GET( '/lists' . $self->{params} );

    return $self->responseContent;
}

sub movie_lists_directory {
    my ( $self ) = @_;

    $self->GET( '/lists/movies' . $self->{params} );

    return $self->responseContent;
}

sub dvd_lists_directory {
    my ( $self ) = @_;

    $self->GET( '/lists/dvds' . $self->{params} );

    return $self->responseContent;
}

sub opening_movies {
    my ( $self, %args ) = @_;

    if ( $args{limit} ) {
        $self->{params} .= '&limit=' . $args{limit};
    }
    if ( $args{country} ) {
        $self->{params} .= '&country=' . $args{country};
    }

    $self->GET( '/lists/movies/opening' . $self->{params} );

    return $self->responseContent;
}

sub upcoming_movies {
    my ( $self, %args ) = @_;

    if ( $args{country} ) {
        $self->{params} .= '&country=' . $args{country};
    }
    if ( $args{page} ) { 
         $self->{params} .= '&page=' . $args{page};
    }
    if ( $args{page_limit} ) {
         $self->{params} .= '&page_limit=' . $args{page_limit};
    }

    $self->GET( '/lists/movies/upcoming' . $self->{params} );

    return $self->responseContent;
}

sub new_release_dvds {
    my ( $self, %args ) = @_;

    if ( $args{country} ) {
	$self->{params} .= '&country=' . $args{country};
    }
    if ( $args{page} ) {
	$self->{params} .= '&page=' . $args{page};
    }
    if ( $args{page_limit} ) {
        $self->{params} .= '&page_limit=' . $args{page_limit};
    }

    $self->GET( '/lists/dvds/new_releases' . $self->{params} );

    return $self->responseContent;
}

sub movie_info {
    my ( $self, %args ) = @_;

    if ( !$args{movie_id} ) {
        croak 'movie_info method requires a "movie_id" parameter'
    }

    $self->GET( "/movies/$args{movie_id}" . $self->{params} );

    return $self->responseContent;
}

sub movie_cast {
    my ( $self, %args ) = @_;

    if ( !$args{movie_id} ) {
        croak 'movie_cast method requires a "movie_id" parameter'
    }

    $self->GET( 
	"/movies/$args{movie_id}/cast" . $self->{params} );

    return $self->responseContent;
}

sub movie_reviews {
    my ( $self, %args ) = @_;

    if ( !$args{movie_id} ) {
        croak 'movie_reviews method requires a "movie_id" parameter';
    }

    if ( $args{review_type} ) {
	$self->{params} .= '&review_type=' . $args{review_type};
    }
    if ( $args{country} ) {
	$self->{params} .= '&country=' . $args{country};
    }
    if ( $args{page} ) {
	$self->{params} .= '&page=' . $args{page};
    }
    if ( $args{page_limit} ) {
	$self->{params} .= '&page_limit=' . $args{page_limit};
    }

    $self->GET( "/movies/$args{movie_id}/reviews" . $self->{params} );

    return $self->responseContent;
}

sub in_theatre_movies {
    my ( $self, %args ) = @_;

    if ( $args{country} ) {
        $self->{params} .= '&country=' . $args{country};
    }
    if ( $args{page} ) {
        $self->{params} .= '&page=' . $args{page};
    }
    if ( $args{page_limit} ) {
        $self->{params} .= '&page_limit=' . $args{page_limit};
    }

    $self->GET( '/lists/movies/in_theaters' . $self->{params} );

    return $self->responseContent;
}

sub callback {
    my ( $self, %args ) = @_;

    if ( !$args{callback_fn} ) {
        croak 'callback method requires a "callback_fn" parameter';
    }

    $self->{params} .= '&callback=' . $args{callback_fn};

    $self->GET( $self->{params} );

    return $self->responseContent;
}

1;

__END__

=head1 NAME

WWW::RottenTomatoes - A Perl interface to the Rotten Tomatoes API

=head1 VERSION

Version 0.01

=head1 SYNPOSIS

use WWW::RottenTomatoes;

my $api = WWW::RottenTomatoes->new(
    api_key      => 'your_api_key',
    pretty_print => 'true'
);

$api->movies_search( query => 'The Goonies' );

=head1 DESCRIPTION

This module is intended to provide an interface between Perl and the Rotten
Tomatoes JSON API. The Rotten Tomatoes API is a RESTful web service. In order
to use this library you must provide an api key which requires registration.
For more information please see Http://dev.rottentomatoes.com    

=head1 CONSTRUCTOR

=over

=item C<< new() >>

Creates and returns a new object

my $api= WWW::RottenTomatoes->new()

=item * C<< api_key => [your_api_key] >>

The api_key parameter is required. You must provide a valid key.

=item * C<< pretty_print => [true|false} >>

This parameter allows you to enable the pretty print function of the API. By
default this parameter is set to false meaning you do not have to specify the
parameter unless you intent to set it to true. This parameter is optional.

=back

=head1 SUBROUTINES/METHODS

=over

=item C<< $obj->movies_search(\%args) >>

The movies search endpoint for plain text queries

* C<< query >> (plain text search query)

string, required: true

* C<< page_limit >> (The amount of movie search results to show per page)

integer, required: false, default: 30

* C<< page >> (The selected page of movie search results)

integer, required: false, default: 1

=item C<< $obj->lists_directory >>

Displays the top level lists available in the API

* no parameters required

=item C<< $obj->movie_lists_directory >>

Shows the movie lists we have available

* no parameters required

=item C<< $obj->dvd_lists_directory >>

Shows the DVD lists we have available

* no parameters required

=item C<< $obj->opening_movies(\%args) >>

Retrieves current opening movies

* limit (limits number of movies returned)

integer, required: false, default: 16

* country (provides localized data for selected country (ISO 3166-1 alpha-2)

string, required: false, default: "us"

=item C<< $obj->upcoming_movies(\%args) >>

Retrieves upcoming movies

* page_limit (The amount of new release dvds to show per page)

integer, required: false, default: 16

* page (The selected page of upcoming movies)

integer, required: false, default: 1

* country (provides localized data for selected country (ISO 3166-1 alpha-2)

string, required: false, default: "us"

=item C<< $obj->new_release_dvds(\%args) >>

Retrieves new release dvds

* page_limit (The amount of new release dvds to show per page)

integer, required: false, default: 16

* page (The selected page of upcoming movies)

integer, required: false, default: 1

* country (provides localized data for selected country (ISO 3166-1 alpha-2)

string, required: false, default: "us"

=item C<< $obj->movie_info(\%args) >>

Detailed information on a specific movie specified by Id. You can use the movies
search endpoint or peruse the lists of movies/dvds to get the urls to movies.

* no parameters required

=item C<< $obj->movie_cast >>

Pulls the complete movie cast for a movie

* no parameters required

=item C<< $obj->movie_reviews(\%args) >>

Retrieves the reviews for a movie. Results are paginated if they go past the
specified page limit

* review_type (3 different review types are possible: "all", "top_critic" and 
"dvd". "top_critic" shows all the Rotten "top_critic" shows all the Rotten.
"dvd" pulls the reviews given on the DVD of the movie. "all" as the name implies
retrieves all reviews

string, required: false, default: top_critic

* page_limit (The amount of new release dvds to show per page)

integer, required: false, default: 16

* page (The selected page of upcoming movies)

integer, required: false, default: 1

* country (provides localized data for selected country (ISO 3166-1 alpha-2)

string, required: false, default: "us"

=item C<< $obj->in_theatre_movies(\%args) >>

Retrieves movies currently in theaters

* page_limit (The amount of new release dvds to show per page)

integer, required: false, default: 16

* page (The selected page of upcoming movies)

integer, required: false, default: 1

* country (provides localized data for selected country (ISO 3166-1 alpha-2)

string, required: false, default: "us"

=item C<< $obj->callback(\%args) >>

* callback_fn (The API supports JSONP calls. Simply append a callback parameter
with the name of your callback method at the end of the request. 

=back

=head1 DIAGNOSTICS 

N/A at the current point in time

=head1 CONFIGURATION AND ENVIRONMENT

This package has only been tested in a 64bit Unix (OSX) environment however
it does not make usage of any code or modules considered OS specific and no
special configuration or configuration files are needed. 

=head1 INCOMPATIBILITIES

This package is intended to be compatible with Perl 5.008 and beyond.

=head1 BUGS AND LIMITATIONS

Current limitations exist in the amount of http requests that can be made
against the API. The scope of this limitation exists outside of the code base.

=head1 DEPENDENCIES

B<REST::Client>, B<URI::Escape>

=head1 SEE ALSO

B<http://developer.rottentomatoes.com/docs>

You may notice differences in the required parameters of this script and the
documentation. Take for instance the C<< movies_search >>. In order to search
for a movie you must provide a query parameter.

=head1 SUPPORT

The module is provided free of support however feel free to contact the
author or current maintainer with questions, bug reports, and patches.

Considerations will be taken when making changes to the API. Any changes to
its interface will go through at the least one deprecation cycle.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 Casey W. Vega.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but without
any warranty; without even the implied warranty of merchantability or
fitness for a particular purpose.

=head1 Author

Casey Vega <cvega@cpan.org>

=cut
