package xmpbot::Plugin;
use Moose::Role;
use feature ':5.10';
use xmpbot;
use Carp;

has 'bot' => (
	is		=> 'ro',
	isa		=> 'xmpbot',
	required	=> 1,
);

sub register_command {
	my ($self, $comm) = @_;
	if ($self->bot->get_plugin($comm)) {
		croak "Command $comm alredy registered";
	} else {
		$self->bot->set_plugin($comm, $self);
		say "Registered command $comm";
	}
}

1;
