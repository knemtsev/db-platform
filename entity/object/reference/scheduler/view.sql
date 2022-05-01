--------------------------------------------------------------------------------
-- Scheduler -------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW Scheduler (Id, Reference, Code, Name, Description,
  Period, DateStart, DateStop,
  Scope, ScopeCode, ScopeName, ScopeDescription
)
AS
  SELECT s.id, s.reference, r.code, r.name, r.description,
         s.period, s.dateStart, s.dateStop,
         r.scope, r.scopecode, r.scopename, r.scopedescription
    FROM db.scheduler s INNER JOIN Reference r ON s.reference = r.id;

GRANT SELECT ON Scheduler TO administrator;

--------------------------------------------------------------------------------
-- AccessScheduler -------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW AccessScheduler
AS
  WITH access AS (
    SELECT * FROM AccessObjectUser(GetEntity('scheduler'), current_userid())
  )
  SELECT s.* FROM Scheduler s INNER JOIN access ac ON s.id = ac.object;

GRANT SELECT ON AccessScheduler TO administrator;

--------------------------------------------------------------------------------
-- ObjectScheduler -------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW ObjectScheduler (Id, Object, Parent,
  Entity, EntityCode, EntityName,
  Class, ClassCode, ClassLabel,
  Type, TypeCode, TypeName, TypeDescription,
  Code, Name, Label, Description,
  Period, DateStart, DateStop,
  StateType, StateTypeCode, StateTypeName,
  State, StateCode, StateLabel, LastUpdate,
  Owner, OwnerCode, OwnerName, Created,
  Oper, OperCode, OperName, OperDate,
  Scope, ScopeCode, ScopeName, ScopeDescription
)
AS
  SELECT t.id, r.object, o.parent,
         o.entity, e.code, et.name,
         o.class, c.code, ct.label,
         o.type, y.code, ty.name, ty.description,
         r.code, rt.name, ot.label, rt.description,
         t.period, t.dateStart, t.dateStop,
         o.state_type, st.code, stt.name,
         o.state, s.code, sst.label, o.udate,
         o.owner, w.username, w.name, o.pdate,
         o.oper, u.username, w.name, o.ldate,
         o.scope, sc.code, sc.name, sc.description
    FROM db.scheduler t INNER JOIN db.reference         r ON t.reference = r.id AND r.scope = current_scope()
                         LEFT JOIN db.reference_text   rt ON rt.reference = r.id AND rt.locale = current_locale()
                        INNER JOIN db.object            o ON t.reference = o.id
                         LEFT JOIN db.object_text      ot ON ot.object = o.id AND ot.locale = current_locale()
                        INNER JOIN db.entity            e ON o.entity = e.id
                         LEFT JOIN db.entity_text      et ON et.entity = e.id AND et.locale = current_locale()
                        INNER JOIN db.class_tree        c ON o.class = c.id
                         LEFT JOIN db.class_text       ct ON ct.class = c.id AND ct.locale = current_locale()
                        INNER JOIN db.type              y ON o.type = y.id
                         LEFT JOIN db.type_text        ty ON ty.type = y.id AND ty.locale = current_locale()
                        INNER JOIN db.state_type       st ON o.state_type = st.id
                         LEFT JOIN db.state_type_text stt ON stt.type = st.id AND stt.locale = current_locale()
                        INNER JOIN db.state             s ON o.state = s.id
                         LEFT JOIN db.state_text      sst ON sst.state = s.id AND sst.locale = current_locale()
                        INNER JOIN db.user              w ON o.owner = w.id
                        INNER JOIN db.user              u ON o.oper = u.id
                        INNER JOIN db.scope            sc ON o.scope = sc.id;

GRANT SELECT ON ObjectScheduler TO administrator;
