package Sub::Genius;

use strict;
use warnings;
use feature 'state';
use FLAT::PFA;
use FLAT::Regex::WithExtraOps;

our $VERSION = q{0.02};

# constructor
sub new {
    my $pkg  = shift;
    my %self = @_;
    die qq{'pre' parameter required!\n} if not defined $self{pre};
    $self{_regex} = FLAT::Regex::WithExtraOps->new( $self{pre} );
    my $self = bless \%self, $pkg;
    return $self;
}

# accepts the same parameters as a constructor, used to re-initialize
# the current reference
sub plan_nein {
    my $pkg  = shift;
    my $self = __PACKAGE__->new(@_);

    # also returns $self for convenience
    return $self;
}

# RO accessor for original pre
sub pre {
    my $self = shift;
    return $self->{pre};
}

# RO accessor for original
sub _regex {
    my $self = shift;
    return $self->{_regex};
}

# set/updated whenever ->next() and friends are called, simple way to
# query what plan was last created; RO, not destructive on current 'plan'
sub plan {
    my $self = shift;
    return $self->{plan};
}

# Converts PRE -> PFA -> NFA -> DFA -> minized DFA:
# NOTE: plan is not generated here, much call ->next()
sub init_plan {
    my ($self) = @_;

    # requires PRE (duh)
    die qq{Need to call 'new' to initialize\n} if not $self->{_regex};

    # warn if DFA is not acyclic (infinite strings accepted)
    if ( $self->min_dfa->is_infinite and not $self->{'infinite-ok'} ) {
        warn qq{(warn) Infinite language detected. To avoid, do not use Kleene Star (*).\n};
        warn qq{ Pass 'infinite-ok'=>1 to constructor to disable this warning\.\n};
    }

    # returns $self, for chaining in __PACKAGE__->run_any
    return $self;
}

# to force a reset, pass in, C<reset => 1>.; this makes a lot of cool things
sub min_dfa {
    my ( $self, %opts ) = @_;
    if ( ( not defined $self->{min_DFA} and q{FLAT::DFA::Minimal} ne ref $self->{min_DFA} ) or $opts{reset} ) {

        # the following line is FLAT: converting PRE to PFA (a form of NFA),
        # then -> NFA->DFA-minDFA + 'trim sink states" resulting from minimization algorithm
        $self->{min_DFA} = $self->{_regex}->as_pfa->as_nfa->as_dfa->as_min_dfa->trim_sinks;
    }
    return $self->{min_DFA};
}

# Acyclic String Iterator
#   force a reset, pass in, C<reset => 1>.
sub next {
    my ( $self, %opts ) = @_;
    if ( not defined $self->{_acyclical_iterator} or $opts{reset} ) {
        $self->{_acyclical_iterator} = $self->{min_DFA}->init_acyclic_iterator(q{ });
    }

    $self->{plan} = $self->{_acyclical_iterator}->();

    return $self->{plan};
}

# wrapper that combines C<init_plan> and C<run_once> to present an idiom,
#    my $final_scope = Sub::Genius->new($pre)->run_any( scope => { ... });
sub run_any {
    my ( $self, %opts ) = @_;
    $self->init_plan;
    my $final_scope = $self->run_once(%opts);
    return $final_scope;
}

# Runs any single serialization ONCE
# defaults to main::, specify namespace of $sub
# with
# * ns => q{Some::NS}    # specify name space
# * scope => { }         # specify initial state of pipeline accumulator
# * verbose => 0|1       # output runtime diagnostics
sub run_once {
    my ( $self, %opts ) = @_;
    $opts{ns}    //= q{main};
    $opts{scope} //= {};
    if ( my $plan = $self->next() ) {
        if ( $opts{verbose} ) {
            print qq{plan: "$plan" <<<\n\nExecute:\n\n};
        }
        my @seq = split( / /, $plan );

        # main run loop - run once
        local $@;
        foreach my $sub (@seq) {
            eval sprintf( qq{%s::%s(\$opts{scope});}, $opts{ns}, $sub );
            die $@ if $@;    # be nice and die for easier debuggering
        }
    }
    return $opts{scope};
}

