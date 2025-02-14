-- Ejercicio 1: Calcula el total de ventas para cada producto (cantidadOrdered * priceEach) y muestra solo aquellos productos cuyo total supere el promedio de ventas de 
-- todos los productos, ordenado de mayor a menor.

SELECT
	P.productName,
    SUM(OD.quantityOrdered * OD.priceEach) AS total_ventas
FROM products AS P
JOIN orderdetails AS OD
	ON P.productCode = OD.productCode
GROUP BY P.productCode, P.productName
HAVING SUM(OD.quantityOrdered * OD.priceEach) >
	(SELECT AVG(totalVentas)
	FROM (SELECT SUM(quantityOrdered * priceEach) AS totalVentas
    FROM orderdetails
    GROUP BY productCode) AS subconsulta)
ORDER BY total_ventas DESC;

-- Ejercicio 2: Muestra los 5 productos con mayor cantidad de órdenes distintas, incluyendo el nombre del producto y la cantidad de órdenes.

SELECT 
	P.productName,
    COUNT(DISTINCT(OD.orderNumber)) AS cantidad_ordenes
FROM products AS P
JOIN orderdetails as OD
	ON P.productCode = OD.productCode
GROUP BY P.productName
ORDER BY cantidad_ordenes DESC
LIMIT 5;
    
-- Ejercicio 3: Lista los clientes que han realizado compras superiores a 5000, mostrando el nombre del cliente, la suma total de sus compras y la cantidad de pedidos realizados, 
-- ordenados de mayor a menor según el total de compras.

SELECT 
	C.customerName,
    SUM(OD.priceEach * quantityOrdered) AS Suma_compras,
    COUNT(O.orderNumber) AS Cant_pedidos
FROM customers as C
JOIN orders as O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails as OD
	ON O.orderNumber = OD.orderNumber
GROUP BY C.customerName
HAVING Suma_compras > 5000
ORDER BY 2 DESC;
  
-- Ejercicio 4: Obtén el nombre y correo electrónico de los empleados que han realizado ventas por encima del promedio, calculado como la suma de (cantidadOrdered * priceEach) 
-- de los pedidos en los que participan.

SELECT
	CONCAT(E.firstName, ' ', E.lastName) AS Nombre_empleado,
    E.email
FROM employees as E
JOIN customers as C
	ON E.employeeNumber = C.salesRepEmployeeNumber
JOIN orders as O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails as OD
	ON O.orderNumber = OD.orderNumber
GROUP BY 1, 2
HAVING SUM(OD.quantityOrdered * OD.priceEach) >
	(SELECT AVG(total_ventas)
    FROM (SELECT SUM(OD2.quantityOrdered * OD2.priceEach) AS total_ventas
              FROM orders AS O2
              JOIN orderdetails AS OD2 ON O2.orderNumber = OD2.orderNumber
              JOIN customers AS C2 ON O2.customerNumber = C2.customerNumber
              JOIN employees AS E2 ON C2.salesRepEmployeeNumber = E2.employeeNumber
              GROUP BY E2.employeeNumber) AS subquery);


-- Ejercicio 5: Consulta el total de pagos realizados por cada cliente y muestra solo aquellos clientes cuyo total de pagos sea inferior a la suma total de sus pedidos.

SELECT 
	C.customerName,
    SUM(P.amount) AS total_pagos
FROM customers AS C
JOIN payments AS P
	ON C.customerNumber = P.customerNumber
GROUP BY C.customerNumber
HAVING total_pagos <
	(SELECT COALESCE(SUM(OD.quantityOrdered * OD.priceEach), 0)
	FROM orders AS O
	JOIN orderdetails AS OD
		ON O.orderNumber = OD.orderNumber
	WHERE O.customerNumber = C.customerNumber);

-- Ejercicio 6: Lista los productos que nunca han sido ordenados, mostrando el nombre del producto y su precio de compra.

SELECT
	P.productName,
    P.buyprice 
FROM products AS P
LEFT JOIN orderdetails AS OD
	ON p.productCode = OD.productCode
WHERE OD.productCode IS NULL;

-- Ejercicio 7: Muestra las oficinas que tienen empleados que han realizado al menos una venta, junto con el total de ventas realizadas por cada oficina.


SELECT 
    O.officeCode, 
    SUM(P.amount) AS total_ventas
FROM offices AS O
JOIN employees AS E 
    ON O.officeCode = E.officeCode
JOIN customers AS C 
    ON E.employeeNumber = C.salesRepEmployeeNumber
JOIN payments AS P 
    ON C.customerNumber = P.customerNumber
GROUP BY O.officeCode;
	
