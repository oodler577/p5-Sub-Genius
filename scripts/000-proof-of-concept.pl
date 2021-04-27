#!/usr/bin/env perl

use strict;
use warnings;
$|++;

package demo::X;

sub a {
  print qq{a};
  sleep 1;
}

sub b {
  print qq{b};
  sleep 1;
}

sub c {
  print qq{c};
  sleep 1;
}

sub D {
  print qq{D};
  sleep 1;
}

sub E {
  print qq{E};
  sleep 1;
}

sub F {
  print qq{F};
  sleep 1;
}

package main;

# use FLAT; 

# step 1 - define sequential constraints using a PFA, compile using FLAT,
#          get one of any possible schedules
my $pfa_desc = q{(abc)&(DEF)};
# desc: subs a(),b(),c() must maintain proper total ordering
#       subs D(),E(),F() must maintain proper total ordering
#       subs in 'abc' can be run in any order wrt 'DEF', thus
#       the sequence 'abc' is partial ordered wrt 'DEF

# step 2 - get a valid 'serialized' string using a gen_string method that
#          uses a DFA generated from the PRE->PFA->NFA->DFA->min_DFA->trim_sinks;
my $consistent = q{aDbcEF}; # POC, get a 'string' (FLAT generates this from PRE)

# step 3 - using sequential ordering, call subs of prescribed names;
#  TODO> FLAT needs to support entities that consist of more than one symbol
#  TODO>   so that subroutines with meaningful names can be used

# one pass over 'string'
DRIVER:
foreach my $sub (split //, $consistent) {
  eval qq{demo::X::$sub};
}
print qq{\n};

