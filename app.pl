use xmpbot;
use xmpbot::Database;

my $bot = xmpbot->new(
	jid => 'beerbot@jabbim.pl',
	passwd => '***********',
	db=> xmpbot::Database->new(
		DBDriver=>'SQLite',
		DBAddr=>'data/db',
		DBUser=>'',
		DBPasswd=>''),
);

$bot->load_plugin('xmpbot::Plugin::Echo');
$bot->load_plugin('xmpbot::Plugin::Ping');
$bot->load_plugin('xmpbot::Plugin::Help');
$bot->load_plugin('xmpbot::Plugin::Translate');
$bot->load_plugin('xmpbot::Plugin::Wikipedia');
$bot->load_plugin('xmpbot::Plugin::Cloudmade');
$bot->load_plugin('xmpbot::Plugin::Aspell');
$bot->load_plugin('xmpbot::Plugin::Set');
$bot->load_plugin('xmpbot::Plugin::Get');

#$bot->load_language("pl");

$bot->run;
