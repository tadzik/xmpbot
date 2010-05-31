use xmpbot;

my $bot = xmpbot->new(
	jid => 'johndoe@jabber.com',
	passwd => 'neverforget'
);

$bot->load_plugin('xmpbot::Plugin::Echo');
$bot->load_plugin('xmpbot::Plugin::Ping');
$bot->load_plugin('xmpbot::Plugin::Help');
$bot->load_plugin('xmpbot::Plugin::Wikipedia');
$bot->load_plugin('xmpbot::Plugin::Aspell');
$bot->load_plugin('xmpbot::Plugin::Translate');
$bot->load_plugin('xmpbot::Plugin::Cloudmade');

$bot->run;
