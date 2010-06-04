package xmpbot::Plugin;
use Moose::Role;
use Data::Localize
requires 'msg_cb';
use Carp;

has 'command' => (
	is			=> 'rw',
	isa			=> 'Str',
	predicate	=> 'has_command',
);

has 'description' => (
	is			=> 'rw',
	isa			=> 'Str',
	predicate	=> 'has_description',
);

has 'help' => (
	is			=> 'rw',
	isa			=> 'Str',
	predicate	=> 'has_help',
);

has 'loc' => (
	is			=> 'rw',
	isa			=> 'Data::Localize'
);

after 'BUILD' => sub {
	my $self = shift;
	croak "Command not specified!" unless $self->has_command;
	carp "Warning: description not set" unless $self->has_description;
	carp "Warning: help message not set" unless $self->has_help;
	$self->{loc} = Data::Localize->new();
};

1;
