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

has 'commands' =>(
	traits     => ['Array'],
	is		=> 'rw',
	isa		=> 'ArrayRef[Str]',
	default		=> sub{ [] },
	handles    => {
		all_commands    => 'elements',
		add_command     => 'push',
		map_commands    => 'map',
		get_command    => 'get',
		join_commands   => 'join',
		count_commands  => 'count',
		sorted_commands => 'sort',
       },
);



sub register_command {
	my ($self, $comm,$lang) = @_;
	if ($self->bot->get_plugin($comm)) {
		croak "Command $comm alredy registered";
	} else {
		$self->bot->set_plugin($comm, $self);
		if(not defined $lang or $lang eq "en"){
			$self->add_command($comm);
		}
		say "Registered command $comm";
	}

}

1;
