-- V1: core tables the rest of the lab builds on
CREATE TABLE students (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE courses (
  id    SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  hours INT  CHECK (hours > 0)
);

INSERT INTO students (name, email) VALUES
  ('Kofi Mensah',   'kofi@example.com'),
  ('Amina Yusuf',   'amina@example.com'),
  ('Chidi Okafor',  'chidi@example.com'),
  ('Wanjiru Kamau', 'wanjiru@example.com');

INSERT INTO courses (title, hours) VALUES
  ('Intro to SQL', 20),
  ('Python Basics', 30);
