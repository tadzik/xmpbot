package xmpbot::Plugin::Ping;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->register_command('ping');
	$self->register_command('pong');
}

sub ping {
	return 'pong'
}

sub pong {
	return 'ping'
}

1;
