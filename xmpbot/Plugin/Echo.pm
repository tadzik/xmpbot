package xmpbot::Plugin::Echo;


sub init {
	return ['echo', 'echoes what was said',
		'This plugin simply retypes what the user said'];
}

sub msg_cb {
	my ($self, $msg) = @_;
	print "Echo.pm: ".$msg."\n";
	return $msg;
}

1;
