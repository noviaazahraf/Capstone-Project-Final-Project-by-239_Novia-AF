#Modul: Analisis Ekspresi Gen Kanker Paru 
#Dataset: GSE10072 (Lung Adenocarcinoma vs Normal)
#Platform: Microarray (Affymetrix GPL96)
#Tujuan: Mengidentifikasi Differentially Expressed Genes (DEG) 

#PART A. PENGANTAR KONSEP 

#Analisis ekspresi gen bertujuan untuk membandingkan tingkat ekspresi gen 
#antara dua kondisi biologis (misalnya kanker vs normal) 
#Pada modul ini kita menggunakan pendekatan statistik limma (Linear Models
#for Microarray Data), yang merupakan standar emas untuk data microarray. 

#PART B. PERSIAPAN LINGKUNGAN KERJA (INSTALL & LOAD PACKAGE) 

#Apa itu package? 
#Package adalah kumpulan fungsi siap pakai di R
#Bioinformatika di R sangat bergantung pada package dari CRAN dan Bioconductor 

#1. Install BiocManager (manajer paket Bioconductor) 
#IF adalah struktur logika : “jika kondisi terpenuhi, lakukan aksi”

if (!require("BiocManager", quietly = TRUE))  {
  install.packages("BiocManager") 
}

# 2. Install paket Bioconductor (GEOquery & limma) 
#GEOquery: mengambil data dari database GEO 
#limma: analisis statistik ekspresi gen 

BiocManager::install(c("GEOquery", "limma"), ask = FALSE, update = FALSE) 

#Install annotation package sesuai platform
#GPL96 = Affymetrix Human Genome U133A 
BiocManager::install("hgu133a.db", ask = FALSE, update = FALSE)

#3. Install paket CRAN untuk visualisasi dan manipulasi data 
#phetmap: heatmap ekspresi gen 
#ggplot2: grafik (volcano plot)
#dplyr: manipulasi tabel data 

install.packages(c("pheatmap", "ggplot2", "dplyr"))

#umap: grafik (plot UMAP) 
if (!requireNamespace("umap", quietly = TRUE)) {
  install.packages("umap")
}

#4. Memanggil library 
#library() digunakan agar fungsi di dalam package bisa digunakan 
library(GEOquery)
library(limma)
library(pheatmap)
library(ggplot2)
library(dplyr)
library(hgu133a.db)
library(AnnotationDbi)


#PART C. PENGAMBILAN DATA DARI GEO 


#GEO (Gene Expression Omnibus) adalah database publik milik NCBI
#getGEO(): fungsi untuk mengunduh dataset berdasarkan ID GEO
#GSEMatrix = TRUE -> data diambil dalam format ExpressionSet
#AnnotGPL  = TRUE -> anotasi gen (Gene Symbol) ikut diunduh

gset <- getGEO("GSE9750", GSEMatrix = TRUE, AnnotGPL = TRUE)[[1]]

#ExpressionSet berisi:
# - exprs() : matriks ekspresi gen
# - pData() : metadata sampel
# - fData() : metadata fitur (probe / gen)

#PART D. PRE-PROCESSING DATA EKSPRESI 

# exprs(): mengambil matriks ekspresi gen
# Baris  = probe/gen
# Kolom  = sampel
ex <- exprs(gset)

#Mengapa perlu log2 transformasi?
#Data microarray mentah memiliki rentang nilai sangat besar.
#Log2 digunakan untuk:
#1. Menstabilkan varians
#2. Mendekati asumsi model linear
#3. Memudahkan interpretasi log fold change

#quantile(): menghitung nilai kuantil (persentil)
#as.numeric(): mengubah hasil quantile (yang berupa named vector)
#menjadi vektor numerik biasa agar mudah dibandingkan
qx <- as.numeric(quantile(ex, c(0, 0.25, 0.5, 0.75, 0.99, 1), na.rm = TRUE))

#LogTransform adalah variabel logika (TRUE / FALSE)
#Operator logika:
#>  : lebih besar dari
#| | : OR (atau)
#&& : AND (dan)
LogTransform <- (qx[5] > 100) || (qx[6] - qx[1] > 50 && qx[2] > 0)

#IF statement:
#Jika LogTransform = TRUE, maka lakukan log2
if (LogTransform) {
  # Nilai <= 0 tidak boleh di-log, maka diubah menjadi NA
  ex[ex <= 0] <- NA
  ex <- log2(ex)
}


##############################################
# PART E. DEFINISI KELOMPOK SAMPEL
##############################################

# Metadata sampel
group_info <- pData(gset)[["source_name_ch1"]]

