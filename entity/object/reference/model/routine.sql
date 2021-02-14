--------------------------------------------------------------------------------
-- CreateModel -----------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт модель
 * @param {numeric} pParent - Идентификатор объекта родителя
 * @param {numeric} pType - Идентификатор типа
 * @param {text} pCode - Код
 * @param {text} pName - Наименование
 * @param {numeric} pVendor - Производитель
 * @param {text} pDescription - Описание
 * @return {numeric}
 */
CREATE OR REPLACE FUNCTION CreateModel (
  pParent       numeric,
  pType         numeric,
  pCode         text,
  pName         text,
  pVendor       numeric,
  pDescription	text default null
) RETURNS       numeric
AS $$
DECLARE
  nReference	numeric;
  nClass        numeric;
  nMethod       numeric;
BEGIN
  SELECT class INTO nClass FROM db.type WHERE id = pType;

  IF GetEntityCode(nClass) <> 'model' THEN
    PERFORM IncorrectClassType();
  END IF;

  nReference := CreateReference(pParent, pType, pCode, pName, pDescription);

  INSERT INTO db.model (id, reference, vendor)
  VALUES (nReference, nReference, pVendor);

  nMethod := GetMethod(nClass, null, GetAction('create'));
  PERFORM ExecuteMethod(nReference, nMethod);

  RETURN nReference;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- EditModel -------------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Редактирует модель
 * @param {numeric} pId - Идентификатор
 * @param {numeric} pParent - Идентификатор объекта родителя
 * @param {numeric} pType - Идентификатор типа
 * @param {text} pCode - Код
 * @param {text} pName - Наименование
 * @param {numeric} pVendor - Производитель
 * @param {text} pDescription - Описание
 * @return {void}
 */
CREATE OR REPLACE FUNCTION EditModel (
  pId           numeric,
  pParent       numeric default null,
  pType         numeric default null,
  pCode         text default null,
  pName         text default null,
  pVendor       numeric default null,
  pDescription	text default null
) RETURNS       void
AS $$
DECLARE
  nClass        numeric;
  nMethod       numeric;
BEGIN
  PERFORM EditReference(pId, pParent, pType, pCode, pName, pDescription);

  UPDATE db.model
     SET vendor = coalesce(pVendor, vendor)
   WHERE id = pId;

  SELECT class INTO nClass FROM db.object WHERE id = pId;

  nMethod := GetMethod(nClass, null, GetAction('edit'));
  PERFORM ExecuteMethod(pId, nMethod);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION GetModel ----------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GetModel (
  pCode		text
) RETURNS 	numeric
AS $$
BEGIN
  RETURN GetReference(pCode, 'model');
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION GetModelVendor -----------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION GetModelVendor (
  pId       numeric
) RETURNS 	numeric
AS $$
  SELECT vendor FROM db.model WHERE id = pId;
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;
