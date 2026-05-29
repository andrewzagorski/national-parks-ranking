-- Revert public read on users table
DROP POLICY IF EXISTS "users: read own" ON users;
CREATE POLICY "users: read own" ON users
    FOR SELECT USING (
        id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );

-- Create secure RPC for checking user existence without exposing the table
CREATE OR REPLACE FUNCTION public.verify_user_exists(p_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM users WHERE id = p_id
    ) INTO v_exists;
    RETURN v_exists;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.verify_user_exists(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.verify_user_exists(UUID) TO anon;
GRANT EXECUTE ON FUNCTION public.verify_user_exists(UUID) TO authenticated;
