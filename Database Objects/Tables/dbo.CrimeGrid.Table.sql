USE [Crime]
GO
/****** Object:  Table [dbo].[CrimeGrid]    Script Date: 12/20/2019 6:22:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CrimeGrid](
	[CrimeGridId] [int] IDENTITY(1,1) NOT NULL,
	[CrimeDate] [date] NULL,
	[DayOfWeek] [int] NULL,
	[MonthOfYear] [int] NULL,
	[DayOfYear] [int] NULL,
	[Year] [int] NULL,
	[IncidentOccurred] [int] NULL,
	[PriorIncident1Day] [int] NULL,
	[PriorIncident2Days] [int] NULL,
	[PriorIncident3Days] [int] NULL,
	[PriorIncident7Days] [int] NULL,
	[PriorIncident14Days] [int] NULL,
	[PriorIncident30Days] [int] NULL,
	[PriorIncident60Days] [int] NULL,
	[GridSmallId] [int] NULL,
	[GridLargeId] [int] NULL
) ON [PRIMARY]
GO
