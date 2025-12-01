-- =============================================
-- STORED PROCEDURE FOR PROJECT CREATION
-- Run this in Supabase SQL Editor
-- This is a safe version that can be run multiple times
-- =============================================
-- Function to create project with owner as member in a transaction
CREATE OR REPLACE FUNCTION CREATE_PROJECT_WITH_OWNER(
        P_NAME TEXT,
        P_OWNER_ID TEXT,
        P_DESCRIPTION TEXT DEFAULT NULL,
        P_COLOR_HEX TEXT DEFAULT '#1E3A5F',
        P_ICON_NAME TEXT DEFAULT 'folder'
    ) RETURNS JSON AS $$
DECLARE V_PROJECT_ID UUID;
V_PROJECT_DATA JSON;
BEGIN -- Insert project
INSERT INTO PROJECTS (
        NAME,
        DESCRIPTION,
        OWNER_ID,
        COLOR_HEX,
        ICON_NAME,
        IS_ARCHIVED
    )
VALUES (
        P_NAME,
        P_DESCRIPTION,
        P_OWNER_ID,
        P_COLOR_HEX,
        P_ICON_NAME,
        FALSE
    )
RETURNING ID INTO V_PROJECT_ID;
-- Add owner as project member
INSERT INTO PROJECT_MEMBERS (
        PROJECT_ID,
        USER_ID,
        ROLE
    )
VALUES (
        V_PROJECT_ID,
        P_OWNER_ID,
        'owner'
    );
-- Get the created project data
SELECT JSON_BUILD_OBJECT(
        'id',
        P.ID,
        'name',
        P.NAME,
        'description',
        P.DESCRIPTION,
        'owner_id',
        P.OWNER_ID,
        'color_hex',
        P.COLOR_HEX,
        'icon_name',
        P.ICON_NAME,
        'is_archived',
        P.IS_ARCHIVED,
        'created_at',
        P.CREATED_AT,
        'updated_at',
        P.UPDATED_AT
    ) INTO V_PROJECT_DATA
FROM PROJECTS P
WHERE P.ID = V_PROJECT_ID;
RETURN V_PROJECT_DATA;
EXCEPTION
WHEN OTHERS THEN RAISE EXCEPTION 'Failed to create project: %',
SQLERRM;
END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;