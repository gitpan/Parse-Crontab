use strict;
use warnings;
use utf8;
use Test::More;
BEGIN {
    use_ok 'Parse::Crontab::Entry::Job';
}

my $entry = new_ok 'Parse::Crontab::Entry::Job', [line => '* * * * * perl', line_number => 1];
ok !$entry->is_error;
is $entry->minute->entity, '*';
is $entry->hour->entity, '*';
is $entry->day->entity, '*';
is $entry->month->entity, '*';
is $entry->day_of_week->entity, '*';
is $entry->command, 'perl';

$entry = new_ok 'Parse::Crontab::Entry::Job', [line => '@hourly perl -e', line_number => 1];
ok !$entry->is_error;
is $entry->minute->entity, '0';
is $entry->hour->entity, '*';
is $entry->day->entity, '*';
is $entry->month->entity, '*';
is $entry->day_of_week->entity, '*';
is $entry->command, 'perl -e';

$entry = new_ok 'Parse::Crontab::Entry::Job', [line => '* * * *  perl', line_number => 1];
ok $entry->is_error;

done_testing;
