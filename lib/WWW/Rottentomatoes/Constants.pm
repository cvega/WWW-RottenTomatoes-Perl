package WWW::RottenTomatoes::Constants;

# method and param validation : 1 = required, 0 = optional
sub params {
    %hash = (
        box_office_movies     => { country => 0, limit => 0 },
        in_theatre_movies     => { country => 0, page  => 0, page_limit => 0 },
        opening_movies        => { country => 0, limit => 0 },
        upcoming_movies       => { country => 0, page  => 0, page_limit => 0 },
        top_dvd_rentals       => { country => 0, limit => 0 },
        current_dvd_releases  => { country => 0, page  => 0, page_limit => 0 },
        new_dvd_releases      => { country => 0, page  => 0, page_limit => 0 },
        upcoming_dvd_releases => { country => 0, page  => 0, page_limit => 0 },
        movies_info    => { id => 1 },
        movies_cast    => { id => 1 },
        movies_clips   => { id => 1 },
        movies_reviews => {
            id          => 1,
            review_type => 1,
            country     => 0,
            page        => 0,
            page_limit  => 0
        },
        movies_similar => { id => 1, limit => 0 },
        movies_alias   => { id => 1, type  => 1 },
        movies_search  => { q  => 1, page  => 0, page_limit => 0 },
        lists_directory       => {},
        movie_lists_directory => {},
        dvd_lists_directory   => {},
    );

    return %hash;
}

1;

__END__

=head1 NAME

WWW::RottenTomatoes::Constants

=head1 VERSION

Version 1.04

=head1 SYNPOSIS

    use WWW::RottenTomatoes::Constants;
    my %params = WWW::RottenTomatoes::Constants->params();

=head1 DESCRIPTION

This modules serves two purposes. The first purpose enables us the validate the
constructor parameters being passed to our methods exist, are properly named,
and defined properly if required. The second reason is because this module
enables me to describe the RESTful methods which will make updates incredibly
easy.

=head1 DIAGNOSTICS

N/A at the time of landing

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

B<WWW::RottenTomatoes>

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

=cut