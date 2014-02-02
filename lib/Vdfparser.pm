package Vdfparser;

use strict;
use warnings;
use Carp;
use Exporter;
use Data::Dumper;
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
my ($string, $path, $newpath, $key, $value) = ("")x5;
my (%result, $myptr, @fullpath);
%result = ();
$myptr = \%result;


#------------------------------------------------------------Decode function---------------------------------------------#
sub vdf_decode
{
	my %args = @_;
	my ($vdfdata, $switch);
	$vdfdata = $args{file} and $switch = 2 if (defined $args{file} && (length $args{file} > 0));
	$vdfdata = $args{data} and $switch = 1 if (defined $args{data} && (length $args{data} > 0));
 	if((defined $args{data}) && (defined $args{file}))
	{
	 	croak "Error! Please pass data or filename to parse!" if (!(length $args{data} > 0) && !(length $args{file} > 0));
	}
	if($switch == 2) {
		open (RFILE,"<",$vdfdata) || croak "failed to open file\n";
		binmode RFILE;
		my ($read, $char);
		while ($read = read RFILE, $char, 1) {
			if(length($key) > 0 && length($value) > 0) {
        			$myptr->{$key} = $value;
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
	}
	if($switch == 1)
	{
		my @chars = split(//, $vdfdata);
		my $skip = 0;
		foreach my $char (@chars) {

			next and $skip = 0 if($skip == 1);			

			if(length($key) > 0 && length($value) > 0) {
                                $myptr->{$key} = $value;
                                ($key, $value) = ("")x2;
                                $quote_counter = 0;
                        }

                        if (defined $switch_trigger{$char}) {
                                 $switch_trigger{$char}->();
                        }

                        $string .= $char if($char ne QUOTE && $char ne NEW_LINE && $char ne TAB && $char ne CARRIAGE_RETURN && $char ne CURLY_BRACE_START && $char ne CURLY_BRACE_END);
                        if($char eq '\\') {
				$skip = 1;
                        }
 		}
	}
return %result;
		
}

#-------------------------Encode function To-do-------------------------
sub vdf_encode
{}

#-----------------------------------------------------------------SWITCH CASES----------------------------------------#
sub case_quote
{
	$quote_counter++;
	$quote_counter = 1 if($quote_counter == 5);
		if($quote_counter == 2) {
			$key = $string;	
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
	croak "Not properly formed key-value structure" if(!(length($key)>0));
	$myptr->{$key} = {};
	$myptr = $myptr->{$key};
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
	$myptr = \%result;
	@fullpath = split(',', $path);
	$newpath = "";
	if(scalar(@fullpath) > 0) {
		for(my $i=0;$i<(scalar(@fullpath)-1);$i++) {
			if($newpath eq "") {
				$newpath .= $fullpath[$i];
				$myptr = $myptr->{$fullpath[$i]};
			} else {
				$newpath .= ','.$fullpath[$i];
				$myptr = $myptr->{$fullpath[$i]};
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

	my %input = (data => $data, [file => $pathtovdffile]);        Pass vdf data or filepath to vdf file
	my %hash_output = vdf_decode(%input);

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
