USE [Crime]
GO
/****** Object:  StoredProcedure [dbo].[Insert_CrimeGrid]    Script Date: 12/20/2019 6:21:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jason Wittenauer
-- Create date: 12/18/2019
-- Description:	Create a grid of all the coordinates 
-- =============================================
CREATE PROCEDURE [dbo].[Insert_CrimeGrid]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Generate full date range for the data set
	DECLARE @MinDate DATE
	DECLARE @MaxDate DATE

	SELECT	@MinDate = Min(CrimeDate),
			@MaxDate = Max(CrimeDate)
	FROM Crime

	IF OBJECT_ID('tempdb..#TempDateGen') IS NOT NULL
	BEGIN
		DROP TABLE #TempDateGen
	END

	;WITH dateGen AS (
		SELECT @MinDate AS CrimeDate
		UNION ALL
		SELECT DATEADD(DAY, 1, CrimeDate)  FROM dateGen WHERE DATEADD(DAY, 1, CrimeDate) <= @MaxDate
	)
	SELECT *
	INTO #TempDateGen
	FROM dateGen
	OPTION (MAXRECURSION 5000)

	-- Generate all combinations of dates for each square on the grid
	IF OBJECT_ID('tempdb..#TempFullGridDates') IS NOT NULL
	BEGIN
		DROP TABLE #TempFullGridDates
	END

	SELECT	CrimeDate,
			GridSmallId
	INTO #TempFullGridDates
	FROM #TempDateGen
	CROSS JOIN GridSmall

	CREATE INDEX #IDX_TempFullGridDates_GridSmallId ON #TempFullGridDates (CrimeDate, GridSmallId)

	-- Combine full grid with crime grid to determine incidents per square and include all of the zeroe incident time periods.
	TRUNCATE TABLE CrimeGrid

	INSERT INTO CrimeGrid(
		CrimeDate,
		DayOfWeek,
		MonthOfYear,
		DayOfYear,
		Year,
		IncidentOccurred,
		GridSmallId
	)
	SELECT	tf.CrimeDate,
			DATEPART(dw, tf.CrimeDate),
			DATEPART(mm, tf.CrimeDate),
			DATEPART(dy, tf.CrimeDate),
			DATEPART(yy, tf.CrimeDate),
			CASE WHEN c.TotalIncidents > 0 THEN 1 ELSE 0 END,
			tf.GridSmallId
	FROM #TempFullGridDates tf
	LEFT JOIN Crime c
		ON c.CrimeDate = tf.CrimeDate
		AND c.GridSmallId = tf.GridSmallId

	-- Add lag features when other crimes occurred
	IF OBJECT_ID('tempdb..#TempCrimeEpicenters') IS NOT NULL
	BEGIN
		DROP TABLE #TempCrimeEpicenters
	END

	SELECT	cg.CrimeGridId,
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 1 THEN 1 ELSE 0 END) as 'PriorIncident1Day',
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) > 1 AND DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 2 THEN 1 ELSE 0 END) as 'PriorIncident2Days',
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) > 2 AND DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 3 THEN 1 ELSE 0 END) as 'PriorIncident3Days',
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) > 3 AND DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 7 THEN 1 ELSE 0 END) as 'PriorIncident7Days',
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) > 7 AND DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 14 THEN 1 ELSE 0 END) as 'PriorIncident14Days',
			Sum(CASE WHEN DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) > 14 AND DATEDIFF(d, cg2.CrimeDate, cg.CrimeDate) <= 30 THEN 1 ELSE 0 END) as 'PriorIncident30Days'
	INTO #TempCrimeEpicenters
	FROM CrimeGrid cg
	LEFT JOIN CrimeGrid cg2
		ON cg2.IncidentOccurred = 1
		AND cg2.GridSmallId = cg.GridSmallId
		AND cg2.CrimeDate < cg.CrimeDate
	GROUP BY cg.CrimeGridId

	UPDATE CrimeGrid
	SET PriorIncident1Day = tce.PriorIncident1Day,
		PriorIncident2Days = tce.PriorIncident2Days,
		PriorIncident3Days = tce.PriorIncident3Days,
		PriorIncident7Days = tce.PriorIncident7Days,
		PriorIncident14Days = tce.PriorIncident14Days,
		PriorIncident30Days = tce.PriorIncident30Days
	FROM CrimeGrid cg
	JOIN #TempCrimeEpicenters tce
		ON tce.CrimeGridId = cg.CrimeGridId


END
GO
