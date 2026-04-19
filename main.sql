CREATE TABLE users (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE
);

CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  price DECIMAL(10, 2)
);

CREATE TABLE ratings (
  id INT PRIMARY KEY,
  user_id INT,
  product_id INT,
  rating INT CHECK(rating BETWEEN 1 AND 5),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE recommendations (
  id INT PRIMARY KEY,
  user_id INT,
  product_id INT,
  score DECIMAL(10, 2),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE user_profiles (
  id INT PRIMARY KEY,
  user_id INT,
  age INT,
  gender VARCHAR(10),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE product_categories (
  id INT PRIMARY KEY,
  product_id INT,
  category VARCHAR(100),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO users (id, name, email) VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Doe', 'jane@example.com'),
(3, 'Bob Smith', 'bob@example.com');

INSERT INTO products (id, name, description, price) VALUES
(1, 'Product A', 'This is product A', 19.99),
(2, 'Product B', 'This is product B', 9.99),
(3, 'Product C', 'This is product C', 29.99);

INSERT INTO ratings (id, user_id, product_id, rating) VALUES
(1, 1, 1, 5),
(2, 1, 2, 3),
(3, 2, 1, 4),
(4, 2, 3, 5),
(5, 3, 2, 2);

INSERT INTO user_profiles (id, user_id, age, gender) VALUES
(1, 1, 30, 'Male'),
(2, 2, 25, 'Female'),
(3, 3, 40, 'Male');

INSERT INTO product_categories (id, product_id, category) VALUES
(1, 1, 'Electronics'),
(2, 2, 'Fashion'),
(3, 3, 'Electronics');

CREATE VIEW user_product_scores AS
SELECT u.id, p.id, AVG(r.rating) AS score
FROM users u
JOIN ratings r ON u.id = r.user_id
JOIN products p ON r.product_id = p.id
GROUP BY u.id, p.id;

CREATE VIEW product_recommendations AS
SELECT p.id, u.id, p.name, p.description, p.price, ups.score
FROM products p
JOIN user_product_scores ups ON p.id = ups.id
JOIN users u ON ups.id = u.id
ORDER BY ups.score DESC;

CREATE TRIGGER update_recommendations
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
  INSERT INTO recommendations (user_id, product_id, score)
  SELECT NEW.user_id, NEW.product_id, (SELECT score FROM user_product_scores WHERE id = NEW.product_id)
  ON DUPLICATE KEY UPDATE score = (SELECT score FROM user_product_scores WHERE id = NEW.product_id);
END;