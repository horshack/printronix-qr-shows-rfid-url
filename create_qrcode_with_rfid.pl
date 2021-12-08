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
use Getopt::Long;

my $maxjobs;
GetOptions ("maxjobs=i" => \$maxjobs) 
    or help_and_exit();

if (!$maxjobs) {
    help_and_exit();
}

my $inifile_fn = 'create_qrcode_with_rfid.ini';
my $ini_obj = Config::IniFiles->new( -file => $inifile_fn);
my $host = $ini_obj->val('printer', 'host');

Log::Log4perl::ConfigByInifile->new(
    { ini_obj => $ini_obj, }
);
my $logger = Log::Log4perl::get_logger('main');
for my $jobnummer (1..$maxjobs) {
    drucke_etikett();
    my $sleeptime = 20;
    if ($jobnummer < $maxjobs) {
        $logger->info("Job $jobnummer/$maxjobs - Ich warte $sleeptime Sekunden bis zum naechsten Druckjob");
        sleep $sleeptime;
    }
}

sub drucke_etikett {
    my $talker = Printer::Printronix::Talk9100->new({
        host => $host,
        logger => Log::Log4perl::get_logger('Printer::Printronix::Talk')
    });
    my $rfid_ist_defekt = 0;
    $talker->create_socket;
    $talker->set_verbose_mode;
    $talker->find_out_current_epc_code;
    $talker->set_silent_mode;
    $logger->info("EPC-Code is " . $talker->epc_code);
    if (!$talker->epc_code) {
        $logger->logdie("EPC-Code ist leer, konnte nicht gelesen werden, ich sterbe");
    }
    if ($talker->epc_code =~ m/(.)\1{7,}/ ) {
        $logger->error("EPC-Code sieht schlecht aus, zu viele gleiche Zeichen. Das ist ein defektes Etikett.");
        # genau 24 Zeichen
        my $epc_defekt = '++ defekter-rfid-chip ++';
        $talker->epc_code($epc_defekt);
        $rfid_ist_defekt = 1;
    }

    # $talker->epc_code("123456789012345678901234");

    # Printjob should work in silent-mode
    my $tt = Template->new;
    my $tt_vars = {
        url_human => $ini_obj->val('label', 'url_human'),
        qrcode_start => $ini_obj->val('label', 'qrcode_start'),
        epc_code => $talker->epc_code,
        rfid_ist_defekt => $rfid_ist_defekt,
    };
    my $pgl_commands;

    $tt->process(
        # file:
        $ini_obj->val('label', 'printjob_template_fn'), 
        $tt_vars, 
        # return results to variable:
        \$pgl_commands )
        || die Dumper($tt->error);
        
    # print Dumper($pgl_commands);
    $talker->execute_printjob({
        pgl_commands => $pgl_commands
    });

    $logger->info("Ready with $0 for EPC <" . $talker->epc_code . ">");
}

sub help_and_exit {
    print <<"EOTEXT";
Usage: 

$0 --maxjobs=3
EOTEXT
    exit 1;
}