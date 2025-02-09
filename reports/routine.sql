--------------------------------------------------------------------------------
-- REPORT FORM -----------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rfc_identifier_form ---------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Форма идентификатора объекта
 * @param {uuid} pForm - Идентификатор формы
 * @param {jsonb} pParams - Параметры
 * @return {SETOF json} - Записи в JSON
 */
CREATE OR REPLACE FUNCTION report.rfc_identifier_form (
  pForm         uuid,
  pParams       json default null
) RETURNS       json
AS $$
DECLARE
  l             record;
  label         text;
BEGIN
  FOR l IN SELECT code FROM db.locale WHERE id = current_locale()
  LOOP
    IF l.code = 'ru' THEN
	  label := 'Идентификатор';
	ELSE
      label := 'Identifier';
	END IF;
  END LOOP;

  RETURN json_build_object('form', pForm, 'fields', jsonb_build_array(jsonb_build_object('type', 'string', 'format', 'uuid', 'key', 'identifier', 'label', label)));
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- rfc_import_file -------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Форма импорта файла
 * @param {uuid} pForm - Идентификатор формы
 * @param {jsonb} pParams - Параметры
 * @return {SETOF json} - Записи в JSON
 */
CREATE OR REPLACE FUNCTION report.rfc_import_file (
  pForm         uuid,
  pParams       json default null
) RETURNS       json
AS $$
DECLARE
  l             record;
  label         text;
BEGIN
  FOR l IN SELECT code FROM db.locale WHERE id = current_locale()
  LOOP
    IF l.code = 'ru' THEN
	  label := 'Импортировать файл';
	ELSE
      label := 'Import file';
	END IF;
  END LOOP;

  RETURN json_build_object('form', pForm, 'fields', jsonb_build_array(jsonb_build_object('type', 'file', 'format', 'JSON', 'key', 'files', 'label', label)));
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- rfc_import_files ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Форма импорта файлов
 * @param {uuid} pForm - Идентификатор формы
 * @param {jsonb} pParams - Параметры
 * @return {SETOF json} - Записи в JSON
 */
CREATE OR REPLACE FUNCTION report.rfc_import_files (
  pForm         uuid,
  pParams       json default null
) RETURNS       json
AS $$
DECLARE
  l             record;
  label         text;
BEGIN
  FOR l IN SELECT code FROM db.locale WHERE id = current_locale()
  LOOP
    IF l.code = 'ru' THEN
	  label := 'Импортировать файлы';
	ELSE
      label := 'Import files';
	END IF;
  END LOOP;

  RETURN json_build_object('form', pForm, 'fields', jsonb_build_array(jsonb_build_object('type', 'file', 'format', 'JSON', 'key', 'files', 'multiple', true, 'label', label)));
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = kernel, pg_temp;
