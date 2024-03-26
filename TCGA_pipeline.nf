process Download_from_gdc{
	publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy"
	
	input:
		val cancer_type
	        val data_type
        output:
		publishDir 
		file "TCGA-*"

	shell:
	"""	
	Rscript $baseDir/modules/Download.R !{cancer_type} !{data_type} "UUID_2_barcode.tsv"
	
	for f in \$(ls ./)	 
	do
		if [ "\$f" != "UUID_2_barcode.tsv" ];then
		f_new=\$(grep \$f "UUID_2_barcode.tsv"|cut -f3)
		echo -e "gene\tgeneSymbol\treadCounts" > \$f_new".tsv"
		awk 'BEGIN { FS=OFS="\t" } {if(NR >6) print \$1,\$2,\$4}' \$f/* >> \$f_new".tsv"
		fi
	done
	"""
}

process Normalization{
	publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy"
	input:
		each path(readCounts)
	output:
		publishDir
                file "*.norm"
	script:
	"""
	python $baseDir/modules/Normalization.py -i ${readCounts} -geneLength ${params.geneLength} -o ${readCounts}".norm"
	"""
}

process Merge{
        publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy"
        input:
                path all_exp_files
        output:
                publishDir
                file "TPM_${params.cancer_type}.merged.tsv"
		file "TPM_${params.cancer_type}.merged.logP_norm.tsv"
        shell:
        """
        #!/usr/bin/env python
        import pandas as pd
        import numpy as np
        import subprocess

        dfs_list = []

        TCGA_indiv_files = "${all_exp_files}"[1:-1]
        TCGA_indiv_files = TCGA_indiv_files.strip().split(", ")
        for f in TCGA_indiv_files:
                TCGA_barcode = f.split('.')[0]
                df_tmp = pd.read_csv(f, sep='\t').loc[:,['geneSymbol','TPM']].set_index('geneSymbol').rename(columns={'TPM':TCGA_barcode})
                dfs_list.append(df_tmp)

        exp_merged = pd.concat(dfs_list, axis=1).T
        exp_merged = exp_merged.loc[:,exp_merged.sum() != 0] 
        exp_merged.dropna(inplace=True)

        exp_merged.to_csv("TPM_${params.cancer_type}.merged.tsv".format(),sep='\t')

	exp_merged_scaled = np.log10(exp_merged+1)
	exp_merged_scaled.to_csv("TPM_${params.cancer_type}.merged.logP_norm.tsv".format(),sep='\t')
        """
}


workflow{
	Download_from_gdc(params.cancer_type, params.data_type)
	Normalization(Download_from_gdc.out)
        Merge(Normalization.out.collect())
}
