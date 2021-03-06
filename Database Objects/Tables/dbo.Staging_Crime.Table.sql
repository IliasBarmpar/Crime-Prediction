USE [Crime]
GO
/****** Object:  Table [dbo].[Staging_Crime]    Script Date: 1/18/2020 3:25:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staging_Crime](
	[CrimeDate] [varchar](max) NULL,
	[CrimeTime] [varchar](max) NULL,
	[CrimeCode] [varchar](max) NULL,
	[Address] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[InsideOutside] [varchar](max) NULL,
	[Weapon] [varchar](max) NULL,
	[Post] [varchar](max) NULL,
	[District] [varchar](max) NULL,
	[Neighborhood] [varchar](max) NULL,
	[Location] [varchar](max) NULL,
	[Premise] [varchar](max) NULL,
	[TotalIncidents] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
