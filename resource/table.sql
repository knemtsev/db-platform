--------------------------------------------------------------------------------
-- RESOURCE --------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- db.resource -----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE db.resource (
    id			    uuid PRIMARY KEY,
    root            uuid NOT NULL,
    node            uuid,
    type			text NOT NULL,
    level           integer NOT NULL,
    sequence		integer NOT NULL,
    CONSTRAINT fk_resource_root FOREIGN KEY (root) REFERENCES db.resource(id),
    CONSTRAINT fk_resource_node FOREIGN KEY (node) REFERENCES db.resource(id)
);

COMMENT ON TABLE db.resource IS 'Ресурс.';

COMMENT ON COLUMN db.resource.id IS 'Идентификатор.';
COMMENT ON COLUMN db.resource.root IS 'Корневой узел.';
COMMENT ON COLUMN db.resource.node IS 'Родительский узел.';
COMMENT ON COLUMN db.resource.type IS 'Multipurpose Internet Mail Extensions (MIME) тип.';
COMMENT ON COLUMN db.resource.level IS 'Уровень вложенности.';
COMMENT ON COLUMN db.resource.sequence IS 'Очерёдность';

CREATE INDEX ON db.resource (root);
CREATE INDEX ON db.resource (node);
CREATE INDEX ON db.resource (type);
CREATE INDEX ON db.resource (sequence);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ft_resource_before()
RETURNS trigger AS $$
BEGIN
  IF NEW.id IS NULL THEN
    NEW.id := gen_random_uuid();
  END IF;

  IF NEW.root IS NULL THEN
    NEW.root := NEW.id;
  END IF;

  IF NEW.node IS NULL THEN
    IF NEW.root <> NEW.id THEN
      NEW.node := NEW.root;
    END IF;
  END IF;

  IF NEW.type IS NULL THEN
    NEW.type := 'text/plain';
  END IF;

  IF NEW.sequence IS NULL THEN
    NEW.sequence := 1;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------

CREATE TRIGGER t_resource_before
  BEFORE INSERT ON db.resource
  FOR EACH ROW
  EXECUTE PROCEDURE ft_resource_before();

--------------------------------------------------------------------------------
-- db.resource_data ------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE db.resource_data (
    resource		uuid NOT NULL,
    locale		    numeric(12) NOT NULL,
    name			text,
    description		text,
    encoding		text,
    data			text,
    updated			timestamptz DEFAULT Now() NOT NULL,
    CONSTRAINT pk_resource_data PRIMARY KEY (resource, locale),
    CONSTRAINT fk_resource_data_resource FOREIGN KEY (resource) REFERENCES db.resource(id),
    CONSTRAINT fk_resource_data_locale FOREIGN KEY (locale) REFERENCES db.locale(id)
);

--------------------------------------------------------------------------------

COMMENT ON TABLE db.resource_data IS 'Данные ресурса.';

COMMENT ON COLUMN db.resource_data.resource IS 'Идентификатор ресурса';
COMMENT ON COLUMN db.resource_data.locale IS 'Идентификатор локали';
COMMENT ON COLUMN db.resource_data.name IS 'Наименование.';
COMMENT ON COLUMN db.resource_data.description IS 'Описание.';
COMMENT ON COLUMN db.resource_data.encoding IS 'Кодировка.';
COMMENT ON COLUMN db.resource_data.data IS 'Данные.';
COMMENT ON COLUMN db.resource_data.updated IS 'Дата обновления.';

--------------------------------------------------------------------------------

CREATE INDEX ON db.resource_data (resource);
CREATE INDEX ON db.resource_data (locale);

CREATE INDEX ON db.resource_data (name);
CREATE INDEX ON db.resource_data (name text_pattern_ops);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ft_resource_data_before()
RETURNS trigger AS $$
BEGIN
  IF NEW.locale IS NULL THEN
    NEW.locale := current_locale();
  END IF;

  IF NEW.name IS NULL THEN
    NEW.name := CheckNull(coalesce(NEW.name, OLD.name, '<null>'));
  END IF;

  IF NEW.description IS NULL THEN
    NEW.description := CheckNull(coalesce(NEW.description, OLD.description, '<null>'));
  END IF;

  IF NEW.encoding IS NULL THEN
    NEW.encoding := CheckNull(coalesce(NEW.encoding, OLD.encoding, '<null>'));
  END IF;

  IF NEW.data IS NULL THEN
    NEW.data := CheckNull(coalesce(NEW.data, OLD.data, '<null>'));
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------

CREATE TRIGGER t_resource_data_before
  BEFORE INSERT OR UPDATE ON db.resource_data
  FOR EACH ROW
  EXECUTE PROCEDURE ft_resource_data_before();

