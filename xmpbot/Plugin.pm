package xmpbot::Plugin;
use Moose::Role;
use feature ':5.10';
use xmpbot;
use Carp;
requires 'getHelp';
requires 'getDescription';

has 'bot' => (
	is		=> 'ro',
	isa		=> 'xmpbot',
	required	=> 1,
);

sub register_command {
	my ($self, $comm,$lang,$func) = @_;

	if ($self->bot->get_plugin($comm,$lang//"default")) {
		croak "Command $comm alredy registered";
	} else {
		$self->bot->set_plugin($comm, $self,$lang//"default",$func//$comm);
		say "Registered command $comm";
	}

}

1;
