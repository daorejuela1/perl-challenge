#!/usr/bin/env perl
use strict;
use warnings;
use version; our $VERSION = qv('5.30');
use Config::JSON;
use Text::CSV qw( csv );
use Readonly;
use String::Random qw(random_regex random_string);
use Generator::Object;
use English qw( -no_match_vars );

Readonly::Scalar my $WRITE_MODE    => '>';
Readonly::Scalar my $STRING_COLUMN => '\w\w\w\w\w\w';
Readonly::Scalar my $INT_COLUMN    => '\d\d\d\d\d\d';

my $count = 1;
my ( $row_numbers, $csv_path, $config_file_name ) = @ARGV;
my $config = Config::JSON->new($config_file_name);

my $csv = Text::CSV->new( { binary => 1, eol => $INPUT_RECORD_SEPARATOR } )
  or croak('Cannot use CSV: Text::CSV->error_diag()');

my $row_generator = generator {
    my $field1      = $config->get('field1');
    my $field2      = $config->get('field2');
    my $field_type1 = $field1 eq 'integer' ? $INT_COLUMN : $STRING_COLUMN;
    my $field_type2 = $field2 eq 'integer' ? $INT_COLUMN : $STRING_COLUMN;
    my @row;
    while (1) {
        @row = ( random_regex($field_type1), random_regex($field_type2) );
        $_->yield(@row);
    }
};

open my $fh, $WRITE_MODE, $csv_path or croak("$csv_path: $OS_ERROR");

while ( $count <= $row_numbers ) {
    my @row_array = $row_generator->next;
    $csv->print( $fh, \@row_array );
    $count++;
}

print $count;
close $fh or croak("$csv_path: $OS_ERROR");
