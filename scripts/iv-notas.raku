#!/usr/bin/env perl6

use IO::Glob;
use IV::Stats;

my $stats = IV::Stats.new;

my @cumplimiento=[.05,.075, .15, .075, .15, 0.05, 0.05, 0.1, 0.1, 0.1, 0.1 ];

for $stats.estudiantes -> $u {
    my @nota = sum $stats.objetivos-de( $u );
    say @nota;
}
