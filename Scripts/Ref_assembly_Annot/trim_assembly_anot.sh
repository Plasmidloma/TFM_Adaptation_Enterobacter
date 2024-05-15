#!/bin/bash

#FastQC y Trimming of the raw reads.

raw="reads"
trm="Trimmed"
ass="Assemblies_spades"
ass1="Assemblies_unicycler"
ann="Annotation_prokka"

## Firstly, a FastQC and MultiQC was done to all the strains and the results were checked outside this loop.

# For each strain, we select the fast-QC:
for R1 in ./$raw/*/*/*_1.fastq.gz;
do
	count=0
	#In R1 name of the reads --> WTCHG_0000_0000_1.fastqc with the PATH.	
	dir=$(dirname ${R1}_1.fastq.gz)
	##In strain --> PF/TC and la Specie/Strain (Ex. TC_EC25)
	strain=$(basename "$dir")
	##En str --> Strain name (Ex. EC25)
	str=$(echo "$R1" | cut -d '/' -f -3 | cut -d '/' -f 3)
	#In sq -> complete path of sequences, without the direction and extension. In seq --> name of the file 
	sq=$(echo $R1 | cut -d '.' -f 1,2 | cut -d '_' -f -5)
	seq=$(echo $sq | cut -d '/' -f 5)	

#Check if the trimming folder exists, that it was not done before to the strain and that we had both reads. 

	while count==0 do 
		if [ ! -d "$trm" ]; then
			echo "$trm doesn't exist. Creating..."
 			mkdir "$trm"
  
		elif [ -d "$trm" ] & [ ! -d "$trm/$str/$seq"_1_val_1.fq.gz ]; then
			echo "$strain has already been trimmed. Moving to the next step."
			count+=1
		
  		elif [ -e "${sq}"_2.fastq.gz ]; then
			echo "FastQC and Trimming of $strain in process" 
			mkdir "$trm/$str"
			trim_galore --quality 20 --length 50  --fastqc --output_dir "$trm/$str/$strain" --paired "$R1" "$sq"_2.fastq.gz
			echo "FastQC and Trimming of $strain completed successfully"
			count+=1
	 	else 
	 		echo "There's been a problem with the Trimming in "$strain". Please, check it out, babe."
	 	fi
	done 
	
	
	# Assembly of strains: If there was a merge_barcode --> unicycler. If we only had Illumina data --> spades
	while count==1 do
		if [ -d "$ass" ] && [ -e "$ass/$str/$strain/assembly.fasta" ]; then
			echo "$strain has already been assembled. Moving to the next step"
			count+=1
		
		elif [ -d "$ass1"] && [ -e "$ass1/$str/$strain/assembly.fasta" ]; then
			echo "$strain has already been assembled. Moving to the next step"
			count+=1
	
		elif [ -e "$raw/$str/$strain/merged_barcode"*.*.gz ]; then 
			echo "It exits a merged_barcode archive. We are using Unicycler for assembling"
		fi

		if [ ! -d "$ass1" ]; then
			mkdir "$ass1"
			echo "$ass1 has been created".
		
		elif [ ! -d "$ass1/$str" ]; then
			mkdir "$ass1/$str"
			echo "$ass1/$str didn't exist and has been created."
		fi
		
		unicycler -t 15 -1 "$trm/$str/$strain/$seq"_1_val_1.fq.gz -2 "$trm/$str/$strain/$seq"_2_val_2.fq.gz -l "$raw/$str/$strain/merged_barcode"*.*.gz -o "$ass1/$str/$strain"
		count+=1
		echo "Assembly by unicycler of $strain has been completed correctly."
	done
		
		## We annotated with prokka
		if [ -e "$ann/$str/$strain/$strain".txt ]; then
			echo "$strain has already been annotate. Finished with $strain."
			count+=1
			
		elif [ ! -d "$ann" ]; then
			mkdir  "$ann"
			echo "$ann has been created."
			
		elif [ ! -d "$ann/$str" ]; then
			mkdir "$ann/$str"
			echo "$ann/$str has been created."
		fi
		
		prokka --outdir "$ann/$str/$strain" --prefix "$strain" --compliant "$ass1/$str/$strain/assembly.fasta"
		count+=1
	done		
		
		
	elif [ ! -e "$raw/$str/$strain/merged_barcode"*.*.gz ]; then 
		echo "It doesn't exit a merged_barcode archive. We are using SPAdes for assembling"
		
		if [ ! -d "$ass" ]; then
			mkdir  "$ass"
			echo "$ass has been created."
		fi
		
		if [ ! -d "$ass/$str" ]; then
			mkdir "$ass/$str"
			echo "$ass/$str has been created."
		fi
	
	
		spades.py --isolate --cov-cutoff auto -o "$ass/$str/$strain" -1 "$trm/$str/$strain/$seq"_1_val_1.fq.gz -2 "$trm/$str/$strain/$seq"_2_val_2.fq.gz
		echo "Assembly by SPAdes of $strain has been completed correctly"
	
		quast="$ass/$str/$strain/Quast_report"
		quast.py -o "$quast" --glimmer "$ass/$str/$strain"/contigs.fasta
		
		
		if [ -e "$ann/$str/$strain/$strain".txt ]; then
			echo "$strain has already been annotate. Finished with $strain."
			continue
			
		elif [ ! -d "$ann" ]; then
			mkdir  "$ann"
			echo "$ann has been created."
			
		elif [ ! -d "$ann/$str" ]; then
			mkdir "$ann/$str"
			echo "$ann/$str has been created."
		fi
		
		prokka --outdir "$ann/$str/$strain" --prefix "$strain" --compliant "$ass/$str/$strain"/contigs.fasta

	else 
		echo "There has been a problem assembling or annotating "$strain". Please check again"
	fi
	
 echo "This script has finished. Check the results before continuing with the variant calling!"
done

#All the strains were also annotated using PGAP. For that, a yaml file had to be created to each strain (there is an example of the requiered files in Ref_assembly_Annot. Then the following command was adapted to all the strains
pgap.py -r --ignore-all-errors -o ./Annotation_pgap/$strain ./$ass/$strain/input.yaml
