CREATE OR REPLACE VIEW imposm3.view_parking AS
SELECT *, 'node' AS typ FROM imposm3.osm_parking_nodes
UNION ALL
SELECT *, 'area' AS typ FROM imposm3.osm_parking_poly;