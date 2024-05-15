#The pangenome was created for K. pneumoniae and E. coli. All the fastas and the reads of the mutated strains were compiled in a folder. The annotation with prokka was used and compiled in a folder.
#For the pangenome creation, the gff of all the affected strains by species were used. This was repeated for each species.
  roary -e --mafft -p 8 -o roary/Ecoli *.gff 

#The pangenome was annotated again using Prokka
conda activate prokka
prokka --compliant roary/Ecoli/pan_genome_reference.fa --outdir ref_genomes/
conda deactivate

#The pangenome was formatted and indexed
conda activate anvio-8
anvi-script-reformat-fasta roary/Ecoli/pan_genome_reference.fa -o Ecoli.reformat.fasta --simplify-names --report-file ../anvio/Ecoli/Ecoli-contigs-reformat.txt
bwa index Ecoli.reformat.fasta
conda deactivate


## The reformatted pangenome was annotated again using as a reference the original pangenome annotation (--proteins)
conda activate prokka
prokka --proteins PROKKA_04082024/PROKKA_04082024.gbk --outdir ../anvio/Ecoli/functions/ --prefix Ecoli.annot Ecoli.reformat.fasta --cpus 5
conda dectivate

#The gene annotation and gene names were extracted using gff_parsey.py (also available in this github and extracted from the anvio page)
conda activate anvio-8
python ../gff_parser.py ../anvio/Ecoli/functions/Ecoli.annot.gff --gene-calls ../anvio/Ecoli/functions/gene_calls.txt --annotation ../anvio/Ecoli/functions/gene_annot.txt


## The database for E. coli was created and the functions from the pangenome annotation were imported

anvi-gen-contigs-database -T 5 -L 5000 -f E.coli/Ecoli.reformat.fasta -o anvio/Ecoli/complete_contigs.db --external-gene-calls anvio/Ecoli/functions/gene_calls.txt -n 'Contigs db from closed Ecoli reference' --skip-mindful-splitting --ignore-internal-stop-codons
anvi-import-functions -c anvio/Ecoli/complete_contigs.db -i anvio/Ecoli/functions/gene_annot.txt


## You need a bam file of all the sequences that are going to be displayed with the anvio. 
## To do this, we first obtain the sam files using bwa mem. Using the sam files, the bam files were obtained with samtools and also indexed.
for reads1 in ./Ecoli/reads_trimmed/*/
do
		reads2=${reads1%%val_1.fq.gz}"val_2.fq.gz"
		sample=$( basename $reads1 )
		sample=$( echo ${sample%%_val_1.fq.gz} )
		sample=$( echo ${sample} | sed 's/^[0-9]_//g' )
		# echo $reads1 $reads2 $sample
		bwa mem ref_genomes/Ecoli*.fasta $reads1 $reads2 > ./Ecoli/mapping/$sample.sam
	done
 

for samfile in ./Ecoli/mapping/*.sam
	do
		sample=$( basename ${samfile} )
		samtools view -b $samfile | samtools sort -o ./Ecoli/mapping/$sample.bam
	done
parallel  samtools index ::: Ecoli/mapping/*.sorted.bam

# With the bam files sorted and indexed, a profile was made for each of the mutated strains.
for bamfile in Ecoli/mapping/*.sorted.bam
do
	samplename=$( basename $bamfile )
	samplename=${samplename::-11 } 	
	anvi-profile -T 5 -i $bamfile -c ../anvio/Ecoli/complete_contigs.db -o ../anvio/Ecoli/profiles/Ecoli-profiledb/ -S $samplename
done
 
	# Merge all profiles into a merged profile for visualization
profiles=$( echo ../anvio/Ecoli/profiles/*/PROFILE.db )
anvi-merge  $profiles -o .anvio/Ecoli/profiles/Ecoli-merged -c anvio/Ecoli/complete_contigs.db

# For visualization:
anvi-interactive -p ../anvio/Ecoli/profiles/Ecoli-merged/PROFILE.db -c ../anvio/Ecoli/complete_contigs.db

conda deactivate
