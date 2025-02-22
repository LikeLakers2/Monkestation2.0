BEGIN TRANSACTION;

------------------
-- ACHIEVEMENTS --
------------------
DROP TABLE IF EXISTS "achievement_metadata";
CREATE TABLE "achievement_metadata" (
	"achievement_key"	TEXT NOT NULL,
	"achievement_version"	UNSIGNED_INTEGER NOT NULL DEFAULT 0,
	"achievement_type"	TEXT DEFAULT null CHECK("achievement_type" IN ('achievement', 'score', 'award')),
	"achievement_name"	TEXT DEFAULT null,
	"achievement_description"	TEXT DEFAULT null,
	PRIMARY KEY("achievement_key")
);

DROP TABLE IF EXISTS "achievements";
CREATE TABLE "achievements" (
	"ckey"	TEXT NOT NULL,
	"achievement_key"	TEXT NOT NULL,
	"value"	INTEGER,
	"last_updated"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("ckey","achievement_key"),
	FOREIGN KEY("achievement_key") REFERENCES "achievement_metadata"("achievement_key")
);

-----------
-- ADMIN --
-----------
DROP TABLE IF EXISTS "admin";
CREATE TABLE "admin" (
	"ckey"	TEXT NOT NULL,
	"rank"	TEXT NOT NULL,
	"feedback"	TEXT DEFAULT NULL,
	PRIMARY KEY("ckey"),
	FOREIGN KEY("rank") REFERENCES "admin_ranks"("rank")
);

DROP TABLE IF EXISTS "admin_connections";
CREATE TABLE "admin_connections" (
	"id"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"cid"	TEXT NOT NULL,
	"verification_time"	DATETIME,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_constraints" UNIQUE("ckey","ip","cid")
);

DROP TABLE IF EXISTS "admin_log";
CREATE TABLE "admin_log" (
	"id"	INTEGER NOT NULL,
	"datetime"	DATETIME NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	"adminckey"	TEXT NOT NULL,
	"adminip"	UNSIGNED_INTEGER NOT NULL,
	"operation"	TEXT NOT NULL CHECK("operation" IN ('add admin', 'remove admin', 'change admin rank', 'add rank', 'remove rank', 'change rank flags')),
	"target"	TEXT NOT NULL,
	"log"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);

DROP TABLE IF EXISTS "admin_ranks";
CREATE TABLE "admin_ranks" (
	"rank"	TEXT NOT NULL,
	"flags"	UNSIGNED_INTEGER NOT NULL,
	"exclude_flags"	UNSIGNED_INTEGER NOT NULL,
	"can_edit_flags"	UNSIGNED_INTEGER NOT NULL,
	PRIMARY KEY("rank")
);

