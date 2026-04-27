-- ============================================================
-- SQL Playground - 심화 문제 데이터 (CH10 ~ CH16)
-- ============================================================

SET NAMES utf8mb4;

-- ───────────────────────────── 챕터 추가 ─────────────────────────────
INSERT INTO chapters (chapter_id, chapter_title, sort_order) VALUES
(10, '[심화] 다중 JOIN & 복합 조건',      10),
(11, '[심화] 윈도우 함수 심화',           11),
(12, '[심화] WITH (CTE) 심화',            12),
(13, '[심화] 서브쿼리 & EXISTS 심화',     13),
(14, '[심화] 날짜/문자열 함수 심화',      14),
(15, '[심화] 집계 & PIVOT 심화',          15),
(16, '[심화] 종합 실전 (복합 쿼리)',       16);

-- ================================================================
-- CH10: 다중 JOIN & 복합 조건
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(10, '회원 등급별 주문 현황 조회', 'medium', 'INNER JOIN × 3 + GROUP BY',
'members, member_grades, adv_orders를 JOIN하여<br>
등급명(grade_name)별 총 주문 건수(order_count)와 총 결제 금액(total_final)을 조회하세요.<br>
delivered 또는 shipped 상태인 주문만 포함하고, total_final 내림차순 정렬하세요.',
'FROM members m JOIN member_grades g ON m.grade_id = g.grade_id JOIN adv_orders o ON ... WHERE o.status IN (...)',
"SELECT g.grade_name,
       COUNT(o.order_id)      AS order_count,
       SUM(o.final_amount)    AS total_final
FROM members m
JOIN member_grades g ON m.grade_id = g.grade_id
JOIN adv_orders    o ON m.member_id  = o.member_id
WHERE o.status IN ('delivered','shipping')
GROUP BY g.grade_name
ORDER BY total_final DESC",
'3개 테이블 INNER JOIN 후 GROUP BY로 집계합니다.<br>
<strong>WHERE절에서 상태 필터</strong>를 먼저 적용해 불필요한 행을 줄이면 성능이 좋아집니다.<br>
실무에서 "등급별 매출 현황" 같은 대시보드 쿼리의 기본 패턴입니다.',
1),

-- 문제 2
(10, '쿠폰 사용 현황 - LEFT JOIN 분석', 'medium', 'LEFT JOIN + CASE WHEN + GROUP BY',
'coupon_policies와 issued_coupons를 JOIN하여 정책별 발급 수(issued_cnt), 사용 수(used_cnt), 미사용 수(unused_cnt)를 조회하세요.<br>
비활성 정책도 포함하고, 발급 수 내림차순으로 정렬하세요.',
'LEFT JOIN issued_coupons ic ON cp.policy_id = ic.policy_id, SUM(CASE WHEN ic.used_at IS NOT NULL THEN 1 ELSE 0 END)',
"SELECT cp.policy_name,
       COUNT(ic.coupon_id)                                             AS issued_cnt,
       SUM(CASE WHEN ic.used_at IS NOT NULL THEN 1 ELSE 0 END)        AS used_cnt,
       SUM(CASE WHEN ic.used_at IS NULL     THEN 1 ELSE 0 END)        AS unused_cnt
FROM coupon_policies cp
LEFT JOIN issued_coupons ic ON cp.policy_id = ic.policy_id
GROUP BY cp.policy_id, cp.policy_name
ORDER BY issued_cnt DESC",
'<strong>LEFT JOIN + CASE WHEN</strong> 조합은 "발급은 됐지만 사용되지 않은" 같은 NULL 분석에 매우 유용합니다.<br>
쿠폰/이벤트 효율 분석 시 실무에서 자주 등장하는 패턴입니다.',
2),

-- 문제 3
(10, '배송 지연 주문 분석', 'hard', 'JOIN + DATEDIFF + 조건 필터',
'adv_orders, members, deliveries를 JOIN하여<br>
배송 완료(delivered)된 주문 중 주문일로부터 배송 완료까지 <strong>3일 초과</strong>된 건을 조회하세요.<br>
결과: order_id, member_name, order_date(DATE 형식), delivered_at(DATE 형식), delivery_days(배송 소요일)<br>
delivery_days 내림차순 정렬.',
'DATEDIFF(d.delivered_at, o.order_date) > 3',
"SELECT o.order_id,
       m.member_name,
       DATE(o.order_date)                                AS order_date,
       DATE(d.delivered_at)                              AS delivered_at,
       DATEDIFF(d.delivered_at, o.order_date)            AS delivery_days
FROM adv_orders o
JOIN members    m ON o.member_id  = m.member_id
JOIN deliveries d ON o.order_id   = d.order_id
WHERE d.delivery_status = 'delivered'
  AND DATEDIFF(d.delivered_at, o.order_date) > 3
ORDER BY delivery_days DESC",
'<strong>DATE(datetime)</strong>으로 날짜 부분만 추출할 수 있습니다.<br>
<strong>DATEDIFF</strong>는 두 날짜(또는 datetime)의 일수 차이를 반환합니다.<br>
WHERE절에서 계산 결과를 바로 조건으로 사용할 수 있습니다.',
3),

