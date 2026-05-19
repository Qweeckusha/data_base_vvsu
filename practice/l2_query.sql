
-- Задание 3

SELECT c.name AS Компания
FROM Клиенты c
JOIN Договоры contracts ON c.id = contracts.Клиенты_id
JOIN Заказы orders ON contracts.id = orders.Договоры_id
WHERE contracts.дата_заключения >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.id, c.name
HAVING COUNT(orders.id) >= 3;

-- Задание 4

SELECT AVG(cnt) AS Среднее_заказов_на_договор
FROM (
    SELECT COUNT(z.id) AS cnt
    FROM Договоры d
    LEFT JOIN Заказы z ON d.id = z.Договоры_id -- Именно LEFT JOIN поможет нам учесть даже те договоры, на которые не было заказов (это 5 договор в наших данных)
    GROUP BY d.id
) AS buffer;

-- Задание 5

SELECT 
    id AS Номер_заказа,
    дата_создания,
    дата_выполнения
FROM Заказы
WHERE дата_выполнения IS NULL 
   OR дата_выполнения > CURDATE();

-- Задание 6

SELECT 
    id AS Номер_заказа,
    дата_создания,
    Статус
FROM Заказы
WHERE Статус = 'Не отправлено';

-- Задание 7

SELECT z.id AS Номер_заказа
FROM Заказы z
LEFT JOIN DeliveryInOrder d ON z.id = d.Заказы_id
WHERE d.id IS NULL;

-- Задание 8
-- 3 товара и 1 вид нанесения самые топовые
(
  SELECT t.name AS Наименование, SUM(k.Количество) AS Объем, 'Товар' AS Категория
  FROM Корзина k
  JOIN Товары t ON k.Товары_id = t.id
  GROUP BY t.id, t.name
  HAVING (
      SELECT COUNT(DISTINCT sub.cnt)
      FROM (
          SELECT SUM(Количество) AS cnt
          FROM Корзина k2
          JOIN Товары t2 ON k2.Товары_id = t2.id
          GROUP BY t2.id
      ) sub
      WHERE sub.cnt > SUM(k.Количество)
  ) < 3
)
UNION ALL
(
  SELECT v.name AS Наименование, SUM(k.Количество) AS Объем, 'Вид нанесения' AS Категория
  FROM Корзина k
  JOIN ВидыНанесения v ON k.ВидыНанесения_id = v.id
  GROUP BY v.id, v.name
  HAVING SUM(k.Количество) = (
      SELECT MAX(cnt) FROM (
          SELECT SUM(Количество) AS cnt
          FROM Корзина k3
          JOIN ВидыНанесения v3 ON k3.ВидыНанесения_id = v3.id
          GROUP BY v3.id
      ) sub_max
  )
);

-- Задание 9

SELECT s.name AS Сотрудник, ROUND(SUM(t.Цена * k.Количество), 2) AS Сумма_цен_заказов
FROM Сотрудники s
JOIN Заказы z ON s.id = z.Сотрудники_id
JOIN Корзина k ON z.id = k.Заказы_id
JOIN Товары t ON k.Товары_id = t.id
GROUP BY s.id, s.name
HAVING (
    SELECT COUNT(DISTINCT sub.Сумма)
    FROM (
        SELECT SUM(t2.Цена * k2.Количество) AS Сумма
        FROM Заказы z2
        JOIN Корзина k2 ON z2.id = k2.Заказы_id
        JOIN Товары t2 ON k2.Товары_id = t2.id
        GROUP BY z2.Сотрудники_id
    ) AS sub
    WHERE sub.Сумма > SUM(t.Цена * k.Количество)
) < 5
ORDER BY Сумма_цен_заказов DESC;

