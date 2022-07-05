package Regexp::From::String;

use strict;
use warnings;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(str_to_re);

sub str_to_re {
    my $str = shift;
    if ($str =~ m!\A(?:/.*/|qr\(.*\))(?:[ims]*)\z!s) {
        my $re = eval(substr($str, 0, 2) eq 'qr' ? $str : "qr$str");
        die if $@;
        return $re;
    }
    $str;
}

1;
# ABSTRACT: Convert '/.../' or 'qr(...)' into Regexp object

=head1 SYNOPSIS

 use Regexp::From::String qw(str_to_re);

 my $re1 = str_to_re('foo');       # stays as string 'foo'
 my $re2 = str_to_re('/foo');      # ditto
 my $re3 = str_to_re('/foo/');     # compiled to Regexp object qr(foo)
 my $re4 = str_to_re('qr(foo)i');  # compiled to Regexp object qr(foo)i
 my $re5 = str_to_re('qr(foo[)i'); # dies, invalid regex syntax


=head1 FUNCTIONS

=head2 str_to_re

Usage:

 $str_or_re = str_to_re($str);

Check if string C<$str> is in the form of C</.../> or C<qr(...)'> and if so,
compile the inside regex (currently simply using stringy C<eval>) and return the
resulting Regexp object. Otherwise, will simply return the argument unmodified.

Will die if compilation fails, e.g. when the regexp syntax is invalid.

For the C<qr(...)> form, unlike in Perl, currently only the C<()> delimiter
characters are recognized and not others.

Optional modifiers C<i>, C<m>, and C<s> are currently allowed at the end.


=head1 SEE ALSO

L<Sah::Schema::str_or_re>
