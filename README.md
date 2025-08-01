# Fabric Cloud ODS Demo 

This document is based on an actual customer use case, the aim of publishing this solution is to highlight that as technology evolves it often breeds life into architectures and solutions that are considered "legacy" by "modern" standards, it is at these moments that we realise that the "modern" architectures have inferred a huge technical debt by solving a low latency problem by creating downstream complexities. 
An example of this is the promise of microservices architecture, 
it solves many problems in the CI/CD realm and offers resilience from code changes in other applications, it does however introduce challenges when you need a consolidation of a user’s experience, or an aggregated view of the state of affairs in the entire clientele.

If we take the following scenario as an example:

![Micro Service Architecture](image.png)

Here we have a typical micro service architecture, each micro service can deploy and transact on it's own and stores only it's own transactional data, this is highly scalable and extremely flexible when it comes to app development, but it causes issues when we need to understand the whole picture of a customer’s order history and shopping behaviour.
In this scenario what normally happens is that we hang an enterprise message bus behind the micro services where each service will publish it's transactions.

![Data Processing Diagram](image-2.png)

what we are now left with is a streaming data source like EventHub or Kafka. 
In order for us to consume this data for a dashboard we need to aggregate and transform this data into a common layer fit for consumption, our first challenge is that we need to process all this stream data, here we introduce complexities such as throughput pressure and schema management, we also need to have a historical reference loop so that we can handle change markers, keys and general filtering, once we have this we then need to store this and ensure that we can manage inserts, updates and deletes, at this point we have introduced multiple engineering processes and complexities and we haven’t even started with the consumption layer.

It is easy to see that we are increasing points of failure and latency, we are also starting to create a process that is not fault tolerant, for instance if we need to reprocess our data stores due to an outage or data corruption we will need to re-ship the data from the application databases as the streaming environment has relatively short retention, this also applies to back pressure as I have seen in the past how increased publishing of events can cause consumption delays in downstream processing.  


## The Resurgence of the Operational Data Store

 ![ODS Purpose](/images/image.png)


Since the beginning of multi-user applications such as ERP, CRM, TMS and ITSM applications there has been a need to be able to display operational dashboards to monitor phone queues, stock levels, team performance and  general ops.
This requirement has in most cases come with technical implementation complexities, from managing database server performance so that the operational dashboards don’t sink the application or managing scenarios that need to span across systems creating complex and expensive patterns that compromise on quality and reliability.

One of the patterns that have always been a central part of this in the enterprise data architecture has been the operational data store (ODS). The ODS has three distinct functions.
1.	Support operational reporting
2.	Support application database consolidation
3.	Act as an integration layer between Applications and Analytics

![Image Credit: Athena IT Solutions and ScienseDirect.com](/images/image-1.png)

Image Credit: Athena IT Solutions and ScienseDirect.com

The above image depicts how  the ODS have been traditionally implemented and viewed, this implementation has a few challenges in terms of meeting todays demand to be able to provide low latency operational reporting in todays cloud reality where we have many operational systems with databases of many dialects and flavours. We also have new concepts such as AI Agents and self service analytics. 
Lets consider the following scenario:

## Scenario brief:
Adventure works Global has many ecommerce portals across the world that are hosted on premise and in the cloud, each portal has two PostgreSQL databases and one SQL Server database server.
The application consists of transactions that are managed using a micro services architecture and one end to end transaction generate data across all three application databases. 

The global operations business unit of Adventure works wants to create a consistent operational reporting data store that can be used to simplify the existing complex data APIs that are serving data back to the application, furthermore the data services division is planning on building out a customer self-services capability that will introduce an agentic AI layer that enables customers to self-serve across the systems using natural language queries.


### Technical design requirements:
1.	The new data store must be low latency < 2 minutes.
2.	The new data store must consolidate into a single query engine.
3.	Data acquisition must support transactional replication with no table based DML transactions.
4.	CDC and Change capture is not allowed. 
5.	Data acquisition must support transparent data encryption on the source application databases.
6.	Data must respect corporate network boundaries.

## The Solution:
With the above requirements in mind the data solutions architecture team is considering Microsoft Azure’s PaaS offering combined with Microsoft Fabric as this meets all 6 requirements and supports the vision of global operations and data services.

![Fabric Cloud ODS Architecture](/images/image-2.png)

To prove out the proposed design Adventure works have contracted **you** as a Solutions Integrator to build out a technical demo.



## Technical Demonstration Setup:

### Azure

