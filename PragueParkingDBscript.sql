USE [PragueParking]
GO
/****** Object:  Table [dbo].[VehicleType]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleType](
	[VehicleTypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](25) NOT NULL,
	[Size] [int] NOT NULL,
	[HourlyRate] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParkingSpot]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingSpot](
	[ParkingSpotID] [int] IDENTITY(1,1) NOT NULL,
	[ParkingSpotNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkingSpotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParkedVehicle]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkedVehicle](
	[VehicleID] [int] IDENTITY(1,1) NOT NULL,
	[Regnum] [nvarchar](25) NULL,
	[InTime] [datetime] NOT NULL,
	[ParkingSpotID] [int] NULL,
	[VehicleTypeID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[SpotsWith1Motorcycle]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SpotsWith1Motorcycle]
AS
SELECT ps.ParkingSpotID 
FROM ParkingSpot ps
JOIN ParkedVehicle pv ON ps.ParkingSpotID = pv.ParkingSpotID
JOIN VehicleType vt ON vt.VehicleTypeID = pv.VehicleTypeID
GROUP BY ps.ParkingSpotID
HAVING SUM(vt.Size) = 1;
GO
/****** Object:  View [dbo].[Empty Spots]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Empty Spots]
AS
SELECT ParkingSpotNumber FROM ParkingSpot
WHERE ParkingSpotID NOT IN (SELECT ParkingSpotID FROM ParkedVehicle);
GO
/****** Object:  Table [dbo].[VehicleHistory]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleHistory](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[Regnum] [nvarchar](10) NOT NULL,
	[InTime] [datetime] NOT NULL,
	[OutTime] [datetime] NOT NULL,
	[AmountPaid] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Income per day]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[Income per day]
AS
SELECT SUM(AmountPaid) AS [Income], CONVERT(DATE, OutTime) AS [Date] FROM VehicleHistory
GROUP BY CONVERT(DATE, OutTime);
GO
/****** Object:  View [dbo].[Vehicles currently parked]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     VIEW [dbo].[Vehicles currently parked]
AS
SELECT pv.Regnum, ps.ParkingSpotNumber, DATEDIFF(HOUR, pv.InTime, GETDATE()) AS [Hours Parked], pv.VehicleTypeID FROM ParkedVehicle pv
JOIN ParkingSpot ps ON pv.ParkingSpotID = ps.ParkingSpotID
GO
/****** Object:  View [dbo].[Single Parked Motorcycles]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[Single Parked Motorcycles]
AS
SELECT pv.Regnum, ps.ParkingSpotNumber FROM ParkedVehicle pv
JOIN VehicleType vt ON pv.VehicleTypeID = vt.VehicleTypeID
JOIN ParkingSpot ps ON pv.ParkingSpotID = ps.ParkingSpotID
WHERE pv.ParkingSpotID IN (SELECT pv.ParkingSpotID FROM ParkedVehicle pv
						   JOIN VehicleType vt ON pv.VehicleTypeID = vt.VehicleTypeID
						   GROUP BY pv.ParkingSpotID
						   HAVING SUM(vt.Size) = 1);
GO
SET IDENTITY_INSERT [dbo].[ParkedVehicle] ON 

INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (15, N'SKU223', CAST(N'2020-02-05T17:21:18.067' AS DateTime), 1, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (23, N'YTJ22Y', CAST(N'2020-02-06T13:42:09.173' AS DateTime), 39, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (24, N'GYE6262', CAST(N'2020-02-06T13:42:20.530' AS DateTime), 6, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (25, N'YH7273KJ', CAST(N'2020-02-06T13:42:30.120' AS DateTime), 7, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (27, N'GYH727', CAST(N'2020-02-06T15:42:54.100' AS DateTime), 4, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (30, N'FIG7672', CAST(N'2020-02-07T10:12:09.717' AS DateTime), 10, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (34, N'OOF88P', CAST(N'2020-02-07T10:14:39.153' AS DateTime), 5, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (37, N'FOP763', CAST(N'2020-02-07T15:57:34.170' AS DateTime), 9, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (38, N'HIT007', CAST(N'2020-02-07T15:57:47.177' AS DateTime), 1, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (40, N'KUK1337', CAST(N'2020-02-07T17:20:50.873' AS DateTime), 12, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (41, N'ROFLCOPTER', CAST(N'2020-02-07T17:21:08.897' AS DateTime), 13, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (43, N'R2D2BB8', CAST(N'2020-02-07T17:21:46.693' AS DateTime), 14, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (45, N'ŠKODA4LIFE', CAST(N'2020-02-08T17:23:12.553' AS DateTime), 3, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (47, N'GJU76D', CAST(N'2020-02-08T17:26:02.450' AS DateTime), 16, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (48, N'VIT62U', CAST(N'2020-02-08T17:27:13.230' AS DateTime), 8, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (49, N'SKJ8227', CAST(N'2020-02-08T17:29:04.627' AS DateTime), 5, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (51, N'LGP412', CAST(N'2020-02-08T20:16:17.107' AS DateTime), 17, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (52, N'EWH328', CAST(N'2020-02-08T20:17:53.040' AS DateTime), 18, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (53, N'PIKA777', CAST(N'2020-02-08T22:14:57.317' AS DateTime), 100, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (54, N'GLÜWEINUBE', CAST(N'2020-02-08T22:16:39.940' AS DateTime), 95, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (55, N'BIKEY2', CAST(N'2020-02-08T22:17:35.597' AS DateTime), 15, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (56, N'MOTO2', CAST(N'2020-02-08T22:17:54.643' AS DateTime), 25, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (57, N'GRO23R', CAST(N'2020-02-08T22:18:07.690' AS DateTime), 26, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (58, N'GYH76B', CAST(N'2020-02-09T13:04:32.840' AS DateTime), 20, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (59, N'HOG999', CAST(N'2020-02-09T13:04:39.943' AS DateTime), 32, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (60, N'ФГЫ222', CAST(N'2020-02-10T16:25:11.110' AS DateTime), 15, 1)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (61, N'СУКАБЛЯТЬ', CAST(N'2020-02-10T16:25:47.747' AS DateTime), 21, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (62, N'PAJ328', CAST(N'2020-02-10T20:04:52.267' AS DateTime), 22, 2)
INSERT [dbo].[ParkedVehicle] ([VehicleID], [Regnum], [InTime], [ParkingSpotID], [VehicleTypeID]) VALUES (63, N'ŠÑË887', CAST(N'2020-02-10T20:06:12.310' AS DateTime), 19, 1)
SET IDENTITY_INSERT [dbo].[ParkedVehicle] OFF
SET IDENTITY_INSERT [dbo].[ParkingSpot] ON 

INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (1, 1)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (2, 2)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (3, 3)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (4, 4)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (5, 5)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (6, 6)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (7, 7)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (8, 8)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (9, 9)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (10, 10)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (11, 11)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (12, 12)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (13, 13)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (14, 14)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (15, 15)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (16, 16)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (17, 17)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (18, 18)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (19, 19)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (20, 20)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (21, 21)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (22, 22)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (23, 23)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (24, 24)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (25, 25)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (26, 26)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (27, 27)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (28, 28)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (29, 29)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (30, 30)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (31, 31)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (32, 32)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (33, 33)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (34, 34)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (35, 35)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (36, 36)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (37, 37)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (38, 38)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (39, 39)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (40, 40)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (41, 41)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (42, 42)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (43, 43)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (44, 44)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (45, 45)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (46, 46)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (47, 47)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (48, 48)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (49, 49)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (50, 50)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (51, 51)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (52, 52)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (53, 53)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (54, 54)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (55, 55)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (56, 56)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (57, 57)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (58, 58)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (59, 59)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (60, 60)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (61, 61)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (62, 62)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (63, 63)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (64, 64)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (65, 65)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (66, 66)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (67, 67)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (68, 68)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (69, 69)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (70, 70)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (71, 71)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (72, 72)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (73, 73)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (74, 74)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (75, 75)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (76, 76)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (77, 77)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (78, 78)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (79, 79)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (80, 80)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (81, 81)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (82, 82)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (83, 83)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (84, 84)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (85, 85)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (86, 86)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (87, 87)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (88, 88)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (89, 89)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (90, 90)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (91, 91)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (92, 92)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (93, 93)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (94, 94)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (95, 95)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (96, 96)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (97, 97)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (98, 98)
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (99, 99)
GO
INSERT [dbo].[ParkingSpot] ([ParkingSpotID], [ParkingSpotNumber]) VALUES (100, 100)
SET IDENTITY_INSERT [dbo].[ParkingSpot] OFF
SET IDENTITY_INSERT [dbo].[VehicleHistory] ON 

INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (1, N'OCF712', CAST(N'2020-02-05T14:26:48.943' AS DateTime), CAST(N'2020-02-05T14:41:18.540' AS DateTime), 100.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (14, N'ZYJ823', CAST(N'2020-02-05T15:09:29.727' AS DateTime), CAST(N'2020-02-06T13:36:23.810' AS DateTime), 440.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (15, N'ZYJ823', CAST(N'2020-02-06T13:40:20.463' AS DateTime), CAST(N'2020-02-06T13:40:30.123' AS DateTime), 0.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (16, N'OCF712', CAST(N'2020-02-06T13:41:25.640' AS DateTime), CAST(N'2020-02-06T13:47:44.720' AS DateTime), 120.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (17, N'TYG772', CAST(N'2020-02-05T17:21:29.633' AS DateTime), CAST(N'2020-02-06T14:00:44.683' AS DateTime), 420.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (18, N'TYG772', CAST(N'2020-02-06T14:02:34.473' AS DateTime), CAST(N'2020-02-07T10:12:42.277' AS DateTime), 400.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (19, N'CUM666', CAST(N'2020-02-07T10:11:59.260' AS DateTime), CAST(N'2020-02-07T10:13:02.890' AS DateTime), 0.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (20, N'PAJ328', CAST(N'2020-02-06T13:41:33.830' AS DateTime), CAST(N'2020-02-07T10:13:19.160' AS DateTime), 420.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (21, N'RUL662', CAST(N'2020-02-06T13:41:58.727' AS DateTime), CAST(N'2020-02-07T10:14:03.467' AS DateTime), 210.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (22, N'HOG999', CAST(N'2020-02-07T10:11:48.787' AS DateTime), CAST(N'2020-02-07T13:29:34.253' AS DateTime), 20.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (23, N'OCF712', CAST(N'2020-02-07T10:14:18.147' AS DateTime), CAST(N'2020-02-07T19:51:26.193' AS DateTime), 0.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (26, N'KOK08K', CAST(N'2020-02-07T17:20:38.427' AS DateTime), CAST(N'2020-02-08T17:28:23.600' AS DateTime), 240.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (27, N'SKJ8227', CAST(N'2020-02-06T13:41:45.843' AS DateTime), CAST(N'2020-02-08T17:28:49.103' AS DateTime), 520.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (28, N'PAJ328', CAST(N'2020-02-08T17:25:29.677' AS DateTime), CAST(N'2020-02-08T20:18:04.070' AS DateTime), 60.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (29, N'GTA943', CAST(N'2020-02-07T10:14:27.600' AS DateTime), CAST(N'2020-02-10T20:09:35.960' AS DateTime), 1620.0000)
INSERT [dbo].[VehicleHistory] ([HistoryID], [Regnum], [InTime], [OutTime], [AmountPaid]) VALUES (30, N'OCF712', CAST(N'2020-02-08T17:30:34.110' AS DateTime), CAST(N'2020-02-10T20:09:42.297' AS DateTime), 1000.0000)
SET IDENTITY_INSERT [dbo].[VehicleHistory] OFF
SET IDENTITY_INSERT [dbo].[VehicleType] ON 

INSERT [dbo].[VehicleType] ([VehicleTypeID], [TypeName], [Size], [HourlyRate]) VALUES (1, N'Motorcycle', 1, 10.0000)
INSERT [dbo].[VehicleType] ([VehicleTypeID], [TypeName], [Size], [HourlyRate]) VALUES (2, N'Car', 2, 20.0000)
SET IDENTITY_INSERT [dbo].[VehicleType] OFF
SET ANSI_PADDING ON
GO
/****** Object:  Index [Unique_Regnum]    Script Date: 2020-02-10 20:17:52 ******/
ALTER TABLE [dbo].[ParkedVehicle] ADD  CONSTRAINT [Unique_Regnum] UNIQUE NONCLUSTERED 
(
	[Regnum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD FOREIGN KEY([ParkingSpotID])
REFERENCES [dbo].[ParkingSpot] ([ParkingSpotID])
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleType] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])>(2)))
GO
ALTER TABLE [dbo].[ParkedVehicle]  WITH CHECK ADD CHECK  ((len([Regnum])<(11)))
GO
ALTER TABLE [dbo].[VehicleHistory]  WITH CHECK ADD CHECK  ((len([Regnum])>(2)))
GO
/****** Object:  StoredProcedure [dbo].[Average income given span]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Average income given span]
@StartDate DATE, @EndDate DATE, @AverageIncome MONEY OUTPUT
AS
SELECT SUM(AmountPaid) AS 'IncomePerDay'
INTO #IncomeDayTable
FROM VehicleHistory
WHERE CONVERT(DATE, OutTime) BETWEEN @StartDate AND @EndDate
GROUP BY CONVERT(DATE, OutTime)

SET @AverageIncome = (SELECT AVG(IncomePerDay)
FROM #IncomeDayTable)

DROP TABLE #IncomeDayTable;
RETURN
GO
/****** Object:  StoredProcedure [dbo].[Calculate Payment]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [dbo].[Calculate Payment]
@Regnum NVARCHAR(10), 
@AmountToPay MONEY OUTPUT
AS
DECLARE @MinutesParked INT = DATEDIFF(MINUTE, (SELECT InTime FROM ParkedVehicle WHERE Regnum=@Regnum), GETDATE())
-- If parked less than 5 minutes, set Amount to pay to 0
IF @MinutesParked < 5
	SET @AmountToPay = 0
ELSE
BEGIN
	DECLARE @HourlyRate INT = (SELECT HourlyRate FROM VehicleType v
					       JOIN ParkedVehicle p ON v.VehicleTypeID = p.VehicleTypeID
						   WHERE p.Regnum = @Regnum)
	--If vehicle is parked less than 2 hours, still charge 2 hours.
	IF @MinutesParked - 5 < 120
		SET @AmountToPay = @HourlyRate * 2
	ELSE
		SET @AmountToPay = (CEILING((@MinutesParked - 5)/60)) * @HourlyRate
END
RETURN
GO
/****** Object:  StoredProcedure [dbo].[FindFreeSpot]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[FindFreeSpot]
@VehicleTypeID INT,
@FreeSpot INT OUTPUT
AS
IF @VehicleTypeID = 1
BEGIN
	SET @FreeSpot = (SELECT TOP 1 ps.ParkingSpotID 
					 FROM ParkingSpot ps
					 JOIN ParkedVehicle pv ON ps.ParkingSpotID = pv.ParkingSpotID
					 JOIN VehicleType vt ON vt.VehicleTypeID = pv.VehicleTypeID
					 GROUP BY ps.ParkingSpotID
					 HAVING SUM(vt.Size) = 1
					 ORDER BY ps.ParkingSpotID)
END
IF @FreeSpot IS NULL
BEGIN
	SET @FreeSpot = (SELECT TOP 1 ParkingSpotID
					 FROM ParkingSpot 
					 WHERE ParkingSpotID NOT IN (SELECT ParkingSpotID FROM ParkedVehicle)
					 ORDER BY ParkingSpotID)
END
RETURN
GO
/****** Object:  StoredProcedure [dbo].[InsertVehicle]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [dbo].[InsertVehicle] 
@Regnum NVARCHAR(10), @VehicleTypeID INT
AS
DECLARE @ParkingSpot INT
-- Run FindFreeSpot, Whichs fills "@ParkingSpot" with the best spot to put the vehicle in (Tries to add motorcycles to places with 1 MC already in it)
EXECUTE FindFreeSpot @VehicleTypeID, @ParkingSpot OUTPUT

BEGIN TRANSACTION
BEGIN TRY
INSERT INTO ParkedVehicle(Regnum, InTime, ParkingSpotID, VehicleTypeID)
VALUES(@Regnum, GETDATE(), @ParkingSpot, @VehicleTypeID)
COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[Move Vehicle]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Move Vehicle]
@Regnum NVARCHAR(10), @ParkingSpot INT
AS
BEGIN TRANSACTION
--Gets the ID of the wanted spotnumber
DECLARE @ParkingSpotID INT = (SELECT ParkingSpotID FROM ParkingSpot
							  WHERE ParkingSpotNumber = @ParkingSpot)
--Gets the new spots current occupied space, ie if any cars or motorcycles are in it
DECLARE @NewSpotOccupiedSize INT = (SELECT SUM(vt.Size) FROM ParkedVehicle pv
								    JOIN VehicleType vt ON pv.VehicleTypeID = vt.VehicleTypeID
								    WHERE pv.ParkingSpotID = @ParkingSpotID)
--Gets the size of the current vehicle
DECLARE @VehicleSize INT = (SELECT vt.Size FROM ParkedVehicle pv
						    JOIN VehicleType vt ON pv.VehicleTypeID = vt.VehicleTypeID
							WHERE pv.Regnum = @Regnum)
--Checks if the vehicle is found in ParkedVehicle
IF (SELECT COUNT(*) FROM ParkedVehicle WHERE Regnum = @Regnum) = 0
BEGIN
	RAISERROR('The vehicle was not found.', 17, 1)
	ROLLBACK TRANSACTION
END
--Checks so that if either the spot is totally full, or if there's 1 motorcycle and we're trying to put a car in it
ELSE IF @NewSpotOccupiedSize >= 2 OR (@NewSpotOccupiedSize = 1 AND @VehicleSize = 2)
BEGIN
	RAISERROR('There was not enough space in the new parking spot', 17, 1)
	ROLLBACK TRANSACTION
END
ELSE
	BEGIN TRY
	UPDATE ParkedVehicle
	SET ParkingSpotID = @ParkingSpotID
	WHERE Regnum = @Regnum;

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION
	RAISERROR('Something went wrong while moving the vehicle.', 17, 1)
	END CATCH
GO
/****** Object:  StoredProcedure [dbo].[Vehicle Leaving]    Script Date: 2020-02-10 20:17:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Procedure for vehicle leaving. PaidMoney is a optional value, if not entered, it's calculated automatically
CREATE   PROCEDURE [dbo].[Vehicle Leaving] @Regnum NVARCHAR(10), @PaidMoney MONEY = NULL
AS
BEGIN TRANSACTION
--If PaidMoney is null, it means that the user didn't input any own value, hence calculate it normally.
IF @PaidMoney IS NULL
BEGIN
	EXECUTE [Calculate Payment] @Regnum, @PaidMoney OUTPUT
END
BEGIN TRY
	--Start by inserting a new entry in the vehicleHistory, given all wanted parameters
	INSERT INTO VehicleHistory(Regnum, InTime, OutTime, AmountPaid)
	SELECT  Regnum, InTime, GETDATE(), @PaidMoney FROM ParkedVehicle
	WHERE Regnum = @Regnum
	--Then delete the vehicle from currently parked vehicles
	DELETE FROM ParkedVehicle
	WHERE Regnum = @Regnum;

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
END CATCH
GO
