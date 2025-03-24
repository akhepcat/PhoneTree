-- Schema for the app, using pgsql - more flexible than sqlite
-- 
-- What am I missing?
-- 
-- Data security model:
-- 	INTERNAL - used by the application, never exposed to a user or admin
-- 	ADMIN - data that can only be seen by an admin
-- 	PRIVATE - data exposed only to a user
--	SHARED - data exposed to a user and specified groups
--	PUBLIC - data that can be shared to any user
--	[..]   - for uuids, these are dereferenced to the name of the object
--



-- This is the users table, for authentication purposes, which is separate from the contacts
CREATE TABLE users (
    userid UUID,		-- INTERNAL: uuid of the user
    created TIMESTAMP,		-- PRIVATE: timestamp of the user creation
    authid UUID,		-- INTERNAL: uuid reference to the primary authentication data
    privs UUID,			-- INTERNAL: uuid reference to the user's privileges 
    username CHARACTER(64),	-- PRIVATE: the logged-in users's name
    emailid UUID,		-- [PRIVATE]: uuid reference to the user's email address
    PRIMARY KEY(userid)
);


-- This is the table of all registered and (hopefully) validated email addresses
CREATE TABLE emails (
    emailid UUID,		-- INTERNAL: uuid of the email account
    timestamp TIMESTAMP,	-- PRIVATE: creation or validation timestamp
    address CHARACTER(64),	-- PRIVATE: the logged-in users's registered email
    verified BOOLEAN,		-- PRIVATE: has the user verified this email
    PRIMARY KEY(emailid)
);


-- This is the authentication data table
CREATE TABLE authids (
    authid UUID,		-- INTERNAL: uuid of the authorization data
    timestamp TIMESTAMP,	-- PRIVATE: timestamp of the authid creation or last update
    userid UUID,		-- INTERNAL: uuid of the associated user who owns this record
    authtype INTEGER,		-- PRIVATE: authentication type ( 0=password, 1=TOTP, 2=magic URL,  4= ... )
    authdata CHARACTER(128),	-- PRIVATE: any time of authentication data (passwords, TOTP data, magic url string, etc)
    PRIMARY KEY(authid)
);


-- This is the privileges tables
CREATE TABLE privileges (
    privs UUID,			-- INTERNAL: uuid of the privilege data
    isadmin INTEGER,		-- INTERNAL: is the user an admin of the system
    PRIMARY KEY(privs)
	-- Yes, this needs to be fleshed out- what admin roles, or privilege levels need to be here?
	-- do we need to have separate user privs, group privs, and admin privs?  maybe at some point?
);


-- This is the contacts table.  
CREATE TABLE contacts (
    contact UUID,		-- INTERNAL: uuid of the contact
    created TIMESTAMP,		-- PRIVATE: timestamp of the contact creation
    nick CHARACTER(64),		-- SHARED: nickname for the user
    fname CHARACTER(64),	-- SHARED: real first name for the user
    lname CHARACTER(64),	-- SHARED: real last name for the user
    location CHARACTER(),	-- SHARED: kind of location identifier
    phone1 CHARACTER(16),	-- SHARED: primary phone number for the user
    phone2 CHARACTER(16),	-- SHARED: phone number for the user
    notes CHARACTER(512),	-- PRIVATE: generic notes
    PRIMARY KEY(contact),
    UNIQUE(phone1),
    UNIQUE(phone2)
);


-- This is a groups table that defines a group of users
CREATE TABLE groups (
    groupid UUID,		-- INTERNAL: uuid of the group
    created TIMESTAMP,		-- SHARED: timestamp of the group creation
    creator UUID,		-- SHARED: uuid reference to the contact who created this group
    name CHARACTER(64),		-- SHARED: name of this group
    PRIMARY KEY(groupid)
);


-- This is the memberships table, that defines which users are members of which groups
CREATE TABLE membership (
    groupid UUID,		-- [SHARED]: uuid reference to a group
    contact UUID,		-- [SHARED]: uuid reference to a contact
    joindate TIMESTAMP		-- SHARED: timestamp of when the contact was added to the group
);


-- This is the invites table, that defines which users are invited into which groups
CREATE TABLE invites (
    invitee UUID,		-- [SHARED]: uuid reference to a contact who is being invited
    groupid UUID,		-- [SHARED]: uuid reference to a group
    inviter UUID,		-- [SHARED]: uuid reference to a contact who made the invitation
    invited TIMESTAMP		-- SHARED: timestamp of when the contact was invited to the group
);


-- This is the table that defines a check-in campaign
CREATE TABLE campaign (
    campaign UUID,		-- INTERNAL: uuid of campaign
    created TIMESTAMP,		-- SHARED: timestamp of the campaign creation
    begins TIMESTAMP,		-- SHARED: timestamp of start of campaign
    ends TIMESTAMP,		-- SHARED: timestamp of end of campaign
    name CHARACTER(64),		-- SHARED: Name for the campaign
    PRIMARY KEY(campaign)
);


-- This is the table for checkins
CREATE TABLE checkins (
    campaign UUID,		-- [SHARED]: uuid reference to a campaign in said table
    contact UUID,		-- [SHARED]: uuid reference to a person who is checking in
    timestamp TIMESTAMP		-- SHARED: time of check-in
);


-- This is the login table, where we log who's logged in
CREATE TABLE logins (
    userid UUID,		-- INTERNAL: uuid of the user
    logints TIMESTAMP,		-- PRIVATE: timestamp of the user login
    active INTEGER		-- PRIVATE: is the user currently active within timeout period?
);
