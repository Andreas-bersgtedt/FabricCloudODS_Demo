CREATE TRIGGER [SalesLT].trg_RemovePassword_AfterInsert
ON [SalesLT].[Customer]
AFTER INSERT ,UPDATE 
AS
BEGIN
    SET NOCOUNT ON;

    -- Update only the rows we just inserted
    UPDATE T
    SET T.[PasswordHash] = 'Redacted'
	,T.[PasswordSalt] ='Redacted'
    FROM [SalesLT].[Customer] AS T
    INNER JOIN inserted AS I
        ON T.[CustomerID] = I.[CustomerID];
END
GO