-- 문제 4
(10, '상품 카테고리 계층 JOIN', 'hard', 'Self JOIN (계층형 카테고리)',
'adv_categories 테이블을 Self JOIN하여<br>
depth=3인 소분류의 cat_name(small_cat), 부모(depth=2) cat_name(mid_cat), 최상위(depth=1) cat_name(top_cat)을 조회하세요.<br>
top_cat → mid_cat → small_cat 오름차순 정렬.',
'FROM adv_categories c3 JOIN adv_categories c2 ON c3.parent_id = c2.cat_id JOIN adv_categories c1 ON c2.parent_id = c1.cat_id WHERE c3.depth = 3',
"SELECT c1.cat_name AS top_cat,
       c2.cat_name AS mid_cat,
       c3.cat_name AS small_cat
FROM adv_categories c3
JOIN adv_categories c2 ON c3.parent_id = c2.cat_id
JOIN adv_categories c1 ON c2.parent_id = c1.cat_id
WHERE c3.depth = 3
ORDER BY top_cat, mid_cat, small_cat",
'<strong>Self JOIN</strong>은 같은 테이블을 여러 별칭으로 JOIN하는 기법입니다.<br>
계층형 데이터(카테고리, 조직도, 댓글 등)에서 부모-자식 관계를 펼칠 때 사용합니다.<br>
깊이가 고정된 경우 Self JOIN이 간단하며, 깊이가 가변적이면 재귀 CTE를 사용합니다.',
4),

-- 문제 5
(10, '리뷰 작성자 프로필 종합 조회', 'hard', '4테이블 JOIN + ROUND',
'reviews, members, member_grades, adv_products를 JOIN하여<br>
베스트 리뷰(is_best=1)의 다음 정보를 조회하세요:<br>
product_name, member_name, grade_name, rating, content(앞 20자만), created_at(DATE)<br>
rating 내림차순 → created_at 내림차순 정렬.',
'JOIN reviews rv → adv_products p → members m → member_grades g, LEFT(content,20)',
"SELECT p.product_name,
       m.member_name,
       g.grade_name,
       rv.rating,
       LEFT(rv.content, 20) AS content,
       DATE(rv.created_at)  AS created_at
FROM reviews rv
JOIN adv_products  p ON rv.product_id  = p.product_id
JOIN members       m ON rv.member_id   = m.member_id
JOIN member_grades g ON m.grade_id     = g.grade_id
WHERE rv.is_best = 1
ORDER BY rv.rating DESC, rv.created_at DESC",
'<strong>LEFT(문자열, n)</strong>으로 앞 n자만 추출할 수 있습니다.<br>
4개 테이블 JOIN도 구조는 동일합니다. JOIN 순서를 논리적으로 reviews → 상품 → 회원 → 등급 순으로 연결하세요.<br>
실무에서 "베스트 리뷰 목록" 같은 화면에 쓰이는 쿼리입니다.',
5);

-- ================================================================
-- CH11: 윈도우 함수 심화
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(11, '회원별 주문 금액 전월 대비 증감', 'hard', 'LAG() OVER',
'adv_orders에서 delivered 상태 주문을 기준으로<br>
회원 ID(member_id)별 · 월별(order_ym) 결제 금액 합계(monthly_amt)와<br>
전월 금액(prev_amt), 증감액(diff_amt)을 조회하세요.<br>
member_id 오름차순 → order_ym 오름차순 정렬.',
"DATE_FORMAT(order_date,'%Y-%m') AS order_ym, LAG(monthly_amt) OVER (PARTITION BY member_id ORDER BY order_ym)",
"SELECT member_id,
       DATE_FORMAT(order_date,'%Y-%m')                               AS order_ym,
       SUM(final_amount)                                              AS monthly_amt,
       LAG(SUM(final_amount)) OVER (
           PARTITION BY member_id
           ORDER BY DATE_FORMAT(order_date,'%Y-%m')
       )                                                              AS prev_amt,
       SUM(final_amount) - LAG(SUM(final_amount)) OVER (
           PARTITION BY member_id
           ORDER BY DATE_FORMAT(order_date,'%Y-%m')
       )                                                              AS diff_amt
FROM adv_orders
WHERE status = 'delivered'
GROUP BY member_id, DATE_FORMAT(order_date,'%Y-%m')
ORDER BY member_id, order_ym",
'<strong>LAG(값) OVER (PARTITION BY ... ORDER BY ...)</strong>는 현재 행보다 n행 이전 값을 가져옵니다.<br>
반대로 <strong>LEAD()</strong>는 이후 행 값을 가져옵니다.<br>
GROUP BY 집계 후에도 윈도우 함수를 적용할 수 있습니다 — 집계된 값을 서브쿼리로 감싸거나 CTE로 분리하는 것이 더 명확합니다.',
1),

-- 문제 2
(11, '카테고리별 상품 가격 백분위 분류', 'hard', 'NTILE() OVER',
'adv_products(is_selling=1)를 대상으로<br>
cat_id별로 sale_price를 기준으로 4분위(NTILE)를 나누고<br>
product_name, cat_id, sale_price, price_tile(1~4)을 조회하세요.<br>
cat_id → price_tile → sale_price 오름차순 정렬.',
'NTILE(4) OVER (PARTITION BY cat_id ORDER BY sale_price)',
"SELECT product_name,
       cat_id,
       sale_price,
       NTILE(4) OVER (
           PARTITION BY cat_id
           ORDER BY sale_price
       ) AS price_tile
FROM adv_products
WHERE is_selling = 1
ORDER BY cat_id, price_tile, sale_price",
'<strong>NTILE(n)</strong>은 각 파티션을 n개의 동일 크기 그룹으로 나누어 번호를 부여합니다.<br>
NTILE(4)는 4분위(사분위수), NTILE(10)는 10분위(십분위수)로 쓸 수 있습니다.<br>
가격 분포, 성과 등급화 등 "상위 25%"같은 표현이 필요할 때 유용합니다.',
2),

