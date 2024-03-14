library("GenomicDataCommons")

args <- commandArgs(trailingOnly = TRUE)
ge_manifest = files() %>% 
    		filter( ~ cases.project.project_id == args[1]) %>% 
                filter(type == args[2]) %>% 
    		filter(access == 'open') %>%
		manifest()

gdc_set_cache(getwd())
fnames = lapply(ge_manifest$id, gdcdata, use_cached=TRUE, progress=TRUE)

# file UUID to TCGA barcode
file_uuids <- ge_manifest$id

TCGAtranslateID = function(file_ids) {
    info = files() %>%
        filter( ~ file_id %in% file_ids) %>%
        select('cases.samples.submitter_id') %>%
        results_all()
    id_list = lapply(info$cases,function(a) {
        a[[1]][[1]][[1]]})
    barcodes_per_file = sapply(id_list,length)
    return(data.frame(file_id = rep(ids(info),barcodes_per_file),
                      submitter_id = unlist(id_list)))
    }

ID_mapping = TCGAtranslateID(file_uuids)
ID_mapping <- cbind(uuid = rownames(ID_mapping), ID_mapping)
rownames(ID_mapping) <- NULL

write.table(ID_mapping, args[3], sep='\t', quote=FALSE, row.names=FALSE)
