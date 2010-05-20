use xmpbot;

my $bot = xmpbot->new(
	jid => 'johndoe@jabber.com',
	passwd => 'neverforget'
);

$bot->load_plugin('Echo');
$bot->load_plugin('Ping');
$bot->load_plugin('Help');
$bot->load_plugin('Wikipedia');

$bot->run;
