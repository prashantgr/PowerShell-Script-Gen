BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '------------------------------------------------'
    PRINT 'Start checking for existing Employees...'
    PRINT '------------------------------------------------'
        PRINT 'Start checking for existing Employees...'
        SELECT 'Employee Exists' AS 'Exists', b.phoneNumber, a.address,  a.EmployeeSubmitDate, a.EmployeeApprovalDate, a.EmployeeStateId 
                            FROM Employee a INNER JOIN Department b ON a.LtEmployeeId = b.LtEmployeeId
                            WHERE b.phoneNumber = 9999999999 AND a.empId = 001 
                            AND b.Department = 'DEV'
        PRINT 'Done checking for existing Employees'
    PRINT '------------------------------------------------'
    PRINT 'Start inserting Employees that do not exist already...'
    DECLARE @count INT
        PRINT '------------------------------------------------'
        PRINT 'Start inserting Employees that do not exist already...'
        IF NOT EXISTS ( SELECT 1 FROM Employee a INNER JOIN Department b ON a.LtEmployeeId = b.LtEmployeeId
                            WHERE b.phoneNumber = '9999999999' AND a.empId = '001' AND b.departmentName = 'DEV') 
           BEGIN 
            PRINT 'Inserting employee with phoneNumber 9999999999, business unit Employee id test address, CreativeBoyz scenario id 001 and status 1'
              
            INSERT Employee (LtEmployeeId, address, EmployeeCreateDate, EmployeeSubmitDate, EmployeeStateId, empId, IsMigratedData) 
            VALUES ('259b9d0e-532c-4340-8ee5-78a24aab511f', 'test address', '20240809 01:35:51', '20240809 01:35:51', '', 1, '001', 1) 

            INSERT Department (LtEmployeeId, departmentName, DepId, Location ) 
            VALUES ('259b9d0e-532c-4340-8ee5-78a24aab511f', 'DEV', 1, 'Bengalore') 

           END
        PRINT 'Done inserting new Employees'
        PRINT '------------------------------------------------'
        PRINT 'Total no of employees : 1'

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Rollback the transaction
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

    -- Error handling
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Log the error (replace with your logging mechanism)
    PRINT 'Error Occurred: ' + @ErrorMessage;

    -- Optionally, you can re-throw the error
    -- THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
END CATCH;

