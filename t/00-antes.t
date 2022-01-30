#!/usr/bin/env raku

use Test;
use IV::Stats;

my @student-list = lista-estudiantes();
my $contenido = "proyectos/objetivo-0.md".IO.slurp;
my %objetivos-cumplidos = estado-objetivos( @student-list, $contenido );
is( %objetivos-cumplidos.keys.elems, 49, "Objetivos cumplidos correctos" );

$contenido = "proyectos/objetivo-9.md".IO.slurp;
%objetivos-cumplidos = estado-objetivos( @student-list, $contenido );
is( %objetivos-cumplidos.keys.elems, 2, "Objetivos 9 cumplidos correctos" );

is %objetivos-cumplidos<amerigal>, CUMPLIDO, "Bien extraidos objetivos";

done-testing;
