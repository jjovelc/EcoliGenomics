SELECT
    s.source,
    a.sample_id,
    COUNT(DISTINCT a.gene_symbol) AS unique_amr_genes
FROM
    samples s
JOIN
    amrp_results a ON s.isolate = a.sample_id
GROUP BY
    s.source, a.sample_id
ORDER BY
    s.source, a.sample_id;
