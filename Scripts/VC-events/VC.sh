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
#we repeated the same process using as a references the plasmid-carrying version. This way, only the mutations in both snippys were selected as they were the ones caused by the plamid pOXA-48 and not and assembly error. 
mkdir Project/Not-closed/snippy_TCvsPF

for i in Project/Not-closed/PF/Trimmed/*_1_val_1.fq.gz; 
do
#We had to extract the original name of the reads using the correct strain name (ex. EC02 -> WTH000001.1_val_1.fq.gz
    filename=$(basename $i | cut -d '_' -f -1,2,3) 
    WTH=$(awk -v r1="$filename" -F ',' '$2 == r1 { print $1 }' "$csv")
    strain=$(echo $WTH | cut -d '_' -f 2)
    
    #If there was also a version carrying the plasmid, then snippy was excuted
    if [[ $WTH == "PF_"* ]]; then
        if [ -e Project/Not-closed/TC/Annotation_pgap/$strain/annot.gbk ]; then
            snippy --report --cpus 15 --outdir Project/Not-closed/snippy_TCvsPF/$strain --ref Project/Not-closed/TC/Annotation_pgap/$strain/annot.gbk --R1 $i --R2 "Project/Not-closed/PF/Trimmed/"$filename"_2_val_2.fq.gz"
        fi
    fi

done


#for those strains with closed references --> breseq was used
mkdir Project/Closed/breseq_TCvsPF

for i in Project/Closed/TC/Trimmed/*_1_val_1.fq.gz; 
do
#We had to extract the original name of the reads using the correct strain name (ex. EC02 -> WTH000001.1_val_1.fq.gz
    filename=$(basename $i | cut -d '_' -f -1,2,3) 
    WTH=$(awk -v r1="$filename" -F ',' '$2 == r1 { print $1 }' "$csv")
    strain=$(echo $WTH | cut -d '_' -f 2)
    
    #If there was also a version carrying the plasmid, then breseq was excuted
    if [[ $WTH == "TC_"* ]]; then
        if [ -e Project/Closed/PF/Annotation_pgap/$strain/annot.gbk ]; then
            breseq -r Project/Not-closed/PF/Annotation_pgap/$strain/annot.gbk -o Project/Closed//breseq_TCvsPF/$strain $i "Project/Closed/TC/Trimmed/"$filename"_2_val_2.fq.gz"
        fi
    fi

done


#For the Conjugation Subset 1.2, the samples were analysed as populations and the corresponding breseq too.

mkdir Project/Closed/breseq_TCvsPF

for i in Project/Closed/Population/Trimmed/*_1_val_1.fq.gz; 
do
#We had to extract the original name of the reads using the correct strain name (ex. EC02 -> WTH000001.1_val_1.fq.gz
    filename=$(basename $i | cut -d '_' -f -1,2,3) 
    WTH=$(awk -v r1="$filename" -F ',' '$2 == r1 { print $1 }' "$csv")
    strain=$(echo $WTH | cut -d '_' -f 2)
    
    #If there was also a version carrying the plasmid, then breseq was excuted
    if [[ $WTH == "TC_"* ]]; then
        if [ -e Project/Closed/PF/Annotation_pgap/$strain/annot.gbk ]; then
            breseq -p -r Project/Not-closed/PF/Annotation_pgap/$strain/annot.gbk -o Project/Closed//breseq_TCvsPF/$strain $i "Project/Closed/Population/Trimmed/"$filename"_2_val_2.fq.gz"
        fi
    fi

done


# Lastly, a variant calling analysis was performed using the plasmid version pOXA-48_K8

cd Project

for i in ./*/TC/Trimmed/*_1_val_1.fq.gz; 
do
    mkdir ./*/TC/breseq_pOXA
    filename=$(basename $i | cut -d '_' -f -1,2,3) 
    WTH=$(awk -v r1="$filename" -F ',' '$2 == r1 { print $1 }' "$csv")
    strain=$(echo $WTH | cut -d '_' -f 2)
    
    if [[ $WTH == "TC_"* ]]; then
        breseq -r pOXA_48_K8.gbk -o breseq_pOXA/$strain $i "TC/Trimmed/"$filename"_2_val_2.fq.gz"
    fi

done
