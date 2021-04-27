#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

# high level description of concurrency
my $pre = q{
  [ begin]
    (
      [ seq_subA]
      (
        [ seq_subB_a]
        [ seq_subB_b]
      )
      [ seq_subC]
    &
      [ seq_subD]
      [ seq_subE]
      [ seq_subF]
    )
  [ end]
};


# Original sequence: begin seq_subD seq_subE seq_subA seq_subF seq_subB_a seq_subB_b seq_subC end;

package main;

my $global_state = {};      # "shared memorye

sub begin {
    state $my_state   = {}; # things to remember inside of "state"
    local $my_scratch = {}; # things to forget once block scope is left
    print qq{begin\n};
    return q{begin};
}

sub seq_subD {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subD\n};
    return q{seq_subD};
}

sub seq_subE {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subE\n};
    return q{seq_subE};
}

sub seq_subA {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subA\n};
    return q{seq_subA};
}

sub seq_subF {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subF\n};
    return q{seq_subF};
}

sub seq_subB_a {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subB_a\n};
    return q{seq_subB_a};
}

sub seq_subB_b {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subB_b\n};
    return q{seq_subB_b};
}

sub seq_subC {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{seq_subC\n};
    return q{seq_subC};
}

sub end {
    state $my_state   = {};
    local $my_scratch = {};
    print qq{end\n};
    return q{end};
}

