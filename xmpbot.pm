package xmpbot;
use feature ':5.12';
use strict;
use warnings;
use AnyEvent;
use AnyEvent::XMPP::Client;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::Version;
use Moose;
use MooseX::NonMoose;
#use Module::Pluggable;
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

has '_condvar' => (
	is	=> 'ro',
	default	=> sub { AnyEvent->condvar; },
);

has '_disco' => (
	is	=> 'ro',
	default	=> sub { AnyEvent::XMPP::Ext::Disco->new; },
);

has '_version' => (
	is	=> 'ro',
	default	=> sub { AnyEvent::XMPP::Ext::Version->new; },
);

sub BUILD {
	my $self = shift;
	$self->add_extension($self->_disco);
	$self->add_extension($self->_version);
	$self->set_presence(undef, "Hurr, I'm a bot");
	$self->add_account($self->jid, $self->passwd);
	$self->reg_cb(
		session_ready => sub {
			warn "Connected\n";
		},
		message => sub {
			my ($cl, $acc, $msg) = @_;
			my $repl = $msg->make_reply;
			$repl->add_body('Nieznane polecenie. Hi hi.');
			$repl->send;
		},
		contact_request_subscribe => sub {
			my ($cl, $acc, $roster, $contact) = @_;
			#automagically accepting subscription request
			$contact->send_subscribed;
		},
		error => sub {
			my ($cl, $acc, $error) = @_;
			warn "Error encountered: ".$error->string."\n";
		},
		disconnect => sub {
			warn "Whoops, disconnected (@_)\n";
		},
	);
}

sub run {
	my $self = shift;
	$self->start;
	$self->_condvar->wait;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
