package xmpbot::Plugin::Ping;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('ping');
	$self->description('respond to "ping"');
	$self->help('This plugin responds to "ping" with "pong". Yep, that\'s it');
}

sub msg_cb {
	return "pong";
}

1;
