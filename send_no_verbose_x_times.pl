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

for (1..5) {
    $logger->info("Send command for silentmode to printer");
    $talker->set_silent_mode;
}
$logger->info("Ready with $0");
