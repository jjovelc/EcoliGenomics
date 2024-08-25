.headers on
.mode column

SELECT 
    ar.id AS amrp_id, 
    ar.sample_id AS amrp_sample_id, 
    ar.contig_id AS amrp_contig_id, 
    ar.start AS amrp_start, 
    ar.stop AS amrp_stop, 
    mr.id AS mge_id, 
    mr.sample_id AS mge_sample_id, 
    mr.contig AS mge_contig, 
    mr.start AS mge_start, 
    mr.end AS mge_end
FROM 
    amrp_results ar
JOIN 
    mge_results mr
ON 
    ar.sample_id = mr.sample_id
    AND ar.contig_id = mr.contig
    AND ar.start <= mr.end
    AND ar.stop >= mr.start;