1;

__END__

=head1 NAME

Sub::Genius - module for managing concurrent C<Perl> semantics in the
uniprocess execution model of C<perl>.

Another way to say this, is that it introduces all the joys and pains of
multi-threaded, shared memory programming to the uniprocess environment
that is C<perl>.

One final way to say it, if we're going to I<fake the funk out of
coroutines> [1], let's do it correctly. C<:)>

=head1 THIS MODULE IS I<EXPERIMENTAL>

Until further noted, this module subject to extreme fluxuations in
interfaces and implied approaches. The hardest part about this will be
managing all the cool and bright ideas stemming from it.

=head2 STATIC CODE STUB GENERATION TOOL

Eventually this module will install a tool called C<stubby> into your
local C<$PATH>. For the time being it is located in the C<./bin> directory
of the distribution and on Github.

=head1 SYNOPSIS

    my $pre = q{( A B    &     C D )       Z};
    #             \ /          \ /         |
    #>>>>>>>>>>>  L1  <shuff>  L2   <cat>  L3

    my $sq = Sub::Genius->new(pre => $pre);

    # sub declaration order has no bearing on anything
    sub A { print qq{A} }
    sub B { print qq{B} }
    sub C { print qq{C} }
    sub D { print qq{D} }
    sub Z { print qq{\n}}

    $sq->run_once();
    print qq{\n};

The following expecity execution of the defined subroutines are all
valid according to the PRE description above:

    # valid order 1
      A(); B(); C(); D(); Z();
    
    # valid order 2
      A(); C(); B(); D(); Z();
    
    # valid order 3
      A(); C(); D(); B(); Z();
    
    # valid order 4
      C(); A(); D(); B(); Z();
    
    # valid order 5
      C(); D(); A(); B(); Z();

In the example above, using a PRE to describe the relationship among
subroutine names (these are just multicharacter C<symbols>); we are
expressing the following constraints:

=over 4

=item C<sub A> must run before C<sub B>

=item C<sub C> must run before C<sub D>

=item C<sub Z> is always called last

=back

C<Sub::Genius> uses C<FLAT>'s functionality to generate any of a
number of valid "strings" or correct symbol orderings that are accepted
by the Regular Language described by the C<shuffle> two regular languages.

=head2 Meaningful Subroutine Names

C<FLAT> allows single character symbols to be expressed with out any decorations;

    my $pre = q{ s ( A (a b) C & D E F) f };

The I<concatentaion> of single symbols is implied, and spaces between symbols doesn't
even matter. The following is equivalent to the PRE above,

    my $pre = q{s(A(ab)C&DEF)f};

It's important to note immediately after the above example, that the PRE
may contain C<symbols> that are made up of more than one character. This
is done using square brackets (C<[...]>), e.g.:

    my $pre = q{[s]([A]([a][b])[C]&[D][E][F])[f]};

But this is a mess, so we can use longer subroutine names as symbols and
break it up in a more familar way:

    my $pre = q{
      [start]
        (
          [sub_A]
          (
            [sub_a]
            [sub_b]
          )
          [sub_C]
        &
          [sub_D]
          [sub_E]
          [sub_F]
        )
      [fin]
    };

This is much nicer and starting to look like a more natural expression
of concurrent semantics.

=head1 C<PERL>'s UNIPROCESS MEMORY MODEL AND ITS EXECUTION ENVIRONMENT

While the language C<Perl> is not necessarily constrained by a uniprocess
execution model, the runtime provided by C<perl> is. This has necessarily
restricted the expressive semantics that can very easily be extended to
C<DWIM> in a concurrent execution model. The problem is that C<perl> has
been organically grown over the years to run as a single process. It is
not immediately obvious to many, even seasoned Perl programmers, why after
all of these years does C<perl> not have I<real> threads or admit I<real>
concurrency and semantics. Accepting the truth of the uniprocess model
makes it clear and brings to it a lot of freedom. This module is meant to
facilitate shared memory, multi-process reasoning to C<perl>'s fixed
uniprocess reality.

