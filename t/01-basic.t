#!perl

use strict;
use warnings;
use Test::More 0.98;

use File::SortedSeek::PERLANCAR qw(binsearch numeric alphabetic);
use File::Temp qw(tempdir);

my $dir = tempdir();
note "tempdir=$dir";
{ open my $fh, ">", "$dir/numeric"   ; for (1..10) { print $fh "$_\n" } }
{ open my $fh, ">", "$dir/alphabetic"; for ("a".."z") { print $fh "$_\n" } }
{ open my $fh, ">", "$dir/len"; for (1..10) { print $fh (chr(107-$_) x $_) . "\n" } }

subtest "numeric" => sub {
    open my $fh, "<", "$dir/numeric";
    for my $x (1..10) {
        numeric($fh, $x);
        chomp(my $res = <$fh>);
        is($res, $x);
    }
    for my $x (reverse 1..10) {
        numeric($fh, $x);
        chomp(my $res = <$fh>);
        is($res, $x);
    }

    subtest "minoffset & maxoffset args" => sub {
        for my $x (2..7) {
            numeric($fh, $x, undef, 2, 13);
            chomp(my $res = <$fh>); is($res, $x);
        }
        numeric($fh, 1, undef, 2, 13);
        chomp(my $res = <$fh>); is_deeply($res, 2);
        #numeric($fh, 8, undef, 2, 13);
        #chomp(my $res = <$fh>); is_deeply($res, 8);
    };
};

subtest "alphabetic" => sub {
    open my $fh, "<", "$dir/alphabetic";
    for my $x ("a".."z") {
        alphabetic($fh, $x);
        chomp(my $res = <$fh>);
        is($res, $x);
    }
    for my $x (reverse "a".."z") {
        alphabetic($fh, $x);
        chomp(my $res = <$fh>);
        is($res, $x);
    }
};

subtest "binsearch" => sub {
    open my $fh, "<", "$dir/len";
    for my $x (1..10) {
        binsearch($fh, $x, sub { length($_[0]) <=> $_[1] });
        #note "tell(\$fh) = ", tell($fh);
        chomp(my $res = <$fh>);
        is($res, chr(107-$x) x $x);
    }
};

done_testing;
