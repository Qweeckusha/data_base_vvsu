USE дикиеягоды;

-- =======================================================

-- 1.1
DELIMITER //
DROP PROCEDURE new_product //
CREATE PROCEDURE new_product (n VARCHAR(45), providerID INT, cost FLOAT)
	BEGIN
		IF EXISTS (SELECT 1 FROM Поставщики WHERE id = providerID) THEN
		INSERT into Товары (name, Поставщики_id, Цена) VALUES (n, providerID, cost);
        SELECT 'Товар добавлен' AS message;
        ELSE 
			SELECT 'Нет поставщика' AS message;
		END IF;
	END 
//

-- 1.2
DELIMITER //
DROP PROCEDURE IF EXISTS new_order //
CREATE PROCEDURE new_order (
    contract_id INT,    
    emp_id INT,
    date_of_end DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM Договоры WHERE id = contract_id LIMIT 1) 
       AND 
       EXISTS (SELECT 1 FROM Сотрудники WHERE id = emp_id LIMIT 1) THEN
        
        INSERT INTO Заказы (
            Договоры_id, 
            дата_создания, 
            дата_выполнения, 
            Сотрудники_id,
            Статус
        ) VALUES (
            contract_id,
            CURDATE(),                
            date_of_end,
            emp_id,
            'Не отправлено'
        );
        
        SELECT 'Заказ успешно добавлен' AS message;
        
    ELSE
        SELECT 'Заказ не добавлен. Проверьте ID договора и/или сотрудника.' AS message;
    END IF;
END //

-- 1.3
DELIMITER //
DROP PROCEDURE IF EXISTS create_contract_and_order //
CREATE PROCEDURE create_contract_and_order(
    p_clients_id INT,
    p_employee_id INT,
    p_order_end_date DATE
)
BEGIN
    DECLARE v_contract_id INT;

    IF EXISTS (SELECT 1 FROM Клиенты WHERE id = p_clients_id) 
       AND EXISTS (SELECT 1 FROM Сотрудники WHERE id = p_employee_id) THEN

        INSERT INTO Договоры (Клиенты_id, дата_заключения)
        VALUES (p_clients_id, CURDATE());

        SET v_contract_id = LAST_INSERT_ID();

        INSERT INTO Заказы (Договоры_id, дата_создания, дата_выполнения, Статус, Сотрудники_id)
        VALUES (v_contract_id, CURDATE(), p_order_end_date, 'Не отправлено', p_employee_id);

        SELECT v_contract_id AS созданный_договор_id, 
               'Заказ успешно создан и привязан' AS статус;
               
    ELSE
        SELECT 'Ошибка: Проверьте ID клиента или сотрудника' AS статус;
    END IF;
END //

DELIMITER ;


-- =======================================================


-- 2.1*
DELIMITER //
DROP procedure if exists order_by_clients //
CREATE PROCEDURE order_by_clients(client_name VARCHAR(90))
BEGIN
    SELECT 
        o.id AS `ID_Заказа`,
        o.дата_создания AS `дата_создания`,
        o.Статус,
        SUM(c.Количество * t.Цена) AS `Итоговая_сумма`
    FROM `Клиенты` cl
    JOIN `Договоры` d       ON cl.id = d.Клиенты_id
    JOIN `Заказы` o         ON d.id = o.Договоры_id
    JOIN `Корзина` c        ON o.id = c.Заказы_id
    JOIN `Товары` t         ON c.Товары_id = t.id
    WHERE cl.name = client_name
    GROUP BY o.id
    -- Задача со *
    UNION ALL
    
    SELECT 
		NULL AS `ID_Заказа`,
        NULL AS `дата_создания`,  
        'ВСЕГО:' AS `Статус`,          
        SUM(c.Количество * t.Цена) AS `Итоговая_сумма`
    FROM `Клиенты` cl
    JOIN `Договоры` d ON cl.id = d.Клиенты_id
    JOIN `Заказы` o ON d.id = o.Договоры_id
    JOIN `Корзина` c ON o.id = c.Заказы_id
    JOIN `Товары` t ON c.Товары_id = t.id
    WHERE cl.name = client_name
    ORDER BY 2 DESC;
