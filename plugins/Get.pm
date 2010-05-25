package Get;

sub init {
	return ['get','',''];
}

#TODO:	global franek@jabber.org
#	local  franek@jabber.org/work

sub msg_cb {
	my($self, $msg,$bot,$a) = @_;	
	my @user=split(/\//, $a->from);
	return $bot->getOption($user[0],$msg);	
}

1;
