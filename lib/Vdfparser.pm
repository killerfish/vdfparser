package Vdfparser;

use strict;
use warnings;
use Carp;
use Exporter;
use Data::Dumper;
$|= 1;
our $VERSION     = 1.00;
our $ABSTRACT    = "Module for Diffbot Article api";
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
          'encode' => [ qw(
                          vdf_encode
                  ) ],
          'decode' => [ qw(
                          vdf_decode
                  ) ],
          'both' => [ qw(
                          vdf_encode
                          vdf_decode
                  ) ],
);
our @EXPORT_OK   = qw(vdf_encode vdf_decode);
our @EXPORT = ();

use constant {
        QUOTE => '"',
        CURLY_BRACE_START => "{",
        CURLY_BRACE_END => "}",
        NEW_LINE => "\n",
        CARRIAGE_RETURN => "\r",
        TAB => "\t",
};

our %switch_trigger = (
        '"' => \&case_quote,
        "{" => \&case_brace_start,
        "}" => \&case_brace_end,
);

my $quote_counter = 0;
my $reading = 0;
my ($string, $path, $newpath, $key, $value) = ("")x5;
my (%result, $ptr, @fullpath);
%result = ();
$ptr = \%result;

sub vdf_decode
{
	my $vdfdata = shift;
	open (RFILE,"<",$vdfdata) || die "failed to open file\n";
	binmode RFILE;
	my ($read, $char);
	while ($read = read RFILE, $char, 1) {
		if(length($key) > 0 && length($value) > 0) {
        		$ptr->{$key} = $value;
                	($key, $value) = ("")x2;
                	$quote_counter = 0;
        	}
		
		if (defined $switch_trigger{$char}) {
       			 $switch_trigger{$char}->();
    		}

                $string .= $char if($char ne QUOTE && $char ne NEW_LINE && $char ne TAB && $char ne CARRIAGE_RETURN && $char ne CURLY_BRACE_START && $char ne CURLY_BRACE_END);
		if($char eq '\\') {
			$read = read RFILE, $char, 1;
		} 
	}
return %result;
		
}
sub vdf_encode
{}

#-----------------------------------------------------------------SWITCH CASES----------------------------------------#
sub case_quote
{
	$quote_counter++;
	$quote_counter = 1 if($quote_counter == 5);
		if($quote_counter == 2) {
			$key = $string;	
		#	print "STRING: $string\n";
			$string = "";
		} elsif($quote_counter == 4) {
			$value = $string;
			if(!(length($value)>0))
			{
				$value = "NA";
			}
			$string = "";
		}
}
sub case_brace_start
{
	die "Not properly formed key-value structure" if(!(length($key)>0));
	$ptr->{$key} = {};
	$ptr = $ptr->{$key};
        if($path eq "") {
        	$path = $key;
        } else {
                $path .= ','.$key;
	}
	($string, $key, $value) = ("")x3;
	$quote_counter = 0;
	
}
sub case_brace_end
{
	$ptr = \%result;
	@fullpath = split(',', $path);
	$newpath = "";
	if(scalar(@fullpath) > 0) {
		for(my $i=0;$i<(scalar(@fullpath)-1);$i++) {
			if($newpath eq "") {
				$newpath .= $fullpath[$i];
				$ptr = $ptr->{$fullpath[$i]};
			} else {
				$newpath .= ','.$fullpath[$i];
				$ptr = $ptr->{$fullpath[$i]};
			}
		}

	}
	$path = $newpath;	
}

1;

__END__

=head1 NAME

Vdfparser - Valve Data Format parser

=head1 VERSION

Version 1.00

=head1 SYNOPSIS

This module provides an encoder/decoder for Valve Data Format <> Perl Data Structure.

=head1 METHODS
	
	use Vdfparser qw(vdf_encode vdf_decode);
	my $vdf = vdf_encode(%your_hash_input);              #-------------Yet to be implemented-------#
	my %hash_output = vdf_decode($your_file_input);

=head1 AUTHOR

Usman Raza, B<C<usman.r123 at gmail.com>>

=head1 SUPPORT

You can find documentation for this module with the perldoc command. Also check the example provided.

    perldoc Vdfparser

Github repo https://github.com/killerfish/vdfparser

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Usman Raza.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
