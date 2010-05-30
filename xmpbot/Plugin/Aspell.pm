package Aspell;
use Text::Aspell;
no utf8;
use Encode;
with 'xmpbot::Plugin';

sub BUILD {
	my $self = shift;
	$self->command('aspell');
	$self->description('');
	$self->help('');
}


sub msg_cb {
	my ($self, $msg) = @_;
	my ($lang,$word) = split(/ /, $msg);
	print "Aspell.pm:".$lang."-".$word."\n";
	my $speller = Text::Aspell->new;
	$speller->set_option('sug-mode','fast');
	if($lang eq "lista"){		
		my $ret="Dostępne słowniki";
		@dicts = $speller->dictionary_info;		
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
