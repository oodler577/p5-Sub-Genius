use strict;
use warnings;
use Test::More;
use Test::Exception;

use_ok q{Sub::Genius};

my $sq = Sub::Genius->new( pre => q{A&B&C} );
isa_ok $sq, q{Sub::Genius};

is $sq->pre, q{A&B&C}, q{PRE retained};

can_ok( $sq, qw/new pre _regex init_plan plan plan_nein next min_dfa run_any run_once/ );

isa_ok( $sq->min_dfa, q{FLAT::DFA::Minimal}, q{min DFA confirmed} );

$sq->init_plan;

while ( my $plan = $sq->next() ) {
    ok $plan, qq{'$plan' is next};
}

is $sq->next(), undef, q{no plan detected, expected};

$sq = Sub::Genius->new( pre => q{D&E&F} );

is $sq->pre, q{D&E&F}, q{PRE retained};

can_ok( $sq, qw/new pre _regex init_plan plan plan_nein next min_dfa run_any run_once/ );

isa_ok( $sq->min_dfa, q{FLAT::DFA::Minimal}, q{min DFA confirmed} );

while ( my $plan = $sq->next() ) {
    ok $plan, qq{'$plan' is next};
}

is $sq->next(), undef, q{no plan detected, expected};

my $plan = $sq->next( reset => 1 );
ok $plan, qq{'$plan', next after 'reset=>1' works};
while ( my $plan = $sq->next() ) {
    ok $plan, qq{'$plan' is next};
}

done_testing();
exit;

__END__
