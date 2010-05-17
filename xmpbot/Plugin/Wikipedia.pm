package xmpbot::Plugin::Wikipedia;
use LWP::Simple;

sub init {
	return ['wiki', '',
		''];
}

sub msg_cb {
	my ($self, $msg) = @_;
	$msg=~ tr/s/_/; #zamiana białych znaków na "_"
	($wiki,$rozdzial) = split(/#/, $msg);
	my $url = "http://pl.wikipedia.org/w/api.php?action=query&prop=revisions&titles=".$wiki."&rvprop=content&format=xml";
	my $content = get $url; #pobieramy dane
	#if($content== ?? )
	#	return "Nie ma takiego hasła";

	$content=~ s/^([\S\s])*<rev[^>]*>//; #usuwanie tagów XML
	$content=~ s/<\/rev[\s\S]*$//;

	#TODO:WYCIĄGANIE INFOBOXÓW
	#USUWANIE INFOBOXÓW
	#$content=~ s/(\{\{[\1^\{]*\}\}\s*)\1//;
	#

	#Zmiana linków wikipedi na linki bota
	$content=~ s/\[\[([^\]\:\|]*)\]\]/\1 {wiki \1}/g;
	$content=~ s/\[\[([\w\s\(\)\.]*)\|([\w\s\(\)\.]*)\]\]/\2 {wiki \1}/g;
	#Usuwamy to co zostalo (moze warto potem wyciągnąć różne wersje językowe)
	$content=~ s/\[\[[^\]]*\]\]//g;

	#Pobieramy rozdziały
	my $rozdzialy = [];
	while ( $content =~ m/===*([\w\s\(\)]*)=*==([^\=])*/g ){
	    push @$matches, [$1,$2];
	}
	
	$content=~ s/==[\s\S]*//;

	print $content;
	return $content;
}

1;


