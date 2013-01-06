package Parse::Crontab;
use 5.008_001;
use strict;
use warnings;
use Carp;

our $VERSION = '0.02';

use Mouse;
use Path::Class;

use Parse::Crontab::Entry::Env;
use Parse::Crontab::Entry::Job;
use Parse::Crontab::Entry::Comment;
use Parse::Crontab::Entry::Empty;
use Parse::Crontab::Entry::Error;

has file => (
    is => 'ro',
);

has content => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        croak 'Attribute file or content is required!' unless defined $self->file;
        Path::Class::file($self->file)->slurp;
    },
);

has entries => (
    is => 'rw',
    isa => 'ArrayRef[Parse::Crontab::Entry]',
    default => sub {[]},
    auto_deref => 1,
);

has env => (
    is => 'rw',
    isa => 'HashRef',
    default => sub {{}},
);


no Mouse;

sub BUILD {
    my $self = shift;

    my $line_number = 1;
    for my $line (split /\r?\n/, $self->content) {
        my $entry_class = 'Parse::Crontab::Entry::'. $self->_decide_entry_class($line);
        my $entry = $entry_class->new(line => $line, line_number => $line_number);
        $line_number++;

        if ($entry_class eq 'Parse::Crontab::Entry::Env' && !$entry->is_error) {
            # overwritten if same key already exists
            $self->env->{$entry->key} = $entry->value;
        }
        push @{$self->entries}, $entry;
    }
}

sub is_valid {
    my $self = shift;

    for my $entry ($self->entries) {
        return () if $entry->is_error;
    }
    1;
}

sub error_messages {
    my $self = shift;
    my @errors;
    for my $entry ($self->entries) {
        push @errors, $entry->error_message if $entry->is_error;
    }
    join "\n", @errors;
}

sub jobs {
    my $self = shift;
    grep {$_->isa('Parse::Crontab::Entry::Job')} $self->entries;
}

sub _decide_entry_class {
    my ($self, $line) = @_;

    if ($line =~ /^#/) {
        'Comment';
    }
    elsif ($line =~ /^\s*$/) {
        'Empty';
    }
    elsif ($line =~ /^(?:@|\*|[0-9])/) {
        'Job';
    }
    elsif ($line =~ /=/) {
        'Env';
    }
    else {
        'Error';
    }
}

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Parse::Crontab - Perl extention to parse Vixie crontab file

=head1 VERSION

This document describes Parse::Crontab version 0.01.

=head1 SYNOPSIS

    use Parse::Crontab;
    my $crontab = Parse::Crontab->new(file => 'crontab.txt');
    if ($crontab->is_valid) {
        warn $crontab->error_message;
    }
    for my $job ($crontab->jobs) {
        say $job->minute;
        say $job->hour;
        say $job->day;
        say $job->month;
        say $job->day_of_week;
        say $job->command;
    }

=head1 DESCRIPTION

This software is for parsing and validating Vixie crontab files.

=head1 INTERFACE

=head2 Functions

=head3 C<< is_valid() >>

Checking crontab is valid or not.

=head3 C<< entries() >>

returns all entries in crontab

=head3 C<< jobs() >>

returns job entries in crontab

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Masayuki Matsuki. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
