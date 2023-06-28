#!/usr/bin/perl

use strict;
use warnings;

# Program to connect people from different communities 

# Libraries used 
use DBI;
use Data::Dumper;

# DB Connection Details
my $driver   = "Pg"; 
my $database = "CommunityConnectionsDB";
my $dsn = "DBI:$driver:dbname=$database;host=localhost;port=5432";
my $userid = "username";
my $password = "password";

# Connect to Database
my $dbh = DBI->connect($dsn, $userid, $password) 
       or die $DBI::errstr;
       
# Create table to store user details
my $user_info_table_query = qq(
	CREATE TABLE user_info ( 
		user_id INTEGER NOT NULL, 
		name VARCHAR(100) NOT NULL, 
		location VARCHAR(100) NOT NULL, 
		interests VARCHAR(200) NOT NULL, 
		PRIMARY KEY (user_id) 
	);
);
$dbh->do($user_info_table_query);

# Create table to store connection details
my $connections_table_query = qq(
	CREATE TABLE connections ( 
		user_id_1 INTEGER NOT NULL, 
		user_id_2 INTEGER NOT NULL, 
		connection_type VARCHAR(50) NOT NULL, 
		PRIMARY KEY (user_id_1, user_id_2) 
	);
);
$dbh->do($connections_table_query);

# Create table to store events information
my $events_table_query = qq(
	CREATE TABLE events ( 
		event_id INTEGER NOT NULL, 
		event_name VARCHAR(100) NOT NULL, 
		event_date VARCHAR(50) NOT NULL, 
		event_location VARCHAR(100) NOT NULL, 
		event_time VARCHAR(50) NOT NULL, 
		event_description VARCHAR(500) NOT NULL, 
		PRIMARY KEY (event_id)
	);
);
$dbh->do($events_table_query);

# Create table to store user event participation
my $user_event_table_query = qq(
	CREATE TABLE user_events ( 
		user_id INTEGER NOT NULL, 
		event_id INTEGER NOT NULL,
		attended INTEGER NOT NULL,
		PRIMARY KEY (user_id, event_id) 
	);
);
$dbh->do($user_event_table_query);

# Insert user information into table 
sub insertUser {
	my $user_id = shift;
	my $name = shift;
	my $location = shift;
	my $interests = shift;

  	my $query = qq(INSERT INTO user_info(user_id, name, location, interests) 
  					VALUES ($user_id, '$name', '$location', '$interests'));
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Insert connections between users into table
sub insertConnections {
	my $user_id_1 = shift;
	my $user_id_2 = shift;
	my $connection_type = shift;

	my $query = qq(INSERT INTO connections(user_id_1, user_id_2, connection_type) 
  					VALUES ($user_id_1, $user_id_2, '$connection_type'));
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
}

# Insert events into table
sub insertEvents {
	my $event_id = shift;
	my $event_name = shift;
	my $event_date = shift;
	my $event_location = shift;
	my $event_time = shift;
	my $event_description = shift;
	
	my $query = qq(INSERT INTO events(event_id, event_name, event_date, event_location, event_time, event_description) 
  					VALUES ($event_id, '$event_name', '$event_date', '$event_location', '$event_time', '$event_description'));
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Insert user event participation into table
sub insertUserEvents {
	my $user_id = shift;
	my $event_id = shift;
	my $attended = shift;

	my $query = qq(INSERT INTO user_events(user_id, event_id, attended) 
  					VALUES ($user_id, $event_id, $attended) );
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Get user information from table
sub getUser {
	my $user_id = shift;
	
	my $query = qq(SELECT * FROM user_info 
					WHERE user_id=$user_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my $user_details = $sth->fetchrow_hashref();
	return $user_details;
}

# Get connections between two users
sub getConnections {
	my $user_id_1 = shift;
	my $user_id_2 = shift;
	
	my $query = qq(SELECT * FROM connections 
					WHERE (user_id_1=$user_id_1 AND user_id_2=$user_id_2 ) 
					OR (user_id_1=$user_id_2 AND user_id_2=$user_id_1 ) );
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my $connection_details = $sth->fetchrow_hashref();
	return $connection_details;
}

# Get event details from table
sub getEvents {
	my $event_id = shift;
	
	my $query = qq(SELECT * FROM events 
					WHERE event_id=$event_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my $event_details = $sth->fetchrow_hashref();
	return $event_details;
}

# Get user event participation
sub getUserEvents {
	my $user_id = shift;
	my $event_id = shift;

	my $query = qq(SELECT * FROM user_events 
					WHERE user_id=$user_id AND event_id=$event_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my $user_event_details = $sth->fetchrow_hashref();
	return $user_event_details;
}

# Update user details 	
sub updateUser {
	my $user_id = shift;
	my $name = shift;
	my $location = shift;
	my $interests = shift;

	my $query = qq(UPDATE user_info SET 
						name='$name', location='$location', interests='$interests'
					WHERE user_id=$user_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Update connection details 
sub updateConnections {
	my $user_id_1 = shift;
	my $user_id_2 = shift;
	my $connection_type = shift;

	my $query = qq(UPDATE connections SET 
						connection_type='$connection_type'
					WHERE user_id_1=$user_id_1 AND user_id_2=$user_id_2);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Update event details
sub updateEvents {
	my $event_id = shift;
	my $event_name = shift;
	my $event_date = shift;
	my $event_location = shift;
	my $event_time = shift;
	my $event_description = shift;
	
	my $query = qq(UPDATE events SET 
						event_name='$event_name', event_date='$event_date', 
						event_location='$event_location', event_time='$event_time', 
						event_description='$event_description'
					WHERE event_id=$event_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# Update user event participation
sub updateUserEvents {
	my $user_id = shift;
	my $event_id = shift;
	my $attended = shift;
	
	my $query = qq(UPDATE user_events SET 
						attended='$attended'
					WHERE user_id=$user_id AND event_id=$event_id);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
}

# List all users
sub listUsers {
	my $query = qq(SELECT * FROM user_info);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my @users;
	while (my @row = $sth->fetchrow_array()) {
		push(@users, \@row);
	}
	
	return @users;
}

# List all events
sub listEvents {
	my $query = qq(SELECT * FROM events);
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my @events;
	while (my @row = $sth->fetchrow_array()) {
		push(@events, \@row);
	}
	
	return @events;
}

# Search for users
sub searchUsers {
	my $keyword = shift;
	
	my $query = qq(SELECT * FROM user_info 
					WHERE name LIKE '%$keyword%'
					OR location LIKE '%$keyword%' 
					OR interests LIKE '%$keyword%');
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my @users;
	while (my @row = $sth->fetchrow_array()) {
		push(@users, \@row);
	}
	
	return @users;
}

# Search for events
sub searchEvents {
	my $keyword = shift;
	
	my $query = qq(SELECT * FROM events 
					WHERE event_name LIKE '%$keyword%'
					OR event_date LIKE '%$keyword%'
					OR event_location LIKE '%$keyword%'
					OR event_time LIKE '%$keyword%'
					OR event_description LIKE '%$keyword%');
	my $sth = $dbh->prepare($query);
	$sth->execute() or die $DBI::errstr;
	
	my @events;
	while (my @row = $sth->fetchrow_array()) {
		push(@events, \@row);
	}
	
	return @events;
}

# Disconnect from Database
$dbh->disconnect();