SELECT
    s.source,
    i.sample_id,
    COUNT(DISTINCT i.int_id) AS num_unique_integrons,
    COUNT(i.int_id) AS total_integron_entries,
    GROUP_CONCAT(DISTINCT i.type_elt) AS unique_integron_types
FROM
    samples s
JOIN
    intFinder_results i ON s.isolate = i.sample_id
GROUP BY
    s.source, i.sample_id
ORDER BY
    s.source, i.sample_id;
