package xmpbot::Plugin::Echo;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('echo');
	$self->description('echoes what was said');
	$self->help('This plugin simply retypes what the user said');
}

sub msg_cb {
	my ($self, $msg) = @_;
	return $msg;
}

1;
