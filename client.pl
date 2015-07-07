#!/usr/bin/perl

use v5.012;
use IO::Socket::INET;

# auto-flush on socket
$| = 1;

my $server_port="5076";
my $server_host="127.0.0.1";

my $client_socket = IO::Socket::INET->new(
	PeerHost => $server_host,
	PeerPort => $server_port,
	Proto => 'tcp',
);

unless($client_socket){
	die "Couldn't create client socket - $!";
}

say "CLIENT connected to server";

my ($server_reply,$client_msg);

while(<STDIN>){
	$client_msg=$_;

	if($client_msg=~ /^quit$/){
		$client_socket->close();
		exit(0);
	}
	$client_socket->send($client_msg);

	$client_socket->recv($server_reply,1024);

	say "$server_reply";
	if($server_reply=~ /^quit$/){
		$client_socket->close();
		exit(0);
	}
}

sleep (10);
$client_socket->close();