-- 문제 3
(11, '상품별 리뷰 점수 이동 평균', 'hard', 'AVG OVER (ROWS BETWEEN)',
'reviews 테이블에서 product_id별로 created_at 오름차순 기준<br>
review_id, product_id, rating, 직전 2건 포함 현재까지의 이동평균(moving_avg_rating, 소수점 2자리)을 조회하세요.<br>
product_id → created_at 오름차순 정렬.',
'AVG(rating) OVER (PARTITION BY product_id ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)',
"SELECT review_id,
       product_id,
       rating,
       ROUND(
           AVG(rating) OVER (
               PARTITION BY product_id
               ORDER BY created_at
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ), 2
       ) AS moving_avg_rating
FROM reviews
ORDER BY product_id, created_at",
'<strong>ROWS BETWEEN n PRECEDING AND CURRENT ROW</strong>는 현재 행을 포함한 이전 n행의 프레임을 지정합니다.<br>
이동 평균(Moving Average), 이동 합계(Rolling Sum)에 활용됩니다.<br>
프레임 옵션: UNBOUNDED PRECEDING (처음부터), n PRECEDING (n행 전), CURRENT ROW, n FOLLOWING, UNBOUNDED FOLLOWING (끝까지)',
3),

-- 문제 4
(11, '주문 금액 상위 누적 비율(Running %)', 'hard', 'SUM OVER + 비율 계산',
'adv_orders에서 delivered 상태 주문을 final_amount 내림차순으로 나열하고<br>
order_id, member_id, final_amount, 누적합계(cum_amount), 누적비율%(cum_pct, 소수점 1자리)을 조회하세요.<br>
누적비율 = 현재까지 누적 금액 / 전체 합계 × 100<br>
final_amount 내림차순 정렬.',
'SUM(final_amount) OVER (ORDER BY final_amount DESC) / SUM(final_amount) OVER () * 100',
"SELECT order_id,
       member_id,
       final_amount,
       SUM(final_amount) OVER (ORDER BY final_amount DESC)             AS cum_amount,
       ROUND(
           SUM(final_amount) OVER (ORDER BY final_amount DESC)
           / SUM(final_amount) OVER ()
           * 100, 1
       )                                                               AS cum_pct
FROM adv_orders
WHERE status = 'delivered'
ORDER BY final_amount DESC",
'<strong>SUM(col) OVER ()</strong> — PARTITION/ORDER 없이 전체 합계를 구합니다.<br>
<strong>SUM(col) OVER (ORDER BY ...)</strong> — 현재 행까지 누적 합계.<br>
둘을 나누면 "전체 대비 누적 비율"이 됩니다. 파레토(80/20) 분석, 매출 누적 기여도 분석에 활용됩니다.',
4);

-- ================================================================
-- CH12: WITH (CTE) 심화
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(12, '회원 등급 업그레이드 대상 추출', 'hard', 'WITH + 집계 + 조건 비교',
'WITH를 사용하여<br>
① member_totals: 회원별 delivered 주문 총 결제액(total_paid)<br>
② 결과: total_paid가 현재 등급의 min_amount보다 높은 다음 등급이 존재하는 회원을 조회.<br>
결과: member_name, grade_name(현재), total_paid, next_grade(다음 등급명)<br>
total_paid 내림차순 정렬.<br>
<em>힌트: 다음 등급은 min_amount가 total_paid 이하인 등급 중 가장 높은 것으로 정의합니다.</em>',
'WITH member_totals AS (...), 그 후 member_grades를 JOIN하여 현재 등급 min_amount < next grade min_amount <= total_paid 조건',
"WITH member_totals AS (
    SELECT o.member_id,
           SUM(o.final_amount) AS total_paid
    FROM adv_orders o
    WHERE o.status = 'delivered'
    GROUP BY o.member_id
),
best_next AS (
    SELECT mt.member_id,
           mt.total_paid,
           MAX(g.min_amount) AS next_min
    FROM member_totals mt
    JOIN member_grades g
      ON g.min_amount <= mt.total_paid
    GROUP BY mt.member_id, mt.total_paid
)
SELECT m.member_name,
       cur_g.grade_name   AS grade_name,
       bn.total_paid,
       next_g.grade_name  AS next_grade
FROM best_next bn
JOIN members       m     ON bn.member_id   = m.member_id
JOIN member_grades cur_g ON m.grade_id     = cur_g.grade_id
JOIN member_grades next_g ON next_g.min_amount = bn.next_min
WHERE next_g.grade_id > cur_g.grade_id
ORDER BY bn.total_paid DESC",
'다중 CTE를 이용해 단계별로 데이터를 처리합니다.<br>
① 회원별 총 결제액 집계 → ② 적용 가능한 가장 높은 등급 기준 탐색 → ③ 현재 등급보다 높은 경우만 필터.<br>
이런 패턴은 실무에서 "등급 갱신 배치 쿼리"로 자주 사용됩니다.',
1),

-- 문제 2
(12, '재귀 CTE — 카테고리 전체 경로 생성', 'hard', 'Recursive CTE',
'재귀 CTE를 사용하여 adv_categories의 모든 카테고리에 대해<br>
cat_id, cat_name, 전체 경로(full_path: 예: "전자제품 > 노트북/PC > 게이밍노트북")를 조회하세요.<br>
cat_id 오름차순 정렬.',
'WITH RECURSIVE cat_path AS (SELECT cat_id, cat_name, cat_name AS full_path, parent_id FROM adv_categories WHERE parent_id IS NULL UNION ALL SELECT c.cat_id, c.cat_name, CONCAT(cp.full_path, '' > '', c.cat_name), c.parent_id FROM adv_categories c JOIN cat_path cp ON c.parent_id = cp.cat_id)',
"WITH RECURSIVE cat_path AS (
    SELECT cat_id,
           cat_name,
           cat_name       AS full_path,
           parent_id
    FROM adv_categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.cat_id,
           c.cat_name,
           CONCAT(cp.full_path, ' > ', c.cat_name) AS full_path,
           c.parent_id
    FROM adv_categories c
    JOIN cat_path cp ON c.parent_id = cp.cat_id
)
SELECT cat_id, cat_name, full_path
FROM cat_path
ORDER BY cat_id",
'<strong>WITH RECURSIVE</strong>는 자기 자신을 참조하는 재귀 CTE입니다.<br>
구조: <code>앵커(종료조건 행) UNION ALL 재귀(이전 결과 참조)</code><br>
계층형 데이터(카테고리 트리, 조직도, BOM 등)를 순회할 때 사용합니다.<br>
⚠️ 반드시 종료 조건(앵커)이 있어야 하며, 무한 루프를 방지해야 합니다.',
2),

