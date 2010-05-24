package xmpbot;
use feature ':5.10';
use lib 'plugins';
use AnyEvent;
use AnyEvent::XMPP::Client;
use Module::Load;
use Moose;
use MooseX::NonMoose;
use DBI qw(:sql_types);
extends 'AnyEvent::XMPP::Client';

  
has 'jid' => (
	is		=> 'ro',
	isa		=> 'Str',
	required	=> 1,
);

has 'passwd' => (
	is		=> 'ro',
	isa		=> 'Str',
	required	=> 1,
);

has 'plugins' => (
	is	=> 'ro',
	isa	=> 'HashRef[HashRef[Str]]',
	default	=> sub { {} },
	traits	=> ['Hash'],
	handles	=> {
		set_plugin	=> 'set',
		get_plugin	=> 'get',
		plugins_pairs	=> 'kv',
	},
);

has 'verbose' => (
	is	=> 'rw',
	isa	=> 'Bool',
	default	=> 0,
);

has 'db' => (
	is => 'rw',
);

has 'DBAddr' => (
	is		=> 'ro',
	isa		=> 'Str',
	required	=> 1,
);
has 'DBDriver' => (
	is		=> 'ro',
	isa		=> 'Str',
	default => 'SQLite'
);
has 'DBUser' => (
	is		=> 'ro',
	isa		=> 'Str',
	default => ''
);
has 'DBPasswd' => (
	is		=> 'ro',
	isa		=> 'Str',
	default => ''
);



sub checkdb{
	#tables
	#$db->do("CREATE TABLE options (id INTEGER PRIMARY KEY, name)");
	#$db->do("CREATE TABLE users (id INTEGER PRIMARY KEY, jid)");
	#$db->do("CREATE TABLE vals (id INTEGER PRIMARY KEY, userID, optionID,value)");
	#TODO:CHECK
	return 1;
}

sub getOption{
#	my ($self, $user, $option) = @_;
#	my $sth = $self->db->prepare("SELECT value FROM users,vals,options WHERE jid=? AND name=? AND options.id=optionID AND users.id=userID ");
#	$sth->bind_param(1, $user, SQL_STRING);
#	$sth->bind_param(2, $option, SQL_TEXT);
#	$sth->execute();
#	my $row = $sth->fetch;
#	my $val = $row->[1];
# 	return $val;
}

sub BUILD {
	my $self = shift;
	$self->db(DBI->connect("dbi:".$self->DBDriver.":".$self->DBAddr,$self->DBUser,$self->DBPasswd));
	if(checkdb()==1){
		print "Baza poprawna\n";
	}
	$self->set_presence(undef, "Hurr, I'm a bot");
	$self->add_account($self->jid, $self->passwd);
	$self->reg_cb(
		session_ready => sub {
			$self->log("Connected\n");
		},
		message => sub {
			my ($cl, $acc, $msg) = @_;
			return unless $msg;
			my ($comm, $args) = split / /, $msg, 2;
			my $repl = undef;
			my $plugin = $self->get_plugin($comm);
			if ($plugin) {
				my $ret = $plugin->{plugin}->msg_cb($args, $self);
				if ($ret) {
					$repl = $msg->make_reply;
					$repl->add_body($ret);
				}
			} else {
				$repl = $msg->make_reply;
				$repl->add_body("Unknown command: $comm");
			}
			$repl->send if $repl;
		},
		contact_request_subscribe => sub {
			my ($cl, $acc, $roster, $contact) = @_;
			#automagically accepting subscription request
			$contact->send_subscribed;
		},
		error => sub {
			my ($cl, $acc, $error) = @_;
			$self->log("Error encountered: ".$error->string."\n");
		},
		disconnect => sub {
			$self->log("Whoops, disconnected (@_)\n");
		},
	);
}

sub load_plugin {
	my ($self, $plugin) = @_;
	load $plugin;
	my $ret = $plugin->init;
	next unless $ret;
	if ($self->get_plugin(@$ret[0])) {
		$self->log("Plugin $plugin tried to register a ",
		"keyword @$ret[0], which is alredy registered\n");
	} else {
		# TODO: Support for passive plugins maybe?
		# So they return undef instead of a keyword
		# and always handle every message.
		# Usecase? Logs, or something
		$self->set_plugin(
			@$ret[0] => {
				plugin	=> $plugin,
				info	=> @$ret[1],
				help	=> @$ret[2],
			},
		);
		$self->log("Registered plugin $plugin ",
			"with keyword @$ret[0]\n");
	}
}

sub log {
	my ($self, @args) = @_;
	if($self->verbose) {
		print @args;
	}
}

sub run {
	my $self = shift;
	my $c = AnyEvent->condvar;
	$self->start;
	$c->wait;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
