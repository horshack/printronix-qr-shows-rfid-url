package Printer::Printronix::Talk9100;
use strict;
use warnings;
use Moo;
use IO::Socket;
use Params::Validate qw(validate_with OBJECT SCALAR);

=head1 SYNOPSIS

    use Printer::Printronix::Talk;
    my $talker = Printer::Printronix::Talk9100->new({
        host => '192.168.100.3',
        logger => $logger
    });

=cut

=head1 DESCRIPTION

Talk to Printronix T4000 printer with RFID-unit.
Read RFID-EPC-numbers, send commands to create label

=cut

has 'host' => ( is => 'rw', );

has 'port' => (
    is      => 'rw',
    default => 9100,
);

# Logger must be an object which is able to do the
# methods info, error, debug

has 'logger' => ( is => 'ro' );

has 'socket' => ( is => 'rw', );

has 'printer_is_in_verbose_mode' => (
    is => 'rw',
    default => 0,
);

# the current rfid-epc-code i found out
has 'epc_code' => (
    is => 'rw',
    default => '',
);

sub create_socket {
    my $self   = shift;
    my $logger = $self->logger;
    my $socket = IO::Socket::INET->new(
        PeerAddr => $self->host,
        PeerPort => $self->port,
        Proto    => 'tcp',
        Type     => SOCK_STREAM
      )
      or do {
        my $error_msg =
          "Can't talk to " . $self->host . " at port " . $self->port;
        $logger->error($error_msg);
        die $error_msg;
      };
    $self->socket($socket);
}

sub set_verbose_mode {
    my $self   = shift;
    my $logger = $self->logger;
    my $socket = $self->socket;

    # ~IDENTITY gives back exactly one line
    my $commands = <<'EOCMD';
~CONFIG 
SNOOP;STATUS
END

EOCMD

    my @cmds = split /\n/, $commands;
    for my $line (@cmds) {
        $logger->debug("Sending: $line");
        $socket->send( $line . "\n" );
    }

    $logger->debug("All commands sent to let our printer be verbose");
    $logger->debug("sending IDENTITY-command to check wether I get a result back");
    $socket->send("~IDENTITY\n");

    my $buffer = "";
    my $length = 200;
    $socket->recv( $buffer, $length );
    $logger->debug("I received this message: $buffer");
    $self->printer_is_in_verbose_mode(1);
}

sub set_silent_mode {
    my $self   = shift;
    my $logger = $self->logger;
    my $socket = $self->socket;

    # ~IDENTITY gives back exactly one line
    my $commands = <<'EOCMD';
~CONFIG 
SNOOP;OFF
END

EOCMD

    my @cmds = split /\n/, $commands;
    for my $line (@cmds) {
        $logger->debug("Sending: $line");
        $socket->send( $line . "\n" );
    }

    $logger->debug("All commands sent to let our printer be silent");
    $self->printer_is_in_verbose_mode(0);
}

sub find_out_current_epc_code {
    my $self = shift;
    my $logger = $self->logger;
    my $error_msg;
    my $socket = $self->socket;

    if (! $self->printer_is_in_verbose_mode) {
        $error_msg = "Printer must be in verbose mode to send commands to it, use \$obj->set_verbose_mode";
        $logger->logdie($error_msg);
    }
    my $commands = <<'EOCMD';
~CREATE;VERIFY;NOMOTION 
RFRTAG;96;EPC
96;DF511;H 
STOP
VERIFY;DF511;H;*STARTEPC=*;*=ENDEPC\n*
END 
~EXECUTE;VERIFY;1 
~NORMAL

EOCMD

    my @cmds = split /\n/, $commands;
    for my $line (@cmds) {
        $logger->debug("Sending: $line");
        $socket->send( $line . "\n" );
    }
    $logger->debug("I am ready sending the commands to get current epc-code");

    my $buffer = "";
    my $length = 200;
    $logger->debug("Now waiting for result from printer, the awaited epc-code");
    $socket->recv( $buffer, $length );
    $logger->debug("I received this message: ${buffer}");
    # There is a space-character after =ENDEPC!
    if ($buffer =~ m/^STARTEPC\=(.*)\=ENDEPC/) {
        my $epc_code = $1;
        $logger->debug("Found epc-code: $epc_code");
        $self->epc_code($epc_code);
    } else {
        $logger->error("Could not find epc-code in answer: $buffer");
    }
}

sub _read_line_from_socket {
    my $self = shift;
    my $logger = $self->logger;
    my $error_msg;
    my $socket = $self->socket;

    my $buffer = "";
    my $length = 200;

    $logger->debug("_read_line_from_socket: I received this message: ${buffer}");
    $socket->recv( $buffer, $length );
    $logger->debug("_read_line_from_socket: done");
}

sub execute_printjob {
    my $self = shift;
    my $args_href = validate_with(
        params => shift,
        spec => {
            pgl_commands => {
                type => SCALAR,
            }
        }
    );
    $self->_check_printjob($args_href);
    my $pgl_commands = $args_href->{pgl_commands};
    my $logger = $self->logger;

    my @cmds = split /\n/, $pgl_commands;
    my $socket = $self->socket;
    for my $line (@cmds) {
        $logger->debug("Sending: $line");
        $socket->send( $line . "\n" );
    }
}

sub _check_printjob {
    my $self = shift;
    my $args_href = validate_with(
        params => shift,
        spec => {
            pgl_commands => {
                type => SCALAR,
            }
        }
    );
    my $pgl_commands = $args_href->{pgl_commands};
    my $logger = $self->logger;

    # Check pgl_commands
    my @errors;
    my @checks_re = (
        qr/~CREATE/,
        qr/~REPEAT/,
        qr/STOP/,
    );
    for my $check_re (@checks_re) {
        if ($pgl_commands !~ $check_re) {
            push @errors, "could not find " . $check_re . " in pgl_commands";
        }
    }
    if (@errors) {
        for (@errors) {
            $logger->error($_);
        }
        $logger->logdie("I will not print this job");
    }   
}


1;
