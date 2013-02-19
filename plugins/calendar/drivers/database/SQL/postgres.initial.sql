/**
 * RoundCube Calendar
 *
 * Plugin to add a calendar to RoundCube.
 *
 * @version @package_version@
 * @author Lazlo Westerhof
 * @author Albert Lee
 * @author Aleksander Machniak <machniak@kolabsys.com>
 * @url http://rc-calendar.lazlo.me
 * @licence GNU AGPL
 * @copyright (c) 2010 Lazlo Westerhof - Netherlands
 *
 **/


CREATE SEQUENCE calendar_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE calendars (
    calendar_id integer DEFAULT nextval('calendar_ids'::regclass) NOT NULL,
    user_id integer NOT NULL
        REFERENCES users (user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    name varchar(255) NOT NULL,
    color varchar(8) NOT NULL,
    showalarms smallint NOT NULL DEFAULT 1,
    PRIMARY KEY (calendar_id)
);

CREATE INDEX calendars_user_id_idx ON calendars (user_id, name);


CREATE SEQUENCE event_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE events (
    event_id integer DEFAULT nextval('event_ids'::regclass) NOT NULL,
    calendar_id integer NOT NULL
        REFERENCES calendars (calendar_id) ON UPDATE CASCADE ON DELETE CASCADE,
    recurrence_id integer NOT NULL DEFAULT 0,
    uid varchar(255) NOT NULL DEFAULT '',
    created timestamp without time zone DEFAULT now() NOT NULL,
    changed timestamp without time zone DEFAULT now(),
    sequence integer NOT NULL DEFAULT 0,
    "start" timestamp without time zone DEFAULT now() NOT NULL,
    "end" timestamp without time zone DEFAULT now() NOT NULL,
    recurrence varchar(255) DEFAULT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    location character varying(255) NOT NULL,
    categories character varying(255) NOT NULL,
    all_day smallint NOT NULL DEFAULT 0,
    free_busy smallint NOT NULL DEFAULT 0,
    priority smallint NOT NULL DEFAULT 0,
    sensitivity smallint NOT NULL DEFAULT 0,
    alarms varchar(255) DEFAULT NULL,
    attendees text DEFAULT NULL,
    notifyat timestamp without time zone DEFAULT NULL,
    PRIMARY KEY (event_id)
);

CREATE INDEX events_calendar_id_notifyat_idx ON events (calendar_id, notifyat);
CREATE INDEX events_uid_idx ON events (uid);
CREATE INDEX events_recurrence_id_idx ON events (recurrence_id);


CREATE SEQUENCE attachment_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE attachments (
    attachment_id integer DEFAULT nextval('attachment_ids'::regclass) NOT NULL,
    event_id integer NOT NULL
        REFERENCES events (event_id) ON DELETE CASCADE ON UPDATE CASCADE,
    filename varchar(255) NOT NULL DEFAULT '',
    mimetype varchar(255) NOT NULL DEFAULT '',
    size integer NOT NULL DEFAULT 0,
    data text NOT NULL DEFAULT '',
    PRIMARY KEY (attachment_id)
);

CREATE INDEX attachments_user_id_idx ON attachments (event_id);


CREATE TABLE itipinvitations (
    token varchar(64) NOT NULL,
    event_uid varchar(255) NOT NULL,
    user_id integer NOT NULL
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    event TEXT NOT NULL,
    expires timestamp without time zone DEFAULT NULL,
    cancelled smallint NOT NULL DEFAULT 0,
    PRIMARY KEY (token)
);

CREATE INDEX itipinvitations_user_id_event_uid_idx ON itipinvitations (user_id, event_uid);

INSERT INTO system (name, value) VALUES ('calendar-database-version', '2013011000');
