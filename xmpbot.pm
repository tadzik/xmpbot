package xmpbot;
use feature ':5.10';
use lib 'plugins';
use AnyEvent;
use AnyEvent::XMPP::Client;
use Module::Load;
use Moose;
use MooseX::NonMoose;
use Data::Dumper;
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
has 'DBAddOptions' => (
	is		=> 'ro',
	isa		=> 'Int',
	default => 1
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
	my ($self, $user, $option) = @_;
	my $sth = $self->db->prepare("SELECT value FROM users,vals,options WHERE jid=? AND name=? AND options.id=optionID AND users.id=userID ");
	$sth->bind_param(1, $user, SQL_VARCHAR);
	$sth->bind_param(2, $option, SQL_VARCHAR);
	$sth->execute() or print $sth->errstr()."\n";
	my @result = $sth->fetchrow_array();
	my $val = $result[0];
 	return $val;
}

sub setOption{
	my ($self, $user, $option, $value) = @_;
	my $optionID;
	my $userID;

	#OPTIONS
	my $sth = $self->db->prepare("SELECT id FROM  options WHERE name=?");
	$sth->bind_param(1, $option, SQL_VARCHAR);
	$sth->execute();# or die $sth->errstr();
	my @result = $sth->fetchrow_array();
	#not found
	if($#result<0&&$self->addOptions==1){
		my $optionAddQuery = $self->db->prepare("INSERT INTO options (name) VALUES (?)");
		$optionAddQuery->bind_param(1, $option, SQL_VARCHAR);
		$optionAddQuery->execute();
		$optionID=$self->db->func('last_insert_rowid');
	}else{
		$optionID = $result[0];
	}
	print 'OPTIONID:'.$optionID."\n";
	#USERS
	my $q2 = $self->db->prepare("SELECT id FROM  users WHERE jid=?");
	$q2->bind_param(1, $user, SQL_VARCHAR);
	$q2->execute();
	my @usersRESULT = $q2->fetchrow_array();
	#not found
	if($#usersRESULT<0){
		my $userAddQuery = $self->db->prepare("INSERT INTO users (jid) VALUES (?)");
		$userAddQuery->bind_param(1, $user, SQL_VARCHAR);
		$userAddQuery->execute();
		$userID=$self->db->func('last_insert_rowid');
	}else{
		$userID = $result[0];
	}
	print 'USERID:'.$userID."\n";
	#SETVALUE
	my $q3 = $self->db->prepare("INSERT INTO vals (userID,optionID,value) SELECT ?,?,NULL  WHERE ? NOT IN (SELECT optionID FROM vals WHERE userID=? AND optionID=?)");
	#TODO: It's UGLY
	$q3->bind_param(1, $userID, SQL_INTEGER);
	$q3->bind_param(2, $optionID, SQL_INTEGER);
	$q3->bind_param(3, $optionID, SQL_INTEGER);
	$q3->bind_param(4, $userID, SQL_INTEGER);
	$q3->bind_param(5, $optionID, SQL_INTEGER);
	$q3->execute();
	my $q4 = $self->db->prepare("UPDATE vals SET value=? WHERE userID = ? AND optionID=?");
	$q4->bind_param(1, $value, SQL_VARCHAR);
	$q4->bind_param(2, $userID, SQL_INTEGER);
	$q4->bind_param(3, $optionID, SQL_INTEGER);
	$q4->execute();

	#TODO:
	#return 0-OPTION not found 1-OK
}


sub BUILD {
	my $self = shift;
	$self->db(DBI->connect("dbi:".$self->DBDriver.":".$self->DBAddr,$self->DBUser,$self->DBPasswd));
	if(checkdb()==1){
		print "Baza poprawna\n";
	}
	setOption($self,"cos","lang","en");
	print "GET:".getOption($self,"cos","lang")."\n";
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
				my $ret = $plugin->{plugin}->msg_cb($args, $self,$msg);
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
