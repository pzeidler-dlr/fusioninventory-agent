#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

my %tests = (
    'dell-xt2' => []
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @modems = FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems::_getModemControllers(file => $file);
    is_deeply(\@modems, $tests{$test}, $test);
}
