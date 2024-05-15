
conda activate anvio-8
anvi-script-reformat-fasta ref_genomes/$strain.fasta -o ref_genomes/$strain.reformat.fasta --simplify-names --report-file anvio/$strain/$strain-contigs-reformat.txt
conda deactivate

## Se anota la referencia del genoma reformateado (reformat.fasta) con el gbk del pangenoma generado antes
##Sobre las anotaciones sin --compliant



conda activate prokka
	prokka --proteins ref_genomes/$strain*.gbk --outdir anvio/$strain/functions/ --prefix $strain.annot ref_genomes/$strain.reformat.fasta --cpus 5
conda deactivate prokka
