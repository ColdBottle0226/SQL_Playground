-- ============================================================
-- SQL Playground - 심화 (Advanced) Schema & Data
-- 도메인: 이커머스 플랫폼
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- A1. 회원 등급 (member_grades)
-- ============================================================
CREATE TABLE member_grades (
  grade_id    INT          PRIMARY KEY AUTO_INCREMENT,
  grade_name  VARCHAR(20)  NOT NULL UNIQUE,           -- BRONZE, SILVER, GOLD, VIP
  min_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,       -- 등급 유지 최소 누적 구매액
  discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0,       -- 기본 할인율(%)
  point_rate  DECIMAL(5,2) NOT NULL DEFAULT 1.0       -- 포인트 적립 배율
);

-- ============================================================
-- A2. 회원 (members)
-- ============================================================
CREATE TABLE members (
  member_id   INT          PRIMARY KEY AUTO_INCREMENT,
  email       VARCHAR(100) NOT NULL UNIQUE,
  member_name VARCHAR(50)  NOT NULL,
  grade_id    INT          NOT NULL,
  join_date   DATE         NOT NULL,
  last_login  DATETIME,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  CONSTRAINT fk_member_grade FOREIGN KEY (grade_id) REFERENCES member_grades(grade_id)
);

-- ============================================================
-- A3. 포인트 이력 (point_history)
-- ============================================================
CREATE TABLE point_history (
  point_id    INT          PRIMARY KEY AUTO_INCREMENT,
  member_id   INT          NOT NULL,
  point_type  ENUM('earn','use','expire') NOT NULL,
  point_amt   INT          NOT NULL,                  -- 양수: 적립/복구, 음수: 사용/소멸
  ref_order_id INT,                                   -- 관련 주문 ID (NULL 가능)
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ph_member FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- ============================================================
-- A4. 쿠폰 정책 (coupon_policies)
-- ============================================================
CREATE TABLE coupon_policies (
  policy_id       INT         PRIMARY KEY AUTO_INCREMENT,
  policy_name     VARCHAR(100) NOT NULL,
  discount_type   ENUM('rate','fixed') NOT NULL,      -- rate: 정률, fixed: 정액
  discount_value  DECIMAL(10,2) NOT NULL,             -- 할인율(%) 또는 할인금액(원)
  min_order_amt   DECIMAL(12,2) NOT NULL DEFAULT 0,   -- 최소 주문 금액
  max_discount    DECIMAL(10,2),                      -- 최대 할인 한도 (rate일 때)
  valid_days      INT          NOT NULL DEFAULT 30,   -- 발급 후 유효 일수
  is_active       TINYINT(1)   NOT NULL DEFAULT 1
);

-- ============================================================
-- A5. 발급된 쿠폰 (issued_coupons)
-- ============================================================
CREATE TABLE issued_coupons (
  coupon_id   INT          PRIMARY KEY AUTO_INCREMENT,
  policy_id   INT          NOT NULL,
  member_id   INT          NOT NULL,
  issued_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at  DATETIME     NOT NULL,
  used_at     DATETIME,
  used_order_id INT,
  CONSTRAINT fk_ic_policy FOREIGN KEY (policy_id)  REFERENCES coupon_policies(policy_id),
  CONSTRAINT fk_ic_member FOREIGN KEY (member_id)  REFERENCES members(member_id)
);

-- ============================================================
-- A6. 상품 카테고리 (adv_categories) — 계층형
-- ============================================================
CREATE TABLE adv_categories (
  cat_id      INT         PRIMARY KEY AUTO_INCREMENT,
  cat_name    VARCHAR(50) NOT NULL,
  parent_id   INT,                                    -- NULL이면 최상위
  depth       INT         NOT NULL DEFAULT 1,
  CONSTRAINT fk_cat_parent FOREIGN KEY (parent_id) REFERENCES adv_categories(cat_id)
);

-- ============================================================
-- A7. 심화 상품 (adv_products)
-- ============================================================
CREATE TABLE adv_products (
  product_id    INT          PRIMARY KEY AUTO_INCREMENT,
  product_name  VARCHAR(200) NOT NULL,
  cat_id        INT          NOT NULL,
  brand         VARCHAR(50),
  original_price DECIMAL(10,2) NOT NULL,
  sale_price    DECIMAL(10,2) NOT NULL,
  cost_price    DECIMAL(10,2) NOT NULL,               -- 원가
  stock_qty     INT          NOT NULL DEFAULT 0,
  rating_avg    DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  review_cnt    INT          NOT NULL DEFAULT 0,
  is_selling    TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATE         NOT NULL,
  CONSTRAINT fk_ap_cat FOREIGN KEY (cat_id) REFERENCES adv_categories(cat_id)
);

-- ============================================================
-- A8. 심화 주문 (adv_orders)
-- ============================================================
CREATE TABLE adv_orders (
  order_id        INT          PRIMARY KEY AUTO_INCREMENT,
  member_id       INT          NOT NULL,
  order_date      DATETIME     NOT NULL,
  status          ENUM('pending','paid','shipping','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  original_amount DECIMAL(12,2) NOT NULL,
  coupon_discount DECIMAL(10,2) NOT NULL DEFAULT 0,
  point_used      INT          NOT NULL DEFAULT 0,
  final_amount    DECIMAL(12,2) NOT NULL,             -- 실결제액
  coupon_id       INT,
  payment_method  ENUM('card','transfer','point','mixed') NOT NULL DEFAULT 'card',
  CONSTRAINT fk_ao_member FOREIGN KEY (member_id)  REFERENCES members(member_id),
  CONSTRAINT fk_ao_coupon FOREIGN KEY (coupon_id)  REFERENCES issued_coupons(coupon_id)
);

-- ============================================================
-- A9. 심화 주문 상세 (adv_order_items)
-- ============================================================
CREATE TABLE adv_order_items (
  item_id     INT          PRIMARY KEY AUTO_INCREMENT,
  order_id    INT          NOT NULL,
  product_id  INT          NOT NULL,
  quantity    INT          NOT NULL,
  unit_price  DECIMAL(10,2) NOT NULL,                -- 주문 당시 판매가
  cost_price  DECIMAL(10,2) NOT NULL,                -- 주문 당시 원가
  discount_amt DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_aoi_order   FOREIGN KEY (order_id)   REFERENCES adv_orders(order_id),
  CONSTRAINT fk_aoi_product FOREIGN KEY (product_id) REFERENCES adv_products(product_id)
);

-- ============================================================
-- A10. 배송 (deliveries)
-- ============================================================
CREATE TABLE deliveries (
  delivery_id     INT         PRIMARY KEY AUTO_INCREMENT,
  order_id        INT         NOT NULL UNIQUE,
  carrier         VARCHAR(50),                        -- 택배사
  tracking_no     VARCHAR(50),
  shipped_at      DATETIME,
  delivered_at    DATETIME,
  delivery_status ENUM('ready','in_transit','delivered','failed') NOT NULL DEFAULT 'ready',
  delivery_fee    DECIMAL(8,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_dlv_order FOREIGN KEY (order_id) REFERENCES adv_orders(order_id)
);

-- ============================================================
-- A11. 상품 리뷰 (reviews)
-- ============================================================
CREATE TABLE reviews (
  review_id   INT          PRIMARY KEY AUTO_INCREMENT,
  product_id  INT          NOT NULL,
  member_id   INT          NOT NULL,
  order_id    INT          NOT NULL,
  rating      TINYINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content     TEXT,
  is_best     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rv_product FOREIGN KEY (product_id) REFERENCES adv_products(product_id),
  CONSTRAINT fk_rv_member  FOREIGN KEY (member_id)  REFERENCES members(member_id),
  CONSTRAINT fk_rv_order   FOREIGN KEY (order_id)   REFERENCES adv_orders(order_id),
  CONSTRAINT uq_review UNIQUE (product_id, member_id, order_id)
);

-- ============================================================
-- A12. 재고 변동 이력 (stock_history)
-- ============================================================
CREATE TABLE stock_history (
  history_id  INT          PRIMARY KEY AUTO_INCREMENT,
  product_id  INT          NOT NULL,
  change_type ENUM('in','out','adjust','return') NOT NULL,
  qty_change  INT          NOT NULL,                  -- 양수: 증가, 음수: 감소
  qty_after   INT          NOT NULL,                  -- 변동 후 재고
  ref_order_id INT,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sh_product FOREIGN KEY (product_id) REFERENCES adv_products(product_id)
);

-- ============================================================
-- A13. 월별 매출 집계 (monthly_sales) — 정산용 집계 테이블
-- ============================================================
CREATE TABLE monthly_sales (
  ms_id          INT     PRIMARY KEY AUTO_INCREMENT,
  ym             CHAR(7) NOT NULL,                    -- 'YYYY-MM'
  cat_id         INT     NOT NULL,
  total_orders   INT     NOT NULL DEFAULT 0,
  total_revenue  DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_cost     DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_profit   DECIMAL(14,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_ms_cat FOREIGN KEY (cat_id) REFERENCES adv_categories(cat_id),
  CONSTRAINT uq_ms UNIQUE (ym, cat_id)
);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- DATA INSERT
-- ============================================================

-- ── 회원 등급 ──
INSERT INTO member_grades (grade_name, min_amount, discount_pct, point_rate) VALUES
('BRONZE',       0,          0,    1.0),
('SILVER',  500000,        2.0,    1.5),
('GOLD',   2000000,        4.0,    2.0),
('VIP',    5000000,        6.0,    3.0);

-- ── 회원 ──
INSERT INTO members (email, member_name, grade_id, join_date, last_login, is_active) VALUES
('kim@example.com',   '김하늘',  1, '2022-01-10', '2024-06-28 09:12:00', 1),
('lee@example.com',   '이도윤',  2, '2021-05-20', '2024-06-25 14:30:00', 1),
('park@example.com',  '박서준',  3, '2020-11-03', '2024-06-30 11:00:00', 1),
('choi@example.com',  '최지아',  4, '2019-07-15', '2024-06-29 18:45:00', 1),
('jung@example.com',  '정민준',  3, '2021-02-28', '2024-05-10 08:20:00', 1),
('yoon@example.com',  '윤서율',  2, '2022-09-01', '2024-06-20 16:10:00', 1),
('lim@example.com',   '임채원',  1, '2023-03-15', '2024-04-01 10:00:00', 1),
('kang@example.com',  '강지훈',  4, '2018-12-01', '2024-06-30 20:00:00', 1),
('jo@example.com',    '조예린',  3, '2020-06-10', '2024-06-15 13:30:00', 1),
('shin@example.com',  '신동우',  2, '2022-04-20', '2024-03-01 09:00:00', 1),
('han@example.com',   '한수빈',  1, '2023-08-05', '2024-06-10 17:20:00', 1),
('oh@example.com',    '오태양',  4, '2017-03-22', '2024-06-30 22:15:00', 1),
('ryu@example.com',   '류나은',  3, '2021-10-11', '2024-06-27 12:00:00', 1),
('baek@example.com',  '백준혁',  2, '2022-07-30', '2024-06-22 15:45:00', 1),
('hwang@example.com', '황소연',  1, '2023-11-20', '2024-02-15 08:30:00', 0);

-- ── 포인트 이력 ──
INSERT INTO point_history (member_id, point_type, point_amt, ref_order_id, created_at) VALUES
(1,  'earn',    500,  1,  '2024-01-15 10:00:00'),
(2,  'earn',   1200,  2,  '2024-01-20 11:00:00'),
(3,  'earn',   3000,  3,  '2024-02-05 09:30:00'),
(4,  'earn',   5000,  4,  '2024-02-10 14:00:00'),
(4,  'use',   -2000,  5,  '2024-02-20 15:00:00'),
(3,  'earn',   2500,  6,  '2024-03-01 10:30:00'),
(5,  'earn',   1800,  7,  '2024-03-10 12:00:00'),
(8,  'earn',   8000,  8,  '2024-03-15 16:00:00'),
(8,  'use',   -3000,  9,  '2024-04-01 09:00:00'),
(12, 'earn',   9500, 10,  '2024-04-05 10:00:00'),
(2,  'expire', -500, NULL, '2024-04-30 00:00:00'),
(6,  'earn',    800, 11,  '2024-05-01 11:00:00'),
(9,  'earn',   2200, 12,  '2024-05-10 13:00:00'),
(1,  'earn',    300, 13,  '2024-05-20 14:00:00'),
(7,  'earn',    150, 14,  '2024-06-01 09:30:00');

-- ── 쿠폰 정책 ──
INSERT INTO coupon_policies (policy_name, discount_type, discount_value, min_order_amt, max_discount, valid_days, is_active) VALUES
('신규회원 10% 할인',      'rate',  10.0,  10000,  5000, 30, 1),
('5만원 이상 3천원 할인',  'fixed',  3000, 50000,  NULL, 60, 1),
('VIP 전용 15% 할인',     'rate',  15.0, 100000, 20000, 90, 1),
('브랜드위크 20% 할인',   'rate',  20.0,  30000, 10000, 14, 0),
('10만원 이상 5천원 할인', 'fixed',  5000, 100000, NULL, 60, 1),
('GOLD 이상 7% 할인',     'rate',   7.0,  50000, 15000, 60, 1);

-- ── 발급 쿠폰 ──
INSERT INTO issued_coupons (policy_id, member_id, issued_at, expired_at, used_at, used_order_id) VALUES
(1,  1, '2022-01-10 10:00:00', '2022-02-10 23:59:59', '2022-01-20 15:00:00', NULL),
(2,  2, '2024-01-01 00:00:00', '2024-03-01 23:59:59', '2024-01-20 11:00:00', 2),
(3,  4, '2024-01-01 00:00:00', '2024-03-31 23:59:59', '2024-02-10 14:00:00', 4),
(5,  3, '2024-02-01 00:00:00', '2024-04-01 23:59:59', NULL, NULL),
(6,  3, '2024-03-01 00:00:00', '2024-05-01 23:59:59', '2024-03-01 10:30:00', 6),
(2,  5, '2024-03-01 00:00:00', '2024-05-01 23:59:59', '2024-03-10 12:00:00', 7),
(3,  8, '2024-01-01 00:00:00', '2024-03-31 23:59:59', '2024-03-15 16:00:00', 8),
(1,  7, '2023-03-15 10:00:00', '2023-04-15 23:59:59', NULL, NULL),
(5,  9, '2024-05-01 00:00:00', '2024-07-01 23:59:59', '2024-05-10 13:00:00', 12),
(6, 13, '2024-06-01 00:00:00', '2024-08-01 23:59:59', NULL, NULL),
(2, 14, '2024-06-01 00:00:00', '2024-08-01 23:59:59', NULL, NULL),
(3, 12, '2024-01-01 00:00:00', '2024-03-31 23:59:59', '2024-04-05 10:00:00', 10);

-- ── 카테고리 (계층형: 대분류→소분류) ──
INSERT INTO adv_categories (cat_id, cat_name, parent_id, depth) VALUES
(1,  '전자제품',    NULL, 1),
(2,  '패션',        NULL, 1),
(3,  '생활/건강',   NULL, 1),
(4,  '스포츠',      NULL, 1),
(5,  '노트북/PC',      1, 2),
(6,  '스마트폰/태블릿', 1, 2),
(7,  '음향/영상',       1, 2),
(8,  '남성의류',        2, 2),
(9,  '여성의류',        2, 2),
(10, '운동화',          2, 2),
(11, '주방용품',        3, 2),
(12, '건강식품',        3, 2),
(13, '헬스/피트니스',   4, 2),
(14, '아웃도어',        4, 2),
(15, '게이밍노트북',    5, 3),
(16, '울트라북',        5, 3),
(17, '안드로이드폰',    6, 3),
(18, '아이폰',          6, 3),
(19, '블루투스이어폰',  7, 3),
(20, '스피커',          7, 3);

-- ── 심화 상품 ──
INSERT INTO adv_products (product_name, cat_id, brand, original_price, sale_price, cost_price, stock_qty, rating_avg, review_cnt, is_selling, created_at) VALUES
('에이수스 ROG Zephyrus G14',    15, 'ASUS',    1890000, 1690000,  980000, 30, 4.7, 128, 1, '2023-01-10'),
('LG 그램 16 울트라슬림',        16, 'LG',      1790000, 1690000, 1000000, 45, 4.5,  95, 1, '2023-03-01'),
('삼성 갤럭시 S24 Ultra',        17, 'Samsung', 1699000, 1549000,  820000, 80, 4.6, 312, 1, '2024-01-17'),
('애플 아이폰 15 Pro Max',       18, 'Apple',   1900000, 1799000,  950000, 60, 4.8, 450, 1, '2023-09-22'),
('소니 WF-1000XM5',             19, 'Sony',     399000,  349000,  160000,120, 4.9, 280, 1, '2023-05-12'),
('JBL Charge 5',                20, 'JBL',      219000,  189000,   85000,200, 4.4, 175, 1, '2022-08-01'),
('나이키 에어맥스 97',           10, 'Nike',     189000,  169000,   72000, 55, 4.3, 210, 1, '2023-02-15'),
('아디다스 울트라부스트 23',     10, 'Adidas',   209000,  189000,   82000, 40, 4.5, 185, 1, '2023-04-01'),
('유니클로 드라이EX 반팔티',      8, 'Uniqlo',   29900,   25900,    9000,300, 4.2, 520, 1, '2023-06-01'),
('무인양품 릴랙스 후드티',        9, 'MUJI',     69900,   59900,   22000,150, 4.6, 340, 1, '2023-06-15'),
('해피콜 IH 인덕션 냄비세트',    11, 'Happycall',129000,  109000,   45000, 70, 4.4, 160, 1, '2023-07-01'),
('종근당 오메가3 6개월분',       12, '종근당',    59000,   49000,   18000,500, 4.7, 890, 1, '2022-09-01'),
('보맥스 스쿼트랙 홈짐세트',     13, '보맥스',   890000,  790000,  350000, 15, 4.5,  62, 1, '2023-08-01'),
('블랙야크 등산화 BYC-1000',     14, '블랙야크',  229000,  199000,   88000, 35, 4.3,  98, 1, '2023-05-01'),
('삼성 오디세이 OLED G9',         5, 'Samsung', 1490000, 1390000,  680000, 20, 4.8,  77, 1, '2023-10-01'),
('애플 맥북 프로 16인치 M3',     16, 'Apple',   4290000, 4090000, 2200000, 18, 4.9,  55, 1, '2023-11-07'),
('로지텍 G Pro X Superlight 2', 15, 'Logitech',  199000,  179000,   65000,250, 4.8, 320, 1, '2023-09-01'),
('필립스 에어프라이어 XXL',      11, 'Philips',  189000,  159000,   68000, 85, 4.5, 430, 1, '2022-11-01'),
('닥터자르트 세라마이딘 크림',    12, 'Dr.Jart',  52000,   45000,   14000,400, 4.6, 750, 1, '2023-01-01'),
('아이더 경량패딩 W9000',         9, 'Eider',    259000,  229000,   95000, 60, 4.4, 140, 1, '2023-10-15');

-- ── 심화 주문 ──
INSERT INTO adv_orders (member_id, order_date, status, original_amount, coupon_discount, point_used, final_amount, coupon_id, payment_method) VALUES
(1,  '2024-01-15 10:30:00', 'delivered',   29900,     0,    0,   29900, NULL,  'card'),
(2,  '2024-01-20 11:00:00', 'delivered',  189000,  3000,    0,  186000,    2,  'card'),
(3,  '2024-02-05 09:30:00', 'delivered', 1549000,     0,    0, 1549000, NULL,  'card'),
(4,  '2024-02-10 14:00:00', 'delivered',  349000, 52350, 2000,  294650,    3,  'mixed'),
(3,  '2024-02-20 15:00:00', 'delivered',  189000,  3000,    0,  186000, NULL,  'card'),
(3,  '2024-03-01 10:30:00', 'delivered',  199000, 13930,    0,  185070,    5,  'card'),
(5,  '2024-03-10 12:00:00', 'delivered',   59000,  3000,    0,   56000,    6,  'card'),
(8,  '2024-03-15 16:00:00', 'delivered', 4090000,613500, 3000, 3473500,    7,  'mixed'),
(8,  '2024-04-01 09:00:00', 'shipping',   169000,     0,  3000,  166000, NULL,  'mixed'),
(12, '2024-04-05 10:00:00', 'delivered', 1799000,269850,    0, 1529150,   12,  'card'),
(6,  '2024-05-01 11:00:00', 'delivered',   49000,     0,    0,   49000, NULL,  'card'),
(9,  '2024-05-10 13:00:00', 'delivered',  109000,  5000,    0,  104000,    9,  'card'),
(1,  '2024-05-20 14:00:00', 'delivered',   25900,     0,    0,   25900, NULL,  'card'),
(7,  '2024-06-01 09:30:00', 'paid',        45000,     0,    0,   45000, NULL, 'transfer'),
(2,  '2024-06-05 16:00:00', 'pending',   1690000,     0,    0, 1690000, NULL,  'card'),
(4,  '2024-06-10 12:00:00', 'delivered',  189000,     0,    0,  189000, NULL,  'card'),
(13, '2024-06-12 10:00:00', 'delivered',  790000,     0,    0,  790000, NULL,  'card'),
(3,  '2024-06-15 14:30:00', 'cancelled',  229000,     0,    0,  229000, NULL,  'card'),
(12, '2024-06-18 11:00:00', 'delivered', 1390000,     0,    0, 1390000, NULL,  'card'),
(8,  '2024-06-20 09:00:00', 'delivered',  179000,     0,    0,  179000, NULL,  'card'),
(4,  '2024-06-22 15:00:00', 'delivered',  169000,     0,    0,  169000, NULL,  'card'),
(9,  '2024-06-25 10:30:00', 'refunded',   59900,      0,    0,   59900, NULL,  'card'),
(11, '2024-06-26 14:00:00', 'pending',    52000,      0,    0,   52000, NULL,  'card'),
(14, '2024-06-28 16:30:00', 'paid',       349000,     0,    0,  349000, NULL,  'card');

-- ── 심화 주문 상세 ──
INSERT INTO adv_order_items (order_id, product_id, quantity, unit_price, cost_price, discount_amt) VALUES
(1,  9,  1,  25900,  9000,    0),
(2,  7,  1, 169000, 72000, 3000),
(3,  3,  1,1549000,820000,    0),
(4,  5,  1, 349000,160000,52350),
(5,  7,  1, 169000, 72000, 3000),
(5,  6,  1, 189000, 85000,    0),  -- 주문 5 두번째 아이템 (실제 total과 맞춤)
(6, 14,  1, 199000, 88000,13930),
(7, 12,  1,  49000, 18000, 3000),
(8, 16,  1,4090000,2200000,613500),
(9,  1,  1,1690000,980000,    0),  -- 주문9: 배송중
(10, 4,  1,1799000,950000,269850),
(11,12,  1,  49000, 18000,    0),
(12,11,  1, 109000, 45000, 5000),
(13,10,  1,  59900, 22000,    0),
(14,19,  1,  45000, 14000,    0),
(15, 2,  1,1690000,1000000,   0),
(16, 7,  1, 169000, 72000,    0),
(16, 6,  1, 189000, 85000,    0),  -- 주문 16 두번째
(17,13,  1, 790000,350000,    0),
(18,20,  1, 229000, 95000,    0),  -- 취소
(19,15,  1,1390000,680000,    0),
(20,17,  1, 179000, 65000,    0),
(21, 8,  1, 169000, 82000,    0),
(22, 9,  1,  59900, 22000,    0),  -- 환불
(23,19,  1,  52000, 14000,    0),
(24, 5,  1, 349000,160000,    0);

-- ── 배송 ──
INSERT INTO deliveries (order_id, carrier, tracking_no, shipped_at, delivered_at, delivery_status, delivery_fee) VALUES
(1,  'CJ대한통운', 'CJ20240115001', '2024-01-16 08:00:00', '2024-01-17 14:30:00', 'delivered',  3000),
(2,  'CJ대한통운', 'CJ20240120001', '2024-01-21 09:00:00', '2024-01-22 16:00:00', 'delivered',     0),
(3,  '롯데택배',   'LT20240205001', '2024-02-06 10:00:00', '2024-02-07 13:30:00', 'delivered',     0),
(4,  '한진택배',   'HJ20240210001', '2024-02-11 08:30:00', '2024-02-12 15:00:00', 'delivered',     0),
(5,  'CJ대한통운', 'CJ20240220001', '2024-02-21 09:00:00', '2024-02-22 12:00:00', 'delivered',  3000),
(6,  '롯데택배',   'LT20240301001', '2024-03-02 10:00:00', '2024-03-04 16:30:00', 'delivered',  3000),
(7,  'CJ대한통운', 'CJ20240310001', '2024-03-11 08:00:00', '2024-03-12 11:00:00', 'delivered',  3000),
(8,  '한진택배',   'HJ20240315001', '2024-03-16 09:00:00', '2024-03-18 14:00:00', 'delivered',     0),
(9,  'CJ대한통운', 'CJ20240401001', '2024-04-02 08:00:00', NULL,                  'in_transit',    0),
(10, '롯데택배',   'LT20240405001', '2024-04-06 10:00:00', '2024-04-08 15:30:00', 'delivered',     0),
(11, 'CJ대한통운', 'CJ20240501001', '2024-05-02 08:00:00', '2024-05-03 13:00:00', 'delivered',  3000),
(12, '한진택배',   'HJ20240510001', '2024-05-11 09:00:00', '2024-05-13 16:00:00', 'delivered',  3000),
(13, '롯데택배',   'LT20240520001', '2024-05-21 10:00:00', '2024-05-22 14:30:00', 'delivered',  3000),
(16, 'CJ대한통운', 'CJ20240610001', '2024-06-11 09:00:00', '2024-06-12 15:00:00', 'delivered',  3000),
(17, '롯데택배',   'LT20240612001', '2024-06-13 10:00:00', '2024-06-14 16:00:00', 'delivered',     0),
(19, 'CJ대한통운', 'CJ20240618001', '2024-06-19 09:00:00', '2024-06-20 14:00:00', 'delivered',     0),
(20, '한진택배',   'HJ20240620001', '2024-06-21 08:00:00', '2024-06-22 11:00:00', 'delivered',  3000),
(21, 'CJ대한통운', 'CJ20240622001', '2024-06-23 09:00:00', '2024-06-24 15:00:00', 'delivered',  3000);

-- ── 리뷰 ──
INSERT INTO reviews (product_id, member_id, order_id, rating, content, is_best, created_at) VALUES
(9,  1,  1, 5, '가성비 최고! 소재도 좋고 핏도 편해요.',    1, '2024-01-18 10:00:00'),
(7,  2,  2, 4, '쿠션감 좋고 디자인 예쁜데 사이즈가 좀 커요.', 0, '2024-01-23 11:00:00'),
(3,  3,  3, 5, '카메라 성능 압도적입니다. 완전 만족!',      1, '2024-02-10 09:00:00'),
(5,  4,  4, 5, '노이즈 캔슬링 최강. 출퇴근 필수템.',        1, '2024-02-15 14:00:00'),
(7,  3,  5, 4, '이번엔 다른 사이즈로 샀는데 딱 맞아요.',    0, '2024-02-25 10:00:00'),
(14, 3,  6, 4, '등산화 밑창이 탄탄하고 발이 편해요.',       0, '2024-03-08 12:00:00'),
(12, 5,  7, 5, '오메가3 섭취 후 피부가 좋아진 것 같아요.',  1, '2024-03-15 09:00:00'),
(16, 8,  8, 5, 'M3 맥북 성능은 진짜 레전드...',             1, '2024-03-22 16:00:00'),
(4, 10,  3, 4, '아이폰 좋은데 가격이 너무 비싸요.',         0, '2024-02-12 10:00:00'),  -- order_id 3
(11,12, 12, 4, '에어프라이어 진짜 편해요. 기름 없이 바삭!', 1, '2024-05-16 13:00:00'),
(10, 1, 13, 3, '가격 대비 품질이 평범해요.',                0, '2024-05-24 10:00:00'),
(4, 12, 10, 5, '아이폰 최고! 역시 애플.',                   1, '2024-04-12 11:00:00'),
(15,12, 19, 5, '모니터 색감과 주사율 완벽합니다.',          1, '2024-06-24 15:00:00'),
(17, 8, 20, 4, '마우스 클릭감 좋고 가벼워요.',              0, '2024-06-25 10:00:00'),
(8,  4, 16, 5, '울트라부스트 발 편안함 최고!',              1, '2024-06-15 11:00:00');

-- ── 재고 변동 이력 ──
INSERT INTO stock_history (product_id, change_type, qty_change, qty_after, ref_order_id, created_at) VALUES
(9,  'out',    -1,  299, 1,  '2024-01-15 10:30:00'),
(7,  'out',    -1,   54, 2,  '2024-01-20 11:00:00'),
(3,  'out',    -1,   79, 3,  '2024-02-05 09:30:00'),
(5,  'out',    -1,  119, 4,  '2024-02-10 14:00:00'),
(7,  'out',    -1,   53, 5,  '2024-02-20 15:00:00'),
(6,  'out',    -1,  199, 5,  '2024-02-20 15:00:00'),
(14, 'out',    -1,   34, 6,  '2024-03-01 10:30:00'),
(12, 'out',    -1,  499, 7,  '2024-03-10 12:00:00'),
(16, 'out',    -1,   17, 8,  '2024-03-15 16:00:00'),
(1,  'out',    -1,   29, 9,  '2024-04-01 09:00:00'),
(4,  'out',    -1,   59, 10, '2024-04-05 10:00:00'),
(12, 'in',    200,  699, NULL,'2024-04-10 09:00:00'),  -- 재입고
(12, 'out',    -1,  698, 11, '2024-05-01 11:00:00'),
(11, 'out',    -1,   84, 12, '2024-05-10 13:00:00'),
(10, 'out',    -1,  149, 13, '2024-05-20 14:00:00'),
(19, 'out',    -1,  399, 14, '2024-06-01 09:30:00'),
(2,  'out',    -1,   44, 15, '2024-06-05 16:00:00'),
(7,  'out',    -1,   52, 16, '2024-06-10 12:00:00'),
(6,  'out',    -1,  198, 16, '2024-06-10 12:00:00'),
(13, 'out',    -1,   14, 17, '2024-06-12 10:00:00'),
(20, 'return', +1,   61, 18, '2024-06-20 10:00:00'),  -- 취소로 재고 복구
(15, 'out',    -1,   19, 19, '2024-06-18 11:00:00'),
(17, 'out',    -1,  249, 20, '2024-06-20 09:00:00'),
(8,  'out',    -1,   39, 21, '2024-06-22 15:00:00'),
(9,  'return', +1,  300, 22, '2024-06-27 10:00:00'),  -- 환불로 재고 복구
(19, 'out',    -1,  398, 23, '2024-06-26 14:00:00'),
(5,  'out',    -1,  118, 24, '2024-06-28 16:30:00'),
(3,  'in',     50,  129, NULL,'2024-06-01 09:00:00');  -- 재입고

-- ── 월별 매출 집계 ──
INSERT INTO monthly_sales (ym, cat_id, total_orders, total_revenue, total_cost, total_profit) VALUES
('2024-01', 10, 2,  355000,  153000,  202000),
('2024-01', 17, 1, 1549000,  820000,  729000),
('2024-02', 19, 1,  349000,  160000,  189000),
('2024-02', 10, 1,  199000,   88000,  111000),
('2024-03', 12, 1,   49000,   18000,   31000),
('2024-03', 16, 1, 4090000, 2200000, 1890000),
('2024-04', 15, 1, 1690000,  980000,  710000),
('2024-04', 18, 1, 1799000,  950000,  849000),
('2024-05', 12, 2,   98000,   36000,   62000),
('2024-05', 11, 1,  109000,   45000,   64000),
('2024-05',  9, 1,   59900,   22000,   37900),
('2024-06', 15, 1, 1390000,  680000,  710000),
('2024-06', 19, 2,   97000,   28000,   69000),
('2024-06', 13, 1,  790000,  350000,  440000),
('2024-06', 10, 1,  169000,   82000,   87000);
