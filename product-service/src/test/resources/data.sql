-- Initialize Categories
INSERT INTO categories (category_id, category_title, image_url, parent_category_id) VALUES 
(10, 'Books', 'https://example.com/images/books.jpg', NULL),
(11, 'Toys', 'https://example.com/images/toys.jpg', NULL),
(12, 'Sports', 'https://example.com/images/sports.jpg', NULL),
(13, 'Fiction', 'https://example.com/images/fiction.jpg', 10),
(14, 'Board Games', 'https://example.com/images/boardgames.jpg', 11),
(15, 'Outdoor', 'https://example.com/images/outdoor.jpg', 12),
(16, 'Non-Fiction', 'https://example.com/images/nonfiction.jpg', 10);

-- Initialize Products
INSERT INTO products (product_id, product_title, image_url, sku, price_unit, quantity, category_id) VALUES 
(21, 'The Great Gatsby', 'https://example.com/images/gatsby.jpg', 'SKU-BOOK-001', 19.99, 100, 13),
(22, 'Chess Set', 'https://example.com/images/chess.jpg', 'SKU-TOY-002', 29.99, 50, 14),
(23, 'Mountain Bike', 'https://example.com/images/bike.jpg', 'SKU-SPRT-003', 499.99, 10, 15),
(24, 'Encyclopedia', 'https://example.com/images/encyclopedia.jpg', 'SKU-BOOK-004', 59.99, 30, 16),
(25, 'Soccer Ball', 'https://example.com/images/soccerball.jpg', 'SKU-SPRT-005', 24.99, 60, 15),
(26, 'Monopoly', 'https://example.com/images/monopoly.jpg', 'SKU-TOY-006', 34.99, 40, 14),
(27, 'Puzzle 1000pcs', 'https://example.com/images/puzzle.jpg', 'SKU-TOY-007', 14.99, 80, 14),
(28, 'Biography Book', 'https://example.com/images/biography.jpg', 'SKU-BOOK-008', 22.99, 70, 16);
