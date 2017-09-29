#!/bin/bash

fwd=${1?bigwig file in fwd strand}
rev=${2?bigwig file in rev strand}
bed6=${3:-../../data/R-ChIP/HEK293/peaks/narrow/all.peaks.bed6}
ref=${4:-~jchen/public/hg19.chrom.sizes}
left=${5:-2000}
right=${6:-2000}

# upstream
bedtools flank -i $bed6 -l $left -r 0 -g $ref -s | while read region;
do
  chr=`echo $region|cut -d " " -f 1`;
  sta=`echo $region|cut -d " " -f 2`;
  end=`echo $region|cut -d " " -f 3`;
  str=`echo $region|cut -d " " -f 6`;
  if [ "$str" = "+" ]; then
    status=`bigWigSummary $fwd $chr $sta $end 200`
  else
    status=`bigWigSummary $rev $chr $sta $end 200 | perl -ne '@t=split;print join("\t",reverse(@t)),"\n";'`
  fi
  if [ "$status" = "" ];then perl -e 'print join(" ",split("",0 x 200)),"\n"';else echo $status; fi
done > upstream

# central
cat $bed6 | while read region;
do
  chr=`echo $region|cut -d " " -f 1`;
  sta=`echo $region|cut -d " " -f 2`;
  end=`echo $region|cut -d " " -f 3`;
  str=`echo $region|cut -d " " -f 6`;
  if [ "$str" = "+" ]; then
    status=`bigWigSummary $fwd $chr $sta $end 100`
  else
    status=`bigWigSummary $rev $chr $sta $end 100 | perl -ne '@t=split;print join("\t",reverse(@t)),"\n";'`
  fi
  if [ "$status" = "" ];then perl -e 'print join(" ",split("",0 x 100)),"\n"';else echo $status; fi
done > central

# downstream
bedtools flank -i $bed6 -r $right -l 0 -g $ref -s | while read region;
do
  chr=`echo $region|cut -d " " -f 1`;
  sta=`echo $region|cut -d " " -f 2`;
  end=`echo $region|cut -d " " -f 3`;
  str=`echo $region|cut -d " " -f 6`;
  if [ "$str" = "+" ]; then
    status=`bigWigSummary $fwd $chr $sta $end 200`
  else
    status=`bigWigSummary $rev $chr $sta $end 200 | perl -ne '@t=split;print join("\t",reverse(@t)),"\n";'`
  fi
  if [ "$status" = "" ];then perl -e 'print join(" ",split("",0 x 200)),"\n"';else echo $status; fi
done > downstream

paste upstream central downstream | sed 's/\t/ /g' | sed 's/n\/a/0/g' > profile
rm upstream central downstream
