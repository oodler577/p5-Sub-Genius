#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

use Sub::Genius ();

#
# Implements classic JAPH, perl hacker hackerman benchmark
# sequentially consistent, yet oblivious, way - that's right!
# This is a Sequential Consistency Oblivious Algorithm (in the
# same vein as 'cache oblivious' algorithms
#
# paradigm below is effective 'fork'/'join'
#
my $preplan = q{a & b & cdef*};

# Load PRE describing concurrent semantics
my $sq = Sub::Genius->new(preplan => $preplan, 'allow-infinite' => 1 );

my $GLOBAL = {};

# 'compile' PRE
$sq->init_plan;   #<- needed??????

#
# need way to specify min/max (and precise length when min==max)
#
while (my $plan = $sq->inext(min => 1, max => 10)) {
  print qq{$plan\n};
}

exit;
