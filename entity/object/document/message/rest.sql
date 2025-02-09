--------------------------------------------------------------------------------
-- REST MESSAGE ----------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Запрос данных в формате REST JSON API (Сообщение).
 * @param {text} pPath - Путь
 * @param {jsonb} pPayload - JSON
 * @return {SETOF json} - Записи в JSON
 */
CREATE OR REPLACE FUNCTION rest.message (
  pPath       text,
  pPayload    jsonb default null
) RETURNS     SETOF json
AS $$
DECLARE
  r           record;
  e           record;

  arKeys      text[];
BEGIN
  IF pPath IS NULL THEN
    PERFORM RouteIsEmpty();
  END IF;

  IF current_session() IS NULL THEN
	PERFORM LoginFailed();
  END IF;

  CASE pPath
  WHEN '/message/type' THEN

    FOR r IN SELECT * FROM jsonb_to_record(pPayload) AS x(fields jsonb)
    LOOP
      FOR e IN EXECUTE format('SELECT %s FROM api.type($1)', JsonbToFields(r.fields, GetColumns('type', 'api'))) USING GetEntity('message')
      LOOP
        RETURN NEXT row_to_json(e);
      END LOOP;
    END LOOP;

  WHEN '/message/method' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, ARRAY['id']);
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN SELECT * FROM jsonb_to_recordset(pPayload) AS x(id uuid)
      LOOP
        FOR e IN SELECT * FROM api.get_object_methods(r.id) ORDER BY sequence
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    ELSE

      FOR r IN SELECT * FROM jsonb_to_record(pPayload) AS x(id uuid)
      LOOP
        FOR e IN SELECT * FROM api.get_object_methods(r.id) ORDER BY sequence
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    END IF;

  WHEN '/message/count' THEN

    IF pPayload IS NOT NULL THEN
      arKeys := array_cat(arKeys, ARRAY['search', 'filter', 'reclimit', 'recoffset', 'orderby']);
      PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);
    ELSE
      pPayload := '{}';
    END IF;

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN SELECT * FROM jsonb_to_recordset(pPayload) AS x(search jsonb, filter jsonb, reclimit integer, recoffset integer, orderby jsonb)
      LOOP
        FOR e IN SELECT count(*) FROM api.list_message(r.search, r.filter, r.reclimit, r.recoffset, r.orderby)
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    ELSE

      FOR r IN SELECT * FROM jsonb_to_record(pPayload) AS x(search jsonb, filter jsonb, reclimit integer, recoffset integer, orderby jsonb)
      LOOP
        FOR e IN SELECT count(*) FROM api.list_message(r.search, r.filter, r.reclimit, r.recoffset, r.orderby)
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    END IF;

  WHEN '/message/set' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('set_message', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.set_message(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('set_message', 'api', false, 'x'), ', '), array_to_string(GetRoutines('set_message', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.set_message(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('set_message', 'api', false, 'x'), ', '), array_to_string(GetRoutines('set_message', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/get' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, ARRAY['id', 'fields']);
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN SELECT * FROM jsonb_to_recordset(pPayload) AS x(id uuid, fields jsonb)
      LOOP
        FOR e IN EXECUTE format('SELECT %s FROM api.get_message($1)', JsonbToFields(r.fields, GetColumns('message', 'api'))) USING r.id
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    ELSE

      FOR r IN SELECT * FROM jsonb_to_record(pPayload) AS x(id uuid, fields jsonb)
      LOOP
        FOR e IN EXECUTE format('SELECT %s FROM api.get_message($1)', JsonbToFields(r.fields, GetColumns('message', 'api'))) USING r.id
        LOOP
          RETURN NEXT row_to_json(e);
        END LOOP;
      END LOOP;

    END IF;

  WHEN '/message/list' THEN

    IF pPayload IS NOT NULL THEN
      arKeys := array_cat(arKeys, ARRAY['fields', 'search', 'filter', 'reclimit', 'recoffset', 'orderby']);
      PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);
    ELSE
      pPayload := '{}';
    END IF;

    FOR r IN SELECT * FROM jsonb_to_record(pPayload) AS x(fields jsonb, search jsonb, filter jsonb, reclimit integer, recoffset integer, orderby jsonb)
    LOOP
      FOR e IN EXECUTE format('SELECT %s FROM api.list_message($1, $2, $3, $4, $5)', JsonbToFields(r.fields, GetColumns('message', 'api'))) USING r.search, r.filter, r.reclimit, r.recoffset, r.orderby
      LOOP
        RETURN NEXT row_to_json(e);
      END LOOP;
    END LOOP;

  WHEN '/message/send' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_message', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_message(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_message', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_message', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_message(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_message', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_message', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/send/mail' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_mail', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_mail(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_mail', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_mail', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_mail(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_mail', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_mail', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/send/sms' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_sms', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_sms(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_sms', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_sms', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_sms(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_sms', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_sms', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/send/push' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_push', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_push(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_push', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_push(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_push', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/send/push/data' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_push_data', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_push_data(%s)) FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_push_data', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push_data', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT row_to_json(api.send_push_data(%s)) FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_push_data', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push_data', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT r;
      END LOOP;

    END IF;

  WHEN '/message/send/push/to/role' THEN

    IF pPayload IS NULL THEN
      PERFORM JsonIsEmpty();
    END IF;

    arKeys := array_cat(arKeys, GetRoutines('send_push_to_role', 'api', false));
    PERFORM CheckJsonbKeys(pPath, arKeys, pPayload);

    IF jsonb_typeof(pPayload) = 'array' THEN

      FOR r IN EXECUTE format('SELECT api.send_push_to_role(%s) AS count FROM jsonb_to_recordset($1) AS x(%s)', array_to_string(GetRoutines('send_push_to_role', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push_to_role', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT json_build_object('count', r.count);
      END LOOP;

    ELSE

      FOR r IN EXECUTE format('SELECT api.send_push_to_role(%s) AS count FROM jsonb_to_record($1) AS x(%s)', array_to_string(GetRoutines('send_push_to_role', 'api', false, 'x'), ', '), array_to_string(GetRoutines('send_push_to_role', 'api', true), ', ')) USING pPayload
      LOOP
        RETURN NEXT json_build_object('count', r.count);
      END LOOP;

    END IF;

  ELSE
    RETURN NEXT ExecuteDynamicMethod(pPath, pPayload);
  END CASE;

  RETURN;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = kernel, pg_temp;
