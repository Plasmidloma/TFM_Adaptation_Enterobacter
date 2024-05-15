#!/bin/bash

#This step was not automated and was done by hand due to the complexity of searching the reference gbk

echo -e 'Strain\tchr_mean\tchr_median\tchr_std\tp_mean\tp_median\tp_std\tmean_ratio\tmedian_ratio' >> ~/TFM/pcn.tsv
#To obtain the chromosome coverage, we used as input the aligned bam file of the variant calling of all the strains and in the reference file used, we looked for the position and contig for the monocopy housekeeping genes 
#(rpoB in Klebsiella spp. and gyrA in E .coli). It was noted in -r as contig:positionstart-positionend. The mean, median and standart deviation was obteined and adapted for the final dataframe. 
strain="K209"
chrstats=$( samtools depth -r 1:5000609-5004637 -a /media/paloma/TFM_Paloma/Projects/experimental_evolution_plan_B/breseqs_ee_ancestors/K209/2_G/data/reference.bam | datamash -R 2 mean 3 median 3 sstdev 3 )
chrstats=${chrstats//,/.} # to change decimal separator
chrmean=$( echo $chrstats | awk '{print $1}' )
chrmedian=$( echo $chrstats | awk '{print $2}' )
chrsd=$( echo $chrstats | awk '{print $3}' )

#To obtain pOXA-48 coverage,  we used as input the aligned bam file of the variant calling of all the strains against pOXA-48_K8 and the whole contig with the plasmid was selected. It was noted as -r contig and it was the same for all the strains,
# as it was the same reference.
pstats=$( samtools depth -r 3 -a /media/paloma/TFM_Paloma/Projects/experimental_evolution_plan_B/breseq_pOXA/K209p/data/reference.bam | datamash -R 2 mean 3 median 3 sstdev 3 )
pstats=${pstats//,/.}
pmean=$( echo $pstats | awk '{print $1}' )
pmedian=$( echo $pstats | awk '{print $2}' )
psd=$( echo $pstats | awk '{print $3}' )
		
		# Calculate the ratio of coverage plasmid/chromosome
ratiomean=$(echo "scale=4; x=($pmean/$chrmean); if(x<1) print 0; x" | bc)
ratiomedian=$(echo "scale=4; x=($pmedian/$chrmedian); if(x<1) print 0; x" | bc )
	
		# Save results in output tsv file
echo -e $strain'\t'$chrmean'\t'$chrmedian'\t'$chrsd'\t'$pmean'\t'$pmedian'\t'$psd'\t'$ratiomean'\t'$ratiomedian >> ~/TFM/pcn.tsv

