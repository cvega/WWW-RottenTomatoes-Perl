package WWW::RottenTomatoes;

use URI::Escape;
use Carp qw{croak};
use base qw{LWP::UserAgent};
use JSON;

our $VERSION = "1.004"; $VERSION = eval $VERSION;

sub new {
    my ( $class, %opts ) = @_;

    if ( !$opts{token} ) {
        croak "method 'new' requires a valid token(key)";
    }

    my $self = $class->SUPER::new;
    $self{token} = $opts{token};
    $self{valid} = 'true' unless $self{valid} = 'false';
    $self{host}  = 'http://api.rottentomatoes.com/api/public/v1.0';
    $self->agent("perl-WWW-RottenTomatoes/$VERSION");

    return bless $self, $class;
}

sub DESTROY { }

sub AUTOLOAD {
    my ( $self, %opts ) = @_;
    my $name = our $AUTOLOAD;
    $name =~ s/.*://;

    # parameter validation (on by default)
    if ( $self{valid} eq 'true' ) {

        use WWW::RottenTomatoes::Constants;
        my %params = WWW::RottenTomatoes::Constants->params;

        # validate method name exists
        croak "$name is not a valid method name"
          unless exists $params{$name};

        # validate option name exists
        foreach my $opt ( keys %opts ) {
            croak "$opt is not a valid method parameter"
              unless exists $params{$name}{$opt};
        }

        # validate required option(s) exist, and not empty
        foreach my $req ( keys %{ $params{$name} } ) {
            next if $name !~ m/^movies_/;
            if ( $params{$name}{$req} == 1 ) {
                croak "$req is a required method parameter"
                  unless defined $opts{$req} && length $opts{$req};
            }
        }
    }

    # begin to build url based on end points (movie, DVD, info, lists)
    my $url;
    if ( $name =~ m/^.*_movies$/ ) {
        $name =~ s/_movies//;
        $url  = "/lists/movies/$name.json";
    }
    elsif ( $name =~ m/^.*_dvd_.*$/ ) {
        $name =~ s/_dvd_//;
        if ( $name =~ m/^upcoming/ ) {
            $url = '/lists/DVDs/upcoming.json';
        }
        else {
            $url = "/lists/DVDs/$name.json";
        }
    }
    elsif ( $name =~ m/^movies_.*$/ ) {
        $name =~ s/^movies_//;
        if ( $name eq 'search' ) {
            $url = '/movies.json';
        }
        elsif ( $name eq 'alias' ) {
            $url = '/movie_alias.json';
        }
        elsif ( $name eq 'info' ) {
            $url = "/movies/$opts{movie_id}.json";
        }
        else {
            $url = "/movies/$opts{movie_id}/$name.json";
        }
    }
    else {
        $name = s/_.*//;
        if ( $name eq 'lists' ) {
            $url = '/lists.json';
        }
        else {
            $url = "/lists/$name.json";
        }
    }

    # continue to build and add key/values pairs to url
    $url = $self{host} . $url . "?apikey=$self{token}";
    while ( my ( $key, $value ) = each(%opts) ) {
        if ( $key eq 'q' ) {
            $value = uri_escape($value);
        }

        $url .= "&$key=$value";
    }

    # url complete, make http request. report accordingly
    my $response = $self->get($url);
    if ( $response->is_success ) {
        return eval { decode_json $response->decoded_content };
    }
    else {
        croak "error: $response->status_line";
    }
}

1;

__END__

=head1 NAME

WWW::RottenTomatoes - A Perl interface to the Rotten Tomatoes API

=head1 VERSION

Version 1.04

=head1 SYNPOSIS

    use WWW::RottenTomatoes;

    my $rt = WWW::RottenTomatoes->new(
        token => 'f@k3ap!tok3n',
        valid => 'false'
    );

    $rt->movies_search( q => 'The Goonies' );

=head1 DESCRIPTION

This module is intended to provide an interface between Perl and the Rotten
Tomatoes JSON API. The Rotten Tomatoes API is a RESTful web service. In order
to use this library you must provide an api key which requires registration.
For more information please see http://developer.rottentomatoes.com

=head1 CONSTRUCTOR

=head2 new()

Creates and returns a new WWW::RottenTomatoes object

    my $rt = WWW::RottenTomatoes->new()

=over 4

=item * C<< token => [<token>] >>

The token parameter is required. You must provide a valid token/key.

=item * C<< valid => [true] >>

This parameter allows you to turn off parameter checking. It currently defaults
to 'true' and must be set to 'false' in order to be disabled. The validator
checks for method name, method constructor name, and the required constructors
of the given method. The validator will also ensure required constructors are
not blank or empty. The validator does not check type.

=back

=head1 SUBROUTINES/METHODS

The following subroutine/methods documentation corresponds with the official
api documentation.

=head2 $obj->box_office_movies(...)

Displays top box office earning movies, sorted by most recent weekend gross
ticket sales

    $obj->box_office_movies(
        limit   => 5,
        country => 'uk'
    );

* B< limit > S< integer, required: false, default: 16>

Limits the number of box office movies returned

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->in_theatre_movies(...)

Retrieves movies currently in theaters

    $obj->in_theatre_movies(
        page_limit => 10,
        page       => 5,
        country    => 'ca'
    );

* B< page_limit > S< integer, required: false, default: 16>

The amount of movies in theaters to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of in theaters movies

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->opening_movies(...)

Retrieves current opening movies

    $obj->opening_movies(
        limit   => 5,
        country => 'mx'
    );

* B< limit > S< integer, required: false, default: 16>

Limits the number of opening movies returned

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->upcoming_movies(...)

