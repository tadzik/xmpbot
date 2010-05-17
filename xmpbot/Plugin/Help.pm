package xmpbot::Plugin::Help;

sub init {
	return ['help', 'list all available commands',
		'This plugin shows a list of available commands with short descriptions, or a longer help for a specified command'];
}

sub msg_cb {
	my (undef, $msg, $bot) = @_;
	my $resp;
	if ($msg eq '') {
		for my $pair ($bot->plugins_pairs) {
			$resp .= "$pair->[0]\t $pair->[1]->{info}\n";
		}
	} else {
		my $comm = $bot->get_plugin($msg);
		if ($comm) {
			$resp = $comm->{help};
		} else {
			$resp = "No help available for '$msg'";
		}
	}
	return $resp;
}

1;
