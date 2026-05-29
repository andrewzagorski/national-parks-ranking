DROP POLICY IF EXISTS "users: read own" ON users;
CREATE POLICY "users: read own" ON users
    FOR SELECT USING (
        true
    );
