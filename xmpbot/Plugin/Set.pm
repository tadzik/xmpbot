package xmpbot::Plugin::Set;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('set');
	$self->name("set");
}


sub getDescription{
	my($self) = @_;
	return $self->loc->localize('set option');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('example: set lang pl');
}


sub set{
	my($self, $msg,$bot,$a) = @_;
	my ($option,$value) = split(/ /, $msg);
	my @user=split(/\//, $a->from);
	print $user[0],"\n";	
}

1;
