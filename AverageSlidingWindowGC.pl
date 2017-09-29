#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use List::Util qw(sum);

my ($file,$window);
GetOptions(
  "inupt|i:s"    =>    \$file,
  "windown|w:i"  =>    \$window,
  "help|h"       =>    sub{&usage;exit(-1);}
);

unless(defined $window){&usage;exit(-1);}
unless($file){&usage;exit(-1);}
open FH,$file;

my (%nuc,$n);
$n=0;
while(<FH>){
  chomp;
  my $seq = $_;
  $seq = uc($seq);
  if (length($seq) < $window){print STDERR "Sliding Window Size is Bigger Than the Sequence Length.\n";exit(-1);}

  foreach(my $i = 0; $i <= length($seq)-$window; $i++){
    my $sub = substr($seq,$i,$window);
    $nuc{$i}->{"A"}->[$n]  = () = $sub =~ /A/g;
    $nuc{$i}->{"C"}->[$n]  = () = $sub =~ /C/g;
    $nuc{$i}->{"G"}->[$n]  = () = $sub =~ /G/g;
    $nuc{$i}->{"T"}->[$n]  = () = $sub =~ /T/g;
    $nuc{$i}->{"GC"}->[$n] = () = $sub =~ /[CG]/g;
    if($nuc{$i}->{"C"}->[$n] + $nuc{$i}->{"G"}->[$n] == 0){
      $nuc{$i}->{"skew"}->[$n] = 0;
    }else{
      $nuc{$i}->{"skew"}->[$n] = ($nuc{$i}->{"G"}->[$n] - $nuc{$i}->{"C"}->[$n]) / ($nuc{$i}->{"G"}->[$n] + $nuc{$i}->{"C"}->[$n]);
    }
  }
  $n++;
}

my @nuc = ("A","C","G","T","GC","skew");
print join("\t","Pos",@nuc),"\n";
my @pos = sort{$a <=> $b} keys %nuc;

foreach (@pos){
  my $pos = $_;
  print "$pos";
  foreach(@nuc[0..4]){
    print "\t",sum(@{$nuc{$pos}->{$_}})/$n/$window;
  }
  print "\t",sum(@{$nuc{$pos}->{"skew"}})/$n;
  print "\n";
}

sub usage{
print STDERR <<HELP
Usage: perl $0 --input|-i <file> --window|-w <#> --case|-c --help|-h

Parameters:
  --inupt|-i:s          input sequence file
  --window|-w:i         size of sliding window
  --help|-h             print this help message

Func:
   nucloetide composition of each position (represented by a window with this position as center)
HELP
}
