package xmpbot::Plugin::Help;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->register_command('help')
}

sub help {
	my ($self, $args) = @_;
	if (not defined $args) {
		return 'what can I help you with?'
	}

	my $comm = $self->bot->get_plugin($args);
	if ($comm and $comm->can('help')) {
		return $comm->help;
	} else {
		return "no help available for $args"
	}
}

1;
