--------------------------------------------------------------------------------
-- REPORT ----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- VIEW api.report -------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.report
AS
  SELECT * FROM ObjectReport;

GRANT SELECT ON api.report TO administrator;

--------------------------------------------------------------------------------
-- FUNCTION api.report_object --------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.report_object (
  pClass	uuid
) RETURNS 	SETOF api.report
AS $$
  WITH RECURSIVE classtree(id, parent, level) AS (
	SELECT id, parent, level FROM db.class_tree WHERE id = pClass
	 UNION
	SELECT c.id, c.parent, c.level
      FROM db.class_tree c INNER JOIN classtree ct ON ct.parent = c.id
  )
  SELECT r.*
    FROM api.report r INNER JOIN classtree c ON r.binding = c.id
   ORDER BY c.level DESC
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION api.add_report -----------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Добавляет отчёт.
 * @param {uuid} pParent - Идентификатор родителя | null
 * @param {uuid} pType - Идентификатор типа
 * @param {uuid} pTree - Идентификатор дерева отчётов.
 * @param {uuid} pForm - Идентификатор формы отчёта.
 * @param {uuid} pBinding - Идентификатор класса объекта. Связь с классом объекта (для отчётов объекта).
 * @param {text} pCode - Строковый идентификатор (код)
 * @param {text} pName - Наименование
 * @param {text} pDescription - Описание
 * @param {jsonb} pInfo - Дополнительная информация
 * @return {uuid}
 */
CREATE OR REPLACE FUNCTION api.add_report (
  pParent       uuid,
  pType         uuid,
  pTree         uuid default null,
  pForm         uuid default null,
  pBinding      uuid default null,
  pCode         text default null,
  pName         text default null,
  pDescription  text default null,
  pInfo         jsonb default null
) RETURNS       uuid
AS $$
BEGIN
  RETURN CreateReport(pParent, coalesce(pType, GetType('sync.report')), pTree, pForm, pBinding, pCode, pName, pDescription, pInfo);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION api.update_report --------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Редактирует отчёт.
 * @param {uuid} pId - Идентификатор (api.get_report)
 * @param {uuid} pParent - Идентификатор родителя | null
 * @param {uuid} pType - Идентификатор типа
 * @param {uuid} pTree - Идентификатор дерева отчётов.
 * @param {uuid} pForm - Идентификатор формы отчёта.
 * @param {uuid} pBinding - Идентификатор класса объекта. Связь с классом объекта (для отчётов объекта).
 * @param {text} pCode - Строковый идентификатор (код)
 * @param {text} pName - Наименование
 * @param {text} pDescription - Описание
 * @param {jsonb} pInfo - Дополнительная информация
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.update_report (
  pId           uuid,
  pParent       uuid default null,
  pType         uuid default null,
  pTree         uuid default null,
  pForm         uuid default null,
  pBinding      uuid default null,
  pCode         text default null,
  pName         text default null,
  pDescription  text default null,
  pInfo         jsonb default null
) RETURNS       void
AS $$
DECLARE
  uId           uuid;
BEGIN
  SELECT r.id INTO uId FROM db.report r WHERE r.id = pId;

  IF NOT FOUND THEN
    PERFORM ObjectNotFound('отчёт', 'id', pId);
  END IF;

  PERFORM EditReport(uId, pParent, pType, pTree, pForm, pBinding, pCode, pName, pDescription, pInfo);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION api.set_report -----------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.set_report (
  pId           uuid,
  pParent       uuid default null,
  pType         uuid default null,
  pTree         uuid default null,
  pForm         uuid default null,
  pBinding      uuid default null,
  pCode         text default null,
  pName         text default null,
  pDescription  text default null,
  pInfo         jsonb default null
) RETURNS       SETOF api.report
AS $$
BEGIN
  IF pId IS NULL THEN
    pId := api.add_report(pParent, pType, pTree, pForm, pBinding, pCode, pName, pDescription, pInfo);
  ELSE
    PERFORM api.update_report(pId, pParent, pType, pTree, pForm, pBinding, pCode, pName, pDescription, pInfo);
  END IF;

  RETURN QUERY SELECT * FROM api.report WHERE id = pId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_report --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает отчёт по идентификатору
 * @param {uuid} pId - Идентификатор
 * @return {api.report}
 */
CREATE OR REPLACE FUNCTION api.get_report (
  pId           uuid
) RETURNS       api.report
AS $$
  SELECT * FROM api.report WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.list_report -------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает список отчётов.
 * @param {jsonb} pSearch - Условие: '[{"condition": "AND|OR", "field": "<поле>", "compare": "EQL|NEQ|LSS|LEQ|GTR|GEQ|GIN|LKE|ISN|INN", "value": "<значение>"}, ...]'
 * @param {jsonb} pFilter - Фильтр: '{"<поле>": "<значение>"}'
 * @param {integer} pLimit - Лимит по количеству строк
 * @param {integer} pOffSet - Пропустить указанное число строк
 * @param {jsonb} pOrderBy - Сортировать по указанным в массиве полям
 * @return {SETOF api.report}
 */
CREATE OR REPLACE FUNCTION api.list_report (
  pSearch       jsonb default null,
  pFilter       jsonb default null,
  pLimit        integer default null,
  pOffSet       integer default null,
  pOrderBy      jsonb default null
) RETURNS       SETOF api.report
AS $$
BEGIN
  RETURN QUERY EXECUTE api.sql('api', 'report', pSearch, pFilter, pLimit, pOffSet, pOrderBy);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.list_report_object ------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает список отчётов объекта.
 * @param {uuid} pClass - Идентификатор класса объекта.
 * @return {SETOF api.report}
 */
CREATE OR REPLACE FUNCTION api.list_report_object (
  pClass        uuid,
  pSearch       jsonb default null,
  pFilter       jsonb default null,
  pLimit        integer default null,
  pOffSet       integer default null,
  pOrderBy      jsonb default null
) RETURNS       SETOF api.report
AS $$
BEGIN
  RETURN QUERY EXECUTE api.sql('api', format('report_object(%L::uuid)', pClass), pSearch, pFilter, pLimit, pOffSet, pOrderBy);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_report_form_files ---------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает файлы отчетной формы
 * @param {uuid} pReport - Идентификатор отчета
 * @return {SETOF json}
 */
CREATE OR REPLACE FUNCTION api.get_report_form_files (
  pReport   uuid
) RETURNS	SETOF api.object_file
AS $$
DECLARE
  r         record;
  uForm     uuid;
BEGIN
  SELECT form INTO uForm FROM db.report WHERE id = pReport;

  IF NOT FOUND THEN
	PERFORM NotFound();
  END IF;

  FOR r IN SELECT * FROM api.object_file WHERE object = uForm
  LOOP
    RETURN NEXT r;
  END LOOP;

  RETURN;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;
