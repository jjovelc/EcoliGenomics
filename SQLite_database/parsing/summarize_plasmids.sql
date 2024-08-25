SELECT 
    s.source,
    COUNT(DISTINCT p.id) AS num_unique_mges,
    COUNT(p.id) AS total_plasmid_entries,
    GROUP_CONCAT(DISTINCT p.gene) AS unique_gene_names
FROM 
    samples s
JOIN 
    plasmFinder_results p ON s.isolate = p.sample_id
GROUP BY 
    s.source
ORDER BY 
    s.source;
