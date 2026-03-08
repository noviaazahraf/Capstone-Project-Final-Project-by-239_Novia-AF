# **Final Project by 239_Novia AF**
Repositori ini merupakan final project dari A-Bioinformatics Research Starter Program yang diselenggarakan Omicslite. 

Dibuat oleh: Novia Azahra Fatoni

Jurnal Pembanding: Wang et al. (2023) - Identification and characterization of differentially expressed genes in cervical cancer: insights from transcriptomic analysis https://cellmolbiol.org/index.php/CMB/article/view/4983/2726 

Dataset: GSE9750

____
# Pendahuluan dan Latar Belakang

Kanker serviks merupakan salah satu penyebab utama morbiditas dan mortalitas pada perempuan di seluruh dunia. Prognosis pasien sangat dipengaruhi oleh stadium penyakit saat diagnosis. Tingkat kelangsungan hidup lima tahun pada kanker serviks stadium awal dapat mencapai lebih dari 90%, namun angka tersebut menurun secara signifikan pada stadium lanjut ketika kanker telah menyebar ke jaringan atau organ sekitar (Lu et al., 2022). Oleh karena itu, identifikasi biomarker molekuler yang berperan dalam progresi kanker serviks menjadi sangat penting untuk meningkatkan diagnosis dini, strategi terapi, serta prediksi prognosis pasien.

Tujuan:
1)	Melakukan identifikasi Differentially Expressed Genes (DEG) antara sampel kanker cervix dan normal dengan aplikasi GEO2R menggunakan dataset GSE9750
2)	Melakukan identifikasi Differentially Expressed Genes (DEG) antara sampel kanker cervix dan normal dengan Bahasa R menggunakan dataset GSE9750
3)	Melakukan analisis enrichment yang mencakup Gene Ontology (GO) dan KEGG Pathway
4)	Melakukan studi komparatif antara hasil olah data mandiri dengan temuan pada jurnal referensi Wang et al. (2023) 


# Metode
1)	Pencarian dan Pengunduhan Data Ekspresi Gen Publik
2)	Identifikasi Gen yang Terekpresikan Diferensial (DEGs)
3)	Analisis Enrichment Fungsional dari DEGs

# Hasil dan Interpretasi
1)	Identifikasi Gen yang Terekspresikan Diferensial (DEGs) dengan Aplikasi GEO2R
<img width="863" height="608" alt="image" src="https://github.com/user-attachments/assets/01623f8f-92c7-4bf1-b1c0-65c70506ebd6" /> (Gen Diferensial pada GSE9750. (A) Box plot. (B) Volcano Plot. (C) MD Plot. (D) Diagram Venn.)

2)	Identifikasi DEGs dengan Bahasa R
   
<img width="654" height="423" alt="image" src="https://github.com/user-attachments/assets/74db54d1-3ca9-4f89-82b2-a9ad1fc1521c" /> (PCA Plot Dataset GSE9750)

<img width="644" height="582" alt="image" src="https://github.com/user-attachments/assets/1b252a7d-b638-4170-85bf-bb9f403e50f4" /> (Volcano Plot Dataset GSE9750)

<img width="756" height="488" alt="image" src="https://github.com/user-attachments/assets/06f0d8de-3cb2-480b-9dee-d0b17d5ed061" /> (Boxplot Dataset GSE9750)

<img width="622" height="562" alt="image" src="https://github.com/user-attachments/assets/ff5663c0-25c3-4d53-b8ec-a1463e1fdeb7" /> (Heatmap Dataset GSE9750)
  
4)	Analisis Enrichment
    a) Gene Ontology (GO) Enrichment

<img width="768" height="496" alt="image" src="https://github.com/user-attachments/assets/ff30d14b-58d4-48c7-8540-78c6afe4948c" />

<img width="771" height="497" alt="image" src="https://github.com/user-attachments/assets/39be4206-7d99-4588-94d3-307e6921ecd7" />

<img width="758" height="488" alt="image" src="https://github.com/user-attachments/assets/da7cf3ad-8623-45d3-805d-01e1179b4e6e" />


  	b) KEGG Pathway

| Category | Subcategory | ID | Description |
| --- | --- | --- | --- |
|Human Diseases|Neurodegenerative disease	|hsa05022	|Pathways of neurodegeneration - multiple diseases|
|Human Diseases|Neurodegenerative disease	|hsa05012|Parkinson disease|
|Human Diseases|Neurodegenerative disease	|hsa05016|Huntington disease|
|Human Diseases|Infectious disease: viral	|hsa05171	|Coronavirus disease - COVID-19|
|Human Diseases|Neurodegenerative disease	|hsa05020|Prion disease|


<img width="760" height="504" alt="image" src="https://github.com/user-attachments/assets/93196ed6-095a-4b3a-b0bb-a7cd194be29d" />

