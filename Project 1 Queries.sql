#Query 1 
Use al_Group_21479_G1;
SELECT p.propertyName,
       COUNT(py.paymentID) AS numPayments,
       SUM(py.amountPaid) AS totalRevenue
FROM Properties p
JOIN Units u ON p.propertyID = u.propertyID
JOIN RentPayments py ON u.unitID = py.unitID
WHERE py.Status = 'Completed'
GROUP BY p.propertyName
HAVING SUM(py.amountPaid) > 2000
ORDER BY totalRevenue DESC;

#Query 2
SELECT t.tenantID, t.firstName, t.lastName
FROM Tenants t
WHERE NOT EXISTS (
    SELECT 1 FROM MaintenanceRequest mr
    WHERE mr.tenantID = t.tenantID
)
ORDER BY t.lastName;

#Query 3
SELECT v.vendorName, v.serviceCategory,
       COUNT(mr.requestID) AS totalRequests
FROM Vendors v
JOIN MaintenanceRequest mr ON v.vendorID = mr.vendorID
GROUP BY v.vendorID, v.vendorName, v.serviceCategory
HAVING COUNT(mr.requestID) > (
    SELECT AVG(reqCount)
    FROM (
        SELECT COUNT(requestID) AS reqCount
        FROM MaintenanceRequest
        GROUP BY vendorID
    ) AS vendorCounts
)
ORDER BY totalRequests DESC;

#Query 4
SELECT p.propertyID, p.propertyName,
       (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID) AS totalUnitsInDB,
       (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID
        AND u.isOccupied = 'Yes') AS occupiedUnits,
       ROUND(
         (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID
          AND u.isOccupied = 'Yes') * 100.0 /
         (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID), 1
       ) AS occupancyPct
FROM Properties p
WHERE (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID) > 0
  AND (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID
       AND u.isOccupied = 'Yes') * 100.0 /
      (SELECT COUNT(*) FROM Units u WHERE u.propertyID = p.propertyID)
      < (SELECT SUM(CASE WHEN isOccupied = 'Yes' THEN 1 ELSE 0 END) * 100.0
         / COUNT(*) FROM Units)
ORDER BY occupancyPct ASC;

#Query 5
SELECT paymentMethod,
       COUNT(*) AS totalTransactions,
       SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS failed,
       ROUND(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0
             / COUNT(*), 1) AS failureRate
FROM RentPayments
GROUP BY paymentMethod
ORDER BY failureRate DESC;

#Query 6
SELECT t.tenantID, t.firstName, t.lastName, l.monthlyRent, p.propertyName
FROM Tenants t
JOIN Leases l ON t.tenantID = l.tenantID
JOIN Units u ON l.unitID = u.unitID
JOIN Properties p ON u.propertyID = p.propertyID
WHERE t.lastName REGEXP '(Clark|Hall|Walker|Lewis)'
  AND l.endDate >= '2024-04-01'
ORDER BY t.lastName, t.firstName;

#Query 7
SELECT t.firstName, t.lastName, u.Bedrooms, u.Bathrooms, p.propertyName
FROM Tenants t
JOIN Leases l ON t.tenantID = l.tenantID
JOIN Units u ON l.unitID = u.unitID
JOIN Properties p ON u.propertyID = p.propertyID
WHERE l.endDate >= '2024-01-01'
ORDER BY p.propertyName;

#Query 8
SELECT u.Bedrooms,
       COUNT(l.leaseID) AS numLeases,
       ROUND(AVG(l.monthlyRent), 2) AS avgMonthlyRent
FROM Units u
JOIN Leases l ON u.unitID = l.unitID
GROUP BY u.Bedrooms
ORDER BY u.Bedrooms;

#Query 9
SELECT mr.requestID, mr.issueDescription, mr.Status, mr.dateReported,
       v.vendorName, v.serviceCategory
FROM MaintenanceRequest mr
JOIN Vendors v ON mr.vendorID = v.vendorID
WHERE mr.Status IN ('Open', 'In Progress', 'Urgent')
ORDER BY mr.dateReported;

#Query 10
SELECT t.firstName, t.lastName, pt.petName, pt.petType, pt.Breed, p.propertyName
FROM Tenants t
JOIN Pets pt ON t.tenantID = pt.Tenants_tenantID
JOIN Leases l ON t.tenantID = l.tenantID
JOIN Units u ON l.unitID = u.unitID
JOIN Properties p ON u.propertyID = p.propertyID
WHERE l.endDate >= '2024-01-01'
ORDER BY t.lastName; 