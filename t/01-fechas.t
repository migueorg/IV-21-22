#!/usr/bin/env raku

use Test;
use IV::Stats::Fechas;

my $fechas = IV::Stats::Fechas.new;

ok( $fechas, "Can create object");
isa-ok( $fechas, IV::Stats::Fechas, "Clase correcta" );

done-testing;
