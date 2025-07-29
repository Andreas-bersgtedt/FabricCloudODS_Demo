CREATE TRIGGER [SalesLT].trg_RemovePassword_AfterInsert
ON [SalesLT].[Customer]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update only the rows we just inserted
    UPDATE T
    SET T.[PasswordHash] = NULL
	,T.[PasswordSalt] =NULL
    FROM [SalesLT].[Customer] AS T
    INNER JOIN inserted AS I
        ON T.[CustomerID] = I.[CustomerID];
END
GO