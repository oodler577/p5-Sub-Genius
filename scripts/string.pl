#!/usr/bin/env perl

use strict;
use warnings;
require Data::Dumper;

use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

# needs 1.0.3
use FLAT::DFA;
use FLAT::NFA;
use FLAT::PFA;
use FLAT::Regex::WithExtraOps;

# high level description of concurrency
my $pre = q{
[begin]
(
  J &
    A &
      P &
        H
)
[end]
};

# initialize "sequential compiler" - i.e., a minified DFA
my $dfa = FLAT::Regex::WithExtraOps->new($pre)->as_pfa->as_nfa->as_dfa->as_min_dfa->trim_sinks;

# get one of potentially *many* strings accepted by DFA (here using a lazy iterator)
my $iter = $dfa->init_acyclic_iterator(q{ }); # useful for PREs with no kleene star

my $string = $iter->(); # may call repeatedly for purpose of 'pumping' the schedule

my @seq = split(/ /, $string);

print codegen($pre,\@seq);

sub codegen {
  my ($pre, $seq) = @_;
  my $cod = qq{#/usr/bin/env perl
use strict;
use warnings;

my \$GLOBAL = {         # global memory
  
};
};
foreach my $sub (@$seq) {
  $cod .= qq{sub $sub {
  state \$persist = {
    
  }; # gives subroutine memory, also 'private'
  
  local \$private = {
  
  }; # reset after each call

  return;
}
};
}
$cod .= qq{
exit;
__DATA__
$pre
};
return $cod;
}