END //


-- 2.2
DELIMITER //
DROP procedure if exists get_UncompletedOrders //
CREATE PROCEDURE get_UncompletedOrders(date_y DATE)
BEGIN
    SELECT 
		o.дата_создания AS `дата создания`,
        o.дата_выполнения AS `дата выполнения`,
		o.Статус AS `Статус заказа`
    FROM Заказы o
    WHERE 
    (o.дата_выполнения IS NULL OR o.дата_выполнения > date_y)
    AND o.дата_создания <= date_y;
END //

-- 2.3
DELIMITER //
DROP PROCEDURE IF EXISTS get_ProductSales //
CREATE PROCEDURE get_ProductSales(product_id INT)
BEGIN
    SELECT 
        t.name AS `Товар`,
        vn.name AS `Вид_нанесения`,
        SUM(k.Количество) AS `Продано_шт`,
        t.Цена AS `Цена_за_шт`,
        SUM(k.Количество * t.Цена) AS `Выручка_руб`
    FROM Товары t
    JOIN Корзина k ON t.id = k.Товары_id
    JOIN ВидыНанесения vn ON k.ВидыНанесения_id = vn.id
    WHERE t.id = product_id
    GROUP BY t.id, vn.id
    ORDER BY `Выручка_руб` DESC;
END //

-- 2.4
DELIMITER //
DROP procedure if exists contract_sum //
CREATE PROCEDURE contract_sum(contract_id INT)
BEGIN
    -- Рассчитываем сумму: Цена * Количество по всем позициям заказов выбранного договора
    SELECT ROUND(SUM(t.Цена * k.Количество), 2) AS Сумма_по_договору
    FROM Договоры d
    JOIN Заказы z ON d.id = z.Договоры_id
    JOIN Корзина k ON z.id = k.Заказы_id
    JOIN Товары t ON k.Товары_id = t.id
    WHERE d.id = contract_id;
END //

-- 2.5
DELIMITER //
DROP PROCEDURE IF EXISTS get_DeliveriesByDate //
CREATE PROCEDURE get_DeliveriesByDate(date_y DATE)
BEGIN
    SELECT 
        d.id AS `№_доставки`,
        d.Заказы_id AS `№_заказа`,
        tc.name AS `Транспортная_компания`,
        vt.name AS `Вид_транспорта`,
        d.Статус_доставки AS `Статус`,
        d.дата_отправки AS `Дата_отправки`
    FROM DeliveryInOrder d
    JOIN ТранспортныеКомп tc ON d.ТранспортныеКомп_id = tc.id
    JOIN ВидыТранспорта vt ON d.ВидыТранспорта_id = vt.id
    WHERE d.дата_отправки = date_y;
END //



-- =======================================================


-- ВЫЗОВЫ ПРОЦЕДУР

DELIMITER ;

-- 1.1
CALL new_product('AirPods', 2, 8000.00);

-- 1.2
CALL new_order(1, 2, '2026-09-12');
CALL new_order(999, 2, '2026-09-12');
CALL new_order(1, 999, '2026-09-12');
CALL new_order(999, 999, '2026-09-12');

SELECT * FROM Заказы;

-- 1.3
CALL create_contract_and_order(3, 1, '2026-06-26');
SELECT * FROM Заказы;
SELECT * FROM Договоры;


-- =======================================================


-- 2.1
SELECT * FROM Клиенты;
CALL order_by_clients ('ООО "Альфа"');

-- 2.2
SELECT * FROM Заказы;
CALL get_UncompletedOrders("2025-11-01"); -- Неудачный вызов 
CALL get_UncompletedOrders("2026-03-01"); -- Удачный вызов 

-- 2.3
SELECT * FROM Корзина;
SELECT * FROM Товары;
CALL get_ProductSales(2);

-- 2.4
CALL contract_sum(1);

-- 2.5
CALL get_DeliveriesByDate("2025-12-11");