----------
-- BANS --
----------
DROP TABLE IF EXISTS "ban";
CREATE TABLE "ban" (
	"id"	INTEGER NOT NULL,
	"bantime"	DATETIME NOT NULL,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER NOT NULL,
	"role"	TEXT DEFAULT null,
	"expiration_time"	DATETIME DEFAULT null,
	"applies_to_admins"	BOOLEAN NOT NULL DEFAULT 0,
	"reason"	TEXT NOT NULL,
	"ckey"	TEXT DEFAULT null,
	"ip"	UNSIGNED_INTEGER DEFAULT null,
	"computerid"	TEXT DEFAULT null,
	"a_ckey"	TEXT NOT NULL,
	"a_ip"	UNSIGNED_INTEGER NOT NULL,
	"a_computerid"	TEXT NOT NULL,
	"who"	TEXT NOT NULL,
	"adminwho"	TEXT NOT NULL,
	"edits"	TEXT DEFAULT null,
	"unbanned_datetime"	DATETIME DEFAULT null,
	"unbanned_ckey"	TEXT DEFAULT null,
	"unbanned_ip"	UNSIGNED_INTEGER DEFAULT null,
	"unbanned_computerid"	TEXT DEFAULT null,
	"unbanned_round_id"	UNSIGNED_INTEGER DEFAULT null,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "idx_ban_count";
CREATE INDEX "idx_ban_count" ON "ban" (
	"bantime",
	"a_ckey",
	"applies_to_admins",
	"unbanned_datetime",
	"expiration_time"
);
DROP INDEX IF EXISTS "idx_ban_isbanned";
CREATE INDEX "idx_ban_isbanned" ON "ban" (
	"ckey",
	"role",
	"unbanned_datetime",
	"expiration_time"
);
DROP INDEX IF EXISTS "idx_ban_isbanned_details";
CREATE INDEX "idx_ban_isbanned_details" ON "ban" (
	"ckey",
	"ip",
	"computerid",
	"role",
	"unbanned_datetime",
	"expiration_time"
);

--------------
-- CITATION --
--------------
DROP TABLE IF EXISTS "citation";
CREATE TABLE "citation" (
	"id"	INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"citation"	TEXT NOT NULL,
	"action"	TEXT NOT NULL DEFAULT '',
	"sender"	TEXT NOT NULL DEFAULT '',
	"sender_ic"	TEXT NOT NULL DEFAULT '',
	"recipient"	TEXT NOT NULL DEFAULT '',
	"crime"	TEXT NOT NULL,
	"fine"	INTEGER DEFAULT null,
	"paid"	INTEGER DEFAULT 0,
	"timestamp"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "idx_constraints" UNIQUE("round_id","server_ip","server_port","citation")
);

--------------------
-- CONNECTION LOG --
--------------------
DROP TABLE IF EXISTS "connection_log";
CREATE TABLE "connection_log" (
	"id"	INTEGER NOT NULL,
	"datetime"	DATETIME DEFAULT null,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER NOT NULL,
	"ckey"	TEXT DEFAULT null,
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"computerid"	TEXT DEFAULT null,
	PRIMARY KEY("id" AUTOINCREMENT)
);

---------------
-- DEATH LOG --
---------------
DROP TABLE IF EXISTS "death";
CREATE TABLE "death" (
	"id"	INTEGER NOT NULL,
	"pod"	TEXT NOT NULL,
	"x_coord"	UNSIGNED_INTEGER NOT NULL,
	"y_coord"	UNSIGNED_INTEGER NOT NULL,
	"z_coord"	UNSIGNED_INTEGER NOT NULL,
	"mapname"	TEXT NOT NULL,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	"tod"	DATETIME NOT NULL,
	"job"	TEXT NOT NULL,
	"special"	TEXT DEFAULT null,
	"name"	TEXT NOT NULL,
	"byondkey"	TEXT NOT NULL,
	"laname"	TEXT DEFAULT null,
	"lakey"	TEXT DEFAULT null,
	"bruteloss"	UNSIGNED_INTEGER NOT NULL,
	"brainloss"	UNSIGNED_INTEGER NOT NULL,
	"fireloss"	UNSIGNED_INTEGER NOT NULL,
	"oxyloss"	UNSIGNED_INTEGER NOT NULL,
	"toxloss"	UNSIGNED_INTEGER NOT NULL,
	"cloneloss"	UNSIGNED_INTEGER NOT NULL,
	"staminaloss"	UNSIGNED_INTEGER NOT NULL,
	"last_words"	TEXT DEFAULT null,
	"suicide"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

----------------------------
-- DISCORD <-> CKEY LINKS --
----------------------------
DROP TABLE IF EXISTS "discord_links";
CREATE TABLE "discord_links" (
	"id"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"discord_id"	INTEGER NOT NULL,
	"timestamp"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"one_time_token"	TEXT NOT NULL,
	"valid"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

--------------
-- FEEDBACK --
--------------
DROP TABLE IF EXISTS "feedback";
CREATE TABLE "feedback" (
	"id"	INTEGER NOT NULL,
	"datetime"	DATETIME NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	"key_name"	TEXT NOT NULL,
	"key_type"	TEXT NOT NULL CHECK("key_type" IN ('text', 'amount', 'tally', 'nested tally', 'associative')),
	"version"	UNSIGNED_INTEGER NOT NULL,
	"json"	TEXT_JSON NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);

--------------
-- IP INTEL --
--------------
DROP TABLE IF EXISTS "ipintel";
CREATE TABLE "ipintel" (
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"date"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"intel"	DOUBLE NOT NULL DEFAULT 0,
	PRIMARY KEY("ip")
);
DROP INDEX IF EXISTS "idx_ipintel";
CREATE INDEX "idx_ipintel" ON "ipintel" (
	"ip",
	"intel",
	"date"
);

----------------
-- KNOWN ALTS --
----------------
DROP TABLE IF EXISTS "known_alts";
CREATE TABLE "known_alts" (
	"id"	INTEGER NOT NULL,
	"ckey1"	TEXT NOT NULL,
	"ckey2"	TEXT NOT NULL,
	"admin_ckey"	TEXT NOT NULL DEFAULT '*no key*',
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_constraints" UNIQUE("ckey1","ckey2")
);

-----------------------
-- LEGACY POPULATION --
-----------------------
DROP TABLE IF EXISTS "legacy_population";
CREATE TABLE "legacy_population" (
	"id"	INTEGER NOT NULL,
	"playercount"	INTEGER DEFAULT null,
	"admincount"	INTEGER DEFAULT null,
	"time"	DATETIME NOT NULL,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);

------------------
-- LIBRARY DATA --
------------------
-- `library` holds a list of books that are available in the library.
DROP TABLE IF EXISTS "library";
CREATE TABLE "library" (
	"id"	INTEGER NOT NULL,
	"author"	TEXT NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
	"category"	TEXT NOT NULL CHECK("category" IN ('Any', 'Fiction', 'Non-Fiction', 'Adult', 'Reference', 'Religion')),
	"ckey"	TEXT NOT NULL DEFAULT 'LEGACY',
	"datetime"	DATETIME NOT NULL,
	"deleted"	BOOLEAN DEFAULT null,
	"round_id_created"	UNSIGNED_INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "deleted_idx";
CREATE INDEX "deleted_idx" ON "library" (
	"deleted"
);
DROP INDEX IF EXISTS "idx_lib_del_title";
CREATE INDEX "idx_lib_del_title" ON "library" (
	"deleted",
	"title"
);
DROP INDEX IF EXISTS "idx_lib_id_del";
CREATE INDEX "idx_lib_id_del" ON "library" (
	"id",
	"deleted"
);
DROP INDEX IF EXISTS "idx_lib_search";
CREATE INDEX "idx_lib_search" ON "library" (
	"deleted",
	"author",
	"title",
	"category"
);

-- `library_action` is a log of admin actions taken on books.
DROP TABLE IF EXISTS "library_action";
CREATE TABLE "library_action" (
	"id"	INTEGER NOT NULL,
	"book"	UNSIGNED_INTEGER NOT NULL,
	"reason"	TEXT DEFAULT null,
	"ckey"	TEXT NOT NULL DEFAULT '',
	"datetime"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"action"	TEXT NOT NULL DEFAULT '',
	"ip_addr"	UNSIGNED_INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("book") REFERENCES "library"("id")
);

--------------
-- MESSAGES --
--------------
DROP TABLE IF EXISTS "messages";
CREATE TABLE "messages" (
	"id"	INTEGER NOT NULL,
	"type"	TEXT NOT NULL CHECK("type" IN ('memo', 'message', 'message sent', 'note', 'watchlist entry')),
	"targetckey"	TEXT NOT NULL,
	"adminckey"	TEXT NOT NULL,
	"text"	TEXT NOT NULL,
	"timestamp"	DATETIME NOT NULL,
	"server"	TEXT DEFAULT null,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"secret"	BOOLEAN NOT NULL,
	"expire_timestamp"	DATETIME DEFAULT null,
	"severity"	TEXT DEFAULT null CHECK("severity" IN ('high', 'medium', 'minor', 'none')),
	"playtime"	UNSIGNED_INTEGER DEFAULT null,
	"lasteditor"	TEXT DEFAULT null,
	"edits"	TEXT,
	"deleted"	BOOLEAN NOT NULL DEFAULT 0,
	"deleted_ckey"	TEXT DEFAULT null,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "idx_msg_ckey_time";
CREATE INDEX "idx_msg_ckey_time" ON "messages" (
	"targetckey",
	"timestamp",
	"deleted"
);
DROP INDEX IF EXISTS "idx_msg_type_ckey_time_odr";
CREATE INDEX "idx_msg_type_ckey_time_odr" ON "messages" (
	"type",
	"targetckey",
	"timestamp",
	"deleted"
);
DROP INDEX IF EXISTS "idx_msg_type_ckeys_time";
CREATE INDEX "idx_msg_type_ckeys_time" ON "messages" (
	"type",
	"targetckey",
	"adminckey",
	"timestamp",
	"deleted"
);

-----------------------------
-- METACOIN ITEM PURCHASES --
-----------------------------
DROP TABLE IF EXISTS "metacoin_item_purchases";
CREATE TABLE "metacoin_item_purchases" (
	"ckey"	TEXT NOT NULL,
	"purchase_date"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"item_id"	TEXT NOT NULL,
	"amount"	UNSIGNED_INTEGER NOT NULL,
	PRIMARY KEY("ckey","item_id")
);

------------
-- PLAYER --
------------
DROP TABLE IF EXISTS "player";
CREATE TABLE "player" (
	"ckey"	TEXT NOT NULL,
	"byond_key"	TEXT DEFAULT null,
	"firstseen"	DATETIME NOT NULL,
	"firstseen_round_id"	UNSIGNED_INTEGER,
	"lastseen"	DATETIME NOT NULL,
	"lastseen_round_id"	INTEGER,
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"computerid"	TEXT NOT NULL,
	"lastadminrank"	TEXT NOT NULL DEFAULT 'Player',
	"accountjoindate"	DATE DEFAULT null,
	"flags"	UNSIGNED_INTEGER NOT NULL DEFAULT 0,
	"antag_tokens"	UNSIGNED_INTEGER DEFAULT 0,
	"metacoins"	UNSIGNED_INTEGER NOT NULL DEFAULT 0,
	"twitch_rank"	TEXT NOT NULL DEFAULT '',
	"patreon_key"	TEXT NOT NULL DEFAULT 'None',
	"patreon_rank"	TEXT NOT NULL DEFAULT 'None',
	PRIMARY KEY("ckey")
);
DROP INDEX IF EXISTS "idx_player_cid_ckey";
CREATE INDEX "idx_player_cid_ckey" ON "player" (
	"computerid",
	"ckey"
);
DROP INDEX IF EXISTS "idx_player_ip_ckey";
CREATE INDEX "idx_player_ip_ckey" ON "player" (
	"ip",
	"ckey"
);

-----------
-- POLLS --
-----------
DROP TABLE IF EXISTS "poll_question";
CREATE TABLE "poll_question" (
	"id"	INTEGER NOT NULL,
	"polltype"	TEXT NOT NULL CHECK("polltype" IN ('OPTION', 'TEXT', 'NUMVAL', 'MULTICHOICE', 'IRV')),
	"created_datetime"	DATETIME NOT NULL,
	"starttime"	DATETIME NOT NULL,
	"endtime"	DATETIME NOT NULL,
	"question"	TEXT NOT NULL,
	"subtitle"	TEXT DEFAULT null,
	"adminonly"	BOOLEAN NOT NULL,
	"multiplechoiceoptions"	INTEGER DEFAULT null,
	"createdby_ckey"	TEXT NOT NULL,
	"createdby_ip"	UNSIGNED_INTEGER NOT NULL,
	"dontshow"	BOOLEAN NOT NULL,
	"allow_revoting"	BOOLEAN NOT NULL,
	"deleted"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "idx_pquest_id_time_type_admin";
CREATE INDEX "idx_pquest_id_time_type_admin" ON "poll_question" (
	"id",
	"starttime",
	"endtime",
	"polltype",
	"adminonly"
);
DROP INDEX IF EXISTS "idx_pquest_question_time_ckey";
CREATE INDEX "idx_pquest_question_time_ckey" ON "poll_question" (
	"question",
	"starttime",
	"endtime",
	"createdby_ckey",
	"createdby_ip"
);
DROP INDEX IF EXISTS "idx_pquest_time_deleted_id";
CREATE INDEX "idx_pquest_time_deleted_id" ON "poll_question" (
	"starttime",
	"endtime",
	"deleted",
	"id"
);

DROP TABLE IF EXISTS "poll_option";
CREATE TABLE "poll_option" (
	"id"	INTEGER NOT NULL,
	"pollid"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"minval"	INTEGER DEFAULT null,
	"maxval"	INTEGER DEFAULT null,
	"descmin"	TEXT DEFAULT null,
	"descmid"	TEXT DEFAULT null,
	"descmax"	TEXT DEFAULT null,
	"default_percentage_calc"	BOOLEAN NOT NULL DEFAULT 1,
	"deleted"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("pollid") REFERENCES "poll_question"("id")
);
DROP INDEX IF EXISTS "idx_pop_pollid";
CREATE INDEX "idx_pop_pollid" ON "poll_option" (
	"pollid"
);

DROP TABLE IF EXISTS "poll_textreply";
CREATE TABLE "poll_textreply" (
	"id"	INTEGER NOT NULL,
	"datetime"	DATETIME NOT NULL,
	"pollid"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"replytext"	TEXT NOT NULL,
	"adminrank"	TEXT NOT NULL,
	"deleted"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("pollid") REFERENCES "poll_question"("id")
);
DROP INDEX IF EXISTS "idx_ptext_pollid_ckey";
CREATE INDEX "idx_ptext_pollid_ckey" ON "poll_textreply" (
	"pollid",
	"ckey"
);

DROP TABLE IF EXISTS "poll_vote";
CREATE TABLE "poll_vote" (
	"id"	INTEGER NOT NULL,
	"datetime"	DATETIME NOT NULL,
	"pollid"	INTEGER NOT NULL,
	"optionid"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"ip"	UNSIGNED_INTEGER NOT NULL,
	"adminrank"	TEXT NOT NULL,
	"rating"	INTEGER DEFAULT null,
	"deleted"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("pollid") REFERENCES "poll_question"("id")
);
DROP INDEX IF EXISTS "idx_pvote_optionid_ckey";
CREATE INDEX "idx_pvote_optionid_ckey" ON "poll_vote" (
	"optionid",
	"ckey"
);
DROP INDEX IF EXISTS "idx_pvote_pollid_ckey";
CREATE INDEX "idx_pvote_pollid_ckey" ON "poll_vote" (
	"pollid",
	"ckey"
);

-- NOTE: This is used in place of a procedure, as SQLite doesn't have stored procedures. The effect is the same, though.
DROP TRIGGER IF EXISTS "poll_questionTdelete";
CREATE TRIGGER "poll_question_deleted"
	AFTER UPDATE OF "deleted" ON "poll_question"
	FOR EACH ROW BEGIN
		UPDATE "poll_option" SET deleted = 1 WHERE pollid = OLD.id;
		UPDATE "poll_textreply" SET deleted = 1 WHERE pollid = OLD.id;
		UPDATE "poll_vote" SET deleted = 1 WHERE pollid = OLD.id;
	END;

---------------
-- ROLE TIME --
---------------
DROP TABLE IF EXISTS "role_time";
CREATE TABLE "role_time" (
	"ckey"	TEXT NOT NULL,
	"job"	TEXT NOT NULL,
	"minutes"	UNSIGNED_INTEGER NOT NULL,
	PRIMARY KEY("ckey","job")
);

DROP TABLE IF EXISTS "role_time_log";
CREATE TABLE "role_time_log" (
	"id"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"job"	TEXT NOT NULL,
	"delta"	INTEGER NOT NULL,
	"datetime"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "ckey";
CREATE INDEX "ckey" ON "role_time_log" (
	"ckey"
);
DROP INDEX IF EXISTS "datetime";
CREATE INDEX "datetime" ON "role_time_log" (
	"datetime"
);
DROP INDEX IF EXISTS "job";
CREATE INDEX "job" ON "role_time_log" (
	"job"
);

DROP TRIGGER IF EXISTS "role_timeTloginsert";
CREATE TRIGGER "role_timeTloginsert"
	AFTER INSERT ON "role_time"
	FOR EACH ROW BEGIN
		INSERT INTO role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes);
	END;

DROP TRIGGER IF EXISTS "role_timeTlogupdate";
CREATE TRIGGER "role_timeTlogupdate"
	AFTER UPDATE ON "role_time"
	FOR EACH ROW BEGIN
		INSERT INTO role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes - OLD.minutes);
	END;

DROP TRIGGER IF EXISTS "role_timeTlogdelete";
CREATE TRIGGER "role_timeTlogdelete"
	AFTER DELETE ON "role_time"
	FOR EACH ROW BEGIN
		INSERT INTO role_time_log (ckey, job, delta) VALUES (OLD.ckey, OLD.job, 0 - OLD.minutes);
	END;

-----------
-- ROUND --
-----------
DROP TABLE IF EXISTS "round";
CREATE TABLE "round" (
	"id"	INTEGER NOT NULL,
	"initialize_datetime"	DATETIME NOT NULL,
	"start_datetime"	DATETIME,
	"end_datetime"	DATETIME,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"commit_hash"	TEXT,
	"game_mode"	TEXT,
	"game_mode_result"	TEXT,
	"end_state"	TEXT,
	"shuttle_name"	TEXT,
	"map_name"	TEXT,
	"station_name"	TEXT,
	"log_directory"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);

---------------------
-- SCHEMA REVISION --
---------------------
DROP TABLE IF EXISTS "schema_revision";
CREATE TABLE "schema_revision" (
	"major"	UNSIGNED_INTEGER NOT NULL,
	"minor"	UNSIGNED_INTEGER NOT NULL,
	"date"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("major","minor")
);

----------------
-- STICKYBANS --
----------------
DROP TABLE IF EXISTS "stickyban";
CREATE TABLE "stickyban" (
	"ckey"	TEXT NOT NULL,
	"reason"	TEXT NOT NULL,
	"banning_admin"	TEXT NOT NULL,
	"datetime"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("ckey")
);

DROP TABLE IF EXISTS "stickyban_matched_cid";
CREATE TABLE "stickyban_matched_cid" (
	"stickyban"	TEXT NOT NULL,
	"matched_cid"	TEXT NOT NULL,
	"first_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"last_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("stickyban","matched_cid")
);

DROP TABLE IF EXISTS "stickyban_matched_ckey";
CREATE TABLE "stickyban_matched_ckey" (
	"stickyban"	TEXT NOT NULL,
	"matched_ckey"	TEXT NOT NULL,
	"first_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"last_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"exempt"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("stickyban","matched_ckey")
);

DROP TABLE IF EXISTS "stickyban_matched_ip";
CREATE TABLE "stickyban_matched_ip" (
	"stickyban"	TEXT NOT NULL,
	"matched_ip"	TEXT NOT NULL,
	"first_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"last_matched"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("stickyban","matched_ip")
);

---------------------------
-- TELEMETRY CONNECTIONS --
---------------------------
DROP TABLE IF EXISTS "telemetry_connections";
CREATE TABLE "telemetry_connections" (
	"id"	INTEGER NOT NULL,
	"ckey"	TEXT NOT NULL,
	"telemetry_ckey"	TEXT NOT NULL,
	"address"	UNSIGNED_INTEGER NOT NULL,
	"computer_id"	TEXT NOT NULL,
	"first_round_id"	UNSIGNED_INTEGER,
	"last_round_id"	UNSIGNED_INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_constraints" UNIQUE("ckey","telemetry_ckey","address","computer_id")
);

------------------------------------
-- EXPLORER DRONE TEXT ADVENTURES --
------------------------------------
DROP TABLE IF EXISTS "text_adventures";
CREATE TABLE "text_adventures" (
	"id"	INTEGER NOT NULL,
	"adventure_data"	TEXT NOT NULL,
	"uploader"	TEXT NOT NULL,
	"timestamp"	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"approved"	BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);

-------------
-- TICKETS --
-------------
DROP TABLE IF EXISTS "ticket";
CREATE TABLE "ticket" (
	"id"	INTEGER NOT NULL,
	"server_ip"	UNSIGNED_INTEGER NOT NULL,
	"server_port"	UNSIGNED_INTEGER NOT NULL,
	"round_id"	UNSIGNED_INTEGER,
	"ticket"	UNSIGNED_INTEGER NOT NULL,
	"action"	TEXT NOT NULL DEFAULT 'Message',
	"urgent"	BOOLEAN NOT NULL DEFAULT 0,
	"message"	TEXT NOT NULL,
	"timestamp"	DATETIME NOT NULL,
	"recipient"	TEXT DEFAULT null,
	"sender"	TEXT DEFAULT null,
	PRIMARY KEY("id" AUTOINCREMENT)
);
DROP INDEX IF EXISTS "idx_ticket_act_recip";
CREATE INDEX "idx_ticket_act_recip" ON "ticket" (
	"action",
	"recipient"
);
DROP INDEX IF EXISTS "idx_ticket_act_send";
CREATE INDEX "idx_ticket_act_send" ON "ticket" (
	"action",
	"sender"
);
DROP INDEX IF EXISTS "idx_ticket_act_time_rid";
CREATE INDEX "idx_ticket_act_time_rid" ON "ticket" (
	"action",
	"timestamp",
	"round_id"
);
DROP INDEX IF EXISTS "idx_ticket_tic_rid";
CREATE INDEX "idx_ticket_tic_rid" ON "ticket" (
	"ticket",
	"round_id"
);


COMMIT;