-- 문제 3
(12, '월별 매출 YoY — 전년 동월 비교 CTE', 'hard', 'WITH + Self JOIN (월 비교)',
'monthly_sales 테이블을 활용하여<br>
WITH로 월별 전체 매출(ym, total_rev)을 집계한 뒤<br>
같은 달(MM)이지만 연도가 다른 행끼리 Self JOIN하여<br>
ym, total_rev, prev_year_rev(전년 동월), yoy_growth_pct(전년 대비 성장률%, 소수점 1자리)를 조회하세요.<br>
prev_year_rev가 NULL인 행은 제외하고 ym 오름차순 정렬.',
"WITH monthly AS (SELECT ym, SUM(total_revenue) AS total_rev FROM monthly_sales GROUP BY ym) SELECT cur.ym, cur.total_rev, prev.total_rev AS prev_year_rev, ROUND((cur.total_rev - prev.total_rev)/prev.total_rev*100,1) FROM monthly cur JOIN monthly prev ON SUBSTR(cur.ym,6,2)=SUBSTR(prev.ym,6,2) AND SUBSTR(cur.ym,1,4)=CAST(SUBSTR(prev.ym,1,4) AS UNSIGNED)+1",
"WITH monthly AS (
    SELECT ym,
           SUM(total_revenue) AS total_rev
    FROM monthly_sales
    GROUP BY ym
)
SELECT cur.ym,
       cur.total_rev,
       prev.total_rev                                                 AS prev_year_rev,
       ROUND((cur.total_rev - prev.total_rev) / prev.total_rev * 100, 1) AS yoy_growth_pct
FROM monthly cur
JOIN monthly prev
  ON SUBSTR(cur.ym, 6, 2) = SUBSTR(prev.ym, 6, 2)
 AND CAST(SUBSTR(cur.ym, 1, 4) AS UNSIGNED) = CAST(SUBSTR(prev.ym, 1, 4) AS UNSIGNED) + 1
WHERE prev.total_rev IS NOT NULL
ORDER BY cur.ym",
'CTE를 Self JOIN하면 같은 집계 결과를 두 번 계산하지 않고 재사용할 수 있습니다.<br>
<strong>YoY(Year-over-Year)</strong> 비교는 전년 동월과 비교하는 가장 일반적인 성장률 분석입니다.<br>
SUBSTR로 연도(1~4자리)와 월(6~7자리)을 분리해 같은 월끼리 JOIN합니다.',
3);

-- ================================================================
-- CH13: 서브쿼리 & EXISTS 심화
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(13, '각 카테고리에서 가장 많이 팔린 상품', 'hard', 'Correlated Subquery (상관 서브쿼리)',
'adv_order_items와 adv_orders(cancelled/refunded 제외), adv_products를 활용하여<br>
각 cat_id에서 판매 수량(total_qty) 기준으로 가장 많이 팔린 상품 1개씩 조회하세요.<br>
결과: cat_id, product_name, total_qty<br>
cat_id 오름차순 정렬.<br>
<em>단, 동일 수량이면 product_id가 작은 것 우선.</em>',
'WHERE total_qty = (SELECT MAX(...) FROM ... WHERE cat_id = outer.cat_id)',
"SELECT s.cat_id,
       p.product_name,
       s.total_qty
FROM (
    SELECT ap.cat_id,
           oi.product_id,
           SUM(oi.quantity) AS total_qty
    FROM adv_order_items oi
    JOIN adv_orders  ao ON oi.order_id  = ao.order_id
    JOIN adv_products ap ON oi.product_id = ap.product_id
    WHERE ao.status NOT IN ('cancelled','refunded')
    GROUP BY ap.cat_id, oi.product_id
) s
JOIN adv_products p ON s.product_id = p.product_id
WHERE s.total_qty = (
    SELECT MAX(s2.total_qty)
    FROM (
        SELECT ap2.cat_id,
               oi2.product_id,
               SUM(oi2.quantity) AS total_qty
        FROM adv_order_items oi2
        JOIN adv_orders  ao2 ON oi2.order_id  = ao2.order_id
        JOIN adv_products ap2 ON oi2.product_id = ap2.product_id
        WHERE ao2.status NOT IN ('cancelled','refunded')
        GROUP BY ap2.cat_id, oi2.product_id
    ) s2
    WHERE s2.cat_id = s.cat_id
)
ORDER BY s.cat_id, s.product_id",
'<strong>상관 서브쿼리(Correlated Subquery)</strong>는 외부 쿼리의 값을 참조하는 서브쿼리입니다.<br>
"각 그룹에서 최댓값과 같은 행"을 찾는 패턴은 매우 자주 사용됩니다.<br>
성능상 WITH + ROW_NUMBER() 패턴이 더 효율적이지만, 서브쿼리로도 표현할 수 있습니다.',
1),

-- 문제 2
(13, '쿠폰을 한 번도 사용하지 않은 회원', 'medium', 'NOT EXISTS',
'쿠폰을 발급받았지만 한 번도 사용하지 않은 회원의<br>
member_name, email, grade_name을 조회하세요.<br>
member_name 오름차순 정렬.',
'WHERE EXISTS (발급 쿠폰) AND NOT EXISTS (사용된 쿠폰)',
"SELECT m.member_name,
       m.email,
       g.grade_name
FROM members m
JOIN member_grades g ON m.grade_id = g.grade_id
WHERE EXISTS (
    SELECT 1 FROM issued_coupons ic
    WHERE ic.member_id = m.member_id
)
AND NOT EXISTS (
    SELECT 1 FROM issued_coupons ic2
    WHERE ic2.member_id = m.member_id
      AND ic2.used_at IS NOT NULL
)
ORDER BY m.member_name",
'<strong>NOT EXISTS</strong>는 서브쿼리 결과가 0건일 때 TRUE입니다.<br>
EXISTS + NOT EXISTS 조합으로 "A는 있지만 B는 없는" 패턴을 깔끔하게 표현할 수 있습니다.<br>
NOT IN과 달리 NULL 값이 있어도 안전하게 동작합니다.',
2),

