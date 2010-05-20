package xmpbot;
use feature ':5.10';
use lib 'plugins';
use AnyEvent;
use AnyEvent::XMPP::Client;
use Moose;
use MooseX::NonMoose;
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

sub BUILD {
	my $self = shift;
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
	require $plugin . '.pm';
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
