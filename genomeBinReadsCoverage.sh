#!/bin/bash
bam=${1?please give .bam file}
chromsize=${2:-~jchen/public/hg19.chrom.sizes}
size=${3:-3000}
prefix=`basename $bam .bam`
output=${prefix}.ReadsCoverage

bedtools makewindows -g $chromsize -w $size | \
  bedtools intersect -b $bam -a - -c -bed > $output
