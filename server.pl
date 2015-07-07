#!/usr/bin/perl

use v5.012;
use DBI;
use IO::Socket::INET;

my ($sth,$dbh);
&dbi_connect();

my $server_port="5076";
my $server_host="127.0.0.1";

$SIG{CHLD} = sub {wait ()};

# creating object interface of IO::Socket::INET modules which internally does socket creation, binding and listening at the specified port address.
my $server_socket = IO::Socket::INET->new(
	LocalHost => $server_host,
	LocalPort => $server_port,
	Listen => 2, #how many connections can receive at one time
	Proto => 'tcp', #protocol
	Reuse => 1
	# Type => 'SOCK_STREAM',	
) or die "Couldn't create server socket - $!";

listen($server_socket,2) or warn "couldnt listen - $!";
say "SERVER Waiting for client connection on port $server_port - pid $$";

my $client_count=-1;

while(my $client = $server_socket->accept()){ # waiting for new client connection.
	my $pid = fork(); 
    die "Cannot fork: $!" unless defined($pid);

    if($pid == 0){  # Child process  
        my $client_host = $client->peerhost(); # get the host and port number of newly connected client.
		my $client_port = $client->peerport();

		say "Accepted new client connection from : $client_host, $client_port ";

		$client->send("Welcome! Type help for command list.\n");

		my ($data,$users);
		while(<$client>){
			$data=$_;

			if($data =~ /^user\s(.*)/){
				my $registered;

				$sth=$dbh->prepare("SELECT * FROM users WHERE name='$1';");
				if($sth->execute() > 0){
					$registered=1;
				}else{
					$sth=$dbh->do("INSERT INTO users SET name='$1';");
				}
				$users->{$1}=1;
				$client->send("Hello, $1!");
			}elsif($data=~ /^list\sonline/){
				foreach my $user(%{$users}){
					$client->send($user);
				}
			}elsif($data =~ m/quit|exit/i){
				$client->close();
				exit(0);
			}elsif($data =~ m/date|time/i){
				printf $client "%s\n", scalar localtime();
			}elsif($data =~ m/who/i){
				print $client `who 2>&1`;
			}elsif($data =~ m/ls/i){
				print $client `ls`;					
			}elsif($data =~ m/help/i){
				$client->send("Commands: user date who ls help quit\n");
			}elsif($data =~ m/\S/){
				$client->send("Command?");
			}
		}
		exit(0);# Child process exits when it is done.
		sleep(10);
		$client->close() or warn "Couldn't close $client_host connection $!";
	} # else 'tis the parent process, which goes back to accept()
}	

sleep(10);
$server_socket->close();

sub dbi_connect(){
	my $driver="mysql";
	my $database="perl_project";
	my $hostname="localhost";
	my $user="svetlina";
	my $passwd="work_time";

	my $dsn="DBI:$driver:$database:$hostname";

	$dbh=DBI->connect($dsn,$user,$passwd) or die "Could not connect to database!";
}