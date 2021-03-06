USE [Crime]
GO
/****** Object:  StoredProcedure [dbo].[Insert_CrimeGrid]    Script Date: 1/18/2020 3:26:58 PM ******/
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

	-- Generate all combinations of dates for each square on the small grid
	IF OBJECT_ID('tempdb..#TempFullGridDates_Small') IS NOT NULL
	BEGIN
		DROP TABLE #TempFullGridDates_Small
	END

	SELECT	td.CrimeDate,
			gs.GridSmallId,
			gs.GridLargeId
	INTO #TempFullGridDates_Small
	FROM #TempDateGen td
	CROSS JOIN GridSmall gs

	CREATE INDEX #IDX_TempFullGridDates_GridSmallId ON #TempFullGridDates_Small (CrimeDate, GridSmallId)

	-- Combine full grid with small and large grids to determine incidents per square. Include all of the zero incident time periods.
	TRUNCATE TABLE CrimeGrid

	INSERT INTO CrimeGrid(
		CrimeDate,
		DayOfWeek,
		MonthOfYear,
		DayOfYear,
		Year,
		IncidentOccurred,
		GridSmallId,
		GridLargeId
	)
	SELECT	tf.CrimeDate,
			DATEPART(dw, tf.CrimeDate),
			DATEPART(mm, tf.CrimeDate),
			DATEPART(dy, tf.CrimeDate),
			DATEPART(yy, tf.CrimeDate),
			CASE WHEN c.TotalIncidents > 0 THEN 1 ELSE 0 END,
			tf.GridSmallId,
			tf.GridLargeId
	FROM #TempFullGridDates_Small tf
	LEFT JOIN Crime c
		ON c.CrimeDate = tf.CrimeDate
		AND c.GridSmallId = tf.GridSmallId

	-- Add lag features when other crimes occurred for the small grid
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
		ON cg2.IncidentOccurred >= 1
		AND cg2.GridSmallId = cg.GridSmallId
		AND cg2.CrimeDate < cg.CrimeDate
	GROUP BY cg.CrimeGridId

	CREATE INDEX #IDX_TempCrimeEpicenters_CrimeGridId ON #TempCrimeEpicenters (CrimeGridId)

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

	-- Add lag features when other crimes occurred for the large grid
	IF OBJECT_ID('tempdb..#TempCrimeEpicenters_Large') IS NOT NULL
	BEGIN
		DROP TABLE #TempCrimeEpicenters_Large
	END

	SELECT	cg.GridLargeId,
			cg.CrimeDate,
			Sum(cg.PriorIncident1Day) as 'PriorIncident1Day',
			Sum(cg.PriorIncident2Days) as 'PriorIncident2Days',
			Sum(cg.PriorIncident3Days) as 'PriorIncident3Days',
			Sum(cg.PriorIncident7Days) as 'PriorIncident7Days',
			Sum(cg.PriorIncident14Days) as 'PriorIncident14Days',
			Sum(cg.PriorIncident30Days) as 'PriorIncident30Days'
	INTO #TempCrimeEpicenters_Large
	FROM CrimeGrid cg
	WHERE cg.IncidentOccurred >= 1
	GROUP BY 
		cg.GridLargeId,
		cg.CrimeDate

	CREATE INDEX #IDX_TempCrimeEpicenters_Large_IDDate ON #TempCrimeEpicenters_Large (GridLargeId, CrimeDate)

	UPDATE CrimeGrid
	SET PriorIncident1Day_Large = tce.PriorIncident1Day,
		PriorIncident2Days_Large = tce.PriorIncident2Days,
		PriorIncident3Days_Large = tce.PriorIncident3Days,
		PriorIncident7Days_Large = tce.PriorIncident7Days,
		PriorIncident14Days_Large = tce.PriorIncident14Days,
		PriorIncident30Days_Large = tce.PriorIncident30Days
	FROM CrimeGrid cg
	JOIN #TempCrimeEpicenters_Large tce
		ON tce.GridLargeId = cg.GridLargeId
		AND tce.CrimeDate = cg.CrimeDate


END
GO
