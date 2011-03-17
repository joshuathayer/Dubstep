use strict;

use Dubstep;

sub do_something {
	my ($next) = @_;
	print "in do_something\n";
	$next->(undef, "okay!");
}

sub do_something_else {
	my ($in, $next) = @_;
	print "in do_something_else, res is $in\n";
	$next->(undef, "okay!");
}

sub do_this {
	my ($in, $next) = @_;
	print "in do_this(), input was $in\n";
	$next->(undef, "from do_this (parallel 0)");
}

sub and_do_this {
	my ($in, $next) = @_;
	print "in and_do_this(), input was $in\n";
	$next->(undef, "from and_do_this (parallel 1)");
}

sub do_this_third_thing {
	my ($in, $next) = @_;
	print "in do_this_third_thing(), input was $in\n";
	$next->(undef, "from do_this_third_thing (parallel 2)");
}

my $dubstep = new Dubstep;

$dubstep->Step(
  sub {
    do_something($dubstep->step);
  },
  sub {
    my ($err, $result) = @_; 
	die($err) if $err;
    do_something_else($result, $dubstep->step);
  },
  sub {
    my ($err, $result) = @_; 
	die($err) if $err;
    do_this("hello there, do_this", $dubstep->parallel());
	and_do_this("hello there, and_do_this", $dubstep->parallel());
  }, 
  sub {
    my ($err, $result) = @_; 
	die($err) if $err;
    do_this("hello again, do_this", $dubstep->parallel());
	and_do_this("hello again, and_do_this", $dubstep->parallel());
	do_this_third_thing("hello there, and_do_this", $dubstep->parallel());
  }, 
  sub {
    my ($err, $res0, $res1) = @_;
	print "ok all done. res0 was ->$res0<-, res1 was ->$res1<-\n";
  }
);

print "we are here now\n";
