package xmpbot::Plugin::Ping;

sub init {
	return ['ping', 'respond to "ping"',
		'This plugin responds to "ping" with "pong". Yep, that\'s it'];
}

sub msg_cb {
	return "pong";
}

1;
