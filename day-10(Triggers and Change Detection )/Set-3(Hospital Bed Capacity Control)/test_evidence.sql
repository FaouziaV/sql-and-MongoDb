/* SET 3 – Execute after triggers.sql */
SET NOCOUNT ON;
GO

PRINT 'Initial occupancy';
SELECT w.WardID, w.WardName, w.Capacity,
       COUNT(a.AdmissionID) AS OccupiedBeds
FROM wards w
LEFT JOIN admissions a
  ON a.WardID = w.WardID AND a.Status = 'ADMITTED'
GROUP BY w.WardID, w.WardName, w.Capacity;
GO

PRINT 'Test 1: attempt one more admission into a full ward';
BEGIN TRY
    INSERT admissions(PatientName, WardID, Status)
    VALUES (N'Patient E',10,'ADMITTED');
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

SELECT 'Ward 10 remains at capacity; rejected admission is absent' AS Evidence,
       w.WardID, w.Capacity, COUNT(a.AdmissionID) AS OccupiedBeds
FROM wards w
LEFT JOIN admissions a
  ON a.WardID = w.WardID AND a.Status = 'ADMITTED'
WHERE w.WardID = 10
GROUP BY w.WardID, w.Capacity;
GO

PRINT 'Test 2: multi-row insert with one row exceeding capacity';
/* Ward 20 has capacity 2 and currently has 1 occupied bed.
   This two-row batch would make occupancy 3, so the entire statement fails. */
BEGIN TRY
    INSERT admissions(PatientName, WardID, Status)
    VALUES (N'Patient F',20,'ADMITTED'),
           (N'Patient G',20,'ADMITTED');
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

SELECT 'Ward 20 batch outcome: original admission remains; both new rows absent' AS Evidence,
       w.WardID, w.Capacity, COUNT(a.AdmissionID) AS OccupiedBeds
FROM wards w
LEFT JOIN admissions a
  ON a.WardID = w.WardID AND a.Status = 'ADMITTED'
WHERE w.WardID = 20
GROUP BY w.WardID, w.Capacity;

SELECT 'No partial insert for F/G' AS Evidence, *
FROM admissions
WHERE PatientName IN (N'Patient F',N'Patient G');
GO

PRINT 'Test 3: update and delete auditing';
UPDATE admissions
SET Status = 'DISCHARGED'
WHERE PatientName = N'Patient A';

DELETE admissions
WHERE PatientName = N'Patient B';

SELECT 'Admission audit evidence' AS Evidence, *
FROM admission_audit
ORDER BY AuditID;
GO
