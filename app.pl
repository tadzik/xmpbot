use xmpbot;

my $bot = xmpbot->new(
	jid => 'johndoe@jabber.com',
	passwd => 'neverforget'
);

$bot->run;
