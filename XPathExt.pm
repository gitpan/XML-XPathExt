
package XML::XPathExt;

use strict;
use vars qw($VERSION $hasXSLT $hasXPCtx);
$VERSION = '0.01_01';

eval 'use XML::LibXSLT; $hasXSLT = 1;';
eval 'use XML::XPathContext; $hasXPCtx = 1;';

sub import {
    if ($hasXSLT) {
        my $pkg = caller;
        no strict 'refs';
        for my $prms (@{$pkg . '::EXTENSIONS'}) {
            XML::LibXSLT->register_function(@$prms);
        }
        return 1;
    }
}

sub registerOnContext {
    die "This method require XML::XPathContext" unless $hasXPCtx;
    my $class = shift;
    my $ctx = shift;
    for my $prms (@{$class . '::EXTENSIONS'}) {
      $ctx->registerFunctionNS(@$prms);
    }
}

1;

1;

=pod

=head1 NAME

XML::XPathExt - Common XPath extension framework

=head1 SYNOPSIS

  package XML::XPathExt::MyCoolExtension;
  use base 'XML::XPathExt';

  my $ns = "http://perl-xml-rocks.org/java-xml-sucks/";
  our @EXTENSIONS = ( [ $ns, 'func1', \&my_func1 ],
                      [ $ns, 'func2', \&my_func2 ],
                      [ $ns, 'func3', \&my_func3 ],);

   # your functions...

=head1 WARNING, HEY, WARNING, YES YOU

THIS IS EVEN BEFORE AN ALPHA, IT IS A PROOF OF CONCEPT THAT HAS NOT BEEN
TESTED.

SURGEON GENERAL WARNING: SMOKING PRE-ALPHA MODULES IN PRODUCTION MAY
ENSURE JOB SECURITY OF CONSULTANTS.

USING THIS YOU ARE IN THE DARK, YOU MAY BE EATEN BY A GRUE.

=head1 DESCRIPTION

This is a simple module, the goal of which is to help make XPath extensions
consistent in such a way that they work with both XML::LibXSLT and XML::XPathContext.

I would very much like to support other modules, but that will require more work
(mostly around having factory methods that do the right thing to convert to the
right objects, which is simple enough but long -- patches welcome).

Your modules implementing XPath extensions should inherit from this class. It will
do two things for them: if c<XML::LibXSLT> is present, when your class is loaded its
extensions will be registered automatically; and you will inherit a C<registerOnContext>
method that when called with an C<XML::XPathContext> context object will register all
your extensions on it (it can't be done automatically as for C<XML::LibXSLT> because
and instance of the class is required).

There's a special variable that should exist and be publically available in your 
package called C<@EXTENSIONS>. It is an array containing arrayrefs. The synopsis
should be pretty clear (hopefully) but in case it is not, each of those arrayrefs
contains three items: the namespace URI, the name of the extension function, and
a reference to its Perl implementation. Behaviour of extension functions with no
defined namespace is not guaranteed and even if it works for you it may very well
blow up in other cases. So it is quite a bad idea to not use a namespace.

=head1 GRATUITOUS PONTIFICATING

It is recommended that your extension modules be under the C<XML::XPathExt::*> hierarchy,
though of course if you have good reasons to put them elsewhere you are totally free
to do as you wish.

It is also B<STRONGLY> recommended that the namespace you choose for your extensions
be an C<http:> URI, and not something much harder to retrieve such as a URN. The reason
for this is that in the close future (as of this writing, in August 2003) it is likely 
that the W3C will publish a Note on RDDL indicating documents to be put at the end of
a namespace URI. Interesting things that could be useful for this module could be
discovered through such a mechanism, using the C<XML::RDDL> module.

Also, if you wish to make your namespace URIs easy to remember for your users, I suggest
you use the form C<http://xmlns.perl.org/xpath/MyExtension/> where C<MyExtension> matches 
the one in C<XML::XPathExt::MyExtension>. The C<xmlns.perl.org> has already been registered
with the perl.org admin (thanks!) and should RDDL be published then a corresponding server
will be made available to the community shortly thereafter to simply RDDL publishing.

=head1 AUTHOR

Robin Berjon, E<lt>robin.berjon@expway.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Robin Berjon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
