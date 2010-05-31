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
	my (undef, $args, $bot) = @_;
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
			$resp = "No help available for '$args'";
		}
	}
	return $resp;
}

1;
