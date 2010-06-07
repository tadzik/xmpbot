package xmpbot;
use feature ':5.10';
use AnyEvent;
use AnyEvent::XMPP::Client;
use Module::Load;
use Moose;
use MooseX::NonMoose;
use Data::Dumper;
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
	isa	=> 'HashRef',
	default	=> sub { {} },
	traits	=> ['Hash'],
	handles	=> {
		set_plugin	=> 'set',
		get_plugin	=> 'get',
		plugins_pairs	=> 'kv',
	},
);

has 'status' => (
	is		=> 'rw',
	isa		=> 'Str',
	default	=> sub { 'xmpbot' },
);

has 'verbose' => (
	is	=> 'rw',
	isa	=> 'Bool',
	default	=> 0,
);

has 'db' => (
	is	=> 'rw',
	isa	=> 'xmpbot::Database',
);




sub BUILD {
	my $self = shift;	
	$self->set_presence(undef, $self->status);
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
				if($plugin->does('xmpbot::Translations')){
					my @user=split(/\//, $msg->from);
					$plugin->{loc}->set_languages($self->db->getOption($user[0],'lang'));
				}
				my $ret = $plugin->$comm($args);
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
	# we don't need the actual object, it'll take care of itself
	$plugin->new(bot => $self);
	$self->log("Registered plugin $plugin\n");
}

sub load_language{
	my ($self,$language)=@_;
	my $hash=$self->plugins;
	while ( my ($key, $value) = each(%$hash) ) {   
		if($value->does('xmpbot::Translations')){
			$value->load_i18n("xmpbot/i18n/",$language,$key);			
		}
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
