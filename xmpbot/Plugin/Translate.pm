package xmpbot::Plugin::Translate;
use Lingua::Translate;
use utf8;

sub init {
	return ['tr', '',
		''];
}

sub msg_cb {
	#TODO: Another engines(get option from db)
	#TODO: security-src,desc
	my ($self, $msg) = @_;
	($langs,$text) = split(/ /, $msg,2);	
	($src,$desc) = split(/2/, $langs); 

	Lingua::Translate::config(back_end => 'Google');


	my $xl8r = Lingua::Translate->new(src => $src,
                                   dest => $desc)
	or return "Nie obsługiwane tłumaczenie $src -> $desc";

	print $src."2".$desc." ".$text."\n";
	return $xl8r->translate($text); 	
}

1;
