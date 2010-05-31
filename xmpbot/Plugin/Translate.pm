package xmpbot::Plugin::Translate;
use Lingua::Translate;

no utf8;
use Encode;
use Moose;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('tr');
	$self->description('translate');
	$self->help('example: translate pl2en Co u Ciebie?');
}
sub msg_cb {
	#TODO: Another engines(get option from db)
	#TODO: security-src,desc
	my ($self, $msg) = @_;
	my ($langs,$text) = split(/ /, $msg,2);	
	my ($src,$desc) = split(/2/, $langs); 

	Lingua::Translate::config(back_end => 'Google');


	my $xl8r = Lingua::Translate->new(src => $src,
                                   dest => $desc)
	or return "Nie obsługiwane tłumaczenie $src -> $desc";

	return decode 'utf8', $xl8r->translate($text);
}

1;
