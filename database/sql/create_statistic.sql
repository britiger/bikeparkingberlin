SET client_min_messages TO WARNING;

CREATE SCHEMA IF NOT EXISTS statistic;
CREATE TABLE IF NOT EXISTS statistic.opendata (
    suffix VARCHAR(255) NOT NULL,
    stat_date DATE NOT NULL,
    cnt_total INT,
    cnt_missing INT,
    primary key (suffix, stat_date)
);

CREATE OR REPLACE FUNCTION statistic.update_statistics()
RETURNS void
LANGUAGE plpgsql 
AS $$
DECLARE
    rec record;
    query text;
    all_table text;
    missing_table text;
    current_date date;
BEGIN
    current_date := NOW();
    FOR rec IN SELECT suffix FROM extern.external_data
    LOOP
        INSERT INTO statistic.opendata (suffix, stat_date) VALUES (rec.suffix, current_date) ON CONFLICT DO NOTHING;
        all_table := 'extern.all_parking_' || rec.suffix;
        missing_table := 'extern.missing_parking_' || rec.suffix;

        query := 'UPDATE statistic.opendata
            SET
                cnt_total=(SELECT count(*) FROM '|| all_table ||'),
                cnt_missing=(SELECT count(*) FROM '|| missing_table ||')
            WHERE suffix=$1 AND stat_date=$2';
        EXECUTE query USING rec.suffix, current_date;
    END LOOP;
END
$$;

-- Initial Update
SELECT statistic.update_statistics();
