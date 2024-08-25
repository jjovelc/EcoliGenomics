SELECT 
    s.source,
    COUNT(DISTINCT i.id) AS num_unique_integrons,
    COUNT(i.id) AS total_integrons_entries,
    GROUP_CONCAT(DISTINCT i.gene) AS unique_gene_names
FROM 
    samples s
JOIN 
    plasmFinder_results p ON s.isolate = p.sample_id
GROUP BY 
    s.source
ORDER BY 
    s.source;
