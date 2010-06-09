package xmpbot::Plugin::Get;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('get');
	$self->name("get");
}


sub getDescription{
	my($self) = @_;
	return $self->loc->localize('get option');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('example: get lang');
}


sub get{
	my($self, $msg,$bot,$a) = @_;	
	my @user=split(/\//, $a->from);
	return $bot->db->getOption($user[0],$msg);
}


1;
