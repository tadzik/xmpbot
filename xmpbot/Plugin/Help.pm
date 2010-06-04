package xmpbot::Plugin::Help;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('help');
	$self->description('list all available commands');
	$self->help('This plugin shows a list of available commands with short descriptions, or a longer help for a specified command');
}

sub msg_cb {
	my ($self, $args, $bot) = @_;
	my $resp;
	if (not defined $args) {
		for my $pair ($bot->plugins_pairs) {
			$resp .= "$pair->[0]\t".$pair->[1]->description."\n";
		}
	} else {
		my $comm = $bot->get_plugin($args);
		if ($comm) {
			$resp = $comm->help;
		} else {
			#TODO CHANGE this!
			$resp= $self->{loc}->localize('No help available for') ." ". $args;			
#			$resp = "No help available for '%s'",$args;
		}
	}
	return $resp;
}

1;
