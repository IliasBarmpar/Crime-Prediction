USE [Crime]
GO
/****** Object:  Table [dbo].[GridSmall]    Script Date: 1/18/2020 3:25:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GridSmall](
	[GridSmallId] [int] IDENTITY(1,1) NOT NULL,
	[BotLeftLatitude] [float] NULL,
	[TopRightLatitude] [float] NULL,
	[BotLeftLongitude] [float] NULL,
	[TopRightLongitude] [float] NULL,
	[GridLargeId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_GridSmall_PK]    Script Date: 1/18/2020 3:25:10 PM ******/
CREATE CLUSTERED INDEX [IDX_GridSmall_PK] ON [dbo].[GridSmall]
(
	[GridSmallId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_GridSmall_Coords]    Script Date: 1/18/2020 3:25:10 PM ******/
CREATE NONCLUSTERED INDEX [IDX_GridSmall_Coords] ON [dbo].[GridSmall]
(
	[BotLeftLatitude] ASC,
	[TopRightLatitude] ASC,
	[BotLeftLongitude] ASC,
	[TopRightLongitude] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
