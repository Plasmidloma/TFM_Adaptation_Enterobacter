conda activate abricate

#the fnas generated by the annotation with PGAP or Prokka was requiered
for genome in /media/paloma/TFM_Paloma/Plasmidome/*.fna
do
  strain=$( basename $genome | cut -d '.' -f 1)
	abricate --db plasmidfinder $genome > abricate_plasmidfinder/$strain.plasmids.tab
	abricate --db resfinder $genome > abricate_resfinder/$strain.args.tab
done

# The final tables were summarized and united using the following command (ex.with args).
abricate --summary C325.args.tab PF_EC11.args.tab PF_KPN06.args.tab CF12.args.tab  PF_EC12.args.tab   PF_KPN07.args.tab CF13.args.tab PF_EC14.args.tab PF_KPN08.args.tab H53.args.tab PF_EC16.args.tab PF_KPN09.args.tab J57.args.tab PF_EC17.args.tab PF_KPN10.args.tab K147.args.tab PF_EC18.args.tab PF_KPN11.args.tab K153.args.tab  PF_EC19.args.tab   PF_KPN12.args.tab K163.args.tab  PF_EC20.args.tab PF_KPN14.args.tab K25.args.tab PF_EC21.args.tab PF_KPN15.args.tab MG1655.args.tab PF_EC22.args.tab PF_KPN16.args.tab PF_EC02.args.tab PF_EC23.args.tab PF_KPN18.args.tab PF_EC03.args.tab PF_EC24.args.tab PF_KPN19.args.tab PF_EC05.args.tab PF_EC25.args.tab PF_KPN20.args.tab PF_EC06.args.tab PF_KPN01.args.tab PF_KQ01.args.tab PF_EC07.args.tab PF_KPN02.args.tab PF_KQ02.args.tab PF_EC08.args.tab PF_KPN03.args.tab PF_KQ03.args.tab PF_EC09.args.tab PF_KPN04.args.tab PF_KQ04.args.tab PF_EC10.args.tab PF_KPN05.args.tab PF_KV01.args.tab  > summary_arg.tab 

#Lastly, this table had to be reconverted --> all the dots transformed to 0,a ll the names homogenize so the heatmao code in R could used it as input data. 
conda deactivate