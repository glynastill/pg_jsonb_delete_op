-- 
-- Glyn Astill 16/01/2015
-- Attempt at hstore style delete operator for jsonb
--

SET search_path = 'public';

CREATE OR REPLACE FUNCTION jsonb_delete_left(a jsonb, b text) 
RETURNS jsonb AS 
$BODY$
    SELECT COALESCE(    	
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE NOT to_json(key)::jsonb ? b
        )
    , '{}')::jsonb;
$BODY$
LANGUAGE sql IMMUTABLE STRICT;
COMMENT ON FUNCTION jsonb_delete_left(jsonb, text) IS 'delete key in second argument from first argument';

CREATE OPERATOR - ( PROCEDURE = jsonb_delete_left, LEFTARG = jsonb, RIGHTARG = text);
COMMENT ON OPERATOR - (jsonb, text) IS 'delete key from left operand';

--

CREATE OR REPLACE FUNCTION jsonb_delete_left(a jsonb, b text[]) 
RETURNS jsonb AS 
$BODY$
    SELECT COALESCE(    	
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE NOT to_json(key)::jsonb ?| b
        )
    , '{}')::jsonb;
$BODY$
LANGUAGE sql IMMUTABLE STRICT;
COMMENT ON FUNCTION jsonb_delete_left(jsonb, text[]) IS 'delete keys in second argument from first argument';

CREATE OPERATOR - ( PROCEDURE = jsonb_delete_left, LEFTARG = jsonb, RIGHTARG = text[]);
COMMENT ON OPERATOR - (jsonb, text[]) IS 'delete keys from left operand';

--

CREATE OR REPLACE FUNCTION jsonb_delete_left(a jsonb, b jsonb) 
RETURNS jsonb AS 
$BODY$
    SELECT COALESCE(    	
        (
            SELECT ('{' || string_agg(to_json(key) || ':' || value, ',') || '}')
            FROM jsonb_each(a)
            WHERE NOT ('{' || to_json(key) || ':' || value || '}')::jsonb <@ b
        )
    , '{}')::jsonb;
$BODY$
LANGUAGE sql IMMUTABLE STRICT;
COMMENT ON FUNCTION jsonb_delete_left(jsonb, jsonb) IS 'delete matching pairs in second argument from first argument';

CREATE OPERATOR - ( PROCEDURE = jsonb_delete_left, LEFTARG = jsonb, RIGHTARG = jsonb);
COMMENT ON OPERATOR - (jsonb, jsonb) IS 'delete matching pairs from left operand';
