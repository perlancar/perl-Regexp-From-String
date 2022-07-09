package Regexp::From::String;

use strict;
use warnings;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(str_maybe_to_re str_to_re);

sub str_maybe_to_re {
    my $str = shift;
    if ($str =~ m!\A(?:/.*/|qr\(.*\))(?:[ims]*)\z!s) {
        my $re = eval(substr($str, 0, 2) eq 'qr' ? $str : "qr$str"); ## no critic: BuiltinFunctions::ProhibitStringyEval
        die if $@;
        return $re;
    }
    $str;
}

sub str_to_re {
    my $opts = ref $_[0] eq 'HASH' ? shift : {};
    my $str = shift;
    if ($str =~ m!\A(?:/.*/|qr\(.*\))(?:[ims]*)\z!s) {
        my $re = eval(substr($str, 0, 2) eq 'qr' ? $str : "qr$str"); ## no critic: BuiltinFunctions::ProhibitStringyEval
        die if $@;
        return $re;
    } else {
        $str = quotemeta($str);
        return $opts->{anchored} ?
            ($opts->{case_insensitive} ? qr/\A$str\z/i : qr/\A$str\z/) :
            ($opts->{case_insensitive} ? qr/$str/i     : qr/$str/);
    }
    $str;
}

1;
# ABSTRACT: Convert '/.../' or 'qr(...)' into Regexp object

=head1 SYNOPSIS

 use Regexp::From::String qw(str_maybe_to_re str_to_re);

 my $re1 = str_maybe_to_re('foo');        # stays as string 'foo'
 my $re2 = str_maybe_to_re('/foo');       # stays as string '/foo'
 my $re3 = str_maybe_to_re('/foo/');      # compiled to Regexp object qr(foo)
 my $re4 = str_maybe_to_re('qr(foo)i');   # compiled to Regexp object qr(foo)i
 my $re5 = str_maybe_to_re('qr(foo[)i');  # dies, invalid regex syntax

 my $re1 = str_to_re('foo');        # compiled to Regexp object qr(foo)
 my $re2 = str_to_re('/foo');       # compiled to Regexp object qr(/foo)
 my $re2 = str_to_re({case_insensitive=>1}, 'foo[]');  # compiled to Regexp object qr(foo\[\])i
 my $re2 = str_to_re({anchored=>1}, 'foo[]');          # compiled to Regexp object qr(\Afoo\[\]\z)
 my $re3 = str_to_re('/foo/');      # compiled to Regexp object qr(foo)
 my $re4 = str_to_re('qr(foo)i');   # compiled to Regexp object qr(foo)i
 my $re5 = str_to_re('qr(foo[)i');  # dies, invalid regex syntax


=head1 FUNCTIONS

=head2 str_maybe_to_re

Maybe convert string to Regexp object.

Usage:

 $str_or_re = str_maybe_to_re($str);

Check if string C<$str> is in the form of C</.../> or C<qr(...)'> and if so,
compile the inside regex (currently simply using stringy C<eval>) and return the
resulting Regexp object. Otherwise, will simply return the argument unmodified.

Will die if compilation fails, e.g. when the regexp syntax is invalid.

For the C<qr(...)> form, unlike in Perl, currently only the C<()> delimiter
characters are recognized and not others.

Optional modifiers C<i>, C<m>, and C<s> are currently allowed at the end.

=head2 str_to_re

Convert string to Regexp object.

Usage:

 $str_or_re = str_to_re([ \%opts , ] $str);

This function is similar to L</str_maybe_to_re> except that when string is not
in the form of C</.../> or C<qr(...)>, the string is C<quotemeta()>'ed then
converted to a Regexp object anyway. There are some options available to specify
in first argument hashref C<\%opts>:

=over

=item case_insensitive

Bool. If set to true will compile to Regexp object with C<i> regexp modifier.

=item anchored

Bool. If set to true will anchor the pattern with C<\A> and C<\z>.

=back


=head1 SEE ALSO

L<Sah::Schema::str_or_re>
