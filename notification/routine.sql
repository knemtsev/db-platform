--------------------------------------------------------------------------------
-- Notification ----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION Notification (
  pDateFrom     timestamptz,
  pUserId		uuid DEFAULT current_userid()
) RETURNS       SETOF Notification
AS $$
  WITH access AS (
	WITH member_group AS (
		SELECT pUserId AS userid UNION SELECT userid FROM db.member_group WHERE member = pUserId
	)
	SELECT a.object, bit_or(a.allow) & ~bit_or(a.deny) AS mask
	  FROM db.notification n INNER JOIN db.aou       a ON n.object = a.object
							 INNER JOIN member_group m ON a.userid = m.userid
     WHERE n.datetime >= pDateFrom
	 GROUP BY a.object
  )
  SELECT n.* FROM Notification n INNER JOIN access a ON n.object = a.object AND a.mask & B'100' = B'100'
   WHERE n.datetime >= pDateFrom
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION CreateNotification -------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION CreateNotification (
  pEntity	    uuid,
  pClass	    uuid,
  pAction	    uuid,
  pMethod       uuid,
  pStateOld     uuid,
  pStateNew     uuid,
  pObject	    uuid,
  pUserId	    uuid DEFAULT current_userid(),
  pDateTime     timestamptz DEFAULT Now()
) RETURNS	    uuid
AS $$
DECLARE
  uId		    uuid;
BEGIN
  INSERT INTO db.notification (entity, class, action, method, state_old, state_new, object, userid, datetime)
  VALUES (pEntity, pClass, pAction, pMethod, pStateOld, pStateNew, pObject, pUserId, pDateTime)
  RETURNING id INTO uId;

  RETURN uId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION EditNotification ---------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION EditNotification (
  pId           uuid,
  pEntity	    uuid DEFAULT null,
  pClass	    uuid DEFAULT null,
  pAction	    uuid DEFAULT null,
  pMethod       uuid DEFAULT null,
  pStateOld     uuid DEFAULT null,
  pStateNew     uuid DEFAULT null,
  pObject	    uuid DEFAULT null,
  pUserId	    uuid DEFAULT null,
  pDateTime     timestamptz DEFAULT null
) RETURNS	    void
AS $$
BEGIN
  UPDATE db.notification
     SET entity = coalesce(pEntity, entity),
         class = coalesce(pClass, class),
         action = coalesce(pAction, action),
         method = coalesce(pMethod, method),
         state_old = coalesce(pStateOld, state_old),
         state_new = coalesce(pStateNew, state_new),
         object = coalesce(pObject, object),
         userid = coalesce(pUserId, userid),
         datetime = coalesce(pDateTime, datetime)
   WHERE id = pId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION DeleteNotification -------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION DeleteNotification (
  pId		    uuid
) RETURNS 	    void
AS $$
BEGIN
  DELETE FROM db.notification WHERE id = pId;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION AddNotification ----------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION AddNotification (
  pClass		uuid,
  pAction		uuid,
  pMethod   	uuid,
  pStateOld     uuid,
  pStateNew     uuid,
  pObject		uuid,
  pUserId		uuid DEFAULT current_userid(),
  pDateTime 	timestamptz DEFAULT Now()
) RETURNS		void
AS $$
DECLARE
  uEntity		uuid;
BEGIN
  SELECT entity INTO uEntity FROM db.class_tree WHERE id = pClass;
  PERFORM CreateNotification(uEntity, pClass, pAction, pMethod, pStateOld, pStateNew, pObject, pUserId, pDateTime);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;
