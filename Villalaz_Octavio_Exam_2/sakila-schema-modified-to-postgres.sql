
-- Instead of Names utf8mb4 SET is used to set client encoding
-- Instead of disabling foregn key and unique key checks we disable checking funtions
-- Set client message level to warining 
-- Remove sql mode traditional
SET client_encoding = 'utf8';
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP SCHEMA IF EXISTS sakila;
CREATE SCHEMA sakila;
SET search_path TO sakila;

-- Function for Timestamp
CREATE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
NEW.last_update = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ language 'plpgsql';


-- remove connection to sakila schema

--
-- Table structure for table `actor`
--

-- Changed actor_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Changed Index creation to CREATE INDEX
-- Remove On Update from timestamp CREATE trigger for update
-- Removed engine and charset
CREATE TABLE actor (
  actor_id SERIAL PRIMARY KEY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_actor_last_name ON actor(last_name);
CREATE TRIGGER update_actor_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `country`
--
--Changed country_id to serial 
-- Remove On Update from timestamp CREATE trigger for update

CREATE TABLE country (
  country_id SERIAL PRIMARY KEY,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
);
 CREATE TRIGGER update_country_t() BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `city`
--
-- Removed Engine Charset
-- Changed city_id to serial
-- Removed country_id unsigned type
-- Changed index to CREATE INDEX
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE city (
  city_id SERIAL PRIMARY KEY,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_country_id ON city(country_id);
CREATE TRIGGER update_city_t() BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();

--
-- Table structure for table `address`
--

-- Changed address_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Removed city_id unsigned type
-- Changed Index creation to CREATE INDEX
-- Remove On Update from timestamp CREATE trigger for update
-- Changed foreign key constraint
-- Removed engine and charset
CREATE TABLE address (
  address_id SERIAL PRIMARY KEY,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_city_id ON address(city_id);
CREATE TRIGGER update_address_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `category`
--

-- Changed category_id's TINYINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER update_category_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `staff`
--
--Changed staff_id's TINYINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Remove unsigned
-- Remove On Update from timestamp CREATE trigger for update
-- Remove character set and collate from password
-- Change blob with bytea
-- Change TINYINT with SMALLINT
CREATE TABLE staff (
  staff_id SERIAL PRIMARY KEY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT  NOT NULL,
  picture BYTEA DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_store_id staff(store_id);
CREATE INDEX idx_fk_address_id staff(address_id);
CREATE TRIGGER update_staff_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `store`
--
--Changed store_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
--Remove unsigned
--Move indexes and used CREATE INDEX
--Move unique key and used CREATE UNIQUE KEY
--Change TINYINT with SMALLINT 
-- REMOVED staff_id and added to a many to many table
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE store (
  store_id SERIAL PRIMARY KEY,
  address_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_address_id ON store(address_id);
CREATE UNIQUE INDEX idx_unique_manager ON store(manager_staff_id);
CREATE TRIGGER update_store_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();



--CREATE MANY TO MANY RELATIONISHIP TABLE BETWEEN staff and store
CREATE TABLE store_staff(
 staff_id INTEGER REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
 store_id INTEGER REFERENCES store(store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
 PRIMARY KEY(staff_id, store_id)
);



--
-- Table structure for table `customer`
--

--Changed customer_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Remove On Update from timestamp CREATE trigger for update
-- Remove unsigned
-- Added CREATE Indexes
-- Changed TINYINT to SMALLINT
CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  store_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date DATE NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_store_id ON customer(store_id);
CREATE INDEX idx_customer_fk_address_id ON customer(address_id);
CREATE INDEX idx_last_name ON customer(last_name);
CREATE TRIGGER update_customer_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();

--
-- Table structure for table `language`
--
-- Changed film_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE language (
  language_id SERIAL PRIMARY KEY,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER update_language_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();
--
-- Table structure for table `film`
--
-- Changed film_id's SMALLINT Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- All TINYINT tyoe to SMALLINT
-- Removed all UNSIGNED
-- Changed Year type to INTEGER
-- Changed DECIMAL to NUMERIC
-- Changed rating ENUM with CHECK
-- Remove On Update from timestamp CREATE trigger for update 
CREATE TABLE film (
  film_id SERIAL PRIMARY KEY,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year INTEGER DEFAULT NULL,
  language_id SMALLINT NOT NULL,
  original_language_id SMALLINT DEFAULT NULL,
  rental_duration SMALLINT NOT NULL DEFAULT 3,
  rental_rate NUMERIC(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT DEFAULT NULL,
  replacement_cost NUMERIC(5,2) NOT NULL DEFAULT 19.99,
  rating VARCHAR(5) CHECK (rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17')) DEFAULT 'G',
  special_features TEXT[] DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_title ON film (title);
CREATE INDEX idx_fk_language_id ON film (language_id);
CREATE INDEX idx_fk_original_language_id ON film (original_language_id);
CREATE TRIGGER update_film_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `film_actor`
--
-- Removed all UNSIGNED
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE film_actor (
  actor_id SMALLINT  NOT NULL,
  film_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id,film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_film_id ON film_actor (film_id);
CREATE TRIGGER update_film_actor_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();
--
-- Table structure for table `film_category`
--
-- Removed all UNSIGNED
-- Remove On Update from timestamp CREATE trigger for update
-- Changed TINYINT to SMALLINT
CREATE TABLE film_category (
  film_id SMALLINT NOT NULL,
  category_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id),
  CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TRIGGER update_film_category_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();
--
-- Table structure for table `film_text`
-- 
--use the to_tsvector function to convert the concatenated title and description columns 
CREATE TABLE film_text (
  film_id SMALLINT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT
);
CREATE INDEX idx_title_description ON film_text USING gin(to_tsvector('english', title || ' ' || description));
--
-- Table structure for table `inventory`
--
-- Changed inventory_id's Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Removed all UNSIGNED
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE inventory (
  inventory_id SERIAL PRIMARY KEY,
  film_id SMALLINT  NOT NULL,
  store_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_inventory_film_id ON inventory(film_id);
CREATE INDEX idx_store_id_film_id ON inventory(store_id,film_id);
CREATE TRIGGER update_inventory_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();

--
-- Table structure for table `rental`
--
-- Changed rental_id's Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Removed all UNSIGNED
-- Changed DATETIME to DATE
-- Change TINYINT to SMALLINT
-- Change MEDIUMINT to INTEGER
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE rental (
  rental_id SERIAL PRIMARY KEY,
  rental_date DATE NOT NULL,
  inventory_id INTEGER NOT NULL,
  customer_id SMALLINT NOT NULL,
  return_date DATE DEFAULT NULL,
  staff_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(rental_date,inventory_id,customer_id),
  CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_inventory_id ON rental (inventory_id);
CREATE INDEX idx_fk_customer_id ON rental(customer_id);
CREATE INDEX idx_fk_staff_id ON rental(staff_id);
CREATE TRIGGER update_rental_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();


--
-- Table structure for table `payment`
--
-- Changed payment_id's Unsigned AUTO_INCREMENT type to Serial type and set it to primary key
-- Changed TINYINT to SMALLINT
-- Changed DECIMAL to NUMERIC
-- Remove On Update from timestamp CREATE trigger for update
CREATE TABLE payment (
  payment_id SERIAL PRIMARY KEY,
  customer_id SMALLINT  NOT NULL,
  staff_id SMALLINT NOT NULL,
  rental_id INT DEFAULT NULL,
  amount NUMERIC(5,2) NOT NULL,
  payment_date DATE NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_fk_payment_staff_id ON payment(staff_id);
CREATE INDEX idx_fk_payment_customer_id ON payment(customer_id);
CREATE TRIGGER update_payment_t BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_timestamp();