# Membuat dua kelompok biologis
groups <- ifelse(
  grepl("normal", group_info, ignore.case = TRUE),
  "Normal",
  "Cancer"
)

# Mengubah menjadi faktor
gset$group <- factor(groups, levels = c("Cancer","Normal"))

# Cek jumlah sampel tiap grup
table(gset$group)

# Menampilkan nama grup
nama_grup <- levels(gset$group)
print(nama_grup)

##############################################
# PART F. DESIGN MATRIX
##############################################
#model.matrix():
#Membuat matriks desain untuk model linear
#~0 berarti TANPA intercept (best practice limma)
design <- model.matrix(~0 + gset$group)

#colnames(): memberi nama kolom agar mudah dibaca
colnames(design) <- levels(gset$group)
design[1:10, ]

#Menentukan perbandingan biologis
grup_kanker <- "Cancer"
grup_normal <- "Normal"

contrast_formula <- paste(grup_kanker, "-", grup_normal)

print(paste("Kontras yang dianalisis:", contrast_formula))

#PART G. ANALISIS DIFFERENTIAL EXPRESSION (LIMMA)

#lmFit():
#Membangun model linear untuk setiap gen
fit <- lmFit(ex, design)

#makeContrasts(): mendefinisikan perbandingan antar grup
contrast_matrix <- makeContrasts(contrasts = contrast_formula, levels = design)

#contrasts.fit(): menerapkan kontras ke model
fit2 <- contrasts.fit(fit, contrast_matrix)

#eBayes():
#Empirical Bayes untuk menstabilkan estimasi varians
fit2 <- eBayes(fit2)

#topTable():
#Mengambil hasil akhir DEG
#adjust = "fdr" -> koreksi multiple testing
#p.value = 0.01  -> gen sangat signifikan
topTableResults <- topTable(
  fit2,
  adjust = "fdr",
  sort.by = "B",
  number = Inf,
  p.value = 0.01
)

head(topTableResults)

# PART H. ANOTASI NAMA GEN
##############################################
#Penting:
#Pada data microarray Affymetrix, unit analisis awal adalah PROBE,
#bukan gen. Oleh karena itu, anotasi ulang diperlukan menggunakan
#database resmi Bioconductor.

#Mengambil ID probe dari hasil DEG
probe_ids <- rownames(ex)
topTableResults$PROBEID <- rownames(ex)[1:nrow(topTableResults)]
head(topTableResults$PROBEID)

#Mapping probe -> gene symbol & gene name
gene_annotation <- AnnotationDbi::select(
  hgu133a.db,
  keys = topTableResults$PROBEID,
  columns = c("SYMBOL","GENENAME"),
  keytype = "PROBEID"
)
#Gabungkan dengan hasil limma
deg_annotated <- merge(
  topTableResults,
  gene_annotation,
  by = "PROBEID",
  all.x = TRUE
)
#Cek hasil anotasi
head(deg_annotated[, c("PROBEID","SYMBOL","GENENAME")])

##########################################################
# PART I.1 BOXPLOT DISTRIBUSI NILAI EKSPRESI

# Boxplot digunakan untuk:
# - Mengecek distribusi nilai ekspresi antar sampel
# - Melihat apakah ada batch effect
# - Mengevaluasi apakah normalisasi/log-transform sudah wajar

# Normalisasi quantile (standar microarray)
ex <- normalizeBetweenArrays(ex)

# Set warna grup

group_colors <- c("Cancer"="salmon", "Normal"="skyblue")[gset$group]

boxplot(
  ex,
  col = group_colors,
  las = 2,
  outline = FALSE,
  main = "Boxplot of Normalized Expression Values",
  ylab = "Log2 Expression",
  cex.axis = 0.7
)

legend(
  "topright",
  legend = levels(gset$group),
  fill = c("skyblue","salmon"),
  cex = 0.8
)


#PART I.2 PCA 
#PCA digunakan untuk
#1. Menyedehanakan data kompleks
#2. Melihat pola global
#3. Mengevaluasi kualitas data

# Transpose matriks ekspresi: observasi = sampel, fitur = gen
pca_input <- t(ex)
# Hilangkan kolom (gen/probe) yang punya NA/Inf
pca_input_clean <- apply(pca_input, 2, function(x) {
  ifelse(is.na(x), mean(x, na.rm = TRUE), x)
})
pca_res <- prcomp(pca_input_clean, center = TRUE, scale. = TRUE)
pca_scores <- as.data.frame(pca_res$x)
pca_scores$Group <- gset$group

#plot PCA

group_colors <- c("Cancer"="salmon", "Normal"="skyblue")

