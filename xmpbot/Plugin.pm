package xmpbot::Plugin;
use Moose::Role;
use feature ':5.10';
use xmpbot;
use Carp;

=pod
Methinks the following should rather go to the Translations role
	use Data::Localize
	has 'loc' => (
		is			=> 'rw',
		isa			=> 'Data::Localize',
		default		=> sub { Data::Locallize->new },
	);
=cut

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