-- 문제 3
(13, '평균 리뷰 점수보다 높은 리뷰를 가진 상품', 'hard', 'ALL / 스칼라 서브쿼리 응용',
'adv_products 중 해당 상품의 rating_avg가<br>
① 동일 cat_id 내 다른 상품들의 평균 rating_avg보다 높고<br>
② 전체 상품 rating_avg(3.0 이상인 상품만 포함) 평균보다도 높은 상품을 조회하세요.<br>
결과: product_name, cat_id, rating_avg<br>
rating_avg 내림차순 정렬.',
'WHERE rating_avg > (SELECT AVG(rating_avg) FROM adv_products WHERE cat_id = ap.cat_id AND product_id != ap.product_id) AND rating_avg > (SELECT AVG(rating_avg) FROM adv_products WHERE rating_avg >= 3.0)',
"SELECT product_name,
       cat_id,
       rating_avg
FROM adv_products ap
WHERE rating_avg > (
    SELECT AVG(rating_avg)
    FROM adv_products
    WHERE cat_id = ap.cat_id
      AND product_id != ap.product_id
)
AND rating_avg > (
    SELECT AVG(rating_avg)
    FROM adv_products
    WHERE rating_avg >= 3.0
)
ORDER BY rating_avg DESC",
'두 개의 상관/비상관 서브쿼리를 AND로 결합합니다.<br>
첫 번째는 외부 쿼리를 참조하는 <strong>상관 서브쿼리</strong>, 두 번째는 독립적인 <strong>비상관 서브쿼리</strong>입니다.<br>
이 패턴으로 "같은 그룹 평균보다 높고, 전체 평균보다도 높은" 조건을 간결하게 표현합니다.',
3),

-- 문제 4
(13, '포인트 잔액 계산 — 집계 서브쿼리', 'hard', 'GROUP BY 서브쿼리 + HAVING',
'point_history에서 회원별 포인트 잔액(earn의 합 + use/expire의 합, 즉 전체 point_amt 합계)을 계산하여<br>
잔액이 1,000포인트 이상인 회원의 member_name, email, balance를 조회하세요.<br>
balance 내림차순 정렬.',
'SELECT member_id, SUM(point_amt) AS balance FROM point_history GROUP BY member_id HAVING balance >= 1000',
"SELECT m.member_name,
       m.email,
       ph.balance
FROM members m
JOIN (
    SELECT member_id,
           SUM(point_amt) AS balance
    FROM point_history
    GROUP BY member_id
    HAVING SUM(point_amt) >= 1000
) ph ON m.member_id = ph.member_id
ORDER BY ph.balance DESC",
'FROM 절 서브쿼리(인라인 뷰)는 집계 결과를 테이블처럼 활용합니다.<br>
HAVING에서 집계 조건을 걸고, 외부에서 JOIN으로 나머지 정보를 붙이는 패턴입니다.<br>
WITH(CTE)로 동일하게 표현할 수도 있습니다.',
4);

-- ================================================================
-- CH14: 날짜 / 문자열 함수 심화
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(14, '월별 신규 가입 회원 집계', 'medium', 'DATE_FORMAT + GROUP BY + 누적합',
'members 테이블에서 is_active=1인 회원의<br>
가입 월(join_ym), 해당 월 신규 가입 수(new_cnt), 누적 가입 수(cum_cnt)를 조회하세요.<br>
join_ym 오름차순 정렬.',
"DATE_FORMAT(join_date,'%Y-%m'), SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(join_date,'%Y-%m'))",
"SELECT DATE_FORMAT(join_date, '%Y-%m')                             AS join_ym,
       COUNT(*)                                                      AS new_cnt,
       SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(join_date, '%Y-%m')) AS cum_cnt
FROM members
WHERE is_active = 1
GROUP BY DATE_FORMAT(join_date, '%Y-%m')
ORDER BY join_ym",
'<strong>SUM(COUNT(*)) OVER (ORDER BY ...)</strong>는 GROUP BY 이후 집계 결과에 윈도우 함수를 적용하는 패턴입니다.<br>
GROUP BY로 월별 카운트를 구하고, 윈도우 함수로 누적합을 냅니다.<br>
<strong>DATE_FORMAT(date, format)</strong>: %Y=4자리연도, %m=2자리월, %d=일',
1),

