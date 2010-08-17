package xmpbot::Plugin::Echo;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->register_command('echo');
}

sub help {
	'this plugin echoes what user has said'
}

sub echo {
	my ($self, $msg, $data) = @_;
	warn "Echo/log: $data->{jid} said exactly $data->{raw}\n";
	return $msg;
}

1;
