#!/bin/bash
summit=${1:-../../data/R-ChIP/HEK293/peaks/narrow/all.summit.bed6}
chromsize=${2:-~jchen/public/hg19.chrom.sizes}
ref=${3:-~jchen/public/genome/hg19.fa}

bedtools slop -l 100 -r 0 -i $summit -g $chromsize -s | \
  bedtools getfasta -fi $ref -bed - -s -tab | cut -f 2 | tr "atcg" "ATCG" | ./GFreq.pl - | sed 's/$/\tCase/g'
num=`cat $summit | wc -l`
bedtools random -g $chromsize -l 100 -n $num | bedtools getfasta -fi $ref -bed - -s -tab | cut -f 2 | tr "atcg" "ATCG" | ./GFreq.pl - | sed 's/$/\tControl/g'
