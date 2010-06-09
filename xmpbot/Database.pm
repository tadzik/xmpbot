package xmpbot::Database;
use Moose;
use DBI qw(:sql_types);


has 'dbi' => (
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

sub BUILD {
	my $self = shift;
	$self->dbi(DBI->connect("dbi:".$self->DBDriver.":".$self->DBAddr,$self->DBUser,$self->DBPasswd));
	if(checkdb()==1){
		print "Baza poprawna\n";
	}
}

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
	my $sth = $self->dbi->prepare("SELECT value FROM users,vals,options WHERE jid=? AND name=? AND options.id=optionID AND users.id=userID ");
	$sth->bind_param(1, $user, SQL_VARCHAR);
	$sth->bind_param(2, $option, SQL_VARCHAR);
	$sth->execute() or print $sth->errstr()."\n";
	my @result = $sth->fetchrow_array();
	my $val = $result[0];
	print $val,"\n";
 	return $val;
}

sub setOption{
	my ($self, $user, $option, $value) = @_;
	my $optionID;
	my $userID;

	#OPTIONS
	my $sth = $self->dbi->prepare("SELECT id FROM  options WHERE name=?");
	$sth->bind_param(1, $option, SQL_VARCHAR);
	$sth->execute();# or die $sth->errstr();
	my @result = $sth->fetchrow_array();
	#not found
	if($#result<0&&$self->addOptions==1){
		my $optionAddQuery = $self->dbi->prepare("INSERT INTO options (name) VALUES (?)");
		$optionAddQuery->bind_param(1, $option, SQL_VARCHAR);
		$optionAddQuery->execute();
		$optionID=$self->db->func('last_insert_rowid');
	}else{
		$optionID = $result[0];
	}
	print 'OPTIONID:'.$optionID."\n";
	#USERS
	my $q2 = $self->dbi->prepare("SELECT id FROM  users WHERE jid=?");
	$q2->bind_param(1, $user, SQL_VARCHAR);
	$q2->execute();
	my @usersRESULT = $q2->fetchrow_array();
	#not found
	if($#usersRESULT<0){
		print "User not found","\n";
		my $userAddQuery = $self->dbi->prepare("INSERT INTO users (jid) VALUES (?)");
		$userAddQuery->bind_param(1, $user, SQL_VARCHAR);
		$userAddQuery->execute();
		$userID=$self->db->func('last_insert_rowid');
	}else{
		$userID = $usersRESULT[0];
	}
	print 'USERID:'.$userID.",".$user."\n";
	#SETVALUE
	my $q3 = $self->dbi->prepare("INSERT INTO vals (userID,optionID,value) SELECT ?,?,NULL  WHERE ? NOT IN (SELECT optionID FROM vals WHERE userID=? AND optionID=?)");
	#TODO: It's UGLY
	$q3->bind_param(1, $userID, SQL_INTEGER);
	$q3->bind_param(2, $optionID, SQL_INTEGER);
	$q3->bind_param(3, $optionID, SQL_INTEGER);
	$q3->bind_param(4, $userID, SQL_INTEGER);
	$q3->bind_param(5, $optionID, SQL_INTEGER);
	$q3->execute();
	my $q4 = $self->dbi->prepare("UPDATE vals SET value=? WHERE userID = ? AND optionID=?");
	$q4->bind_param(1, $value, SQL_VARCHAR);
	$q4->bind_param(2, $userID, SQL_INTEGER);
	$q4->bind_param(3, $optionID, SQL_INTEGER);
	$q4->execute();

	#TODO:
	#return 0-OPTION not found 1-OK
}
1;

