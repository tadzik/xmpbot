package xmpbot::Translations;
use Moose::Role;
use strict;
use Data::Localize;
use Data::Dumper;

has 'loc' => (
	is			=> 'rw',
	isa			=> 'Data::Localize',
	default		=> sub { Data::Localize->new() },
);

has 'name'	=>(
	is		=> 'rw',
	isa		=> 'Str',
);


after 'BUILD' => sub {
	my $self = shift;
};

sub load_i18n{
	my ($self,$path,$lang) = @_;
	$self->loc->add_localizer(class => "Gettext",path  => $path."/".$self->name()."/".$lang.".po");
	$self->loc->set_languages($lang);
	foreach ($self->all_commands){
		$self->register_command($self->loc->localize($_),$lang);
	}
}

1;
