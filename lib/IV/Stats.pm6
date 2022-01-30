use IO::Glob;
use Git::File::History;

enum Estados <CUMPLIDO ENVIADO INCOMPLETO>;

sub estado-objetivos( @student-list, $contenido) is export {
    my @contenido = $contenido.split("\n").grep(/"|"/);
    my %estados;
    for @student-list.kv -> $index, $usuario {
        given  @contenido[$index + 2] {
            when /"✓"/ { %estados{$usuario} = CUMPLIDO }
            when /"✗"/ { %estados{$usuario} = INCOMPLETO }
            when /"github.com"/  { %estados{$usuario} = ENVIADO }
        }
    }
    return %estados;
}

unit class IV::Stats;

has @!student-list;
has %!students;
has @!objetivos;
has @!entregas;
has @!fechas-entregas;

my @cumplimiento=[.05,.075, .15, .075, .15, 0.05, 0.05, 0.1, 0.1, 0.1, 0.1 ];

method new( Str $file = "proyectos/usuarios.md") {
    my @student-list = $file.IO.slurp.lines.grep( /"<!--"/ )
        .map( *.split( "--" )[1].split(" ")[3]);
    my %students;
    my @objetivos;
    my @entregas;
    @student-list.map: { %students{$_} = { :objetivos(set()), :entrega(0) } };
    my $file-history = Git::File::History.new(
                :files("proyectos/objetivo-*.md")
            );
    my @fechas-entregas;
    for glob( "proyectos/objetivo-*.md" ).sort: { $^a cmp $^b} -> $f {
        my ($objetivo) := $f ~~ /(\d+)/;
        my @contenido = $f.IO.lines.grep(/"|"/);
        @objetivos[$objetivo] = set();
        @entregas[$objetivo] = set();
        for @student-list.kv -> $index, $usuario {
            if ( @contenido[$index + 2] ~~ /"✓"/ ) {
                %students{$usuario}<objetivos> ∪= +$objetivo;
                @objetivos[$objetivo] ∪= $usuario;
            }
            if ( @contenido[$index + 2] ~~ /"github.com"/ ) {
                %students{$usuario}<entrega> = +$objetivo ;
                @entregas[$objetivo] ∪= $usuario;
            }
        }

        for $file-history.history-of( ~$f )<> -> %file-version {
            my $this-version = %file-version<state>;
            my $fecha = %file-version<date>;
            my %estado-objetivos = estado-objetivos( @student-list,
                    $this-version);
            for %estado-objetivos.kv -> $estudiante, $estado {
                my $estado-actual = @fechas-entregas[$objetivo]{$estudiante};
                say "$estado-actual $estado";
                given $estado {
                    when ENVIADO {
                        if !$estado-actual {
                            @fechas-entregas[$objetivo]{$estudiante}<entrega>
                                    = $fecha;
                        }
                    }
                    when CUMPLIDO {
                        if $estado-actual == ENVIADO {
                            @fechas-entregas[$objetivo]{$estudiante}<corregido>
                                    = $fecha;
                        }
                    }
                    when INCOMPLETO {
                        if $estado-actual == ENVIADO {
                            @fechas-entregas[$objetivo]{$estudiante}<corregido>
                                    = $fecha;
                            @fechas-entregas[$objetivo]{$estudiante}<incompleto> = True;
                        }
                    }
                }
            }
        }
    }
    self.bless( :@student-list, :%students, :@objetivos, :@entregas,
            :@fechas-entregas );
}

submethod BUILD( :@!student-list, :%!students, :@!objetivos, :@!entregas,
                 :@!fechas-entregas) {}

method objetivos-de( Str $user  ) {
    return %!students{$user}<objetivos>;
}

method entregas-de( Str $user ) {
    return %!students{$user}<entrega>;
}

method cumple-objetivo( UInt $objetivo ) {
    return @!objetivos[$objetivo];
}

method hecha-entrega( UInt $entrega ) {
    return @!entregas[$entrega];
}

method bajas-objetivos( UInt $objetivo) {
    return @!objetivos[$objetivo] ⊖  @!objetivos[$objetivo + 1];
}

method bajas-totales( UInt $objetivo) {
    return @!objetivos[$objetivo] ⊖  @!entregas[$objetivo + 1];
}

method objetivos() {
    return @!entregas.keys;
}

method estudiantes() {
    return %!students.keys;
}

method objetivos-cumplidos() {
    return @!objetivos.map( *.keys.sort( { $^a.lc cmp $^b.lc }) );
}

method notas( --> Seq ) {
    return gather for @!student-list -> $u {
        my $nota = 0;
        for  %!students{$u}<objetivos>.list.keys -> $n {
            $nota += @cumplimiento[$n]
        }
        take $nota*7;
    }
}

method fechas-entregas-to-CSV() {

    my $csv = "Objetivo;Estudiante;Entrega;Correccion;Incompleto";
    for @!fechas-entregas -> $o {
        for @!fechas-entregas[$o].kv -> $estudiante, %datos {
            my $fila = "$o; $estudiante;";
            for <entrega corregido> -> $e {
                $fila ~= %datos{$e} ~ ";";
            }
            if %datos<incompleto> {
                $fila ~= "Incompleto";
            } else {
                $fila ~= "Completo";
            }
            $csv ~= $fila ~ "\n";
        }

    }
    return $csv;
}
