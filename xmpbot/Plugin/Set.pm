package xmpbot::Plugin::Set;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('set');
	$self->description('set option');
	$self->help('example: set lang pl');
}


#TODO:	global franek@jabber.org
#	local  franek@jabber.org/work

sub msg_cb {
	my($self, $msg,$bot,$a) = @_;
	my ($option,$value) = split(/ /, $msg);
	my @user=split(/\//, $a->from);
	return $bot->setOption($user[0],$option,$value);	
}

1;