ggplot(pca_scores, aes(x = PC1, y = PC2, color = Group)) +
  geom_point(size = 3) +
  scale_color_manual(values = group_colors) +
  theme_minimal() +
  labs(
    title = "PCA of GSE9750 Samples",
    x = paste0("PC1 (", round(summary(pca_res)$importance[2,1]*100, 1), "%)"),
    y = paste0("PC2 (", round(summary(pca_res)$importance[2,2]*100, 1), "%)")
  )


#PART J. VISUALISASI VOLCANO PLOT 

#Volcano plot menggabungkan:
#- Log fold change (efek biologis)
#- Signifikansi statistik

volcano_data <- deg_annotated

# Tentukan status UP/DOWN/NO
volcano_data$status <- "NO"
volcano_data$status[volcano_data$logFC > 1 & volcano_data$adj.P.Val < 0.05] <- "UP"
volcano_data$status[volcano_data$logFC < -1 & volcano_data$adj.P.Val < 0.05] <- "DOWN"

ggplot(volcano_data, aes(x = logFC, y = -log10(adj.P.Val), color = status)) +
  geom_point(alpha = 0.6) +
  scale_color_manual(values = c("DOWN" = "lightblue", "NO" = "grey", "UP" = "salmon")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  theme_minimal() +
  ggtitle("Volcano Plot DEG Kanker Cervix")

#PART J.2 VISUALISASI HEATMAP 

#Heatmap digunakan untuk melihat pola ekspresi gen
#antar sampel berdasarkan gen-gen paling signifikan

#Pilih 50 gen paling signifikan berdasarkan adj.P.Val
top50 <- head(deg_annotated[order(deg_annotated$adj.P.Val), ], 50)

#Ambil matriks ekspresi untuk gen terpilih
mat_heatmap <- ex[top50$PROBEID, ]
# Buat anotasi kolom (sampel)
annotation_col <- data.frame(
  Group = gset$group   # pastikan gset$group sudah berisi faktor "Cancer"/"Normal"
)

# Nama baris data.frame harus sama dengan kolom matriks ekspresi
rownames(annotation_col) <- colnames(mat_heatmap)

# Sekarang jalankan heatmap
library(pheatmap)

pheatmap(
  mat_heatmap,
  scale = "row",                 # Z-score per gen
  annotation_col = annotation_col,
  show_colnames = FALSE,         # nama sampel dimatikan
  show_rownames = TRUE,
  fontsize_row = 7,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  main = "Top 50 Differentially Expressed Genes"
)

#PART K.Filter Top 100 Differentially Expressed Genes
# Filter with |log2FC| > 2.5 and FDR < 0.05
library(DESeq2)
# counts: gen sebagai baris, sampel sebagai kolom
counts <- matrix(c(100,200,150,80,300,120), nrow=2)
rownames(counts) <- c("Gene1", "Gene2")
colnames(counts) <- c("ctl_1","ctl_2","uvc_1")

# colData: baris = sampel, kolom = Treatment
colData <- data.frame(
  Treatment = c("Control","Control","UV-C"),
  row.names = c("ctl_1","ctl_2","uvc_1")
)
#pembuatan DESeq2
library(DESeq2)

dds <- DESeq(dds)  # ini akan menjalankan analisis
res <- results(dds)

res_filtered <- res %>%
  as.data.frame() %>%
  filter(!is.na(padj)) %>%
  filter(abs(log2FoldChange) > 0.5, padj < 0.05)

# Sort by adjusted p-value (or |log2FC|)
top100 <- res_filtered %>%
  arrange(padj) %>%
  head(100)

head(top100)

#PART M. Enrichment Analysis
# Get the gene IDs DE result
de_genes <- rownames(top100)

gene_entrez <- bitr(
  deg_sig$SYMBOL,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

# drop NAs
entrez_ids <- na.omit(entrez)
length(entrez_ids)

# GO: Biological Process
ego_bp <- enrichGO(gene       = gene_entrez$ENTREZID,
                   OrgDb         = org.Hs.eg.db,
                   keyType       = "ENTREZID",
                   ont           = "BP",         # Biological Process
                   pAdjustMethod = "BH",
                   pvalueCutoff  = 0.05,
                   qvalueCutoff  = 0.05,
                   readable      = TRUE) 

# Plot
dotplot(ego_bp, showCategory = 20) +
  ggtitle("GO Enrichment: Biological Process") +
  theme(
    plot.title   = element_text(size = 18, face = "bold"),
    axis.text.x  = element_text(size = 12),
    axis.text.y  = element_text(size = 10),
    legend.text  = element_text(size = 12),
    legend.title = element_text(size = 14)
  )

# GO: Cellular Component
ego_cc <- enrichGO(gene       = gene_entrez$ENTREZID,
                   OrgDb         = org.Hs.eg.db,
                   keyType       = "ENTREZID",
                   ont           = "CC",         # Biological Process
                   pAdjustMethod = "BH",
                   pvalueCutoff  = 0.05,
                   qvalueCutoff  = 0.05,
                   readable      = TRUE) 

# Plot
dotplot(ego_cc, showCategory = 20) +
  ggtitle("GO Enrichment: Cellular Component") +
  theme(
    plot.title   = element_text(size = 18, face = "bold"),
    axis.text.x  = element_text(size = 12),
    axis.text.y  = element_text(size = 10),
    legend.text  = element_text(size = 12),
    legend.title = element_text(size = 14)
  )

# GO: Molecular Function
ego_mf <- enrichGO(gene       = gene_entrez$ENTREZID,
                   OrgDb         = org.Hs.eg.db,
                   keyType       = "ENTREZID",
                   ont           = "MF",         # Biological Process
                   pAdjustMethod = "BH",
                   pvalueCutoff  = 0.05,
                   qvalueCutoff  = 0.05,
                   readable      = TRUE) 

# Plot
dotplot(ego_mf, showCategory = 20) +
  ggtitle("GO Enrichment: Molecular Function") +
  theme(
    plot.title   = element_text(size = 18, face = "bold"),
    axis.text.x  = element_text(size = 12),
    axis.text.y  = element_text(size = 8),
    legend.text  = element_text(size = 12),
    legend.title = element_text(size = 14)
  )

# Write csv for top 20 GO result
# Convert to data frames and take top 20
bp_df <- head(as.data.frame(ego_bp), 20)
cc_df <- head(as.data.frame(ego_cc), 20)
mf_df <- head(as.data.frame(ego_mf), 20)

# Add a column to indicate the ontology
bp_df$Ontology <- "BP"
cc_df$Ontology <- "CC"
mf_df$Ontology <- "MF"

# Combine into one table
go_top20 <- rbind(bp_df, cc_df, mf_df)
# KEGG Pathway Analysis
# Run KEGG enrichment 
kegg_result <- enrichKEGG(
  gene = gene_entrez$ENTREZID,
  organism = "hsa"
)

kegg_result <- setReadable(
  kegg_result,
  OrgDb = org.Hs.eg.db,
  keyType = "ENTREZID"
)

# Create plot
dotplot(kegg_result, showCategory = 20) +
  ggtitle("KEGG Pathway Enrichment") +
  theme(
    plot.title   = element_text(size = 18, face = "bold"),
    axis.text.x  = element_text(size = 12),
    axis.text.y  = element_text(size = 5),
    legend.text  = element_text(size = 12),
    legend.title = element_text(size = 14)
  )

# View top 5 pathways
top5_pathways <- kegg_result@result %>%
  arrange(p.adjust) %>%
  head(5)


# 11. Save outputs
write.csv(res,         "all_results.csv")
write.csv(up,          "upregulated.csv")
write.csv(down,        "downregulated.csv")
write.csv(raw_counts,  "raw_counts.csv")
write.csv(top100, "top100_DE_genes.csv", row.names = TRUE)
write.csv(top5_pathways, "top5_pathways.csv", row.names = FALSE)
write.csv(go_top20, "GO_top20_BP_CC_MF.csv", row.names = FALSE)

































#Pembersihan data (WAJIB agar tidak error hclust)
#Hapus baris dengan NA
mat_heatmap <- mat_heatmap[
  rowSums(is.na(mat_heatmap)) == 0,
]

#Hapus gen dengan varians nol
gene_variance <- apply(mat_heatmap, 1, var)
mat_heatmap <- mat_heatmap[gene_variance > 0, ]

#Anotasi kolom (kelompok sampel)
annotation_col <- data.frame(
  Group = gset$group
)

rownames(annotation_col) <- colnames(mat_heatmap)

#Visualisasi heatmap 
pheatmap(
  mat_heatmap,
  scale = "row",                 # Z-score per gen
  annotation_col = annotation_col,
  show_colnames = FALSE,         # nama sampel dimatikan
  show_rownames = TRUE,
  fontsize_row = 7,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  main = "Top 50 Differentially Expressed Genes"
)


#PART K. MENYIMPAN HASIL 

# write.csv(): menyimpan hasil analisis ke file CSV
write.csv(topTableResults, "Hasil_GSE10072_DEG.csv")

message("Analisis selesai. File hasil telah disimpan.")








