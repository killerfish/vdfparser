#! /usr/bin/perl

use strict;
use warnings;

BEGIN { push @INC, './lib' } #Remove this when you install the module#

use Data::Dumper;
use Vdfparser qw(:decode);
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Sortkeys = sub { [sort {$b cmp $a} keys %{$_[0]}] };


my %hash = vdf_decode("./samplevdf");
print Dumper \%hash;

