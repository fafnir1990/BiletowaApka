USE [master]
GO
/****** Object:  Database [BiletowaApka2]    Script Date: 11.06.2019 16:35:21 ******/
CREATE DATABASE [BiletowaApka2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BiletowaApka2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\BiletowaApka2.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BiletowaApka2_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\BiletowaApka2_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [BiletowaApka2] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BiletowaApka2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BiletowaApka2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BiletowaApka2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BiletowaApka2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BiletowaApka2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BiletowaApka2] SET ARITHABORT OFF 
GO
ALTER DATABASE [BiletowaApka2] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BiletowaApka2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BiletowaApka2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BiletowaApka2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BiletowaApka2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BiletowaApka2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BiletowaApka2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BiletowaApka2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BiletowaApka2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BiletowaApka2] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BiletowaApka2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BiletowaApka2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BiletowaApka2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BiletowaApka2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BiletowaApka2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BiletowaApka2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BiletowaApka2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BiletowaApka2] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BiletowaApka2] SET  MULTI_USER 
GO
ALTER DATABASE [BiletowaApka2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BiletowaApka2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BiletowaApka2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BiletowaApka2] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BiletowaApka2] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BiletowaApka2] SET QUERY_STORE = OFF
GO
USE [BiletowaApka2]
GO
/****** Object:  UserDefinedFunction [dbo].[F_USR_ShowSpecimensSimilarToTicket]    Script Date: 11.06.2019 16:35:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-11
-- Description:	Function returns specimens 
--				which are similar to ticket
--				identified by Tic_ID
-- =============================================
CREATE FUNCTION [dbo].[F_USR_ShowSpecimensSimilarToTicket] 
(	
	@Tic_ID int
)
RETURNS @SimilarSpecimens TABLE
	(
		[ID] int
		,[Wartość] decimal(18,2)
		,[Awers] VARBINARY(MAX)
		,[Rewers] VARBINARY(MAX)
		,[Miejscowość] NVARCHAR(100)
		,[Powiat] NVARCHAR(100)
		,[Województwo] NVARCHAR(100)
		,[Uchwała]	NVARCHAR(50)	
		,[Organizator]	NVARCHAR(300)	

	)
AS
	BEGIN

		declare @imported_organisator nvarchar(300)
			   ,@imported_town nvarchar(100)
			   ,@imported_powiat nvarchar(100)
			   ,@imported_voivodership nvarchar(100)
			   ,@imported_resolution_code nvarchar(50)
			   ,@imported_series varchar(10)

		SELECT
			@imported_organisator = Tic_ImportedOrganisatorName
			,@imported_town = Tic_ImportedTown
			,@imported_powiat = Tic_ImportedPowiat
			,@imported_voivodership = Tic_ImportedVoivodership
			,@imported_resolution_code = ISNULL(Tic_ImportedResolutionCode, 'Nieznana')
			,@imported_series = Tic_Series
		FROM [dbo].[Tickets] 
		WHERE Tic_ID = @Tic_ID

		INSERT INTO @SimilarSpecimens
		SELECT [Spe_ID] [ID]
			  ,[Spe_Value] [Wartość]
			  ,[Spe_Obverse] [Awers]
			  ,[Spe_Reverse] [Rewers]
			  ,[Twn_Name]		[Miejscowość]
			  ,[Pow_Name]		[Powiat]
			  ,[Voi_Name]			[Voivodership]
			  ,ISNULL([Res_Code], 'Nieznana')		[Uchwała]
			  ,[Org_Name]		[Organizator]
		  FROM [dbo].[Specimens]
		  JOIN [dbo].Organisators on Spe_OrgID = Org_ID
		  JOIN [dbo].Towns on Org_TwnID = Twn_ID
		  JOIN [dbo].Powiats on Twn_PowID = Pow_ID
		  JOIN [dbo].Voivoderships on Pow_VoiID = Voi_ID
		  LEFT JOIN [dbo].Resolutions on [Spe_ResID] = [Res_ID]
		  WHERE
			   (Org_Name = @imported_organisator or Org_Abbreviation = @imported_organisator)
			   AND Twn_Name = @imported_town
			   AND Pow_Name = @imported_powiat
			   AND Voi_Name = @imported_voivodership
			   AND ISNULL([Res_Code], 'Nieznana') = @imported_resolution_code
			   AND Spe_Series = @imported_series
		
		RETURN
	END 


GO
/****** Object:  Table [dbo].[Users]    Script Date: 11.06.2019 16:35:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Usr_ID] [int] IDENTITY(1,1) NOT NULL,
	[Usr_Name] [nvarchar](50) NOT NULL,
	[Usr_Surname] [nvarchar](50) NOT NULL,
	[Usr_FirstName] [nvarchar](50) NOT NULL,
	[Usr_Email] [nvarchar](100) NOT NULL,
	[Usr_IsAdmin] [smallint] NOT NULL,
	[Usr_Password] [nvarchar](100) NOT NULL,
	[Usr_IsLocked] [smallint] NOT NULL,
	[Usr_IsActivated] [smallint] NOT NULL,
	[Usr_InsertDate] [datetime] NOT NULL,
	[Usr_UpdateDate] [datetime] NOT NULL,
	[Usr_LastConnectionDate] [datetime] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Usr_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Users_UsrEmail] UNIQUE NONCLUSTERED 
(
	[Usr_Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Users_UsrName] UNIQUE NONCLUSTERED 
(
	[Usr_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tickets]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tickets](
	[Tic_ID] [int] IDENTITY(1,1) NOT NULL,
	[Tic_Value] [decimal](18, 2) NOT NULL,
	[Tic_OwnerID] [int] NULL,
	[Tic_Obverse] [nvarchar](500) NOT NULL,
	[Tic_Reverse] [nvarchar](500) NULL,
	[Tic_IsPrivate] [tinyint] NOT NULL,
	[Tic_SpeID] [int] NULL,
	[Tic_Amount] [int] NOT NULL,
	[Tic_Series] [varchar](10) NULL,
	[Tic_ImportedTown] [nvarchar](100) NOT NULL,
	[Tic_ImportedPowiat] [nvarchar](100) NOT NULL,
	[Tic_ImportedVoivodership] [nvarchar](100) NOT NULL,
	[Tic_ImportedResolutionCode] [varchar](50) NULL,
	[Tic_ImportedOrganisatorName] [nvarchar](300) NOT NULL,
	[Tic_Description] [nvarchar](300) NULL,
	[Tic_InsertDate] [datetime] NOT NULL,
	[Tic_UpdateDate] [datetime] NOT NULL,
	[Tic_ImportedPrintery] [nvarchar](300) NULL,
 CONSTRAINT [PK_Tickets] PRIMARY KEY CLUSTERED 
(
	[Tic_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Tickets] UNIQUE NONCLUSTERED 
(
	[Tic_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_ShowAllPublicTickets]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_ShowAllPublicTickets] as
SELECT [Tic_ID] as [ID]
      ,[Tic_Value] as [Wartość]
      ,[Usr_Name] as [Posiadacz] 
      ,[Tic_Obverse] as [Rewers]
      ,[Tic_Reverse] as [Awers]
      ,[Tic_SpeID] as [ID Wzornika]
      ,[Tic_Amount] as [Ilość]
      ,[Tic_Series] as [Seria]
      ,[Tic_ImportedTown] as [Miejscowość]
      ,[Tic_ImportedPowiat] as [Powiat]
      ,[Tic_ImportedVoivodership] as [Województwo] 
      ,[Tic_ImportedResolutionCode] as [Uchwała]
      ,[Tic_ImportedOrganisatorName] as [Organizator]
      ,[Tic_Description] as [Opis]
  FROM [dbo].[Tickets]
  JOIN [dbo].[Users] ON [Usr_ID] = [Tic_OwnerID]
  WHERE [Tic_IsPrivate] = 0
GO
/****** Object:  Table [dbo].[UsersTicketsShare]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersTicketsShare](
	[Uti_ID] [int] IDENTITY(1,1) NOT NULL,
	[Uti_UsrID] [int] NOT NULL,
	[Uti_TicID] [int] NOT NULL,
 CONSTRAINT [PK_UsersTicketsPermissions] PRIMARY KEY CLUSTERED 
(
	[Uti_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_UsersTicketsPermissions] UNIQUE NONCLUSTERED 
(
	[Uti_UsrID] ASC,
	[Uti_TicID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[F_USR_ShowTicketsShared]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-11
-- Description:	Function returns tickets shared 
--				with user identified by Usr_ID
-- =============================================
CREATE FUNCTION [dbo].[F_USR_ShowTicketsShared]
(	
	@Usr_ID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		   [Tic_Value]		[Value]
		  ,[Tic_Series]		[Series]
		  ,[Tic_Obverse]	[Obverse]
		  ,[Tic_Reverse]	[Reverse]
		  ,[Tic_Amount]  [Amount]
		  ,[Tic_ImportedTown]			[Town]
		  ,[Tic_ImportedPowiat]		[Powiat]
		  ,[Tic_ImportedVoivodership]			[Voivodership]
		  ,[Tic_ImportedResolutionCode]		[Resolution]
		  ,[Tic_ImportedOrganisatorName]		[Organisator]
		  ,[Tic_Amount]						[Ilość]


	  FROM [dbo].[Tickets]
	  JOIN [dbo].[UsersTicketsShare] on [Tic_ID] = [Uti_TicID]
	  WHERE [Uti_UsrID] = @Usr_ID
)
GO
/****** Object:  Table [dbo].[Resolutions]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resolutions](
	[Res_ID] [int] IDENTITY(1,1) NOT NULL,
	[Res_Code] [varchar](50) NOT NULL,
	[Res_TwnID] [int] NOT NULL,
	[Res_Resolution] [varbinary](max) NOT NULL,
	[Res_Description] [nvarchar](500) NULL,
	[Res_DateFrom] [date] NOT NULL,
	[Res_DateTo] [date] NULL,
	[Res_InsertDate] [datetime] NOT NULL,
	[Res_UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Resolutions] PRIMARY KEY CLUSTERED 
(
	[Res_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Resolutions] UNIQUE NONCLUSTERED 
(
	[Res_Code] ASC,
	[Res_TwnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organisators]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organisators](
	[Org_ID] [int] IDENTITY(1,1) NOT NULL,
	[Org_Name] [nvarchar](300) NOT NULL,
	[Org_Abbreviation] [nvarchar](50) NULL,
	[Org_TwnID] [int] NOT NULL,
 CONSTRAINT [PK_Organisators] PRIMARY KEY CLUSTERED 
(
	[Org_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Powiats]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Powiats](
	[Pow_ID] [int] IDENTITY(1,1) NOT NULL,
	[Pow_Name] [nvarchar](100) NOT NULL,
	[Pow_VoiID] [int] NOT NULL,
 CONSTRAINT [PK_Powiats] PRIMARY KEY CLUSTERED 
(
	[Pow_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Powiats_PowNamePowVoiID] UNIQUE NONCLUSTERED 
(
	[Pow_Name] ASC,
	[Pow_VoiID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Voivoderships]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Voivoderships](
	[Voi_ID] [int] IDENTITY(1,1) NOT NULL,
	[Voi_Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Voivorerships] PRIMARY KEY CLUSTERED 
(
	[Voi_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Voivoderships_VoiName] UNIQUE NONCLUSTERED 
(
	[Voi_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Towns]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Towns](
	[Twn_ID] [int] IDENTITY(1,1) NOT NULL,
	[Twn_Name] [nvarchar](100) NOT NULL,
	[Twn_PowID] [int] NOT NULL,
 CONSTRAINT [PK_Towns] PRIMARY KEY CLUSTERED 
(
	[Twn_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Towns_TwnNamePowID] UNIQUE NONCLUSTERED 
(
	[Twn_Name] ASC,
	[Twn_PowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SuggestedSpecimens]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SuggestedSpecimens](
	[Ssp_ID] [int] IDENTITY(1,1) NOT NULL,
	[Ssp_TicID] [int] NOT NULL,
	[Ssp_OrgID] [int] NOT NULL,
	[SSp_PrtID] [int] NULL,
	[Ssp_ResID] [int] NULL,
 CONSTRAINT [PK_SuggestedSpecimens] PRIMARY KEY CLUSTERED 
(
	[Ssp_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[F_USR_ShowSpecimensSuggestedByUSer]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-11
-- Description:	Function returns specimens 
--				suggested by user identified
--				by usr_id 
-- =============================================
CREATE FUNCTION [dbo].[F_USR_ShowSpecimensSuggestedByUSer]
(	
	@Usr_ID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		   [Tic_Value]		[Wartość]
		  ,[Tic_Series]		[Seria]
		  ,[Tic_Obverse]	[Awers]
		  ,[Tic_Reverse]	[Rewers]
		  ,[Twn_Name]			[Miejscowość]
		  ,[Pow_Name]		[Powiat]
		  ,[Voi_Name]			[Voivodership]
		  ,ISNULL([Res_Code], 'Nieznana')		[Uchwała]
		  ,[Org_Name]		[Organizator]

	  FROM [dbo].[Tickets]
	  JOIN [dbo].[SuggestedSpecimens] on [Tic_ID] = [Ssp_TicID]
	  JOIN [dbo].Organisators on Ssp_OrgID = Org_ID
	  JOIN [dbo].Towns on Org_TwnID = Twn_ID
	  JOIN [dbo].Powiats on Twn_PowID = Pow_ID
	  JOIN [dbo].Voivoderships on Pow_VoiID = Voi_ID
	  LEFT JOIN [dbo].Resolutions on [Ssp_ResID] = [Res_ID]
	  WHERE [Tic_OwnerID] = @Usr_ID
)
GO
/****** Object:  UserDefinedFunction [dbo].[F_USR_ShowTicketsForExchange]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-06
-- Description:	Function returns tickets for exchange
--				for current user
-- =============================================
CREATE FUNCTION [dbo].[F_USR_ShowTicketsForExchange]
(	
	@Tic_OwnerID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		   [Tic_Value]		[Wartość]
		  ,[Tic_Series]		[Seria]
		  ,[Tic_Obverse]	[Awers]
		  ,[Tic_Reverse]	[Rewers]
		  ,[Tic_Amount] - 1 [Ilość na wymianę] --one ticket should remains in collection
		  ,Tic_ImportedTown			[Town]
		  ,Tic_ImportedPowiat			[Powiat]
		  ,Tic_ImportedVoivodership			[Województwo]
		  ,Tic_ImportedResolutionCode		[Uchwała]
		  ,Tic_ImportedOrganisatorName		[Organizator]
		  ,isnull(Tic_Description, '')		[Opis]


	  FROM [dbo].[Tickets]
	  WHERE Tic_OwnerID = @Tic_OwnerID and Tic_Amount >= 1
)
GO
/****** Object:  Table [dbo].[abc]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[abc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[password] [nvarchar](128) NOT NULL,
	[last_login] [datetime2](7) NULL,
	[is_superuser] [bit] NOT NULL,
	[username] [nvarchar](30) NOT NULL,
	[first_name] [nvarchar](30) NOT NULL,
	[last_name] [nvarchar](30) NOT NULL,
	[email] [nvarchar](254) NOT NULL,
	[is_staff] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[date_joined] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](80) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_group_permissions_group_id_permission_id_0cd325b0_uniq] UNIQUE NONCLUSTERED 
(
	[group_id] ASC,
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_permission]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_permission](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[content_type_id] [int] NOT NULL,
	[codename] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_permission_content_type_id_codename_01ab375a_uniq] UNIQUE NONCLUSTERED 
(
	[content_type_id] ASC,
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[password] [nvarchar](128) NOT NULL,
	[last_login] [datetime2](7) NULL,
	[is_superuser] [bit] NOT NULL,
	[username] [nvarchar](150) NOT NULL,
	[first_name] [nvarchar](30) NOT NULL,
	[last_name] [nvarchar](150) NOT NULL,
	[email] [nvarchar](254) NOT NULL,
	[is_staff] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[date_joined] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_username_6821ab7c_uniq] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user_groups]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_groups](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[group_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_groups_user_id_group_id_94350c0c_uniq] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_user_user_permissions]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_user_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_user_permissions_user_id_permission_id_14a6b632_uniq] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 11.06.2019 16:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_admin_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[action_time] [datetime2](7) NOT NULL,
	[object_id] [nvarchar](max) NULL,
	[object_repr] [nvarchar](200) NOT NULL,
	[action_flag] [smallint] NOT NULL,
	[change_message] [nvarchar](max) NOT NULL,
	[content_type_id] [int] NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_content_type]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_content_type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app_label] [nvarchar](100) NOT NULL,
	[model] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [django_content_type_app_label_model_76bd3d3b_uniq] UNIQUE NONCLUSTERED 
(
	[app_label] ASC,
	[model] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_migrations]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_migrations](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[applied] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_session]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_session](
	[session_key] [nvarchar](40) NOT NULL,
	[session_data] [nvarchar](max) NOT NULL,
	[expire_date] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[session_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewsletterLogs]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsletterLogs](
	[Log_ID] [int] IDENTITY(1,1) NOT NULL,
	[Log_Date] [datetime] NOT NULL,
	[Log_Success] [smallint] NOT NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[Log_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Printeries]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Printeries](
	[Prt_ID] [int] IDENTITY(1,1) NOT NULL,
	[Prt_Name] [nvarchar](300) NOT NULL,
	[Prt_Abbreviation] [nvarchar](300) NULL,
 CONSTRAINT [PK_Printeries] PRIMARY KEY CLUSTERED 
(
	[Prt_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_PrinteriesName] UNIQUE NONCLUSTERED 
(
	[Prt_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Specimens]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Specimens](
	[Spe_ID] [int] IDENTITY(1,1) NOT NULL,
	[Spe_Value] [decimal](18, 2) NOT NULL,
	[Spe_ResID] [int] NULL,
	[Spe_Obverse] [nvarchar](500) NOT NULL,
	[Spe_Reverse] [nvarchar](500) NOT NULL,
	[Spe_OrgID] [int] NULL,
	[Spe_Series] [varchar](10) NULL,
	[Spe_InsertDate] [datetime] NOT NULL,
	[Spe_UpdateDate] [datetime] NOT NULL,
	[Spe_PrtID] [int] NULL,
 CONSTRAINT [PK_Specimens] PRIMARY KEY CLUSTERED 
(
	[Spe_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Statuses]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Statuses](
	[Sta_ID] [int] IDENTITY(1,1) NOT NULL,
	[Sta_Name] [varchar](20) NOT NULL,
	[Sta_Description] [varchar](300) NULL,
 CONSTRAINT [PK_Statuses] PRIMARY KEY CLUSTERED 
(
	[Sta_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_Statuses_StaName] UNIQUE NONCLUSTERED 
(
	[Sta_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SuggestedResolutions]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SuggestedResolutions](
	[Sre_ID] [int] IDENTITY(1,1) NOT NULL,
	[Sre_Resolution] [nvarchar](500) NOT NULL,
	[Sre_Description] [nvarchar](500) NULL,
	[Sre_DateFrom] [date] NOT NULL,
	[Sre_DateTo] [date] NULL,
	[Sre_InsertDate] [datetime] NOT NULL,
	[Sre_UpdateDate] [datetime] NOT NULL,
	[Sre_OwnerID] [int] NOT NULL,
	[Sre_ImportedCode] [varchar](50) NOT NULL,
	[Sre_ImportedTown] [nvarchar](100) NOT NULL,
	[Sre_ImportedPowiat] [nvarchar](100) NOT NULL,
	[Sre_ImportedVoivodership] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SuggestedResolutions] PRIMARY KEY CLUSTERED 
(
	[Sre_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TownsUsers]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TownsUsers](
	[Ciu_UsrID] [int] NOT NULL,
	[Ciu_TwnID] [int] NOT NULL,
	[Ciu_ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_TownsUsers] PRIMARY KEY CLUSTERED 
(
	[Ciu_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_TownsUsers] UNIQUE NONCLUSTERED 
(
	[Ciu_UsrID] ASC,
	[Ciu_TwnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_group_id_b120cbf9]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_group_id_b120cbf9] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_permission_id_84c5c92e]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_permission_id_84c5c92e] ON [dbo].[auth_group_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_permission_content_type_id_2f476e4b]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_permission_content_type_id_2f476e4b] ON [dbo].[auth_permission]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_group_id_97559544]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_group_id_97559544] ON [dbo].[auth_user_groups]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_user_id_6a12ed8b]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_user_id_6a12ed8b] ON [dbo].[auth_user_groups]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_permission_id_1fbb5f2c]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_permission_id_1fbb5f2c] ON [dbo].[auth_user_user_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_user_id_a95ead1b]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_user_id_a95ead1b] ON [dbo].[auth_user_user_permissions]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_content_type_id_c4bce8eb]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_content_type_id_c4bce8eb] ON [dbo].[django_admin_log]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_user_id_c564eba6]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_user_id_c564eba6] ON [dbo].[django_admin_log]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_session_expire_date_a5c62663]    Script Date: 11.06.2019 16:35:24 ******/
