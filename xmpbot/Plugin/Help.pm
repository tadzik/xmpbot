package xmpbot::Plugin::Help;
use Data::Dumper;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('help');
	$self->name("help");
}


sub getDescription{
	my($self) = @_;
	return $self->loc->localize('This plugin shows a list of available commands with short descriptions, or a longer help for a specified command');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('show this message');
}


sub help{
	my ($self, $args, $bot) = @_;
	#get language without db? TODO
	my $resp;
	if (not defined $args) {

	} else {
		#TODO!
	}
	return $resp;
}



1;
