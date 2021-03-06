USE [Crime]
GO
/****** Object:  StoredProcedure [dbo].[Update_CrimeCoordinates]    Script Date: 1/18/2020 3:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jason Wittenauer
-- Create date: 12/18/2019
-- Description:	Create two grids (small and large) to group up data points together and add those groupings to the crime data set
-- =============================================
CREATE PROCEDURE [dbo].[Update_CrimeCoordinates]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Set Variables
	DECLARE @MaxLatitude FLOAT
	DECLARE @MinLatitude FLOAT
	DECLARE @MaxLongitude FLOAT
	DECLARE @MinLongitude FLOAT
	DECLARE @GridSize INT

	-- Max grid size on map X by X
	SET @GridSize = 200

	-- Get max values for latitude and longitude
	SELECT	@MaxLatitude = Max(Latitude),
			@MinLatitude = Min(Latitude),
			@MaxLongitude = Max(Longitude),
			@MinLongitude = Min(Longitude)
	FROM Crime

	--Generate small square grid
	EXEC Insert_GridSmall @MaxLatitude, @MinLatitude, @MaxLongitude, @MinLongitude, @GridSize

	--Generate large square grid (x2 bigger than small grid squares)
	SET @GridSize = @GridSize / 2

	EXEC Insert_GridLarge @MaxLatitude, @MinLatitude, @MaxLongitude, @MinLongitude, @GridSize

	-- Assign each crime point to a place on the small grid for grouping of crimes together
	UPDATE Crime
	SET GridSmallId = g.GridSmallId
	FROM Crime c
	LEFT JOIN GridSmall g
		ON c.Latitude >= g.BotLeftLatitude
		AND c.Latitude < g.TopRightLatitude
		AND c.Longitude >= g.BotLeftLongitude
		AND c.Longitude < g.TopRightLongitude

	-- Assign each crime point to a place on the large grid for grouping of crimes together
	UPDATE Crime
	SET GridLargeId = g.GridLargeId
	FROM Crime c
	LEFT JOIN GridLarge g
		ON c.Latitude >= g.BotLeftLatitude
		AND c.Latitude < g.TopRightLatitude
		AND c.Longitude >= g.BotLeftLongitude
		AND c.Longitude < g.TopRightLongitude

	

END
GO
