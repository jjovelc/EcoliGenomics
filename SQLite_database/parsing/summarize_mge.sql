SELECT 
    s.source,
    COUNT(DISTINCT m.mge_no) AS num_unique_mges,
    COUNT(m.id) AS total_mge_entries,
    GROUP_CONCAT(DISTINCT m.name) AS unique_mge_names
FROM 
    samples s
JOIN 
    mge_results m ON s.isolate = m.sample_id
GROUP BY 
    s.source
ORDER BY 
    s.source;
