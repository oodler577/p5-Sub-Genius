
use strict;
use warnings;
use feature 'state';

# generated using stubby

use Sub::Genius ();

# vvv---- PRE - #xxxx NOT COMPLETE, NEED TO MANUALLY ADD PARALLEL SEMANTIC
my $pre = q{
                  [init]
                  [spawn]
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
          ([thread1a] & [thread2a])
                  [atomic]
                  [atomic]
                  [atomic]
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
          ([thread1b] & [thread2b])
                  [syncup]
                    [fin]
};
# ^^^---- PRE - #xxxx NOT COMPLETE, NEED TO MANUALLY ADD PARALLEL SEMANTIC

## intialize hash ref as container for global memory
my $GLOBAL = {};


## initialize Sub::Genius
my $sq = Sub::Genius->new( pre => qq{$pre} );
$sq->init_plan;
my $final_scope = $sq->run_once( scope => {}, ns => q{main}, verbose => 1);


 
              ##########
             ############ 
#    |      ##############
#CCC##|#Subroutines>>>####
#    |      ##############
             ############
              ##########

sub spawn {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub spawn: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub init {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub init: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub thread1a {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub thread1a: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub thread2a {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub thread2a: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub thread2b {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub thread2b: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub fin {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub fin: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub atomic {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub atomic: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub syncup {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub syncup: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

sub thread1b {
  my $scope      = shift;    # execution context passed by Sub::Genius::run_once
  state $mystate = {};       # sticks around on subsequent calls
  my    $myprivs = {};       # reaped when execution is out of sub scope
   
  #-- begin subroutine implementation here --#
  print qq{Sub thread1b: ELOH! Replace me, I am just placeholder!\n};
  
  # return $scope, which will be passed to next subroutine
  return $scope;
}

exit;
__END__

=head1 NAME

nameMe -

=head1 SYNAPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item * C<spawn>

=item * C<init>

=item * C<thread1a>

=item * C<thread2a>

=item * C<thread2b>

=item * C<fin>

=item * C<atomic>

=item * C<syncup>

=item * C<thread1b>

=back

=head1 SEE ALSO

L<Sub::Genius>

=head1 COPYRIGHT AND LICENSE

Same terms as perl itself.

=head1 AUTHOR

Rosie Tay Robert E<lt>???@??.????<gt>

