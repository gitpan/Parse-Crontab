package Parse::Crontab::Entry::Job;
use strict;
use warnings;
use Try::Tiny;

use Mouse;
extends 'Parse::Crontab::Entry';
use Parse::Crontab::Schedule;

has command => (
    is  => 'rw',
    isa => 'Str',
);

has schedule => (
    is  => 'rw',
    isa => 'Parse::Crontab::Schedule',
    handles => [qw/minute hour day month day_of_week definition/],
);

no Mouse;

sub BUILD {
    my $self = shift;

    my $line = $self->line;
    my $definition;
    my $command;

    my %args;
    if (($definition) = $line =~ /^@([^\s]+)/) {
        $command = (split /\s+/, $line, 2)[1];
        $args{definition} = $definition;
    }

    unless ($definition) {
        my ($min, $hour, $day, $month, $dow, $com) = split /\s+/, $line, 6;
        unless ($com) {
            $self->set_error(sprintf '[%s] is not valid cron job', $self->line);
            return;
        }
        $command = $com;
        %args = (
            minute      => $min,
            hour        => $hour,
            day         => $day,
            month       => $month,
            day_of_week => $dow,
        );
    }

    unless ($command) {
        $self->set_error(sprintf '[%s] is not valid cron job', $self->line);
        return;
    }
    $self->command($command);

    try {
        $self->schedule(Parse::Crontab::Schedule->new(%args));
    }
    catch {
        $self->set_error(sprintf 'schedule error! %s', $_);
    };

}

__PACKAGE__->meta->make_immutable;
