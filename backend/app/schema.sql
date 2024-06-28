CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    contact TEXT,
    password TEXT NOT NULL,
    role TEXT
);

CREATE TABLE guardians (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    guardianId INTEGER,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (guardianId) REFERENCES users(id)
);

CREATE TABLE alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    victimId INTEGER,
    message TEXT,
    latitude TEXT,
    logitude TEXT,
    place TEXT,
    FOREIGN KEY (victimId) REFERENCES users(id)
);
