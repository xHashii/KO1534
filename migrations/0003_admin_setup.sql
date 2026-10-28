-- Make user's account admin with correct password
-- Password is plain text "test" (no encryption in C++ source)

-- Update test account to use "test" as password
UPDATE `TB_USER` SET `strPasswd` = 'test', `strAuthority` = 6 WHERE `strAccountID` = 'test';

-- Update admin account to use "test" as password
UPDATE `TB_USER` SET `strPasswd` = 'test', `strAuthority` = 6 WHERE `strAccountID` = 'admin';

-- Verify
SELECT strAccountID, strPasswd, strAuthority FROM TB_USER WHERE strAccountID IN ('test', 'admin');