-- Ejercicio 8: Consulta el promedio de ventas por producto para cada productLine, mostrando la productLine, el promedio de ventas y la cantidad total de productos vendidos.

SELECT
	PL.productLine,
    AVG(OD.quantityOrdered * OD.priceEach) AS promedio_venta,
    SUM(OD.quantityOrdered) AS Total_vendidos
FROM productlines AS PL
JOIN products as PR
	ON PL.productLine = PR.productLine
JOIN orderdetails AS OD
	ON PR.productCode = OD.productCode
GROUP BY PL.productLine;

-- Ejercicio 9: Obtén el ranking de empleados basado en el total de ventas que han realizado, mostrando el nombre del empleado, su oficina y el total vendido, ordenado de mayor a menor.
--  (Utiliza funciones de ventana o variables de usuario para asignar el ranking).

  SELECT
	RANK() OVER (ORDER BY SUM(OD.quantityOrdered * OD.priceEach) DESC) AS ranking,
	E.firstName,
    E.lastName,
    OS.officeCode,
	SUM(OD.quantityOrdered * OD.priceEach) AS total_ventas
FROM employees AS E
JOIN offices AS OS
	ON E.officeCode = OS.officeCode
JOIN customers AS C
	ON E.employeeNumber = C.salesRepEmployeeNumber
JOIN orders AS O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
GROUP BY E.employeeNumber
ORDER BY total_ventas DESC;

    
-- Ejercicio 10: Muestra el total de ventas por mes durante el año 2003, indicando el mes y el total de ventas, y filtra para mostrar solo los meses en los que las ventas superaron los 10000.

SELECT
	MONTH(O.orderDate) AS Mes,
    SUM(OD.quantityOrdered * OD.priceEach) AS total_ventas
FROM orders AS O
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
WHERE YEAR(O.orderDate) = 2003
GROUP BY Mes
HAVING total_ventas > 10000;

-- Ejercicio 11: Consulta la relación entre productos y sus órdenes, mostrando el nombre del producto, el número de orden y el total de ventas por cada orden, 
-- y filtra para mostrar solo aquellas órdenes donde el total supere los 500.

SELECT
    O.orderNumber,
    P.productName,
    SUM(OD.quantityOrdered * OD.priceEach) AS total_ventas
FROM products AS P
JOIN orderdetails AS OD
	ON P.productCode = OD.productCode
JOIN orders AS O
	ON OD.orderNumber = O.orderNumber
GROUP BY O.orderNumber, P.productName
HAVING total_ventas > 500
ORDER BY total_ventas;
    

-- Ejercicio 12: Muestra el nombre del cliente, la fecha del pedido y el monto total del pedido, 
-- pero solo para aquellos pedidos enviados después de la fecha requerida (indicando un retraso), ordenados por fecha del pedido.

SELECT 
	C.customerName,
    O.orderNumber,
    O.orderDate,
    SUM(OD.quantityOrdered * OD.priceEach) AS total_pedido
FROM customers AS C
JOIN orders AS O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
WHERE DATEDIFF(O.shippedDate, O.requiredDate) > 0  -- Filtramos solo los pedidos con retraso
GROUP BY C.customerName, O.orderNumber, O.orderDate  -- Aseguramos consistencia en la agregación
ORDER BY O.orderDate;

  
-- Ejercicio 13: Lista los productos que han tenido un incremento en las ventas en el último año en comparación con el año anterior, mostrando el nombre del producto 
-- y la variación porcentual, utilizando subconsultas para cada año.

SELECT 
	P.productCode,
    P.ventas2004,
    P.ventas2003,
    CONCAT(ROUND(((P.ventas2004 - P.ventas2003) / P.ventas2003) *100,2),'%') AS VariacionPorcentual
FROM (
	SELECT 
		OD.productCode,
        SUM(CASE WHEN YEAR(O.orderDate) = 2003 THEN OD.quantityOrdered * OD.priceEach ELSE 0 END) AS Ventas2003,
        SUM(CASE WHEN YEAR(O.orderDate) = 2004 THEN OD.quantityOrdered * OD.priceEach ELSE 0 END) AS Ventas2004
	FROM orderdetails AS OD
    JOIN orders AS O
		ON OD.orderNumber = O.orderNumber
	GROUP BY OD.productCode
)AS P
WHERE P.ventas2004 > P.ventas2003;
  
-- Ejercicio 14: Consulta el empleado que más ventas ha realizado en cada oficina, mostrando el nombre del empleado, 
-- el nombre de la oficina y el total de ventas, usando subconsultas correlacionadas o funciones de agregación.

