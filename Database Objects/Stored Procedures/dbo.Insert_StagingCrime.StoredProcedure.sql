USE [Crime]
GO
/****** Object:  StoredProcedure [dbo].[Insert_StagingCrime]    Script Date: 1/18/2020 3:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jason Wittenauer
-- Create date: 12/18/2019
-- Description:	Import crime data from a csv file into a staging table using a format file
-- =============================================
CREATE PROCEDURE [dbo].[Insert_StagingCrime]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Remove prior data from staging table
	TRUNCATE TABLE Staging_Crime

	-- Bulk insert data into staging tabe
	BULK INSERT Staging_Crime 
	FROM 'C:\Projects\Crime Prediction\Data\Baltimore Incident Data.csv'
	WITH (FIRSTROW = 2, FORMATFILE = 'C:\Projects\Crime Prediction\Data\FormatFile.fmt')

END
GO
