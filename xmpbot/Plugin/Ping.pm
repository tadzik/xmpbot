package xmpbot::Plugin::Ping;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('ping');
	$self->register_command('pong');
	$self->name("ping");
}

sub getDescription{
	my($self) = @_;
	return $self->loc->localize('This plugin responds to "ping" with "pong". Yep, that\'s it');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('respond to "ping" and "pong"');
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
