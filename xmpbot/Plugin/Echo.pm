package xmpbot::Plugin::Echo;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->register_command('echo');
}

sub echo {
	my ($self, $msg) = @_;
	return $msg;
}

1;
