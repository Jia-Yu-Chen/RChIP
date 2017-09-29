#!/usr/bin/perl
use strict;
use warnings;

unless(@ARGV==1){print STDERR "Usage: perl $0 .sequence \n"; exit(-1)}

my %Gfreq;
open FH,$ARGV[0];
while(<FH>){
  chomp;
  $Gfreq{"GG"} ++ if /GG/i;
  $Gfreq{"GGG"} ++ if /GGG/i;
  $Gfreq{"GGGG"} ++ if /GGGG/i;
  $Gfreq{"GGGGG"} ++ if /GGGGG/i;
  $Gfreq{"GGGGGG"} ++ if /G{6,}/i;
}

foreach(sort{$a cmp $b} keys %Gfreq){
  print "$_\t";
  if(exists $Gfreq{$_}){
    print $Gfreq{$_},"\n";
  }else{
    print "0\n";
  }
}
