CREATE TABLE IF NOT EXISTS users (
	user_id VARCHAR(64) PRIMARY KEY,
	connected BOOLEAN
);

CREATE TABLE IF NOT EXISTS notes (
	note_id INT AUTO_INCREMENT PRIMARY KEY,
	user_id VARCHAR(64) NOT NULL,
	latitude DOUBLE NOT NULL,
	longitude DOUBLE NOT NULL,
	message VARCHAR(128) NOT NULL,
	creation_time DATETIME NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);
