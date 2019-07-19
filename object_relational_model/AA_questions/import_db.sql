PRAGMA foreign_keys = ON;

/* USERS */
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

INSERT INTO 
  users (fname, lname)
VALUES
  ("Foo", "Bar"), ("Wil", "Son"), ("Cat", "Dog");


/* QUESTIONS */
DROP TABLE IF EXISTS questions;

CREATE TABLE IF NOT EXISTS questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
);

INSERT INTO 
  questions (title, body, users_id)
VALUES
  ('Foo''s Q', 'What does foo bar mean?', 
    (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'));

INSERT INTO 
  questions (title, body, users_id)
VALUES
  ('Wil''s Q', 'What is App Academy?', 
    (SELECT id FROM users WHERE fname = 'Wil' AND lname = 'Son'));

INSERT INTO 
  questions (title, body, users_id)
VALUES
  ('Cat''s Q', 'What is your favorite cartoon?', 
    (SELECT id FROM users WHERE fname = 'Cat' AND lname = 'Dog'));


/* QUESTION_FOLLOWS */
/* a user can have many questions she is following, and a question can have 
many followers */
DROP TABLE IF EXISTS question_follows;

CREATE TABLE IF NOT EXISTS question_follows(
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO 
  question_follows (users_id, questions_id)
VALUES
  (
    (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'),
    (SELECT id FROM questions WHERE title = 'Cat''s Q')    
  ),
  (
    (SELECT id FROM users WHERE fname = 'Wil' AND lname = 'Son'),
    (SELECT id FROM questions WHERE title = 'Cat''s Q') 
  );


/* REPLIES */
/*self referential; a foreign key can point to a primary key in the same table*/
DROP TABLE IF EXISTS replies;

CREATE TABLE IF NOT EXISTS replies(
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  parent_id INTEGER,
  users_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

INSERT INTO 
  replies (questions_id, parent_id, users_id, body)
VALUES
  (
    (SELECT id FROM questions WHERE title = 'Foo''s Q'),
    NULL,
    (SELECT id FROM users WHERE fname = 'Wil' AND lname = 'Son'),
    'It is the name of a bar.'
  );

INSERT INTO 
  replies (questions_id, parent_id, users_id, body)
VALUES
  (
    (SELECT id FROM questions WHERE title = 'Foo''s Q'),
    (SELECT id FROM replies WHERE body = 'It is the name of a bar.'),
    (SELECT id FROM users WHERE fname = 'Cat' AND lname = 'Dog'),
    'It is commonly used as variable and placeholder names in programming.'
  );


/* QUESTION_LIKES */
DROP TABLE IF EXISTS question_likes;

CREATE TABLE IF NOT EXISTS question_likes(
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO 
  question_likes(users_id, questions_id)
VALUES
  (
    (SELECT id FROM users WHERE fname = 'Cat' AND lname = 'Dog'),
    (Select id FROM questions WHERE title = 'Foo''s Q')
  );
