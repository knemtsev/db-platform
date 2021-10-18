--------------------------------------------------------------------------------
-- Vendor ----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW Vendor (Id, Reference,
  Code, Name, Description,
  Scope, ScopeCode, ScopeName, ScopeDescription
) AS
  SELECT v.id, v.reference, r.code, r.name, r.description,
         r.scope, r.scopecode, r.scopename, r.scopedescription
    FROM db.vendor v INNER JOIN Reference r ON v.reference = r.id;

GRANT SELECT ON Vendor TO administrator;

--------------------------------------------------------------------------------
-- AccessVendor ----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW AccessVendor
AS
  WITH access AS (
    SELECT * FROM AccessObjectUser(GetEntity('vendor'), current_userid())
  )
  SELECT v.* FROM Vendor v INNER JOIN access ac ON v.id = ac.object;

GRANT SELECT ON AccessVendor TO administrator;

--------------------------------------------------------------------------------
-- ObjectVendor ----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW ObjectVendor (Id, Object, Parent,
  Entity, EntityCode, EntityName,
  Class, ClassCode, ClassLabel,
  Type, TypeCode, TypeName, TypeDescription,
  Code, Name, Label, Description,
  StateType, StateTypeCode, StateTypeName,
  State, StateCode, StateLabel, LastUpdate,
  Owner, OwnerCode, OwnerName, Created,
  Oper, OperCode, OperName, OperDate,
  Scope, ScopeCode, ScopeName, ScopeDescription
)
AS
  SELECT t.id, r.object, r.parent,
         r.entity, r.entitycode, r.entityname,
         r.class, r.classcode, r.classlabel,
         r.type, r.typecode, r.typename, r.typedescription,
         r.code, r.name, r.label, r.description,
         r.statetype, r.statetypecode, r.statetypename,
         r.state, r.statecode, r.statelabel, r.lastupdate,
         r.owner, r.ownercode, r.ownername, r.created,
         r.oper, r.opercode, r.opername, r.operdate,
         r.scope, r.scopecode, r.scopename, r.scopedescription
    FROM AccessVendor t INNER JOIN ObjectReference r ON t.reference = r.id;

GRANT SELECT ON ObjectVendor TO administrator;