Retrieves upcoming movies. Results are paginated if they go past the specified
page limit

    $obj->upcoming_movies(
        page_limit => 5,
        page       => 2,
        country    => 'br'
    );

* B< page_limit > S< integer, required: false, default: 16>

The amount of upcoming movies to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of in theaters movies

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->top_dvd_rentals(...)

Retrieves the current top DVD rentals

    $obj->top_dvd_rentals(
        limit   => 5,
        country => 'au'
    );

* B< limit > S< integer, required: false, default: 10>

Limits the number of top rentals returned

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->current_dvd_releases(...)

Retrieves current release DVDs. Results are paginated if they go past the
specified page limit

    $obj->current_dvd_releases(
        page_limit => 3,
        page       => 1,
        country    => 'in'
    );

* B< page_limit > S< integer, required: false, default: 16>

The amount of current release DVDs to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of current DVD releases

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->new_dvd_releases(...)

Retrieves new release DVDs. Results are paginated if they go past the specified
page limit.

    $obj->new_dvd_releases(
        page_limit => 1,
        page       => 5,
        country    => 'cn'
    );

* B< page_limit > S< integer, required: false, default: 16>

The amount of new release DVDs to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of new DVD releases

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->upcoming_dvd_releases(...)

Retrieves upcoming dvds. Results are paginated if they go past the specified
page limit

    $obj->upcoming_dvd_releases(
        page_limit => 20,
        page       => 7,
        country    => 'jp'
    );

* B< page_limit > S< integer, required: false, default: 16>

The amount of upcoming DVDs to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of upcoming DVD releases

* B< country > S< string, required: false, default: "us">

Provides localized data for the selected country (ISO 3166-1 alpha-2) if
available. Otherwise, returns US data

=head2 $obj->movies_info(...)

Detailed information on a specific movie specified by Id. You can use the
movies search endpoint or peruse the lists of movies/dvds to get the urls to
movies.

    $obj->movies_info( id => 770672122 );

* B< id > S< integer, required: true>

The movie identification number

=head2 $obj->movies_cast(...)

Pulls the complete movie cast for a movie

    $obj->movies_cast( id => 770672122 );

* B< id > S< integer, required: true>

The movie identification number

=head2 $obj->movies_clips(...)

Related movie clips and trailers for a movie

    $obj->movies_clips( id => 770672122 );

* B< id > S< integer, required: true>

The movie identification number

=head2 $obj->movies_reviews(...)

Retrieves the reviews for a movie. Results are paginated if they go past the
specified page limit

    $obj->movie_reviews(
        id          => 770672122,
        review_type => 'dvd',
        page_limit  => 1,
        page        => 5,
        country     => 'us'
    );

* B< id > S< integer, required: true>

The movie identification number

* B< review_type > S< string, required: false, default: top_critic>

3 different review types are possible: "all", "top_critic" and  "dvd".
"top_critic" shows all the Rotten "top_critic" shows all the Rotten. "dvd"
pulls the reviews given on the DVD of the movie. "all" as the name implies
retrieves all reviews

* B< page_limit > S< integer, required: false, default: 20>

The amount of movie reviews to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of movie reviews

* B< country > S< string, required: false, default: "us">

provides localized data for selected country (ISO 3166-1 alpha-2)

=head2 $obj->movies_similar(...)

Shows similar movies for a movie.

    $obj->movies_similar(
        id    => 770672122,
        limit => 1,
    );

* B< id > S< integer, required: true>

The movie identification number

* B< limit > S< integer, required: false, default: 5>

Limit the number of similar movies to show

=head2 $obj->movies_alias(...)

Provides a movie lookup by an id from a different vendor. Only supports imdb
lookup at this time

    $obj->movies_alias  (
        id   => 9818,
        type => 'imdb',
    );

* B< id > S< integer, required: true>

The movie identification number

* B< type > S< string, required: true>

alias type you want to look up - only imdb is supported at this time

=head2 $obj->movies_search(...)

The movies search endpoint for plain text queries. Allows you to search for
movies!

    $obj->movies_search(
        q          => 'The Goonies'
        page_limit => 20,
        page       => 7,
    );

* B< q > S< string, required: true>

The plain text search query to search for a movie (url encoded for you)

* B< page_limit > S< integer, required: false, default: 30>

The amount of upcoming DVDs to show per page

* B< page > S< integer, required: false, default: 1>

The selected page of upcoming DVD releases

=head2 $obj->lists_directory

Displays the top level lists available in the API. Currently movie lists and
dvd lists available

    $obj->lists_directory;

no parameters required

=head2 $obj->movie_lists_directory

Shows the movie lists vailable

    $obj->movie_lists_directory;

no parameters required

=head2 $obj->dvd_lists_directory

Shows the DVD lists available

    $obj->dvd_list_directory;

no parameters required

=head1 DIAGNOSTICS

N/A at the current point in time

=head1 CONFIGURATION AND ENVIRONMENT

This package does not make usage of any code or modules considered OS specific
and no special configuration and or configuration files are needed. In order to
use this package you must provide an api token/key and be able to reach the
Rotten Tomatoes API url.

=head1 INCOMPATIBILITIES

This package is intended to be compatible with Perl 5.008 and beyond.

=head1 BUGS AND LIMITATIONS

Current limitations exist in the amount of http requests that can be made
against the API. The scope of this limitation exists outside of the code base.

=head1 DEPENDENCIES

B<Carp>, B<JSON>, B<LWP::UserAgent>, B<URI::Escape>

=head1 SEE ALSO

B<http://developer.rottentomatoes.com/docs>

You may notice differences in the required parameters of this script and the
documentation. The differences are typically stop gaps to prevent the API from
returning with errors and or empty/wrong results.

This is present in methods that require movie id's and the search method which
requires a plain text query.

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
