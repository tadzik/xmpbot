package xmpbot::Translations;
use Moose::Role;
use strict;
use Data::Localize;

has 'loc' => (
	is			=> 'rw',
	isa			=> 'Data::Localize',
	default		=> sub { Data::Localize->new() },
);

after 'BUILD' => sub {
	my $self = shift;
};

1;
