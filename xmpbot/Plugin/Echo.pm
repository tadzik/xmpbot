package xmpbot::Plugin::Echo;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('echo');
	$self->name("echo");
}


sub getDescription{
	my($self) = @_;
	return $self->loc->localize('echoes what was said');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('This plugin simply retypes what the user said');
}


sub echo{
	my($self, $msg) = @_;
	return $msg;
}

1;
