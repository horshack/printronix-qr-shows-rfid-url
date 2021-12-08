#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use Test::More;

use_ok('Params::Validate');
use_ok('Moo');
use_ok('Template');
use_ok('IO::Socket::INET');
use_ok('Log::Log4perl');
use_ok('Log::Log4perl::ConfigByInifile');
use_ok('Config::IniFiles');

done_testing();