•	Source Database: SQL Server 2022 (Standard D2ads v6 (2 vcpus, 8 GiB memory))

•	Test data: [Adventureworks LightWeight database](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms)

•	Transaction velocity: Six sales transaction per second, comprising of 105 database transactions per second.

•	Azure SQL Managed instance size: General Purpose Standard-series (Gen 5) (4 vCores, 20GB Memory, 64 GB storage, Geo-redundant backup storage)


![Azure SQL Setup](/images/image-3.png)

### Microsoft Fabric

•	Fabric SKU: F2 Capacity

•	Workspace setup: Two workspaces

    o	Workspace 1: Landing zone for the Mirrored Database

    o	Workspace 2: Consumption workspace for the Operational Data Store


![Fabric Setup](/images/image-4.png)




### The Deployment:
Once you have deployed the demo assets in Azure, restore the [Adventureworks Lightweight 2022 database](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms#restore-to-sql-server) on the SQL server. Next, create the [Transactional Replication](https://learn.microsoft.com/en-us/sql/relational-databases/replication/transactional/transactional-replication?view=sql-server-ver16) publication and create a push subscription that pushes any changes to the Azure SQL Managed Instance.

Now that the simulated application databases are deployed and the replication is configured and running, you need to prepare the replica database for Mirroring into Fabric.

For this, you must ensure that there are no constraints or indexes that prevent any tables in the database from being mirrored. 
Run the [Drop_incompatible_indexes.sql](/scripts/Drop_incompatible_indexes.sql) script against the replicated database on the Azure SQL Managed instance, then execute the Alter table scripts one by one to ensure that the tables can be mirrored into Microsoft Fabric.

At this point you are ready to create the first Microsoft Fabric workspace that will act as the Landing Zone. Create a [workspace and assign Fabric Capacity](https://learn.microsoft.com/en-us/fabric/fundamentals/create-workspaces).


![Create Workspace](/images/image-5.png)
 


Next create a [Mirrored database for Azure SQL Managed Instance](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/azure-sql-managed-instance-tutorial) and connect it to the Advetureworks Lightweight database replica.

Selects the tables,

![Select Mirrored Tables](/images/image-6.png) 

and name the Mirrored Data Warehouse as ***AdventureWorksLT2022***.

![Name Mirrored DW](/images/image-7.png)
 	 


Confirm that the Azure SQL Managed Instance database has generated the initial snapshots by executing the following command against the replicated database:
***“EXEC sp_help_change_feed”***
 
![sp_help_change_feed in SSMS](/images/image-8.png)

Confirms that the Mirrored database in the ODS_POV workspace has been replicated 

![Mirrored database status](/images/image-9.png)

and is accessible.

![Select statement in Fabric](/images/image-10.png)


Now that data the replica is created, you can now start building a data load, do this by creating a stored procedure using the “[Generate_SO.SQL](/scripts/GenerateSO.sql)” script.
In order to simulate a regular flow of transacions create a [SQL Server Job](https://learn.microsoft.com/en-us/ssms/agent/create-a-job?view=sql-server-ver16) that executes the new stored procedure every 10 seconds.
    

![SQL Job Agent Setup](/images/image-11.png)




To test the performance latency from start to finish, execute the following [SQL Script](/scripts/SalesOrderAgeInSeconds.sql) against the Replicated database:

![SSMS SQL Scrip Execution on MI](/images/image-12.png)
 

Then execute the same script against the mirrored SQL endpoint and observe the consistent sub-minute latency.
 
![SSMS SQL Scrip Execution against Mirrored DB](/images/image-13.png) 

Next, create the Consumption Workspace and a Lakehouse that will be used for consumption, ensuring that the [Lakehouse Schemas](https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-schemas) is enabled as this will enable you to shortcut entire database schemas from the mirrored database.

![Create Workspace Dialouge](/images/image-14.png)



You can now create the schema [shortcut](https://learn.microsoft.com/en-us/fabric/onelake/create-onelake-shortcut) in the Lakehouse and validate that you can see the data.


![Create and validate shortcuts](/images/image-15.png)

 

  
To test the operational reporting consumption, create a [PowerBI Semantic model](https://learn.microsoft.com/en-us/fabric/fundamentals/lakehouse-power-bi-reporting) in direct lake mode.

![PowerBI Semantic model](/images/image-16.png)

 	 

In the PowerBI Semantic model, create a few base [measures](https://learn.microsoft.com/en-us/power-bi/transform-model/service-edit-data-models#create-measures) to simulate the sales order dashboard and the data freshness.

![PowerBI Measures](/images/image-17.png)
 
Create a [PowerBI Dashboard](/Templates/SO%20Dashboard.pbit) that can be used to monitor the sales order transactions over time and to see the data freshness.

![Power BI SO Dashboard](/images/image-18.png)

 
Also create a stored procedure using the [GetDataFreshness.sql](/scripts/GetDataFreshness.sql) script in the Analytics endpoint of the POV_Analytics Lakehouse that will be used as a data source for the Query Performance testing.

![GetDataFreshness.sql in Fabric](/images/image-19.png)
 

Next, create a [GraphQL Data API](https://learn.microsoft.com/en-us/fabric/data-engineering/get-started-api-graphql) to test query performance and response for your data API requirement.

![Create GraphQL Data API](/images/image-20.png)
 
Select Fabric data sources with single sign-on (SSO) and the SalesLT.GetDataFreshness stored procedure for the Pov_Analytics Lakehouse.

![GraphGL Get Data](/images/image-21.png)
   
You are now ready to test performance for the data API. Use the [rest_API_Query.json](/scripts/rest_API_Query.json) script and you can clearly see the stored procedure performance.

![QraphQL Query Execution](/images/image-22.png) 

### The Agentic Experience

Next, pivot to the final requirement to be able to serve a self-service [Fabric Data Agent](https://learn.microsoft.com/en-us/fabric/data-science/how-to-create-data-agent) that can be used for natural language queries and can be extended into [Copilot studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/fundamentals-what-is-copilot-studio) and extended further using [AI foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/what-is-azure-ai-foundry) to build an in app agentic experience for your customers.

To start, create a Data Agent called SO_Data_Agent.

![Create Data Agent](/images/image-23.png)
 
Add the Pov_Analytics Lakehouse and select the Customer, Product, SalesOrderDetail and SalesOrderHeader tables.

Now test the data agent with a simple question:
***“What customer has the highest sales amount in the last 24 hours”***

This successfully identifies “Action Bicycle Specialists” as the customer with the highest sales amount in the last 24 hours.

![Action Bicycle Specialists](/images/image-24.png)

When asked “What top 5 products has Action Bicycle Specialists bought in the last 48 hours?” the agent correctly lists the top 5 products by order quantity.
 
![What top 5 products has Action Bicycle Specialists bought in the last 48 hours?](/images/image-25.png)


When asked follow up questions about “what product has generated the most revenue for Action Bicycle Specialists in the last 48 hours?” the agent correctly lists product 957.
 
![what product has generated the most revenue](/images/image-26.png)



### Conclusion of the POV

To conclude we can clearly see that we have managed to implement an architecture and solution that meet ***all the design and business requirements that were*** set out in the [solutions overview section](/README.md#scenario-brief) above.



## Governance and compliance review

During the testing by the AdventureWorks data services business team, they conducted a compliance review that triggered an audit finding pertaining to sensitive information. 

![Microsoft Purview Data Map](/images/sec_image.png)  


In the SalesLT.Customer table contains encryption data for user passwords that cannot be stored in an analytical data store according to the corporate data protection policies and therefore needs to be removed.
You are again asked to commission a solution that automatically and persistently removes the data from the sensitive columns prior to being mirrored into the Fabric Mirrored database.

As the lead architect on the project you conclude that in order to comply with the requirements you will need to use a SQL Server trigger on the SalesLT.Customer table that blanks out the data in the PasswordHash and PasswordSalt columns when data is inserted or updates in the application database.

Your reasoning is as follows:

1.	A trigger supports SQL Server replication
2.	A trigger will persist the solution
3.	A trigger is the least administrative effort

To test this you execute the “[RemovePassword_trigger.sql](/scripts/RemovePassword_trigger.sql)” SQL script against the Replicated database.
 
![SSMS RemovePassword trigger script](/images/sec_image-1.png)

To test the new trigger and to confirm that the data is removed from the replication server and into the Microsoft Fabric Mirrored ODS you now run a benign update on the SalesLT.Customer source table on the application database.

![SSMS Update script](/images/sec_image-2.png)

You can now see the change propagated to the replication database

 ![SSMS Redacted screenshot MI](/images/sec_image-3.png)

And Also into the Fabric Mirrored Database and the final consumption layer:

![Fabric Redacted Screenshot LH](/images/sec_image-4.png) 

With this you have now created a fully compliant solution that prevents any accidental exposure of sensitive data that can be leaked via the operational data store.
