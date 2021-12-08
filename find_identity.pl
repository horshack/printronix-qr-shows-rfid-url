#!/usr/bin/perl
use IO::Socket;
use strict;
use warnings;
use Data::Dumper;
use Template;
use Params::Validate qw(validate_with OBJECT SCALAR);
use lib 'lib';
use Printer::Printronix::Talk9100;
use Log::Log4perl;
use Log::Log4perl::ConfigByInifile;
use Config::IniFiles;

# How often to send the identity command
my $max_default = 5;
my $max = shift // $max_default;

my $inifile_fn = 'create_qrcode_with_rfid.ini';
my $ini_obj = Config::IniFiles->new( -file => $inifile_fn);
my $host = $ini_obj->val('printer', 'host');

Log::Log4perl::ConfigByInifile->new(
    { ini_obj => $ini_obj, }
);
my $logger = Log::Log4perl::get_logger('main');

my $talker = Printer::Printronix::Talk9100->new({
    host => $host,
    logger => Log::Log4perl::get_logger('Printer::Printronix::Talk')
});
$talker->create_socket;
$talker->set_verbose_mode;

for my $i (1 .. $max) {
    $logger->info("Fetch identity ${i}/${max}");
    $talker->fetch_identity;
}

$talker->set_silent_mode;

$logger->info("Ready with $0");
