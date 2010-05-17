package xmpbot::Plugin::Wikipedia;
use LWP::Simple;
use utf8;

sub init {
	return ['wiki', '',
		''];
}

sub msg_cb {
	my ($self, $msg) = @_;
	$msg=~ tr/ /_/; #zamiana białych znaków na "_"
	($wiki,$rozdzial) = split(/#/, $msg);
	my $url = "http://pl.wikipedia.org/w/api.php?action=query&prop=revisions&titles=".$wiki."&rvprop=content&format=xml";
	my $content = get $url; #pobieramy dane
	#if($content== ?? )
	#	return "Nie ma takiego hasła";

	$content=~ s/^([\S\s])*<rev[^>]*>//; #usuwanie tagów XML
	$content=~ s/<\/rev[\s\S]*$//;

	#WYCIĄGANIE INFOBOXÓW
	#my $infoboxy = [];
	#while ( $content =~ m/({{(\0|(?R)|[^\}\{])*}})/g ){
	#    	push (@infoboxy, $1);
	#}	
	#print $#infoboxy;
	#USUWANIE INFOBOXÓW
	#$content=~ s/({{*(\1|[^\}\{])*}*})//;

	#Zmiana linków wikipedi na linki bota
	$content=~ s/\[\[([^\]\:\|]*)\]\]/\1 {wiki \1}/g;
	$content=~ s/\[\[([\w\s\(\)\.]*)\|([\w\s\(\)\.]*)\]\]/\2 {wiki \1}/g;
	#Usuwamy to co zostalo (moze warto potem wyciągnąć różne wersje językowe)
	$content=~ s/\[\[[^\]]*\]\]//g;

	#Pobieramy rozdziały
	my $rozdzialy = [];
	while ( $content =~ m/(=(==*)([^=]*)===*(([^=]|=[^=])*))/g ){
	    	push (@rozdzialy, [$2,$3,$4]);
	}	
	#zostawiamy tylko wstęp
	$content=~ s/==[\s\S]*//;


	if($rozdzial==""){ #gdy nie podano rozdziału		
		$content=$content."\n\nSpis treści:";
		$i=0;
		for(my $i=0; $i<$#rozdzialy; $i++) {
			$content=$content."\n{wiki $wiki#".($i+1)."}.".$rozdzialy[$i][0].$rozdzialy[$i][1];
		} 
		return $content;
	}else{
		return $rozdzialy[$rozdzial-1][2];
	}
}

1;


