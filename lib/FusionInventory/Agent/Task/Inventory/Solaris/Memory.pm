package FusionInventory::Agent::Task::Inventory::Solaris::Memory;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{memory};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $memorySize = getFirstMatch(
        command => '/usr/sbin/prtconf',
        logger  => $logger,
        pattern => qr/^Memory\ssize:\s+(\S+)/
    );

    my $swapSize = getFirstMatch(
        command => '/usr/sbin/swap -l',
        logger  => $logger,
        pattern => qr/\s+(\d+)$/
    );

    $inventory->setHardware({
        MEMORY => $memorySize,
        SWAP =>   $swapSize
    });

    my $zone = getZone();

    my @memories = $zone eq 'global' ?
        _getMemoriesPrtdiag() :
        _getZoneAllocatedMemories($memorySize) ;

    foreach my $memory (@memories) {
        $inventory->addEntry(
            section => 'MEMORIES',
            entry   => $memory
        );
    }
}

sub _getMemoriesPrtdiag {
    my $info = getPrtdiagInfos(@_);

    return $info->{memories} ? @{$info->{memories}} : ();
}

sub _getZoneAllocatedMemories {
    my ($size) = @_;

    my @memories;

    # Just format one virtual memory slot with the detected memory size
    push @memories, {
            DESCRIPTION => "Allocated memory",
            CAPTION     => "Shared memory",
            NUMSLOTS    => 1,
            CAPACITY    => $size
    };

    return @memories;
}

1;