-- 문제 2
(14, '이메일 도메인별 회원 분포', 'medium', 'SUBSTRING_INDEX + GROUP BY',
'members 테이블에서 이메일 도메인(@ 이후)별 회원 수(cnt)를 조회하세요.<br>
cnt 내림차순 정렬.',
"SUBSTRING_INDEX(email,'@',-1) AS domain",
"SELECT SUBSTRING_INDEX(email, '@', -1)  AS domain,
       COUNT(*)                           AS cnt
FROM members
GROUP BY SUBSTRING_INDEX(email, '@', -1)
ORDER BY cnt DESC",
'<strong>SUBSTRING_INDEX(문자열, 구분자, n)</strong><br>
n > 0: 구분자 기준 왼쪽에서 n번째까지<br>
n < 0: 구분자 기준 오른쪽에서 |n|번째까지<br>
예: SUBSTRING_INDEX(''user@gmail.com'', ''@'', -1) → ''gmail.com''',
2),

-- 문제 3
(14, '주문 후 배송까지 시간 분석', 'hard', 'TIMESTAMPDIFF + CASE WHEN',
'adv_orders와 deliveries를 JOIN하여 shipped(배송 시작)된 주문에 대해<br>
주문 생성부터 발송까지의 시간(hours)을 계산하고<br>
처리 속도 등급(speed_grade)을 부여하세요:<br>
- 24시간 이하: "당일처리"<br>
- 48시간 이하: "익일처리"<br>
- 그 외: "지연처리"<br>
결과: order_id, order_date(datetime), shipped_at, process_hours, speed_grade<br>
process_hours 오름차순 정렬.',
'TIMESTAMPDIFF(HOUR, o.order_date, d.shipped_at)',
"SELECT o.order_id,
       o.order_date,
       d.shipped_at,
       TIMESTAMPDIFF(HOUR, o.order_date, d.shipped_at)  AS process_hours,
       CASE
           WHEN TIMESTAMPDIFF(HOUR, o.order_date, d.shipped_at) <= 24 THEN '당일처리'
           WHEN TIMESTAMPDIFF(HOUR, o.order_date, d.shipped_at) <= 48 THEN '익일처리'
           ELSE '지연처리'
       END                                               AS speed_grade
FROM adv_orders o
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.shipped_at IS NOT NULL
ORDER BY process_hours",
'<strong>TIMESTAMPDIFF(단위, 시작, 끝)</strong>은 두 datetime 사이의 차이를 지정 단위로 반환합니다.<br>
단위: SECOND, MINUTE, HOUR, DAY, MONTH, YEAR<br>
DATEDIFF는 날짜 단위만 가능하지만, TIMESTAMPDIFF는 시/분/초 단위까지 정밀하게 계산합니다.',
3),

-- 문제 4
(14, '리뷰 텍스트 길이 분석 및 등급', 'medium', 'CHAR_LENGTH + CONCAT + LPAD',
'reviews 테이블에서 content가 NULL이 아닌 리뷰에 대해<br>
review_id, 내용 길이(content_len), 앞 15자(preview), 별점 시각화(star_visual: ★ 반복)를 조회하세요.<br>
content_len 내림차순 → review_id 오름차순 정렬.',
"CHAR_LENGTH(content), LEFT(content,15), REPEAT('★', rating)",
"SELECT review_id,
       CHAR_LENGTH(content)            AS content_len,
       LEFT(content, 15)               AS preview,
       REPEAT('★', rating)            AS star_visual
FROM reviews
WHERE content IS NOT NULL
ORDER BY content_len DESC, review_id",
'<strong>CHAR_LENGTH(s)</strong>: 문자 수 반환 (멀티바이트 고려, 한글도 1자로 계산)<br>
<strong>REPEAT(s, n)</strong>: 문자열 s를 n번 반복<br>
<strong>LEFT(s, n)</strong>: 앞 n자 추출<br>
이 함수들을 조합하면 텍스트 길이 분석, 미리보기 텍스트 생성 등을 SQL로 처리할 수 있습니다.',
4);

-- ================================================================
-- CH15: 집계 & PIVOT 심화
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(15, '결제 수단별 × 주문 상태별 PIVOT', 'hard', 'CASE WHEN PIVOT (이중 분류)',
'adv_orders에서 결제 수단(payment_method)을 행, 주문 상태(status)를 열로 하는 피벗 테이블을 만드세요.<br>
컬럼: payment_method, delivered_cnt, shipping_cnt, pending_cnt, paid_cnt, cancelled_cnt, refunded_cnt<br>
payment_method 오름차순 정렬.',
"SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END) AS delivered_cnt",
"SELECT payment_method,
       SUM(CASE WHEN status = 'delivered'  THEN 1 ELSE 0 END) AS delivered_cnt,
       SUM(CASE WHEN status = 'shipping'   THEN 1 ELSE 0 END) AS shipping_cnt,
       SUM(CASE WHEN status = 'pending'    THEN 1 ELSE 0 END) AS pending_cnt,
       SUM(CASE WHEN status = 'paid'       THEN 1 ELSE 0 END) AS paid_cnt,
       SUM(CASE WHEN status = 'cancelled'  THEN 1 ELSE 0 END) AS cancelled_cnt,
       SUM(CASE WHEN status = 'refunded'   THEN 1 ELSE 0 END) AS refunded_cnt
FROM adv_orders
GROUP BY payment_method
ORDER BY payment_method",
'행을 열로 변환하는 <strong>PIVOT</strong>은 MySQL에서 CASE WHEN + SUM/COUNT로 구현합니다.<br>
행 분류(GROUP BY)와 열 분류(CASE WHEN)을 조합하면 2차원 집계 표를 만들 수 있습니다.<br>
실무에서 대시보드, 교차 분석 리포트에 자주 사용됩니다.',
1),

-- 문제 2
(15, '상품별 원가율 및 마진 분석', 'hard', 'GROUP BY + 계산 컬럼 + HAVING',
'adv_order_items와 adv_orders(cancelled/refunded 제외), adv_products를 JOIN하여<br>
상품별 총 매출(total_revenue), 총 원가(total_cost), 마진(margin), 마진율%(margin_pct, 소수점 1자리)을 조회하세요.<br>
마진율이 30% 이상인 상품만 포함하고, margin_pct 내림차순 정렬.',
'SUM(oi.unit_price * oi.quantity), SUM(oi.cost_price * oi.quantity), HAVING ROUND(margin/revenue*100,1) >= 30',
"SELECT p.product_name,
       SUM(oi.unit_price  * oi.quantity) AS total_revenue,
       SUM(oi.cost_price  * oi.quantity) AS total_cost,
       SUM(oi.unit_price  * oi.quantity)
       - SUM(oi.cost_price * oi.quantity)  AS margin,
       ROUND(
           (SUM(oi.unit_price  * oi.quantity)
            - SUM(oi.cost_price * oi.quantity))
           / SUM(oi.unit_price * oi.quantity) * 100, 1
       )                                   AS margin_pct
FROM adv_order_items oi
JOIN adv_orders    ao ON oi.order_id   = ao.order_id
JOIN adv_products   p ON oi.product_id = p.product_id
WHERE ao.status NOT IN ('cancelled','refunded')
GROUP BY p.product_id, p.product_name
HAVING ROUND(
    (SUM(oi.unit_price * oi.quantity) - SUM(oi.cost_price * oi.quantity))
    / SUM(oi.unit_price * oi.quantity) * 100, 1
) >= 30
ORDER BY margin_pct DESC",
'HAVING 절에서 집계 함수를 직접 사용하거나 계산식을 반복할 수 있습니다.<br>
<strong>마진율 = (매출 - 원가) / 매출 × 100</strong>은 실무 분석의 기본 KPI입니다.<br>
컬럼 별칭(margin_pct)은 HAVING에서 직접 사용할 수 없으므로 식을 반복하거나 서브쿼리/CTE로 감쌉니다.',
2),

-- 문제 3
(15, '월별 카테고리 매출 비중 (WITH + 윈도우)', 'hard', 'WITH + SUM OVER + 비율',
'monthly_sales에서 2024년 데이터를 기준으로<br>
월(ym)별 전체 매출(monthly_total) 대비 각 카테고리(cat_id)의 매출 비중(share_pct, 소수점 1자리)을 조회하세요.<br>
결과: ym, cat_id, total_revenue, monthly_total, share_pct<br>
ym → share_pct 내림차순 정렬.',
"SUM(total_revenue) OVER (PARTITION BY ym) AS monthly_total, ROUND(total_revenue / SUM(total_revenue) OVER (PARTITION BY ym) * 100, 1)",
"SELECT ym,
       cat_id,
       total_revenue,
       SUM(total_revenue) OVER (PARTITION BY ym)        AS monthly_total,
       ROUND(
           total_revenue
           / SUM(total_revenue) OVER (PARTITION BY ym) * 100, 1
       )                                                  AS share_pct
FROM monthly_sales
WHERE ym LIKE '2024%'
ORDER BY ym, share_pct DESC",
'<strong>SUM() OVER (PARTITION BY ym)</strong>은 월별 전체 합계를 각 행에 붙입니다.<br>
이를 분모로 활용해 "전체 대비 비중"을 계산합니다.<br>
GROUP BY 없이 원래 행을 유지하면서 비중을 계산할 수 있는 것이 윈도우 함수의 강점입니다.',
3);

-- ================================================================
-- CH16: 종합 실전 (복합 쿼리)
-- ================================================================
INSERT INTO problems (chapter_id, title, difficulty, concept, description, hint, answer_sql, concept_explain, sort_order) VALUES

-- 문제 1
(16, 'VIP 회원 쿠폰 ROI 분석', 'hard', 'WITH + 다중 JOIN + 집계',
'WITH를 활용하여 grade_name이 VIP 또는 GOLD인 회원의 쿠폰 사용 효과를 분석하세요.<br>
결과: member_name, grade_name, 총 주문 수(order_cnt), 총 결제액(total_final), 총 쿠폰 할인액(total_discount), 할인율%(discount_rate, 소수점 1자리)<br>
total_final 내림차순 정렬. (주문이 없는 회원 제외)',
'WITH vip_members AS (... WHERE grade IN (VIP,GOLD)) → JOIN adv_orders → GROUP BY',
"WITH vip_members AS (
    SELECT m.member_id, m.member_name, g.grade_name
    FROM members m
    JOIN member_grades g ON m.grade_id = g.grade_id
    WHERE g.grade_name IN ('VIP','GOLD')
)
SELECT vm.member_name,
       vm.grade_name,
       COUNT(o.order_id)             AS order_cnt,
       SUM(o.final_amount)           AS total_final,
       SUM(o.coupon_discount)        AS total_discount,
       ROUND(
           SUM(o.coupon_discount)
           / (SUM(o.final_amount) + SUM(o.coupon_discount)) * 100, 1
       )                             AS discount_rate
FROM vip_members vm
JOIN adv_orders o ON vm.member_id = o.member_id
WHERE o.status NOT IN ('cancelled','refunded')
GROUP BY vm.member_id, vm.member_name, vm.grade_name
ORDER BY total_final DESC",
'CTE로 대상 회원을 먼저 필터링하면 이후 JOIN 비용이 줄어 성능이 좋아집니다.<br>
<strong>할인율 = 총 쿠폰 할인 / (실결제액 + 쿠폰 할인) × 100</strong> — 분모에 원래 금액을 복원해야 정확한 비율이 나옵니다.<br>
쿠폰 ROI 분석, 프로모션 효율 측정에 자주 쓰이는 패턴입니다.',
1),

-- 문제 2
(16, '재고 부족 임박 상품 알림 쿼리', 'hard', 'WITH + 윈도우 + 복합 조건',
'WITH를 사용하여 다음 조건을 만족하는 상품을 조회하세요:<br>
① is_selling=1인 상품 중 stock_qty가 30 이하<br>
② 최근 30일(2024-07-01 기준) 내 판매 수량(recent_sold)이 1개 이상<br>
결과: product_name, cat_id, stock_qty, recent_sold, est_days_left(재고 소진 예상일수 = stock_qty / (recent_sold/30.0), 정수 내림)<br>
est_days_left 오름차순 정렬.',
"WITH recent_sales AS (SELECT product_id, SUM(quantity) AS recent_sold FROM adv_order_items oi JOIN adv_orders ao ON ... WHERE order_date >= '2024-06-01' GROUP BY product_id)",
"WITH recent_sales AS (
    SELECT oi.product_id,
           SUM(oi.quantity) AS recent_sold
    FROM adv_order_items oi
    JOIN adv_orders ao ON oi.order_id = ao.order_id
    WHERE ao.order_date >= '2024-06-01'
      AND ao.status NOT IN ('cancelled','refunded')
    GROUP BY oi.product_id
)
SELECT p.product_name,
       p.cat_id,
       p.stock_qty,
       rs.recent_sold,
       FLOOR(p.stock_qty / (rs.recent_sold / 30.0)) AS est_days_left
FROM adv_products p
JOIN recent_sales rs ON p.product_id = rs.product_id
WHERE p.is_selling = 1
  AND p.stock_qty  <= 30
  AND rs.recent_sold >= 1
ORDER BY est_days_left",
'재고 관리에서 "소진 예상일" 계산은 실무에서 자주 사용됩니다.<br>
<strong>FLOOR()</strong>는 소수점 이하를 버림합니다. <strong>CEIL()</strong>은 올림.<br>
CTE로 최근 판매량을 먼저 집계하고, 메인 쿼리에서 재고 조건과 결합하는 패턴입니다.',
2),

-- 문제 3
(16, '회원별 첫/마지막 주문 및 구매 주기 분석', 'hard', 'WITH + MIN/MAX + DATEDIFF + 윈도우',
'delivered 상태 주문을 기준으로 2회 이상 주문한 회원의 다음을 조회하세요:<br>
member_name, grade_name, first_order_date, last_order_date, order_cnt(주문 수), avg_interval_days(평균 구매 주기, 정수 반올림)<br>
avg_interval_days = (마지막 주문일 - 첫 주문일) / (주문 수 - 1)<br>
avg_interval_days 오름차순 정렬.',
'MIN(DATE(order_date)), MAX(DATE(order_date)), ROUND(DATEDIFF(last,first)/(cnt-1))',
"SELECT m.member_name,
       g.grade_name,
       MIN(DATE(o.order_date))                                          AS first_order_date,
       MAX(DATE(o.order_date))                                          AS last_order_date,
       COUNT(o.order_id)                                                AS order_cnt,
       ROUND(
           DATEDIFF(MAX(o.order_date), MIN(o.order_date))
           / (COUNT(o.order_id) - 1)
       )                                                                AS avg_interval_days
FROM adv_orders o
JOIN members       m ON o.member_id = m.member_id
JOIN member_grades g ON m.grade_id  = g.grade_id
WHERE o.status = 'delivered'
GROUP BY o.member_id, m.member_name, g.grade_name
HAVING COUNT(o.order_id) >= 2
ORDER BY avg_interval_days",
'<strong>평균 구매 주기</strong>는 리텐션 분석의 핵심 지표입니다.<br>
(마지막-처음) / (주문수-1) 공식으로 평균 간격을 계산합니다.<br>
HAVING에서 COUNT 조건을 걸어 2회 이상만 필터링합니다.',
3),

-- 문제 4
(16, '상품 종합 성과 스코어카드', 'hard', 'WITH + 다중 집계 + RANK + CASE WHEN',
'WITH를 활용해 상품별 종합 성과를 분석하세요.<br>
① 판매 실적(sales_info): 상품별 총 판매 수량, 총 매출액 (cancelled/refunded 제외)<br>
② 리뷰 실적(review_info): 상품별 리뷰 수, 평균 별점<br>
최종 결과: product_name, total_qty, total_revenue, review_count, avg_rating,<br>
revenue_rank(매출 순위), performance(등급: 매출 TOP3 이면서 평균별점 4.5 이상 → "S", 매출 TOP5 → "A", 그 외 → "B")<br>
revenue_rank 오름차순 정렬.',
'WITH sales_info AS (...), review_info AS (...) SELECT ... RANK() OVER (ORDER BY total_revenue DESC) ... CASE WHEN rank<=3 AND avg_rating>=4.5 THEN S ...',
"WITH sales_info AS (
    SELECT oi.product_id,
           SUM(oi.quantity)              AS total_qty,
           SUM(oi.unit_price*oi.quantity) AS total_revenue
    FROM adv_order_items oi
    JOIN adv_orders ao ON oi.order_id = ao.order_id
    WHERE ao.status NOT IN ('cancelled','refunded')
    GROUP BY oi.product_id
),
review_info AS (
    SELECT product_id,
           COUNT(*)       AS review_count,
           ROUND(AVG(rating),2) AS avg_rating
    FROM reviews
    GROUP BY product_id
),
ranked AS (
    SELECT p.product_name,
           si.total_qty,
           si.total_revenue,
           COALESCE(ri.review_count, 0) AS review_count,
           COALESCE(ri.avg_rating, 0)   AS avg_rating,
           RANK() OVER (ORDER BY si.total_revenue DESC) AS revenue_rank
    FROM sales_info si
    JOIN adv_products p  ON si.product_id = p.product_id
    LEFT JOIN review_info ri ON si.product_id = ri.product_id
)
SELECT product_name,
       total_qty,
       total_revenue,
       review_count,
       avg_rating,
       revenue_rank,
       CASE
           WHEN revenue_rank <= 3 AND avg_rating >= 4.5 THEN 'S'
           WHEN revenue_rank <= 5                       THEN 'A'
           ELSE 'B'
       END AS performance
FROM ranked
ORDER BY revenue_rank",
'여러 CTE로 관심사를 분리(판매 / 리뷰)하고 마지막에 합치는 패턴입니다.<br>
<strong>COALESCE(값, 기본값)</strong>은 NULL을 대체합니다. 리뷰가 없는 상품도 표시되도록 LEFT JOIN 사용.<br>
윈도우 함수(RANK)와 CASE WHEN을 결합해 종합 등급을 산출하는 실무 스코어카드 패턴입니다.',
4);