6) Perbandingan Hasil Percobaan dan Jurnal


# Kesimpulan

Berdasarkan analisis bioinformatika terhadap dataset GSE9750, berhasil diidentifikasi gen-gen yang mengalami perubahan ekspresi signifikan antara sampel kanker serviks dan jaringan serviks normal. Analisis menggunakan GEO2R dan bahasa pemrograman R menunjukkan adanya ribuan gen yang berbeda secara signifikan, dengan penyaringan lebih lanjut menghasilkan 1.633 differentially expressed genes (DEGs) menggunakan kriteria |log2 fold change| > 1 dan adjusted p-value < 0,05.
Visualisasi data melalui PCA plot, volcano plot, boxplot, dan heatmap menunjukkan pemisahan yang jelas antara kelompok sampel normal dan kanker, yang mengindikasikan adanya perbedaan pola ekspresi gen yang signifikan di antara kedua kelompok tersebut. Hasil ini mendukung validitas dataset dan metode analisis yang digunakan.
Analisis enrichment menggunakan Gene Ontology (GO) menunjukkan bahwa gen-gen yang mengalami perubahan ekspresi terutama terlibat dalam proses translasi protein, metabolisme energi, pemrosesan RNA, serta regulasi adhesi sel. Sementara itu, analisis KEGG pathway menunjukkan keterlibatan jalur yang berkaitan dengan fungsi mitokondria, stres oksidatif, metabolisme energi sel, dan respons terhadap infeksi virus.
Secara keseluruhan, hasil penelitian ini mendukung temuan sebelumnya bahwa disregulasi metabolisme sel, sintesis protein, serta perubahan regulasi ekspresi gen merupakan mekanisme penting dalam perkembangan kanker serviks. Analisis bioinformatika ini memberikan wawasan tambahan mengenai jalur molekuler yang berpotensi menjadi target penelitian lebih lanjut dalam pengembangan biomarker diagnostik maupun terapi untuk kanker serviks.




_________
***Referenes***

Bolstad, B. M., Irizarry, R. A., Åstrand, M., & Speed, T. P. (2003). A comparison of normalization methods for high density oligonucleotide array data based on variance and bias. Bioinformatics, 19(2), 185–193. https://doi.org/10.1093/bioinformatics/19.2.185

Cui, X., & Churchill, G. A. (2003). Statistical tests for differential expression in cDNA microarray experiments. Genome Biology, 4(4), 210. https://doi.org/10.1186/gb-2003-4-4-210

Graham, S. V. (2017). The human papillomavirus replication cycle, and its links to cancer progression: A comprehensive review. Clinical Science, 131(17), 2201–2221. https://doi.org/10.1042/CS20160786

Hanahan, D., & Weinberg, R. A. (2011). Hallmarks of cancer: The next generation. Cell, 144(5), 646–674. https://doi.org/10.1016/j.cell.2011.02.013

Hynes, R. O. (2002). Integrins: Bidirectional, allosteric signaling machines. Cell, 110(6), 673–687. https://doi.org/10.1016/S0092-8674(02)00971-6

Lu, H., et al. (2022). Timely estimates of 5-year relative survival for patients with cervical cancer. Frontiers in Public Health, 10, 926058. https://doi.org/10.3389/fpubh.2022.926058

NCBI. (2024). About GEO2R. https://www.ncbi.nlm.nih.gov/geo/info/geo2r.html#vooma

Oltean, S., & Bates, D. O. (2014). Hallmarks of alternative splicing in cancer. Oncogene, 33(46), 5311–5318. https://doi.org/10.1038/onc.2013.533

Ringnér, M. (2008). What is principal component analysis? Nature Biotechnology, 26(3), 303–304. https://doi.org/10.1038/nbt0308-303

Takeichi, M. (2014). Dynamic contacts: Rearranging adherens junctions to drive epithelial remodelling. Nature Reviews Molecular Cell Biology, 15(6), 397–410. https://doi.org/10.1038/nrm3802

Wallace, D. C. (2012). Mitochondria and cancer. Nature Reviews Cancer, 12(10), 685–698. https://doi.org/10.1038/nrc3365

Wang, H., Lu, X., Fang, L., Shi, Q., & Yang, X. (2023). Identification and characterization of differentially expressed genes in cervical cancer: Insights from transcriptomic analysis. Cellular and Molecular Biology, 69(10), 276–281. https://doi.org/10.14715/cmb/2023.69.10.40

Wilkinson, L., & Friendly, M. (2009). The history of the cluster heat map. The American Statistician, 63(2), 179–184. https://doi.org/10.1198/tas.2009.0033

Wu, B., & Xi, S. (2021). Bioinformatics analysis of differentially expressed genes and pathways in the development of cervical cancer. BMC Cancer, 21, 733. https://doi.org/10.1186/s12885-021-08450-7
