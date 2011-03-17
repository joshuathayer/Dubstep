package Dubstep;
use strict;

sub new {
  my ($class, $this) = @_;

  $this = $this ? $this : {};

  bless $this, $class;

  {
    package MyDubstep;
    our @ISA = qw/Dubstep/;

    $this->{results} = [];
    $this->{p_count} = 0;
    $this->{p_done} = 0;
	$this->{steps} = [];
	$this->{in_call} = 0;

	# factory for callbacks
    sub step {
	  return sub {
        my ($err, @res) = @_;
        my $f = shift(@{$this->{steps}});
        $this->{in_call} = 1;
		\$f->($err, @res);
	    $this->{in_call} = 0;
		$this->check();
      };
    };

    sub check  {
      my ($this, $in) = @_;
      return unless ($this->{in_call} == 0);
	  return unless ($this->{p_count} > 0); 
      $this->{p_done} += 1;
	  return unless ($this->{p_done} == $this->{p_count});
      my $res_array = $this->{results};
      $this->{results} = [];
      $this->{p_count} = 0;
      $this->{p_done} = 0;
	  my $cb = $this->step();
	  $cb->(undef, @$res_array);
    }
        
    sub parallel {
      my $you_are_number = $this->{p_count};
      $this->{p_count} += 1;
  
      return sub {
        my ($err, $res) = @_;
        $this->{results}->[$you_are_number] = $res;
        $this->check();
      }

    };

    $this = bless $this;
  };

}

sub Step {
  my $self = shift;

  @{$self->{steps}} = @_;
  my $f = shift(@{$self->{steps}});
  \$f->();
}

sub step {
	print "dummy step.\n";
}



1;