WITH VentasPorEmpleado AS (
  SELECT
	E.firstName,
    E.officeCode,
    SUM(OD.priceEach * OD.quantityOrdered) AS totalVentas,
    RANK() OVER (PARTITION BY E.officeCode ORDER BY SUM(OD.priceEach * OD.quantityOrdered) DESC) AS RankVentas
FROM employees AS E
JOIN customers AS C
	ON E.employeeNumber = C.salesRepEmployeeNumber
JOIN orders AS O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
GROUP BY E.firstName, E.officeCode
)
SELECT firstName, officeCode, totalVentas
FROM ventasPorEmpleado
WHERE RankVentas = 1;

-- Ejercicio 15: Obtén el número de órdenes y el total de ventas por cada día en que se realizaron pedidos, mostrando solo aquellos días en los que se hicieron más de 5 órdenes.

SELECT
	O.orderDate,
    COUNT(O.orderNumber) AS cantidadOrdenes,
    SUM(OD.quantityOrdered * OD.priceEach) AS totalVentas
FROM orders AS O
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
GROUP BY O.orderDate
HAVING cantidadOrdenes > 5;
  
-- Ejercicio 16: Muestra los clientes que han pagado más de lo que debían, es decir, donde la suma de sus pagos supera la suma de sus pedidos, incluyendo el nombre del cliente, total pagado, total de pedidos y la diferencia.

SELECT 
	C.customerNumber,
    C.customerName,
	SUM(P.amount) AS totalPagado,
    SUM(OD.quantityOrdered * OD.priceEach) AS totalPedidos,
    (SUM(P.amount) - SUM(OD.quantityOrdered * OD.PriceEach)) AS saldoAFavor
FROM customers AS C
JOIN payments AS P
	ON C.customerNumber = P.customerNumber
JOIN orders AS O
	ON C.customerNumber = O.customerNumber
JOIN orderdetails AS OD
	ON O.orderNumber = OD.orderNumber
GROUP BY C.customerNumber, C.customerName
HAVING SUM(P.amount) > SUM(OD.quantityOrdered * OD.priceEach);
  
-- Ejercicio 17: Lista los productos cuyo MSRP es al menos 50% mayor que su precio de compra y que además han generado ventas totales por encima de 10000, mostrando el nombre del producto, MSRP, precio de compra y total de ventas.

SELECT 
	P.productName,
    P.MSRP,
    P.buyPrice,
    SUM(OD.quantityOrdered * OD.priceEach) AS totalVentas
FROM products AS P
JOIN orderdetails AS OD
	ON P.productCode = OD.productCode
WHERE P.MSRP >= (P.buyPrice * 1.5)
GROUP BY P.productCode, P.productName, P.MSRP, P.buyPrice
HAVING totalVentas > 10000;


-- Ejercicio 18: Consulta la diferencia porcentual entre el total de ventas y el total de pagos para cada cliente, mostrando el nombre del cliente,
-- total de ventas, total de pagos y la diferencia porcentual.

SELECT C.customerName,
       SUM(OD.priceEach * OD.quantityOrdered) AS totalVentas,
       SUM(P.amount) AS totalPagos,
       CONCAT(ROUND(((SUM(OD.priceEach * OD.quantityOrdered) - SUM(P.amount))/SUM(OD.priceEach * OD.quantityOrdered))*100, 2), '%') AS diferencia
FROM customers AS C
JOIN payments AS P ON C.customerNumber = P.customerNumber
JOIN orders AS O ON C.customerNumber = O.customerNumber
JOIN orderdetails AS OD ON O.orderNumber = OD.orderNumber
GROUP BY C.customerNumber,
         C.customerName;


-- Ejercicio 19: Obtén un resumen por productLine que incluya la cantidad total de productos, el total de ventas de productos en esa línea, el promedio de ventas por producto y
-- el porcentaje que representa la línea en el total de ventas generales, utilizando subconsultas para calcular el total general.

SELECT PL.productline,
       COUNT(P.productCode) AS cantidadProductos,
       SUM(OD.quantityOrdered * OD.priceEach) AS totalVentas,
       ROUND(AVG(OD.quantityOrdered * OD.priceEach), 2) AS promedioVentas,
       CONCAT(ROUND((SUM(OD.quantityOrdered * OD.priceEach)/
                       (SELECT SUM(quantityOrdered * priceEach)
                        FROM orderdetails) *100),2), '%') AS porcentajeVentas
FROM productlines AS PL
JOIN products AS P ON PL.productLine = P.productLine
JOIN orderdetails AS OD ON P.productCode = OD.productCode
GROUP BY PL.productLine;


