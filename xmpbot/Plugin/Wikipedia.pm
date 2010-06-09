package xmpbot::Plugin::Wikipedia;
use LWP::Simple;
use utf8;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('wiki');
	$self->name("wikipedia");
}

sub getDescription{
	my($self) = @_;
	return $self->loc->localize('query wikipedia.org');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('This plugin looks up desired article on wikipedia.org and prints it to the user');
}


sub wiki{
	my ($self, $msg) = @_;
	$msg=~ tr/ /_/; #changing white spaces
	my ($wiki,$rozdzial) = split(/#/, $msg);
	#TODO: Zazwyczaj jak ktoś szuka jakiś informacji najpierw wpisze np. wiki Warszawa potem wiki Warszawa#1 itp. Dlatego potrzebny cashe (najlepiej w db)
	#TODO: lang.wikipedia.org ......
	my $url = "http://pl.wikipedia.org/w/api.php?action=query&prop=revisions&titles=".$wiki."&rvprop=content&format=xml";
	print "Wikipedia.pm: Download from ".$url."\n";
	my $content = get $url; #pobieramy dane	

	$content=~ s/^([\S\s])*<rev[^>]*>//; #usuwanie tagów XML
	$content=~ s/<\/rev[\s\S]*$//;

	#TODO: Można to ulepszyć
	my $regex = qr/({{([^\}\{])*}})/;
	$content=~ s/$regex//g;
	$content=~ s/$regex//g;
	$content=~ s/$regex//g;
	$content=~ s/&[^\s\;]*;//g;


	#Zmiana linków wikipedi na linki bota
	$content=~ s/\[\[([^\]\:\|]*)\]\]/$1 {wiki $1}/g;
	$content=~ s/\[\[([\w\s\(\)\.]*)\|([\w\s\(\)\.]*)\]\]/$2 {wiki $1}/g;
	#Usuwamy to co zostalo (moze warto potem wyciągnąć różne wersje językowe)
	$content=~ s/\[\[[^\]]*\]\]//g;
	#remove new line
#	$content=~ s///g;

	#Pobieramy rozdziały
	my @rozdzialy = ();
	while ( $content =~ m/(=(==*)([^=]*)===*(([^=]|=[^=])*))/g ){
	    	push (@rozdzialy, [$2,$3,$4]);
	}	
	$content=~ s/==[\s\S]*//;

	my $ret;

	if($rozdzial==""){ #gdy nie podano rozdziału		
		$content=$content."\n\nSpis treści:";
		for(my $i=0; $i<$#rozdzialy; $i++) {
			$content=$content."\n{wiki $wiki#".($i+1)."}.".$rozdzialy[$i][0].$rozdzialy[$i][1];
		} 
		$ret=$content;
	}else{
		$ret=$rozdzialy[$rozdzial-1][2];
	}
	$ret="Źródło: http://pl.wikipedia.org/wiki/".$wiki."\n\n".$ret;
	return $ret;
}


1;