=head2 Atomics and Barriers

When speaking of concurrent semantics in C<Perl>, the topic of atomic
primatives often comes up, because in a truly multi-process execution
environment, they are very important to coordinating the competitive access
of resources such as files and shared memory. Since this execution model
necessarily serializes parallel semantics in a C<sequentially consistent>
way, there is no need for any of these things. Singular lines of execution
need no coordination because there is no competition for any resource
(e.g., a file, memory, network port, etc).

=head1 RUNTIME METHODS

A minimal set of methods is provided, more so to not suggest the right
way to use this module.

=over 4

=item C<new>

Constructor, requires a single scalar string argument that is a valid
PRE accepted by L<FLAT>.

    my $pre = q{
      [start]
        (
          [subA] (
            [subB_a] [subB_b]
          ) [subC]
        &
          [subD] [subE] [subF]
        )
      [finish]
    };

    my $sq = Sub::Genius->new(pre => $pre);

Note: due to the need to explore the advantages of supporting I<infinite>
languages, i.e., PREs that contain a C<Kleene> star; C<init_plan> will
C<die> after it compiles the PRE into a min DFA. It checks this using the
C<FLAT::DFA::is_finite> subroutine, which simply checks for the presence
of cycles. Once this is understood more clearly, this restriction may be
lifted. This module is all about correctness, and only finite languages
are being considered at this time.

The reference, if captured by a scalar, can be wholly reset using the same
parameters as C<new> but calling the C<plan_nein> methods. It's a minor
convenience, but one all the same.

=item C<plan_nein>

Using an existing reference instantiation of C<Sub::Genius>, resets
everything about the instance. It's effectively link calling C<new> on the
instance without having to recapture it.

=item C<init_plan>

This takes the PRE provided in the C<new> constructure, and runs through
the conversion process provded by L<FLAT> to an equivalent mininimzed
DFA. It's this DFA that is then used to generate the (currently) finite
set of strings, or I<plans> that are acceptible for the algorithm or
steps being implemented.

    my $pre = q{
      [start]
        (
          [subA] (
            [subB_a] [subB_b]
          ) [subC]
        &
          [subD] [subE] [subF]
        )
      [finish]
    };
    my $sq = Sub::Genius->new(pre => $pre);
    $sq->init_plan;

=item C<run_once>

Returns C<scope> as affected by the assorted subroutines.

Accepts two parameters, both are optional:

=over 4

=item ns => q{My::Subsequentializer::Oblivious::Funcs}

Defaults to C<main::>, allows one to specify a namespace that points to a library
of subroutines that are specially crafted to run in a I<sequentialized> environment.
Usually, this points to some sort of willful obliviousness, but might prove to be
useful nonetheless.

=item scope => {}

Allows one to initiate the execution scoped memory, and may be used to manage
a data flow pipeline. Useful and consistent only in the context of a single
plan execution. If not provided, C<scope> is initialized as an empty anonymous
hash reference:

    my $final_scope = $sq->run_once(
                           scope   => {},
                           verbose => undef,
                      );

=item verbose => 1|0

Default is falsy, or I<off>. When enabled, outputs arguably useless diagnostic
information.


=back

Runs the execution plan once, returns whatever the last subroutine executed
returns:

    my $pre = join(q{&},(a..z));
    my $sq = Sub::Genius->new(pre => $pre);
    $plan = $sq->init_plan;
    my $final_scope = $sq->run_once;

=item C<next>

L<FLAT> provides some utility methods to pump FAs for valid strings;
effectively, its the enumeration of paths that exist from an initial
state to a final state. There is nothing magical here. The underlying
method used to do this actually creates an interator.

