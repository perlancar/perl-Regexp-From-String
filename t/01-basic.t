#!perl

use strict;
use warnings;
use Test::Exception;
use Test::More 0.98;

use Regexp::From::String qw(str_maybe_to_re str_to_re);

subtest str_maybe_to_re => sub {
    dies_ok { str_maybe_to_re({foo=>1}, 'bar') } 'unknown option -> dies';

    is_deeply(str_maybe_to_re('foo'), 'foo');
    is_deeply(str_maybe_to_re('/foo'), '/foo');
    is_deeply(str_maybe_to_re('qr(foo'), 'qr(foo');
    is_deeply(str_maybe_to_re('qr|foo|'), 'qr|foo|');
    is_deeply(str_maybe_to_re('qr(foo)x'), 'qr(foo)x');

    is_deeply(str_maybe_to_re('/foo./'), qr(foo.));
    is_deeply(str_maybe_to_re('qr(foo.)i'), qr(foo.)i);

    is_deeply(str_maybe_to_re({ci=>1}, '/foo/'), qr(foo)i);
    is_deeply(str_maybe_to_re({ci=>1}, 'qr(foo)i'), qr(foo)i);

    is_deeply(str_maybe_to_re({always_quote=>1}, '/foo/'), '/foo/');
    is_deeply(str_maybe_to_re({always_quote=>1}, 'qr(foo.)'), 'qr(foo.)');

    if ($] >= 5.014) { # regex syntax (?^:)
        is_deeply(str_maybe_to_re({anchored=>1}, '/foo/'), qr(\A(?^:foo)\z));
    }

    dies_ok { str_maybe_to_re('/foo(/') };
};

subtest str_to_re => sub {
    dies_ok { str_to_re({foo=>1}, 'bar') } 'unknown option -> dies';

    is_deeply(str_to_re('foo['), qr(foo\[));
    is_deeply(str_to_re('/foo'), qr(\/foo));
    is_deeply(str_to_re({case_insensitive=>1}, '/foo'), qr(\/foo)i);
    is_deeply(str_to_re({ci=>1}, '/foo'), qr(\/foo)i);
    is_deeply(str_to_re({anchored=>1}, '/foo'), qr(\A\/foo\z));

    is_deeply(str_to_re('/foo/'), qr(foo));
    is_deeply(str_to_re({always_quote=>1}, '/foo/'), qr(\/foo\/));
    is_deeply(str_to_re({always_quote=>1}, 'qr(foo.)'), qr(qr\(foo\.\)));
    is_deeply(str_to_re('qr(foo)i'), qr(foo)i);

    is_deeply(str_to_re({ci=>1}, 'qr(foo)'), qr(foo)i);

    if ($] >= 5.014) { # regex syntax (?^:)
        is_deeply(str_to_re({anchored=>1}, '/foo/'), qr(\A(?^:foo)\z));
    }

    dies_ok { str_to_re('/foo(/') };
};

DONE_TESTING:
done_testing();
