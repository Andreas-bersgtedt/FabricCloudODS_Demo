/*Stored Procedure that generates sales order transactions for Adventure Works LightWeight 2022 database*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[generateSO]
    
AS
BEGIN
Declare @maxID int = (SELECT MAX([SalesOrderID]) from [SalesLT].[SalesOrderHeader])

SELECT TOP (60) [SalesOrderID] = @maxID + ROW_NUMBER() Over (Order By OrderDate)
      ,[RevisionNumber]
      ,[OrderDate]= GETUTCDATE()
      ,[DueDate]= Dateadd(day, 7 ,GETUTCDATE())
      ,[ShipDate] = Dateadd(day, 3 ,GETUTCDATE())
      ,[Status]
      ,[OnlineOrderFlag]
      ,[SalesOrderNumber]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[ShipToAddressID]
      ,[BillToAddressID]
      ,[ShipMethod]
      ,[CreditCardApprovalCode]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      ,[TotalDue]
      ,[Comment]
      ,[rowguid] =NEWID()
      ,[ModifiedDate] = GETUTCDATE()
	  ,orgSalesOrderID=[SalesOrderID]
  INTO #TTSOH
  FROM [SalesLT].[SalesOrderHeader]
  
  SET IDENTITY_INSERT [SalesLT].[SalesOrderHeader] ON;
  INSERT INTO SalesLT.SalesOrderHeader ([SalesOrderID]
      ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
      --,[SalesOrderNumber]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[ShipToAddressID]
      ,[BillToAddressID]
      ,[ShipMethod]
      ,[CreditCardApprovalCode]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      --,[TotalDue]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate])
	  SELECT [SalesOrderID]
      ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
     -- ,[SalesOrderNumber]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[ShipToAddressID]
      ,[BillToAddressID]
      ,[ShipMethod]
      ,[CreditCardApprovalCode]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      --,[TotalDue]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate] FROM #TTSOH

   SET IDENTITY_INSERT [SalesLT].[SalesOrderHeader] OFF;

insert into SalesLT.SalesOrderDetail ([SalesOrderID]
      
      ,[OrderQty]
      ,[ProductID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
   --   ,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate])
  SELECT soh.[SalesOrderID]
      --,[SalesOrderDetailID]
      ,[OrderQty]
      ,[ProductID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
     -- ,[LineTotal]
      ,[rowguid]=newid()
      ,[ModifiedDate]=getutcdate()
  FROM #TTSOH soh inner join
  [SalesLT].[SalesOrderDetail] sod on soh.orgSalesOrderID=sod.SalesOrderID



  Drop Table #TTSOH
  end
GO