When C<next> is called the first time, an interator is created, and the
first string is returned. There is currently no way to specify which
string (or C<plan>) is returned first, which is why it is important that
the concurrent semantics declared in the PRE are done in such a way that
any valid string presented is considered to be sequentially consistent
with the memory model used in the implementation of the subroutines. Perl
provides the access to these memories by use of their lexical variable
scoping (C<my>, C<local>) and the convenient way it allows one to make a
subroutine maintain persistent memory (i.e., make it a coroutine) using
the C<state> keyword. See more about C<PERL's UNIPROCESS MEMORY MODEL
AND ITS EXECUTION ENVIRONMENT> in the section above of the same name.

An example of iterating over all valid strings in a loop follows:

    while (my $plan = $sq->next_plan()) {
      print qq{Plan: $plan\n};
      $sq->run_once;
    }

Note, in the above example, the concept of I<pipelining> is violated since the
loop is running each plan ( with no guaranteed ordering ) in turn. C<$scope> is
only meaningful within each execution context. Dealing with multiple returned
final scopes is not part of this module, but can be captured during each iteration
for future processessing:

    my @all_final_scopes = ();
    while (my $plan = $sq->next_plan()) {
      print qq{Plan: $plan\n};
      my $final_scope = $sq->run_once;
      push @all_final_scopes, { $plan => $final_scope };
    }
    # now do something with all the final scopes collected
    # by @all_final_scopes

At this time C<Sub::Genius> only permits I<finite> languages, therefore
there is always a finite list of accepted strings. The list may be long, but
it's finite.

As an example, the following admits a large number of orderings in a realtively
compact DFA, in fact there are 26! (factorial) such valid orderings:

    my $pre = join(q{&},(a..z));
    my $final_scope = Sub::Genius->new(pre => $pre)->run_once;

Thus, the following will take long time to complete; but it will complete:

    my $ans; # global to all subroutines executed
    while ($my $plan = $sq->next_plan()) {
      $sq->run_once;
    }
    print qq{ans: $ans\n};

Done right, the output after 26! iterations may very well be:

    ans: 42

A formulation of 26 subroutines operating over shared memory in which all
cooperative execution of all 26! orderings reduces to C<42> is left as an
excercise for the reader.

=item C<run_any>

For convenience, this wraps up the steps of C<plan>, C<init_plan>, C<next>,
and C<run_once>. It presents a simple one line interfaces:

    my $pre = q{
      [start]
        (
          [subA] (
            [subB_a] [subB_b]
          ) [subC]
        &
          [subD] [subE] [subF]
        )
      [finish]
    };
    Sub::Genius->new(pre => $pre)->run_any();

=back

=head1 STATIC CODE UTILITY METHODS

The C<stubby> utility is provided for this purpose and is not part of the
main module.

=head1 SEE ALSO

L<Pipeworks>, L<Sub::Pipeline>, L<Process::Pipeline>, L<FLAT>,
L<Graph::PetriNet>

=head2 GOOD READINGS

=over 4

=item * 1. L<https://www.planetmath.org/shuffleoflanguages>

=item * 2. Leslie Lamport, "How to Make a Multiprocessor Computer That Correctly Executes Multiprocess Programs", IEEE Trans. Comput. C-28,9 (Sept. 1979), 690-691.

=item * 3. L<https://www.hpl.hp.com/techreports/Compaq-DEC/WRL-95-7.pdf>

=back

=head1 COPYRIGHT AND LICENSE

Same terms as perl itself.

=head1 AUTHOR

OODLER 577 E<lt>oodler@cpan.orgE<gt>

=head1 ACKNOWLEDGEMENTS

L<TEODESIAN> is acknowledged for his support and interest in
this project, in particular his work lifting the veil off of what
passes for I<concurrency> these days; namely, I<most of the "Async"
modules out there are actually fakin' the funk with coroutines.>. See
L<https://troglodyne.net/video/1615853053> for a fun, fresh, and informative
video on the subject.
