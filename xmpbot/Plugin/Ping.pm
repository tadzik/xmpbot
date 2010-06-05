package xmpbot::Plugin::Ping;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('ping');
	$self->register_command('pong');
}

sub ping {
	my $self = shift;
	return $self->loc->localize('pong');
}

sub pong {
	my $self = shift;
	return $self->loc->localize('ping');
}

1;
