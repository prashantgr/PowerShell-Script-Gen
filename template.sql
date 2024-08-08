BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '------------------------------------------------'
    PRINT 'Start checking for existing Employees...'
    --CHECKEmployees--
    PRINT '------------------------------------------------'
    PRINT 'Start inserting Employees that do not exist already...'
    --COPYEmployees--

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
