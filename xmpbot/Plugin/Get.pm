package xmpbot::Plugin::Get;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('get');
	$self->description('get option');
	$self->help('example: get lang');
}


#TODO:	global franek@jabber.org
#	local  franek@jabber.org/work

sub msg_cb {
	my($self, $msg,$bot,$a) = @_;	
	my @user=split(/\//, $a->from);
	return $bot->getOption($user[0],$msg);	
}

1;
