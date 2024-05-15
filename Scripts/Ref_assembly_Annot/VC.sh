#!/bin/bash


csv="./Projects/README.csv"

mkdir Project/Not-closed/snippy_PFvsTC

#for those strains without closed references --> Snippy was used and the annotation of the plasmid free as reference
for i in Project/Not-closed/TC/Trimmed/*_1_val_1.fq.gz; 
do
#We had to extract the original name of the reads using the correct strain name (ex. EC02 -> WTH000001.1_val_1.fq.gz
    filename=$(basename $i | cut -d '_' -f -1,2,3) 
    WTH=$(awk -v r1="$filename" -F ',' '$2 == r1 { print $1 }' "$csv")
    strain=$(echo $WTH | cut -d '_' -f 2)
    #If there was also a version carrying the plasmid, then snippy was excuted
    if [[ $WTH == "TC_"* ]]; then
        if [ -e Project/Not-closed/PF/Annotation_pgap/$strain/annot.gbk ]; then
            snippy --report --cpus 15 --outdir mkdir Project/Not-closed/snippy_PFvsTC/$strain --ref Project/Not-closed/PF/Annotation_pgap/$strain/annot.gbk --R1 $i --R2 "Project/Not-closed/TC/Trimmed/"$filename"_2_val_2.fq.gz"
        fi
    fi

done
