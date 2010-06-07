package Net::Snarl;

use warnings;
use strict;

use IO::Socket;
use Carp;

=head1 NAME

Net::Snarl - Snarl network protocol

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use constant SNARL_PORT           => 9887;
use constant SNARL_PROTO_VERSION  => '1.0';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Snarl;

    my $foo = Net::Snarl->new();
    ...

=cut

sub _send {
  my ($self, %param) = @_;
  
  my $data = 'type=SNP#?version=' . Net::Snarl::SNARL_PROTO_VERSION . '#?' . 
    join('#?', map "$_=$param{$_}", keys %param);
    
  print "> $data\n";
    
  $self->{socket}->print("$data\x0d\x0a");
  $self->_recv;  
}

sub _recv {
  my ($self) = @_;
  
  my $data = $self->{socket}->getline();
  chomp $data;
  
  print "< $data\n";
  
  my ($header, $version, $code, $desc, @rest) = split /\//, $data;
  
  die "Unexpected response: $data" unless $header eq 'SNP';
  
  if ($code >= 300) {
    push @{$self->{queue}}, [$code, $desc, @rest];
    return $self->_recv;
  }
  
  return $code, $desc, @rest;
}
    
=head1 SUBROUTINES/METHODS

=head2 register($application, $host, $port)

Connects to Snarl and register an application.  Host defaults to localhost and 
port defaults to C<Net::Snarl::SNARL_PORT>.

=cut

sub register {
  my ($class, $application, $host, $port) = @_;
  
  croak 'Cannot call register as an instance method' if ref $class;
  croak 'Application name required' unless $application;
  
  my $socket = IO::Socket::INET->new(
    PeerAddr  => $host || 'localhost',
    PeerPort  => $port || Net::Snarl::SNARL_PORT,
    Proto     => 'tcp',
  ) or die "Unable to create socket: $!";
  
  my $self = bless { socket => $socket, application => $application }, $class;
  
  my ($result, $text) = $self->_send(
    action => 'register', 
    app => $application
  );
  
  die "Unable to register: $text" if $result;
  
  return $self;
}

=head2 add_class($class, $title)

Registers a notification class with your application.  Title is the optional 
friendly name for the class.

=cut

sub add_class {
  my ($self, $class, $title) = @_;
  
  croak 'Cannot call add_class as a class method' unless ref $self;
  croak 'Class name required' unless $class;
  
  my ($result, $text) = $self->_send(
    action  => 'add_class', 
    app     => $self->{application},
    class   => $class,
    title   => $title || $class,
  );
  
  die "Unable to add class: $text" if $result;
}

=head2 notify($class, $title, $text, $timeout)

Displays a notification of the specified class.  Timeout defaults to 0 (sticky).

=cut

sub notify {
  my ($self, $class, $title, $text, $timeout) = @_;
  
  croak 'Cannot call notify as a class method' unless ref $self;
  croak 'Class name required' unless $class;
  croak 'Title required' unless $title;
  croak 'Text required' unless $text;
  
  my ($result, $rtext) = $self->_send(
    action  => 'notification',
    app     => $self->{application},
    class   => $class,
    title   => $title,
    text    => $text,
    timeout => $timeout || 0,
  );
  
  die "Unable to send notification: $rtext" if $result;
}

sub DESTROY {
  my ($self) = @_;
  
  $self->_send(
    action  => 'unregister',
    app     => $self->{application},
  );
}

=head1 AUTHOR

Alan Berndt, C<< <alan at eatabrick.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-snarl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Snarl>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Snarl


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Snarl>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Snarl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Snarl>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Snarl/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alan Berndt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Net::Snarl
