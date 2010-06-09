package xmpbot::Plugin::Aspell;
use Text::Aspell;
no utf8;
use Encode;
use Moose;
with 'xmpbot::Plugin';
with 'xmpbot::Translations';

sub BUILD {
	my $self = shift;
	$self->register_command('aspell');
	$self->name("aspell");
}


sub getDescription{
	my($self) = @_;
	return $self->loc->localize('validation word');
}

sub getHelp{
	my($self) = @_;
	return $self->loc->localize('example: aspell en who');
}


sub aspell{
	my ($self, $msg) = @_;
	my ($lang,$word) = split(/ /, $msg);
	print "Aspell.pm:".$lang."-".$word."\n";
	my $speller = Text::Aspell->new;
	$speller->set_option('sug-mode','fast');
	if($lang eq "lista"){		
		my $ret="Dostępne słowniki";
		my @dicts = $speller->dictionary_info;		
		foreach (@dicts) {
			$ret=$ret.$_->{'code'}.", ";
		}
		return $ret;
	}

	$speller->set_option('lang',$lang);



	# check a word
	if($speller->check( $word)){
		return "Znaleziono";
	}
	else{
		my $ret="Nie znaleziono, sugestie:\n";
		my @suggestions = $speller->suggest( $word );
		foreach (@suggestions) {
			$ret=$ret.$_.", ";
		}
		return decode 'utf8', $ret;
	}
}


1;
