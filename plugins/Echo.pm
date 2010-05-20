package Echo;

sub init {
	return ['echo', 'echoes what was said',
		'This plugin simply retypes what the user said'];
}

sub msg_cb {
	my ($self, $msg) = @_;
	return $msg;
}

1;