CREATE NONCLUSTERED INDEX [django_session_expire_date_a5c62663] ON [dbo].[django_session]
(
	[expire_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Organisators_NameTwnID]    Script Date: 11.06.2019 16:35:24 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Organisators_NameTwnID] ON [dbo].[Organisators]
(
	[Org_Name] ASC,
	[Org_TwnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_Tickets_Tic_SpeID]  DEFAULT (NULL) FOR [Tic_SpeID]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_Tickets_Tic_Amount]  DEFAULT ((1)) FOR [Tic_Amount]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_ImportedTown]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedTown]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_ImportedPowiat]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedPowiat]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_ImportedVoivodership]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedVoivodership]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_ResolutionCode]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedResolutionCode]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF_OrganisatorName]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedOrganisatorName]
GO
ALTER TABLE [dbo].[Tickets] ADD  CONSTRAINT [DF__Tickets__Tic_Imp__02084FDA]  DEFAULT (N'Niezaimportowany') FOR [Tic_ImportedPrintery]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Usr_IsAdmin]  DEFAULT ((0)) FOR [Usr_IsAdmin]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Usr_IsLocked]  DEFAULT ((0)) FOR [Usr_IsLocked]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Usr_IsActivated]  DEFAULT ((0)) FOR [Usr_IsActivated]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_permission]  WITH CHECK ADD  CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[auth_permission] CHECK CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_user_id_c564eba6_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_user_id_c564eba6_fk_auth_user_id]
GO
ALTER TABLE [dbo].[Organisators]  WITH NOCHECK ADD  CONSTRAINT [FK_Organisators_Towns] FOREIGN KEY([Org_TwnID])
REFERENCES [dbo].[Towns] ([Twn_ID])
GO
ALTER TABLE [dbo].[Organisators] CHECK CONSTRAINT [FK_Organisators_Towns]
GO
ALTER TABLE [dbo].[Powiats]  WITH NOCHECK ADD  CONSTRAINT [FK_Powiats_Voivoderships] FOREIGN KEY([Pow_VoiID])
REFERENCES [dbo].[Voivoderships] ([Voi_ID])
GO
ALTER TABLE [dbo].[Powiats] CHECK CONSTRAINT [FK_Powiats_Voivoderships]
GO
ALTER TABLE [dbo].[Resolutions]  WITH NOCHECK ADD  CONSTRAINT [FK_Resolutions_Towns] FOREIGN KEY([Res_TwnID])
REFERENCES [dbo].[Towns] ([Twn_ID])
GO
ALTER TABLE [dbo].[Resolutions] CHECK CONSTRAINT [FK_Resolutions_Towns]
GO
ALTER TABLE [dbo].[Specimens]  WITH NOCHECK ADD  CONSTRAINT [FK_Specimens_Organisators] FOREIGN KEY([Spe_OrgID])
REFERENCES [dbo].[Organisators] ([Org_ID])
GO
ALTER TABLE [dbo].[Specimens] CHECK CONSTRAINT [FK_Specimens_Organisators]
GO
ALTER TABLE [dbo].[Specimens]  WITH CHECK ADD  CONSTRAINT [FK_Specimens_Pritneries] FOREIGN KEY([Spe_PrtID])
REFERENCES [dbo].[Printeries] ([Prt_ID])
GO
ALTER TABLE [dbo].[Specimens] CHECK CONSTRAINT [FK_Specimens_Pritneries]
GO
ALTER TABLE [dbo].[Specimens]  WITH NOCHECK ADD  CONSTRAINT [FK_Specimens_Resolutions] FOREIGN KEY([Spe_ResID])
REFERENCES [dbo].[Resolutions] ([Res_ID])
GO
ALTER TABLE [dbo].[Specimens] CHECK CONSTRAINT [FK_Specimens_Resolutions]
GO
ALTER TABLE [dbo].[SuggestedResolutions]  WITH NOCHECK ADD  CONSTRAINT [FK_SuggestedResolutions_Users] FOREIGN KEY([Sre_OwnerID])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[SuggestedResolutions] CHECK CONSTRAINT [FK_SuggestedResolutions_Users]
GO
ALTER TABLE [dbo].[SuggestedSpecimens]  WITH NOCHECK ADD  CONSTRAINT [FK_SuggestedSpecimens_Organisators] FOREIGN KEY([Ssp_OrgID])
REFERENCES [dbo].[Organisators] ([Org_ID])
GO
ALTER TABLE [dbo].[SuggestedSpecimens] CHECK CONSTRAINT [FK_SuggestedSpecimens_Organisators]
GO
ALTER TABLE [dbo].[SuggestedSpecimens]  WITH CHECK ADD  CONSTRAINT [FK_SuggestedSpecimens_Printeries] FOREIGN KEY([SSp_PrtID])
REFERENCES [dbo].[Printeries] ([Prt_ID])
GO
ALTER TABLE [dbo].[SuggestedSpecimens] CHECK CONSTRAINT [FK_SuggestedSpecimens_Printeries]
GO
ALTER TABLE [dbo].[SuggestedSpecimens]  WITH NOCHECK ADD  CONSTRAINT [FK_SuggestedSpecimens_Resolutions] FOREIGN KEY([Ssp_ResID])
REFERENCES [dbo].[Resolutions] ([Res_ID])
GO
ALTER TABLE [dbo].[SuggestedSpecimens] CHECK CONSTRAINT [FK_SuggestedSpecimens_Resolutions]
GO
ALTER TABLE [dbo].[SuggestedSpecimens]  WITH NOCHECK ADD  CONSTRAINT [FK_SuggestedSpecimens_Tickets] FOREIGN KEY([Ssp_TicID])
REFERENCES [dbo].[Tickets] ([Tic_ID])
GO
ALTER TABLE [dbo].[SuggestedSpecimens] CHECK CONSTRAINT [FK_SuggestedSpecimens_Tickets]
GO
ALTER TABLE [dbo].[Tickets]  WITH NOCHECK ADD  CONSTRAINT [FK_Tickets_Owner_UsrID] FOREIGN KEY([Tic_OwnerID])
REFERENCES [dbo].[auth_user] ([id])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [FK_Tickets_Owner_UsrID]
GO
ALTER TABLE [dbo].[Tickets]  WITH NOCHECK ADD  CONSTRAINT [FK_Tickets_Specimens] FOREIGN KEY([Tic_SpeID])
REFERENCES [dbo].[Specimens] ([Spe_ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [FK_Tickets_Specimens]
GO
ALTER TABLE [dbo].[Towns]  WITH NOCHECK ADD  CONSTRAINT [FK_Towns_Powiats] FOREIGN KEY([Twn_PowID])
REFERENCES [dbo].[Powiats] ([Pow_ID])
GO
ALTER TABLE [dbo].[Towns] CHECK CONSTRAINT [FK_Towns_Powiats]
GO
ALTER TABLE [dbo].[TownsUsers]  WITH NOCHECK ADD  CONSTRAINT [FK_TownsUsers_TwnID] FOREIGN KEY([Ciu_TwnID])
REFERENCES [dbo].[Towns] ([Twn_ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TownsUsers] CHECK CONSTRAINT [FK_TownsUsers_TwnID]
GO
ALTER TABLE [dbo].[TownsUsers]  WITH NOCHECK ADD  CONSTRAINT [FK_TownsUsers_UsrID] FOREIGN KEY([Ciu_UsrID])
REFERENCES [dbo].[auth_user] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TownsUsers] CHECK CONSTRAINT [FK_TownsUsers_UsrID]
GO
ALTER TABLE [dbo].[UsersTicketsShare]  WITH NOCHECK ADD  CONSTRAINT [FK_UsersTicketsPermissions_Tickets] FOREIGN KEY([Uti_TicID])
REFERENCES [dbo].[Tickets] ([Tic_ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsersTicketsShare] CHECK CONSTRAINT [FK_UsersTicketsPermissions_Tickets]
GO
ALTER TABLE [dbo].[UsersTicketsShare]  WITH NOCHECK ADD  CONSTRAINT [FK_UsersTicketsPermissions_Users] FOREIGN KEY([Uti_UsrID])
REFERENCES [dbo].[auth_user] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsersTicketsShare] CHECK CONSTRAINT [FK_UsersTicketsPermissions_Users]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
ALTER TABLE [dbo].[NewsletterLogs]  WITH CHECK ADD  CONSTRAINT [CK_NewsletterLogs_Success] CHECK  (([Log_Success]=(1) OR [Log_Success]=(0)))
GO
ALTER TABLE [dbo].[NewsletterLogs] CHECK CONSTRAINT [CK_NewsletterLogs_Success]
GO
ALTER TABLE [dbo].[Resolutions]  WITH NOCHECK ADD  CONSTRAINT [CK_Resolutions_DateFrom_and_DateTo] CHECK  (([Res_DateTo] IS NULL OR [Res_DateFrom]<=[Res_DateTo]))
GO
ALTER TABLE [dbo].[Resolutions] CHECK CONSTRAINT [CK_Resolutions_DateFrom_and_DateTo]
GO
ALTER TABLE [dbo].[Specimens]  WITH NOCHECK ADD  CONSTRAINT [CK_Specimens_SpeValue] CHECK  (([Spe_Value]>=(0)))
GO
ALTER TABLE [dbo].[Specimens] CHECK CONSTRAINT [CK_Specimens_SpeValue]
GO
ALTER TABLE [dbo].[SuggestedResolutions]  WITH NOCHECK ADD  CONSTRAINT [CK_SuggestedResolutions_DateFrom_and_DateTo] CHECK  (([Sre_DateTo] IS NULL OR [Sre_DateFrom]<=[Sre_DateTo]))
GO
ALTER TABLE [dbo].[SuggestedResolutions] CHECK CONSTRAINT [CK_SuggestedResolutions_DateFrom_and_DateTo]
GO
ALTER TABLE [dbo].[Tickets]  WITH NOCHECK ADD  CONSTRAINT [CK_Tickets_TicAmount] CHECK  (([Tic_Amount]>=(0)))
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [CK_Tickets_TicAmount]
GO
ALTER TABLE [dbo].[Tickets]  WITH NOCHECK ADD  CONSTRAINT [CK_Tickets_TicIsPrivate] CHECK  (([Tic_IsPrivate]=(1) OR [Tic_IsPrivate]=(0)))
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [CK_Tickets_TicIsPrivate]
GO
ALTER TABLE [dbo].[Tickets]  WITH NOCHECK ADD  CONSTRAINT [CK_Tickets_TicValue] CHECK  (([Tic_Value]>=(0)))
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [CK_Tickets_TicValue]
GO
ALTER TABLE [dbo].[Users]  WITH NOCHECK ADD  CONSTRAINT [CK_Users_Usr_IsActivated] CHECK  (([Usr_IsActivated]=(1) OR [Usr_IsActivated]=(0)))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_Usr_IsActivated]
GO
ALTER TABLE [dbo].[Users]  WITH NOCHECK ADD  CONSTRAINT [CK_Users_Usr_IsAdmin] CHECK  (([Usr_IsAdmin]=(1) OR [Usr_IsAdmin]=(0)))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_Usr_IsAdmin]
GO
ALTER TABLE [dbo].[Users]  WITH NOCHECK ADD  CONSTRAINT [CK_Users_Usr_IsLocked] CHECK  (([Usr_IsLocked]=(1) OR [Usr_IsLocked]=(0)))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_Usr_IsLocked]
GO
/****** Object:  StoredProcedure [dbo].[ADM_Logs_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Insert single record to Logs table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Logs_Insert_Single]
    @Log_ObjID int
    ,@Log_Table nvarchar(100)
    ,@Log_OperationType nvarchar(20)
    ,@Log_UsrID int
    ,@Log_Date datetime
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[Logs]
           (
            [Log_ObjID]
           ,[Log_Table]
           ,[Log_OperationType]
           ,[Log_UsrID]
           ,[Log_Date])
     VALUES
           (
            @Log_ObjID
           ,@Log_Table
           ,@Log_OperationType
           ,@Log_UsrID
           ,@Log_Date
		   )
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Powiats_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete single record from Powiats table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Powiats_Delete_Single]
	 @Pow_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].Powiats
	WHERE Powiats.Pow_ID = @Pow_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Powiats_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Insert single record to Powiats table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Powiats_Insert_Single]
	 @Pow_Name nvarchar(100),
	 @Pow_VoiID int
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[Powiats]
           ([Pow_Name]
           ,[Pow_VoiID])
     VALUES
           (@Pow_Name
           ,@Pow_VoiID)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Powiats_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Update single record in Powiats table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Powiats_Update_Single]
	 @Pow_ID int,
	 @Pow_Name nvarchar(100),
	 @Pow_VoiID int
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].Powiats
		set Pow_VoiID = @Pow_VoiID,
			Pow_Name = @Pow_Name
	WHERE Powiats.Pow_ID = @Pow_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Resolutions_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Delete single record from Specimens table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Resolutions_Delete_Single]
	 @Res_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].Resolutions
	WHERE Resolutions.Res_ID = @Res_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Specimens_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Delete single record from Specimens table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Specimens_Delete_Single]
	 @Spe_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].Specimens
	WHERE Specimens.Spe_ID = @Spe_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Specimens_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-06
-- Description:	Insert single record to Specimens table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Specimens_Insert_Single]
	 @Spe_Value decimal(18,2)
	 ,@Spe_ResID int
	 ,@Spe_OrgID int
	 ,@Spe_Series varchar(10)
	 ,@Spe_Obverse varbinary(max)
	 ,@Spe_Reverse varbinary(max)

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[Specimens]
	([Spe_Value]
	,[Spe_ResID]
	,[Spe_OrgID]
	,[Spe_Series]
	,[Spe_Obverse]
	,[Spe_Reverse]
	,[Spe_InsertDate]
	,[Spe_UpdateDate]
	)
	VALUES
	(@Spe_Value
	,@Spe_ResID
	,@Spe_OrgID
	,@Spe_Series
	,@Spe_Obverse
	,@Spe_Reverse
	,getdate()
	,getdate()
	)

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Specimens_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-06
-- Description:	Update single record in Specimens table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Specimens_Update_Single]
	 @Spe_ID int
	 ,@Spe_Value decimal(18,2)
	 ,@Spe_ResID int
	 ,@Spe_OrgID int
	 ,@Spe_Series varchar(10)

AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].[Specimens]
	   SET 
		  [Spe_Value] = @Spe_Value
		  ,[Spe_ResID] = @Spe_ResID
		  ,[Spe_OrgID] = @Spe_OrgID
		  ,[Spe_Series] = @Spe_Series
		  ,[Spe_UpdateDate] = getdate()
	 WHERE Spe_ID = @Spe_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Statuses_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Delete single record from Statuses table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Statuses_Delete_Single]
	 @Sta_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].Statuses
	WHERE Statuses.Sta_ID = @Sta_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Statuses_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-10
-- Description:	Insert single record into Statuses table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Statuses_Insert_Single]
	 @Sta_Name nvarchar(20)
	 ,@Sta_Description nvarchar(300)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].Statuses
	(Sta_Name
	,Sta_Description
	)
	VALUES
	(
	@Sta_Name
	,@Sta_Description
	)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Statuses_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-10
-- Description:	Update single record in Statuses table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Statuses_Update_Single]
	 @Sta_ID int
	 ,@Sta_Name nvarchar(20)
	 ,@Sta_Description nvarchar(300)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].Statuses
		set 
			Sta_Name = @Sta_Name
			,Sta_Description = @Sta_Description
		WHERE Sta_ID = @Sta_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_SuggestedSpecimens_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-06
-- Description:	Insert single record to 
--              SuggestedSpecimens table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_SuggestedSpecimens_Insert_Single]
	 @Ssp_TicID int
	 ,@Ssp_OrgID int
	 ,@Ssp_ResID int

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[SuggestedSpecimens]
	([Ssp_TicID]
	,[Ssp_OrgID]
	,[Ssp_ResID]
	)
	VALUES
	(@Ssp_TicID
	,@Ssp_OrgID
	,@Ssp_ResID
	)

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Tickets_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Delete single record from Tickets table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Tickets_Delete_Single]
	 @Tic_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].Tickets
	WHERE Tickets.Tic_ID = @Tic_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_TicketsInsertSingle]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-17
-- Description:	Insert single ticket into
--				Tickets table.
-- =============================================
CREATE PROCEDURE [dbo].[ADM_TicketsInsertSingle]
	 @Tic_Value decimal(18,2)
	,@Tic_OwnerID int
	,@Tic_Obverse varbinary(max)
	,@Tic_Reverse varbinary(max)
	,@Tic_IsPrivate tinyint
	,@Tic_SpeID int
	,@Tic_Amount int
	,@Tic_Series varchar(10)
	,@Tic_ImportedTown nvarchar(100)
	,@Tic_ImportedPowiat nvarchar(100)
	,@Tic_ImportedVoivodership nvarchar(100)
	,@Tic_ImportedResolutionCode varchar(50)
	,@Tic_ImportedOrganisatorName nvarchar(300)
	,@Tic_Description nvarchar(300)
	,@Tic_InsertDate datetime
	,@Tic_UpdateDate datetime
	,@Tic_ImportedPrintery nvarchar(300)
AS
BEGIN
	INSERT INTO [dbo].[Tickets]
			   ([Tic_Value]
			   ,[Tic_OwnerID]
			   ,[Tic_Obverse]
			   ,[Tic_Reverse]
			   ,[Tic_IsPrivate]
			   ,[Tic_SpeID]
			   ,[Tic_Amount]
			   ,[Tic_Series]
			   ,[Tic_ImportedTown]
			   ,[Tic_ImportedPowiat]
			   ,[Tic_ImportedVoivodership]
			   ,[Tic_ImportedResolutionCode]
			   ,[Tic_ImportedOrganisatorName]
			   ,[Tic_Description]
			   ,[Tic_InsertDate]
			   ,[Tic_UpdateDate]
			   ,[Tic_ImportedPrintery])
		 VALUES
		 (
			@Tic_Value 
			,@Tic_OwnerID 
			,@Tic_Obverse 
			,@Tic_Reverse 
			,@Tic_IsPrivate 
			,@Tic_SpeID 
			,@Tic_Amount 
			,@Tic_Series 
			,@Tic_ImportedTown 
			,@Tic_ImportedPowiat 
			,@Tic_ImportedVoivodership 
			,@Tic_ImportedResolutionCode 
			,@Tic_ImportedOrganisatorName 
			,@Tic_Description 
			,GETDATE() 
			,GETDATE() 
			,@Tic_ImportedPrintery 
		)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Towns_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete single record from Towns table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Towns_Delete_Single]
	 @Twn_ID int
	 ,@Twn_Name  varchar(100)
	 ,@Twn_PowID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].[Towns]
		WHERE [Twn_ID] = @Twn_ID

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Towns_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Insert single record to Towns table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Towns_Insert_Single]
	 @Twn_Name  nvarchar(100)
	 ,@Twn_PowID int
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[Towns]
	(
	[Twn_Name]
	,[Twn_PowID]
	)
	VALUES( @Twn_Name, @Twn_PowID)

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Towns_Insert_Single_Town_Pow_Voi]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-11
-- Description:	Insert single record to Towns table
--				using Voivodership name, Powiat name
--				and town name.
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Towns_Insert_Single_Town_Pow_Voi]
	  @Twn_Name  nvarchar(100) 
	 ,@Pow_Name nvarchar(100)
	 ,@Voi_Name nvarchar(100)
	 ,@message nvarchar(500) OUTPUT
AS
BEGIN
	
	declare @validation_counter int
			,@voi_id int
			,@pow_id int

	EXEC [dbo].[R_ADM_ValidateImportToDictionaryTable]
													'Voivoderships'
													,@Voi_Name
													,null
													,@validation_counter OUTPUT
	IF @validation_counter = 1
		EXEC  [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
													'Voivoderships'
													,@Voi_Name
													,null
													,@voi_id OUTPUT
	ELSE
		BEGIN 
			SET @message = CONCAT('Województwo: ', @Voi_Name
								  ,' nie istnieje w bazie '
								  ,' lub jest niejednoznaczne'
								  )
			PRINT @message
			RETURN -1
		END
	
	EXEC dbo.R_ADM_ValidateImportToDictionaryTable 
											'Powiats'
											,@Pow_Name
											,@voi_id
											,@validation_counter OUTPUT
	IF @validation_counter = 1
	EXEC [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
											'Powiats'
											,@Pow_Name
											,@voi_id
											,@pow_id OUTPUT
	ELSE
		BEGIN 
			SET @message = concat('Powiat: ', @Pow_Name 
								   ,' w województwie: ', @Voi_Name
								   ,' nie istnieje w bazie'
								   ,' lub jest niejednoznaczny')
			PRINT @message
			RETURN -1
		END
	
	IF @pow_id is not null
		BEGIN
			EXEC dbo.ADM_Towns_Insert_Single @Twn_Name, @pow_id
			SET @message = concat('Miejscowość: ', @Twn_Name
								  ,' Powiat: ', @Pow_Name 
								  ,' w województwie: ', @Voi_Name
								  ,' zaimportowana pomyślnie'
								  )
			PRINT @message
			RETURN 0
		END
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Towns_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Update single record from Towns table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Towns_Update_Single]
	 @Twn_ID int
	 ,@Twn_Name  nvarchar(100)
	 ,@Twn_PowID int
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].[Towns]
	   SET 
		  [Twn_Name] = @Twn_Name
		  ,[Twn_PowID] = @Twn_PowID
	 WHERE [Twn_ID] = @Twn_ID

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_TownsUsers_Delete_All_By_UsrID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete all record from 
--				TownsUsers table
--				using Usr_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_TownsUsers_Delete_All_By_UsrID]
	 @Usr_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].TownsUsers
	WHERE TownsUsers.Ciu_UsrID = @Usr_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_TownsUsers_Delete_Single_By_UsrID_TwnID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete all records from 
--				TownsUsers table
--				using Usr_ID ant Twn_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_TownsUsers_Delete_Single_By_UsrID_TwnID]
	 @Usr_ID int,
	 @Twn_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].TownsUsers
	WHERE TownsUsers.Ciu_UsrID = @Usr_ID
		and TownsUsers.Ciu_TwnID = @Twn_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_TownsUsers_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Insert single record to 
--				TownsUsers table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_TownsUsers_Insert_Single]
	 @Usr_ID int,
	 @Twn_ID int
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].TownsUsers (Ciu_UsrID,Ciu_TwnID)
	VALUES (@Usr_ID, @Twn_ID)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Users_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Update single User from Users table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Users_Delete_Single]
	 @Usr_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].[Users]
	WHERE Users.Usr_ID = @Usr_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Users_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Insert single User to Users table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Users_Insert_Single]
     @Usr_Name nvarchar(30)
    ,@Usr_Surname nvarchar(50)
    ,@Usr_FirstName nvarchar(50)
    ,@Usr_Email nvarchar(100)
    ,@Usr_IsAdmin smallint
    ,@Usr_Password nvarchar(100)
    ,@Usr_IsLocked smallint
    ,@Usr_IsActivated smallint
AS
BEGIN
	SET NOCOUNT ON;
INSERT INTO [dbo].[Users]
           ([Usr_Name]
           ,[Usr_Surname]
           ,[Usr_FirstName]
           ,[Usr_Email]
           ,[Usr_IsAdmin]
           ,[Usr_Password]
           ,[Usr_IsLocked]
           ,[Usr_IsActivated]
		   ,[Usr_InsertDate]
		   ,[Usr_UpdateDate]
		   ,[Usr_LastConnectionDate])
     VALUES
           (
            @Usr_Name 
           ,@Usr_Surname 
           ,@Usr_FirstName 
           ,@Usr_Email 
           ,@Usr_IsAdmin 
           ,@Usr_Password 
           ,@Usr_IsLocked 
           ,@Usr_IsActivated
		   ,GETDATE()
		   ,GETDATE()
		   ,null
		   )
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Users_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Update single User from Users table
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Users_Update_Single]
	 @Usr_ID int
    ,@Usr_Name nvarchar(30)
    ,@Usr_Surname nvarchar(50)
    ,@Usr_FirstName nvarchar(50)
    ,@Usr_Email nvarchar(100)
    ,@Usr_IsAdmin smallint
    ,@Usr_Password nvarchar(100)
    ,@Usr_IsLocked smallint
    ,@Usr_IsActivated smallint
	,@Usr_LastConnectionDate datetime
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].[Users]
	   SET 
		   [Usr_Name] = @Usr_Name
		  ,[Usr_Surname] = @Usr_Surname
		  ,[Usr_FirstName] = @Usr_FirstName
		  ,[Usr_Email] = @Usr_Email
		  ,[Usr_IsAdmin] = @Usr_IsAdmin
		  ,[Usr_Password] = @Usr_Password
		  ,[Usr_IsLocked] = @Usr_IsLocked
		  ,[Usr_IsActivated] = @Usr_IsActivated
		  ,[Usr_UpdateDate] = GETDATE()
		  ,[Usr_LastConnectionDate] = @Usr_LastConnectionDate
	 WHERE [Usr_ID] = @Usr_ID

END
GO
/****** Object:  StoredProcedure [dbo].[ADM_UsersTicketsShare_Delete_All_By_UsrID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete all record from 
--				UsersTicketsShare table
--				using Usr_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_UsersTicketsShare_Delete_All_By_UsrID]
	 @Usr_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].UsersTicketsShare
	WHERE UsersTicketsShare.Uti_UsrId = @Usr_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_UsersTicketsShare_Delete_Single_By_UsrID_TicID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-27
-- Description:	Delete single record from 
--				UsersTicketsShare table
--				using Usr_ID and Tic_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_UsersTicketsShare_Delete_Single_By_UsrID_TicID]
	 @Usr_ID int,
	 @Tic_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM [dbo].UsersTicketsShare
	WHERE UsersTicketsShare.Uti_UsrId = @Usr_ID
		and UsersTicketsShare.Uti_TicId = @Tic_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_UsersTicketsShare_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Insert single record to UsersTicketsShare 
-- =============================================
CREATE PROCEDURE [dbo].[ADM_UsersTicketsShare_Insert_Single]
	@Usr_ID int,
	@Tic_ID int
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO UsersTicketsShare 
				(Uti_UsrID, Uti_TicID)
	VALUES(@Usr_ID, @Tic_ID)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_UsersTicketsShare_Select_TicID_By_UsrID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Select Tic_ID from UsersTicketsShare 
--				by Usr_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_UsersTicketsShare_Select_TicID_By_UsrID]
	@Usr_ID int
AS
BEGIN
	SET NOCOUNT ON;
	Select Uti_TicID FROM UsersTicketsShare 
		where  Uti_UsrID = @Usr_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_UsersTicketsShare_Select_UsrID_By_TicID]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Select Tic_ID from UsersTicketsShare 
--				by Usr_ID
-- =============================================
CREATE PROCEDURE [dbo].[ADM_UsersTicketsShare_Select_UsrID_By_TicID]
	@Tic_ID int
AS
BEGIN
	SET NOCOUNT ON;
	Select Uti_UsrID FROM UsersTicketsShare 
		where  Uti_TicID = @Tic_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Voivodership_Delete_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Delete Voivodership Single Record
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Voivodership_Delete_Single] 
	@Voi_ID int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM Voivoderships  where Voi_ID = @Voi_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Voivodership_Insert_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Insert to Voivodership Single Record
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Voivodership_Insert_Single] 
	@Voi_Name nvarchar(100)	
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO Voivoderships (Voi_Name) 
	Values (@Voi_Name)
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Voivodership_Select_All]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Select Voivodership All Records
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Voivodership_Select_All]
	@Voi_ID int
AS
BEGIN
	SET NOCOUNT ON;
	Select Voi_ID, Voi_Name FROM Voivoderships  
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Voivodership_Select_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Select Voivodership Single Record
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Voivodership_Select_Single] 
	@Voi_ID int
AS
BEGIN
	SET NOCOUNT ON;
	Select Voi_ID, Voi_Name FROM Voivoderships  
	where Voi_ID = @Voi_ID
END
GO
/****** Object:  StoredProcedure [dbo].[ADM_Voivodership_Update_Single]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-01-13
-- Description:	Update Voivodership Single Record
-- =============================================
CREATE PROCEDURE [dbo].[ADM_Voivodership_Update_Single] 
	@Voi_ID int,
	@Voi_Name nvarchar(100)	
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Voivoderships set Voi_Name = @Voi_Name where Voi_ID = @Voi_ID
END
GO
/****** Object:  StoredProcedure [dbo].[R_ADM_SelectSingleIDFromDictionaryTable]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-10
-- Description:	Select single identity value
--				from selected dictionary table
-- =============================================
CREATE PROCEDURE [dbo].[R_ADM_SelectSingleIDFromDictionaryTable]
(
	 @TableName VARCHAR(50)
	,@ObjectName VARCHAR(300)
	,@AddtitonalParameter INT
	,@output int OUTPUT
)

AS
BEGIN
	DECLARE @addtitonal_parameter_name VARCHAR(100)
	DECLARE @identity_column_name VARCHAR(100)
	DECLARE @parameter_name VARCHAR(100)
	DECLARE @SQL NVARCHAR(500)
	SELECT @addtitonal_parameter_name =
		CASE 
			WHEN @TableName = 'Resolutions' then 'Org_TwnID'
			WHEN @TableName = 'Organisators' then 'Org_TwnID'
			WHEN @TableName = 'Powiats' then 'Pow_VoiID'
			WHEN @TableName = 'Voivoderships' then null
			WHEN @TableName = 'Towns' then 'Twn_PowID'
			else 'Table not exists in database'
		end
	SELECT @parameter_name =
		CASE 
			WHEN @TableName = 'Resolutions' then 'Res_Code'
			WHEN @TableName = 'Organisators' then 'Org_Name'
			WHEN @TableName = 'Powiats' then 'Pow_Name'
			WHEN @TableName = 'Voivoderships' then 'Voi_Name'
			WHEN @TableName = 'Towns' then 'Twn_Name'
			else 'Table not exists in database'
		end
	SELECT @identity_column_name =
		CASE 
			WHEN @TableName = 'Resolutions' then 'Res_ID'
			WHEN @TableName = 'Organisators' then 'Org_ID'
			WHEN @TableName = 'Powiats' then 'Pow_ID'
			WHEN @TableName = 'Voivoderships' then 'Voi_ID'
			WHEN @TableName = 'Towns' then 'Twn_ID'
			else 'Table not exists in database'
		end
	IF @parameter_name = 'Table not exists in database'
		set @output = -1
	ELSE IF @addtitonal_parameter_name is null
		BEGIN
			set @SQL = CONCAT('SELECT @output = '
									,@identity_column_name
									,' FROM '
									,@TableName, ' WHERE '
									,@parameter_name, '='
									,'''', @ObjectName, ''''
									)
			EXEC sp_executesql @SQL, N'@output INT OUTPUT', @output = @output OUTPUT
		END
	ELSE
		BEGIN
			set @SQL = CONCAT('SELECT @output ='
									,@identity_column_name 
									,' FROM '
									,@TableName, ' WHERE '
									,@parameter_name, '='
									,'''', @ObjectName, '''', ' and '
									,@addtitonal_parameter_name, '='
									,cast(@AddtitonalParameter as varchar(20))
									)
			EXEC sp_executesql @SQL, N'@output INT OUTPUT', @output = @output OUTPUT
		END
	RETURN @output
END
GO
/****** Object:  StoredProcedure [dbo].[R_ADM_ValidateImportToDictionaryTable]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-10
-- Description:	Validates parameters inserted to
--				selected table.
-- =============================================
CREATE PROCEDURE [dbo].[R_ADM_ValidateImportToDictionaryTable]
(
	 @TableName VARCHAR(50)
	,@ObjectName VARCHAR(300)
	,@AddtitonalParameter INT
	,@output int OUTPUT
)

AS
BEGIN
	DECLARE @addtitonal_parameter_name VARCHAR(100)
	DECLARE @parameter_name VARCHAR(100)
	DECLARE @SQL NVARCHAR(500)
	DECLARE @params NVARCHAR(500)
	SELECT @addtitonal_parameter_name =
		CASE 
			WHEN @TableName = 'Resolutions' then 'Res_TwnID'
			WHEN @TableName = 'Organisators' then 'Org_TwnID'
			WHEN @TableName = 'Powiats' then 'Pow_VoiID'
			WHEN @TableName = 'Voivoderships' then null
			WHEN @TableName = 'Towns' then 'Twn_PowID'
			else 'Table not exists in database'
		end
	SELECT @parameter_name =
		CASE 
			WHEN @TableName = 'Resolutions' then 'Res_Code'
			WHEN @TableName = 'Organisators' then 'Org_Name'
			WHEN @TableName = 'Powiats' then 'Pow_Name'
			WHEN @TableName = 'Voivoderships' then 'Voi_Name'
			WHEN @TableName = 'Towns' then 'Twn_Name'
			else 'Table not exists in database'
		end
	IF @parameter_name = 'Table not exists in database'
		set @output = -1
	ELSE IF @addtitonal_parameter_name is null
		BEGIN
			set @SQL = CONCAT('SELECT @output = COUNT(*) FROM '
									,@TableName, ' WHERE '
									,@parameter_name, '='
									,'''', @ObjectName, ''''
									)
			EXEC sp_executesql @SQL, N'@output INT OUTPUT', @output = @output OUTPUT
		END
	ELSE
		BEGIN
			set @SQL = CONCAT('SELECT @output = COUNT(*) FROM '
									,@TableName, ' WHERE '
									,@parameter_name, '='
									,'''', @ObjectName,'''', ' and '
									,@addtitonal_parameter_name, '='
									,cast(@AddtitonalParameter as varchar(20))
									)
			EXEC sp_executesql @SQL, N'@output INT OUTPUT', @output = @output OUTPUT
		END
	--RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[USR_MergeChoosenTickets]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-17
-- Description:	Procedure for merging two tickets.
--				Case when user imported two tickets
--				and that tickets are the same,
--				user can sum amount of two or 
--				more choosen tickets and delete 
--				redundant.
-- =============================================
CREATE PROCEDURE [dbo].[USR_MergeChoosenTickets]
	@selected_Tic_ids VARCHAR(MAX)
	,@message VARCHAR(300) OUTPUT
AS
BEGIN
	DECLARE @selected_Tic_ids_table TABLE
		(
			Tic_ID INT
		)
	DECLARE @choosen_towns VARCHAR(max)
	DECLARE @choosen_towns_amount int
	DECLARE @choosen_powiats VARCHAR(max)
	DECLARE @choosen_powiats_amount int
	DECLARE @choosen_voivoderships VARCHAR(max)
	DECLARE @choosen_voivoderships_amount int
	DECLARE @choosen_organisators VARCHAR(max)
	DECLARE @choosen_organisators_amount int
	DECLARE @choosen_series VARCHAR(max)
	DECLARE @choosen_series_amount int
	DECLARE @choosen_printeries VARCHAR(max)
	DECLARE @choosen_printeries_amount int
		
	BEGIN TRY
		INSERT INTO @selected_Tic_ids_table
			select CAST(TRIM(value) AS INT) 
				from STRING_SPLIT ( @selected_Tic_ids , ',' ) 
	END TRY
	BEGIN CATCH
		SET @message = ERROR_MESSAGE() + CHAR(13) + CHAR(10)
						+ 'Prawdopodobnie nie wybrano identyfikatorów'
		RETURN -1
	END CATCH
	/* TODO
	-sprawdzenie, czy input nie null i czy co zawiera tabela wynikowa*/

	SELECT @choosen_towns_amount = COUNT(DISTINCT TRIM(Tic_ImportedTown))
		  ,@choosen_towns =STRING_AGG(TRIM(Tic_ImportedTown), ',')  
	FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

	SELECT COUNT(DISTINCT Tic_ImportedPowiat)  FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

	SELECT COUNT(DISTINCT Tic_ImportedVoivodership)  FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

	SELECT COUNT(DISTINCT Tic_ImportedOrganisatorName)  FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

	SELECT COUNT(DISTINCT Tic_Series)  FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

	SELECT COUNT(DISTINCT Tic_ImportedPrintery)  FROM dbo.Tickets
	JOIN @selected_Tic_ids_table ChoosenTickets 
		ON  Tickets.Tic_ID = ChoosenTickets.Tic_ID

