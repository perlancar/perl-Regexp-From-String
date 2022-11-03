package Regexp::From::String;

use strict;
use warnings;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(str_maybe_to_re str_to_re);

sub _str_maybe_to_re_or_to_re {
    my $which = shift;

    my $opts = ref $_[0] eq 'HASH' ? {%{shift()}} : {};
    my $opt_ci1 = delete($opts->{ci});
    my $opt_ci2 = delete $opts->{case_insensitive}; # so we delete both ci & this
    my $opt_ci  = defined $opt_ci1 ? $opt_ci1 : defined $opt_ci2 ? $opt_ci2 : 0;
    my $opt_always_quote = delete $opts->{always_quote};
    my $opt_anchored = delete $opts->{anchored}; $opt_anchored = 0 unless defined $opt_anchored;
    die "Unknown option(s): ".join(", ", sort keys %$opts) if keys %$opts;

    my $str = shift;

    if (!$opt_always_quote && $str =~ m!\A(?:/.*/|qr\(.*\))(?:[ims]*)\z!s) {
        my $code = "my \$re = " . (substr($str, 0, 2) eq 'qr' ? $str : "qr$str");
        $code .= "i" if $opt_ci;
        $code .= "; \$re = qr(\\A\$re\\z)" if $opt_anchored;
        #print "D: $code\n";
        my $re = eval $code; ## no critic: BuiltinFunctions::ProhibitStringyEval
        die if $@;
        return $re;
    } else {
        return $str if $which eq 'maybe_to';

        $str = quotemeta($str);
        my $re = $opt_anchored ?
            ($opt_ci ? qr/\A$str\z/i : qr/\A$str\z/) :
            ($opt_ci ? qr/$str/i     : qr/$str/);
        return $re;
    }
}

sub str_maybe_to_re {
    _str_maybe_to_re_or_to_re('maybe_to', @_);
}

sub str_to_re {
    _str_maybe_to_re_or_to_re('to', @_);
}

1;
# ABSTRACT: Convert '/.../' or 'qr(...)' into Regexp object

=head1 SYNOPSIS

 use Regexp::From::String qw(str_maybe_to_re str_to_re);

 my $re1 = str_maybe_to_re('foo.');       # stays as string 'foo.'
 my $re2 = str_maybe_to_re('/foo.');      # stays as string '/foo.'
 my $re3 = str_maybe_to_re('/foo./');     # compiled to Regexp object qr(foo.) (metacharacters are allowed)
 my $re4 = str_maybe_to_re('qr(foo.)i');  # compiled to Regexp object qr(foo.)i
 my $re5 = str_maybe_to_re('qr(foo[)i');  # dies, invalid regex syntax

 my $re1 = str_to_re('foo.');       # compiled to Regexp object qr(foo\.) (metacharacters are quoted)
 my $re2 = str_to_re('/foo.');      # compiled to Regexp object qr(/foo\.)
 my $re2 = str_to_re({case_insensitive=>1}, 'foo.');    # compiled to Regexp object qr(foo\.)i
 my $re2 = str_to_re({anchored=>1}, 'foo.');            # compiled to Regexp object qr(\Afoo\.\z)
 my $re3 = str_to_re('/foo./');     # compiled to Regexp object qr(foo) (metacharacters are allowed)
 my $re4 = str_to_re('qr(foo.)i');  # compiled to Regexp object qr(foo.)i
 my $re4 = str_to_re({always_quote=>1}, 'qr(foo.)');  # compiled to Regexp object qr(qr\(foo\.\)s) (the whole string is quotemeta'ed)
 my $re5 = str_to_re('qr(foo[)i');  # dies, invalid regex syntax


=head1 FUNCTIONS

=head2 str_maybe_to_re

Maybe convert string to Regexp object.

Usage:

 $str_or_re = str_maybe_to_re([ \%opts , ] $str);

Check if string C<$str> is in the form of C</.../> or C<qr(...)'> and if so,
compile the inside regex (currently simply using stringy C<eval>) and return the
resulting Regexp object. Otherwise, will simply return the argument unmodified.

Will die if compilation fails, e.g. when the regexp syntax is invalid.

For the C<qr(...)> form, unlike in Perl, currently only the C<()> delimiter
characters are recognized and not others.

Optional modifiers C<i>, C<m>, and C<s> are currently allowed at the end.

Recognize some options, see L</str_to_re> for more details.

=head2 str_to_re

Convert string to Regexp object.

Usage:

 $str_or_re = str_to_re([ \%opts , ] $str);

This function is similar to L</str_maybe_to_re> except that when string is not
in the form of C</.../> or C<qr(...)>, the string is C<quotemeta()>'ed then
converted to a Regexp object anyway. There are some options available to specify
in first argument hashref C<\%opts>:

=over

=item * always_quote

Bool. Default is false. If set to true then will always quote the whole string
regardless of whether the string is in the form of C</.../> or C<qr(...)>. This
means user will not be able to use metacharacters and the Regexp will only match
the literal string (with some option like anchoring and case-sensitivity, see
other options).

Defaults to false because the main point of this function is to allow specifying
regex.

=item * case_insensitive

Bool, default is false.

If set to true will compile to regexp with the /i modifier. This includes when
the string is in the form of C</.../> or C<qr(...)> (the /i is added).

=item * ci

Integer, alias for C<case_insensitive>.

=item * anchored

Bool. If set to true will anchor the pattern with C<\A> and C<\z>. This includes
when the string is in the form of C</.../> or C<qr(...)> (the regexp will be
enclosed with anchor).

=back


=head1 SEE ALSO

L<Sah::Schema::str_or_re>
