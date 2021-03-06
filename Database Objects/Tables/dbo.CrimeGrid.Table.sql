USE [Crime]
GO
/****** Object:  Table [dbo].[CrimeGrid]    Script Date: 1/18/2020 3:25:09 PM ******/
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
	[GridLargeId] [int] NULL,
	[PriorIncident1Day_Large] [int] NULL,
	[PriorIncident2Days_Large] [int] NULL,
	[PriorIncident3Days_Large] [int] NULL,
	[PriorIncident7Days_Large] [int] NULL,
	[PriorIncident14Days_Large] [int] NULL,
	[PriorIncident30Days_Large] [int] NULL,
	[PriorIncident60Days_Large] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [IncidentOccurred]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident1Day]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident2Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident3Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident7Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident14Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident30Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident60Days]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident1Day_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident2Days_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident3Days_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident7Days_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident14Days_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident30Days_Large]
GO
ALTER TABLE [dbo].[CrimeGrid] ADD  DEFAULT ((0)) FOR [PriorIncident60Days_Large]
GO
