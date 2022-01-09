#!/usr/bin/env perl6

use IO::Glob;
use IV::Stats;

my $stats = IV::Stats.new;

my @cumplimiento=[.05,.075, .15, .075, .15, 0.05, 0.05, 0.1, 0.1, 0.1, 0.1 ];

for $stats.estudiantes -> $u {
    my $nota = 0;
    say $u, $stats.objetivos-de( $u );
    for $stats.objetivos-de( $u ).list.keys -> $n {
        $nota += @cumplimiento[$n]
    }
    say $nota*7;
}
