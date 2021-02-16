--------------------------------------------------------------------------------
-- AGENT -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- api.agent -------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.agent
AS
  SELECT * FROM ObjectAgent;

GRANT SELECT ON api.agent TO administrator;

--------------------------------------------------------------------------------
-- api.add_agent ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Добавляет агента.
 * @param {uuid} pParent - Ссылка на родительский объект: api.document | null
 * @param {text} pType - Тип
 * @param {text} pCode - Код
 * @param {text} pName - Наименование
 * @param {uuid} pVendor - Производитель
 * @param {text} pDescription - Описание
 * @return {uuid}
 */
CREATE OR REPLACE FUNCTION api.add_agent (
  pParent       uuid,
  pType         text,
  pCode         text,
  pName         text,
  pVendor       uuid,
  pDescription	text default null
) RETURNS       uuid
AS $$
BEGIN
  RETURN CreateAgent(pParent, CodeToType(lower(coalesce(pType, 'system')), 'agent'), pCode, pName, pVendor, pDescription);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_agent ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Редактирует агента.
 * @param {uuid} pParent - Ссылка на родительский объект: Object.Parent | null
 * @param {text} pType - Тип
 * @param {text} pCode - Код
 * @param {text} pName - Наименование
 * @param {uuid} pVendor - Производитель
 * @param {text} pDescription - Описание
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.update_agent (
  pId		    uuid,
  pParent       uuid default null,
  pType         text default null,
  pCode         text default null,
  pName         text default null,
  pVendor       uuid default null,
  pDescription	text default null
) RETURNS       void
AS $$
DECLARE
  nType         uuid;
  nAgent        uuid;
BEGIN
  SELECT t.id INTO nAgent FROM db.agent t WHERE t.id = pId;

  IF NOT FOUND THEN
    PERFORM ObjectNotFound('агент', 'id', pId);
  END IF;

  IF pType IS NOT NULL THEN
    nType := CodeToType(lower(pType), 'agent');
  ELSE
    SELECT o.type INTO nType FROM db.object o WHERE o.id = pId;
  END IF;

  PERFORM EditAgent(nAgent, pParent, nType, pCode, pName, pVendor, pDescription);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.set_agent ---------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.set_agent (
  pId           uuid,
  pParent       uuid default null,
  pType         text default null,
  pCode         text default null,
  pName         text default null,
  pVendor       uuid default null,
  pDescription	text default null
) RETURNS       SETOF api.agent
AS $$
BEGIN
  IF pId IS NULL THEN
    pId := api.add_agent(pParent, pType, pCode, pName, pVendor, pDescription);
  ELSE
    PERFORM api.update_agent(pId, pParent, pType, pCode, pName, pVendor, pDescription);
  END IF;

  RETURN QUERY SELECT * FROM api.agent WHERE id = pId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_agent ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает агента
 * @param {uuid} pId - Идентификатор
 * @return {api.agent}
 */
CREATE OR REPLACE FUNCTION api.get_agent (
  pId		uuid
) RETURNS	api.agent
AS $$
  SELECT * FROM api.agent WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.list_agent --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает список агентов.
 * @param {jsonb} pSearch - Условие: '[{"condition": "AND|OR", "field": "<поле>", "compare": "EQL|NEQ|LSS|LEQ|GTR|GEQ|GIN|LKE|ISN|INN", "value": "<значение>"}, ...]'
 * @param {jsonb} pFilter - Фильтр: '{"<поле>": "<значение>"}'
 * @param {integer} pLimit - Лимит по количеству строк
 * @param {integer} pOffSet - Пропустить указанное число строк
 * @param {jsonb} pOrderBy - Сортировать по указанным в массиве полям
 * @return {SETOF api.agent}
 */
CREATE OR REPLACE FUNCTION api.list_agent (
  pSearch	jsonb default null,
  pFilter	jsonb default null,
  pLimit	integer default null,
  pOffSet	integer default null,
  pOrderBy	jsonb default null
) RETURNS	SETOF api.agent
AS $$
BEGIN
  RETURN QUERY EXECUTE api.sql('api', 'agent', pSearch, pFilter, pLimit, pOffSet, pOrderBy);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;
