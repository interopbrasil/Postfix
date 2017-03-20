#!/usr/bin/perl -w
#################################################################################################
#                                                                                               #
# Script realiza a verificao a lista de usuários coletads no LDAP, bem como a integridade desta
# lista
#                                                                                               #
# Criado em: 10/02/2017 por Wagner Garcez                                                       #
#                                                                                               #
#################################################################################################

# ============================= = ==============================
use Switch;
use Getopt::Long qw(:config no_ignore_case bundling);

# ============================= = ==============================
$PATH = "/etc/postfix/relay_recipients" ;
$row = 0 ;
%exit_codes  = ('UNKNOWN' , 3,
                'OK'      , 0,
                'CRITICAL', 2,);

# ============================= = ==============================
sub integrity_collect_of_LDPA {
  if ( $quantity == 0) {
    print "UNKNOWN - Quantidade de usuários esperados não foi definido!\n" ;
    exit $exit_codes{'UNKNOWN'};
  }
  if ($row < $quantity) {
    print "CRITICAL - Inconsistencia na coleta de dados do LDAP do cliente $domain. Número de usuários esperados: $quantity , números de usuários encontrados: $row |integrity_ldap=$row;;$quantity;;\n" ;
    exit $exit_codes{'CRITICAL'};
  } else {
      print "OK - Coleta de dados do LDAP do cliente $domain encontra-se integra. Números de usuários encontrados: $row |integrity_ldap=$row;;$quantity;;\n" ;
      exit $exit_codes{'OK'};
    }
}

# ============================= = ==============================
sub status_collect_of_LDPA {
  my $status = 0 ;
  if ($row <= 0) {
    print "CRITICAL - Não está coletando dados do LDAP do cliente $domain |status=$status;;$status;;\n" ;
    exit $exit_codes{'CRITICAL'};
  } else {
      my $status = 1 ;
      print "OK - Coleta de dados do LDAP do cliente $domain está ok. |status=$status;;$status;;\n" ;
      exit $exit_codes{'OK'};
    }
}

# ============================= = ==============================
sub read_arq {
  open (my $arquivo, "<$PATH") or die "Não foi possível abrir o arquivo: $PATH";
    while (<$arquivo>) {
      if ($_ =~ /$domain/) {
        $row ++ ;
      }
    }
  close $arquivo;
}

# ============================= = ==============================
sub parse_args{
  GetOptions(
    "D|domain=s"                        => \$domain,
    "q|quantity=s"                      => \$quantity,
    "o|options=s"                       => \$optType,
    "h"                 => \$help
  );
  if (defined ($help) ) {
    PrintHelp();
    exit $exit_codes{'UNKNOWN'}
  };

  if (!defined($domain) || !defined($optType)) {
    &PrintHelp;
    exit $exit_codes{'UNKNOWN'};
   }
}

# ============================= = ==============================
sub PrintHelp {
  print "------------------------------------------------\n" ;
  print "Exemplo de Uso: script.pl -D [domain] -q [quantity] -o [integrity|status]\n\n" ;
  print "       Parametros:\n" ;
  print "-D|--domain      =>      Nome do dominio\n" ;
  print "-q|--quantity    =>      Qauntidade de usuários\n" ;
  print "-o|--option [integrity|status]\n" ;
  print "  integrity    =>      Verifica se está coletando\n" ;
  print "  status       =>      Verifica a consistência da lista\n" ;
  print "------------------------------------------------\n" ;
}

# ============================= = ==============================
sub main{
  parse_args();
  read_arq();
  switch ($optType) {
    case "integrity"      { integrity_collect_of_LDPA() }
    case "status"         { status_collect_of_LDPA }
    else { print "UNKNOWN - Opção desconhecida. Favor verificar\n"; exit $exit_codes{'UNKNOWN'} } ;
  }
}

# ============================= = ==============================
main();
exit;
