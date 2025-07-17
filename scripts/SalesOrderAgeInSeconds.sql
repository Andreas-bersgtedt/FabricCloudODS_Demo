SELECT SalesOrderAgeInSeconds=DATEDIFF(SECOND ,MAX([ModifiedDate]),GETUTCDATE())
  FROM [SalesLT].[SalesOrderDetail]