END
GO
/****** Object:  StoredProcedure [dbo].[USR_Suggest_Single_Resolution]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-12
-- Description:	Insert single record into 
--				SuggestedResolutions table.
-- =============================================
CREATE PROCEDURE [dbo].[USR_Suggest_Single_Resolution] 
	@Sre_Resolution varbinary(max)
	,@Sre_Description nvarchar(500)
	,@Sre_DateFrom date 
	,@Sre_DateTo date 
	,@Sre_OwnerID int 
	,@Sre_ImportedCode varchar(50) 
	,@Sre_ImportedTown nvarchar(100) 
	,@Sre_ImportedPowiat nvarchar(100) 
	,@Sre_ImportedVoivodership nvarchar(100) 
	,@message NVARCHAR(500) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO [dbo].[SuggestedResolutions]
           ([Sre_Resolution]
           ,[Sre_Description]
           ,[Sre_DateFrom]
           ,[Sre_DateTo]
           ,[Sre_InsertDate]
           ,[Sre_UpdateDate]
           ,[Sre_OwnerID]
           ,[Sre_ImportedCode]
           ,[Sre_ImportedTown]
           ,[Sre_ImportedPowiat]
           ,[Sre_ImportedVoivodership])
		VALUES
           ( @Sre_Resolution 
			,@Sre_Description 
			,@Sre_DateFrom  
			,@Sre_DateTo  
			,GETDATE()
			,GETDATE()  
			,@Sre_OwnerID  
			,@Sre_ImportedCode  
			,@Sre_ImportedTown 
			,@Sre_ImportedPowiat  
			,@Sre_ImportedVoivodership )
		SET @message = 'Sugestia uchwały powiodła się'
	END TRY
	BEGIN CATCH
		set @message = ERROR_MESSAGE()
	END CATCH


		
END
GO
/****** Object:  StoredProcedure [dbo].[USR_Suggest_Single_Ticket]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 2019-02-12
-- Description:	Insert single record into 
--				SuggestedSpecimens table.
-- =============================================
CREATE PROCEDURE [dbo].[USR_Suggest_Single_Ticket] 
	@Tic_ID int
	,@message NVARCHAR(500) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	declare @voivodership nvarchar(100)
	declare @powiat nvarchar(100)
	declare @town nvarchar(100)
	declare @resolution nvarchar(100)
	declare @organisator nvarchar(100)
	declare @series varchar(10)
	declare @value decimal(18,2)
	declare @current_SpeID int
	declare @obverse varbinary(max)
	declare @reverse varbinary(max)

	declare @validation_counter int
			,@voi_id int
			,@pow_id int
			,@twn_id int
		    ,@res_id int
	        ,@org_id int

	select
		 @voivodership = Tic_ImportedVoivodership
		,@powiat = Tic_ImportedPowiat
		,@town = Tic_ImportedTown
		,@resolution = Tic_ImportedResolutionCode
		,@organisator = Tic_ImportedOrganisatorName
		,@series = Tic_Series
		,@value = Tic_Value
		,@current_SpeID = Tic_SpeID
		,@obverse = Tic_Obverse
		,@reverse = Tic_Reverse
	from Tickets where Tic_ID = @Tic_ID

	IF @current_SpeID is not null
		BEGIN
			set @message = concat('Bilet:', char(9)
								  ,@value, char(9)
								  ,@series, char(9)
								  ,@town, char(9)
								  ,'ma przypisany wzornik')
			RETURN -1  
		END

	BEGIN TRAN
	EXEC [dbo].[R_ADM_ValidateImportToDictionaryTable]
										'Voivoderships'
										,@voivodership
										,null
										,@validation_counter OUTPUT
	IF @validation_counter = 1
		EXEC  [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
										'Voivoderships'
										,@voivodership
										,null
										,@voi_id OUTPUT
	ELSE
		BEGIN 
			SET @message = CONCAT('Województwo: ', @voivodership
									,' nie istnieje w bazie '
									,' lub jest niejednoznaczne'
									)
			ROLLBACK TRAN
			RETURN -1
		END
	
	EXEC dbo.R_ADM_ValidateImportToDictionaryTable 
											'Powiats'
											,@powiat
											,@voi_id
											,@validation_counter OUTPUT
	IF @validation_counter = 1
		EXEC [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
											'Powiats'
											,@powiat
											,@voi_id
											,@pow_id OUTPUT
	ELSE
		BEGIN 
			SET @message = concat('Powiat: ', @powiat 
									,' w województwie: ', @voivodership
									,' nie istnieje w bazie'
									,' lub jest niejednoznaczny')
			ROLLBACK TRAN
			RETURN -1
		END

	EXEC dbo.R_ADM_ValidateImportToDictionaryTable 
											'Powiats'
											,@powiat
											,@voi_id
											,@validation_counter OUTPUT
	IF @validation_counter = 1
		EXEC [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
												'Towns'
												,@town
												,@pow_id
												,@twn_id OUTPUT
	ELSE
		BEGIN 
			SET @message = concat(	'Miejscowość: ', @town
									,'w powiecie: ', @powiat 
									,' w województwie: ', @voivodership
									,' nie istnieje w bazie'
									,' lub jest niejednoznaczna')
			ROLLBACK TRAN
			RETURN -1
		END

	IF @validation_counter = 1
		EXEC [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
												'Organisators'
												,@organisator
												,@twn_id
												,@org_id OUTPUT
	ELSE
		BEGIN 
			SET @message = concat(	'Organizator: ', @organisator
									,'miejscowość: ', @town
									,'w powiecie: ', @powiat 
									,' w województwie: ', @voivodership
									,' nie istnieje w bazie'
									,' lub jest niejednoznaczny')
			ROLLBACK TRAN
			RETURN -1
		END

	IF @resolution is not null
		BEGIN
			IF @validation_counter = 1
				EXEC [dbo].[R_ADM_SelectSingleIDFromDictionaryTable] 
														'Resolution'
														,@resolution
														,@twn_id
														,@res_id OUTPUT
			ELSE
				BEGIN 
					SET @message = concat(	'Uchwała: ', @resolution
											,'w miejscowości: ', @town
											,'w powiecie: ', @powiat 
											,' w województwie: ', @voivodership
											,' nie istnieje w bazie'
											,' lub jest niejednoznaczny')
					ROLLBACK TRAN
					RETURN -1
			END
		END
	ELSE
		set @res_id = null

	IF @org_id is not null
		BEGIN
			BEGIN TRY 
				EXEC dbo.ADM_SuggestedSpecimens_Insert_Single @Tic_ID, @org_id, @res_id
				COMMIT TRAN
				set @message = 'Sugestia powiodła się :( Skontaktuj się z adminem'
				RETURN 1
			END TRY
			BEGIN CATCH
				set @message = 'Sugestia nie powiodła się :( Skontaktuj się z adminem'
				ROLLBACK TRAN
				RETURN -1
			END CATCH
		END
	ELSE
		BEGIN
			set @message = 'Sugestia nie powiodła się :( Skontaktuj się z adminem'
			ROLLBACK TRAN
			RETURN -1
		END

		    		
		
END
GO
/****** Object:  Trigger [dbo].[BIU_Specimens]    Script Date: 11.06.2019 16:35:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rafał Szkotak
-- Create date: 16.12.2018
-- Description:	Trigger prevents inserting ticket 
--				with inconsistent information about 
--				Organisator`s town and Resolution`s town 
-- =============================================
CREATE TRIGGER [dbo].[BIU_Specimens] ON  [dbo].[Specimens]
   INSTEAD OF INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @message varchar(100)
	set @message = 'You cannot insert inconsistent information about 
	Organisator`s town and Resolution`s town'

	IF EXISTS(
	select 1 from inserted
		left join Resolutions on Spe_ResID = Res_ID
		left join Organisators on Spe_OrgID = Org_ID
	where isnull(Res_TwnID, -1) <>  isnull(Org_TwnID, -1)
	)
		BEGIN
			RAISERROR(@message, 16, 1)
		END
    -- Insert statements for trigger here

END
GO
ALTER TABLE [dbo].[Specimens] ENABLE TRIGGER [BIU_Specimens]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Success can take only two values 0 and 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsletterLogs', @level2type=N'CONSTRAINT',@level2name=N'CK_NewsletterLogs_Success'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Public Transport Organisator`s ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators', @level2type=N'COLUMN',@level2name=N'Org_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Public Transport Organisator`s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators', @level2type=N'COLUMN',@level2name=N'Org_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Public Transport Organisator`s abbreviation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators', @level2type=N'COLUMN',@level2name=N'Org_Abbreviation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Town`s id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators', @level2type=N'COLUMN',@level2name=N'Org_TwnID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Public transport Administrators in Towns. 
Organisator`s name and Town`s identifier should be unique.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Adminstrator`s town, for example ZIKiT and Kraków ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organisators', @level2type=N'CONSTRAINT',@level2name=N'FK_Organisators_Towns'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Town`s id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resolutions', @level2type=N'COLUMN',@level2name=N'Res_TwnID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check if date from <= date to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resolutions', @level2type=N'CONSTRAINT',@level2name=N'CK_Resolutions_DateFrom_and_DateTo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Public Transport Organisator`s ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Specimens', @level2type=N'COLUMN',@level2name=N'Spe_OrgID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Specimen`s public transport Orgnisator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Specimens', @level2type=N'CONSTRAINT',@level2name=N'FK_Specimens_Organisators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Link to User table (Information about owner)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SuggestedResolutions', @level2type=N'CONSTRAINT',@level2name=N'FK_SuggestedResolutions_Users'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Checks if Date from is lower than Date To, when Date To is not null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SuggestedResolutions', @level2type=N'CONSTRAINT',@level2name=N'CK_SuggestedResolutions_DateFrom_and_DateTo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Link to existing ticket' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SuggestedSpecimens', @level2type=N'CONSTRAINT',@level2name=N'FK_SuggestedSpecimens_Tickets'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ticket`s owner from Users table. OwnerID is set to null after deleting User from Users table  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets', @level2type=N'COLUMN',@level2name=N'Tic_OwnerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tickets marked as "Private" are not visible in V_ShowAllPublicTickets' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets', @level2type=N'COLUMN',@level2name=N'Tic_IsPrivate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Specimens identifier. Value is set to null after Specimens deleting.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets', @level2type=N'COLUMN',@level2name=N'Tic_SpeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'How many tickets Owner have' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets', @level2type=N'COLUMN',@level2name=N'Tic_Amount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Database`s essential table. Table stores information about Users` tickets, about Owner (Tic_OwnerID), amount of tickets, privacy (Tic_IsPrivate), public transport organisator(Tic_OrgID), resolution and town. Table also stores photos or scans (Tic_Obverse and Tic_Reverse).
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount cannot be below 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tickets', @level2type=N'CONSTRAINT',@level2name=N'CK_Tickets_TicAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Town`s id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Towns', @level2type=N'COLUMN',@level2name=N'Twn_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Town`s id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TownsUsers', @level2type=N'COLUMN',@level2name=N'Ciu_TwnID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table stores information about Users interested in specific cities.
Table is used by newsletter function, which sends information about new tickets specimens' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TownsUsers'
GO
USE [master]
GO
ALTER DATABASE [BiletowaApka2] SET  READ_WRITE 
GO
