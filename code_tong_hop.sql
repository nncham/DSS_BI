
----------Sử dụng dữ liệu trong DB nguồn:
USE DB_Nguon_Sakila
GO 
----------Sử dụng dữ liệu trong DB đích:
USE DB_Dich_Sakila
GO 

DELETE FROM Fact_Retail_Sales;
DELETE FROM Dim_Customer;
DELETE FROM Dim_Date;
DELETE FROM Dim_Product;
DELETE FROM Dim_Staff;
DELETE FROM Dim_Store;
DROP TABLE Fact_Retail_Sales;
DROP TABLE Dim_Customer;
DROP TABLE Dim_Date;
DROP TABLE Dim_Product;
DROP TABLE Dim_Staff;
DROP TABLE Dim_Store;

-----1.Tạo các bảng dim, fact:
--1.1. Dim_Product:
--Bảng Dim chỉ có một khóa chính (id) nên đổi Language_id -> Language_name, Original_language_id -> Original_language_name
CREATE TABLE Dim_Product(
	[Product_key] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Product_ID] [int],
	[Title] [varchar](255),
	[Description] nvarchar(max),
	[Release_year] [varchar](4),
	[Language_name] char(20), 
	[Original_language_name] char(20),
	[Rental_duration] [tinyint],
	[Rental_rate] [decimal](4, 2),
	[Length] [smallint],
	[Replacement_cost] [decimal](5, 2),
	[Rating] [varchar](10),
	[Special_features] [varchar](255),
	[Last_update] [datetime],
	[Category] [varchar] (50),
	[Inventory] [int], 
	[Start_update] [datetime])

--Thay đổi kiểu dữ liệu của trường description ở bảng nguồn - film: text -> nvarchar(max)
ALTER TABLE dbo.film
ALTER COLUMN [description] NVARCHAR(MAX);
--(vì nếu để text thì gặp lỗi SSIS không hỗ trợ kiểu dữ liệu này)

--Xóa trigger ở bảng nguồn - film thì mới thay đổi được kiểu dữ liệu trong bảng nguồn:
ALTER TABLE dbo.film
DROP CONSTRAINT DF__film__descriptio__6754599E;
--DF__film__descriptio__6754599E: ở mỗi máy có một mã khác nhau

--1.2. Dim_Staff: 
CREATE TABLE Dim_Staff(
	[Staff_key] [bigint] IDENTITY (1, 1) PRIMARY KEY,
	[Staff_id] [tinyint],
	[First_name] [varchar](45),
	[Last_name] [varchar](45),
	[Address_name] [varchar](50),
	[Picture] image,
	[Email] [varchar](50),
	[Address_store] [varchar](50),
	[Active] [bit],
	[Username] [varchar](16),
	[Password] [varchar](40),
	[Last_update] [datetime],
	[Feedback] nvarchar(max), 
	[Start_update] datetime,
	[End_update] datetime)

--1.3. Dim_Store:
CREATE TABLE Dim_Store(
	[Store_key] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Store_id] [int],
	[Manager_staff_name] [varchar](45),
	[Address_name] [varchar](50),
	[Last_update] [datetime])

--1.4. Dim_Customer: 
CREATE TABLE Dim_Customer(
	[Customer_key] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Customer_id] [int],
	[Store_name] [varchar](50),
	[First_name] [varchar](45), 
	[Last_name] [varchar](45),
	[Email] [varchar](50),
	[Address_name] [varchar](50),
	[Active] [char](1),
	[Create_date] [datetime],
	[Last_update] [datetime],
	[Age] [int], 
	[Sex] [int], 
	[Income] [money],
	[Hobbies] [varchar](200))

--1.5. Dim_Date: 
CREATE TABLE Dim_Date
(
Date_ID int primary key not null,
FullDate date not null,
DD int not null,
MM int not null,
YYYY int not null,
WeekDayName varchar(50) not null,
WeekDayShort varchar(50) not null,
Month_Name varchar(50) not null,
Month_Short varchar(50) not null,
Day_Of_Year int not null,
Week_Of_Month int not null,
Week_Of_Year int not null,
QuarterYear int not null,
QuarterName varchar(50) not null,
IsWeekend bit not null,
IsHoliday bit not null,
HolidayName nvarchar(50) null,
FirstDateofYear DATE NULL,
LastDateofYear DATE NULL,
FirstDateofQuarter DATE NULL,
LastDateofQuarter DATE NULL,
FirstDateofMonth DATE NULL,
LastDateofMonth DATE NULL,
FirstDateofWeek DATE NULL,
LastDateofWeek DATE NULL,
)
SET NOCOUNT ON
Declare @SD DATE
set @SD = '2005-01-01'
DECLARE @ED DATE
set @ED = '2006-12-31'
WHILE @SD < @ED
begin
insert into Dim_Date
(
[Date_id],
[FullDate],
[DD],
[MM],
[YYYY],
[WeekDayName],
[WeekDayShort],
[Month_Name],
[Month_Short],
[Day_Of_Year],
[Week_Of_Month],
[Week_Of_Year],
[QuarterYear],
[QuarterName],
[IsWeekend],
[IsHoliday],
[FirstDateofYear],
[LastDateofYear],
[FirstDateofQuarter],
[LastDateofQuarter],
[FirstDateofMonth],
[LastDateofMonth],
[FirstDateofWeek],
[LastDateofWeek]
)
select
[Date_id] = year(@SD)*10000 + MONTH(@SD)*100 +

DAY(@SD),

[FullDate] = @SD,
[DD] = DAY(@SD),
[MM] = MONTH(@SD),
[YYYY] = YEAR(@SD),

[WeekDayName] = DATENAME(dw, @SD),
[WeekDayShort] = UPPER(LEFT(DATENAME(dw, @SD),3)),
[Month_Name] = DATENAME(mm, @SD) ,
[MonthShort] = UPPER(LEFT(DATENAME(mm, @SD),3)) ,
[Day_Of_Year] = DATENAME(dy, @SD),
[Week_Of_Month] = DATEPART(WEEK, @SD) -
DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM,0, @SD), 0)) + 1,

[Week_Of_Year] = DATEPART(wk, @SD),
[QuarterYear] = DATEPART(q, @SD),
[QuaterName] = case
when DATENAME(qq, @SD) = 1
THEN 'First'
WHEN DATENAME(qq, @SD) = 2
THEN 'Second'
WHEN DATENAME(qq, @SD) = 3
THEN 'Third&'
WHEN DATENAME(qq, @SD) = 4
THEN 'Fourth&'
END,
[IsWeekend] = case
when DATENAME(dw,@SD) = 'Sunday' or

DATENAME(dw,@SD) = 'Saturday' then 1

else 0 end,
[IsHoliday] = 0,
[FirstDateofYear] = CAST(CAST(YEAR(@SD) AS

VARCHAR(4)) + '-01-01' AS DATE),

[LastDateofYear] = CAST(CAST(YEAR(@SD) AS

VARCHAR(4)) + '-12-31' AS DATE),

[FirstDateofQuarter] = DATEADD(qq, DATEDIFF(qq, 0,

GETDATE()), 0),


[LastDateofQuarter] = DATEADD(dd, - 1, DATEADD(qq,

DATEDIFF(qq, 0, GETDATE()) + 1,0)),

[FirstDateofMonth] = CAST(CAST(YEAR(@SD) AS
VARCHAR(4)) + '-' + CAST(MONTH(@SD) AS VARCHAR(2)) + '-01' AS
DATE),

[LastDateofMonth] = CONVERT(DATETIME,
CONVERT(DATE, DATEADD(DD, -(DATEPART(DD,(DATEADD(MM, 1,
@SD)))), DATEADD(MM, 1, @SD)))),

[FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @SD)

- 1), @SD),

[LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw,

@SD)), @SD)

SET @SD = DATEADD(DD, 1, @SD)
end

UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 1 Tết
dương lịch' WHERE [MM] = 1 AND [DD] = 1;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 2 Tết
dương lịch' WHERE [MM] = 1 AND [DD] = 2;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Tết ông
Công ông Táo' WHERE [MM] = 1 AND [DD] = 25;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Đêm Giao
thừa' WHERE [MM] = 1 AND [DD] = 31;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 1 Tết
Nguyên Đán' WHERE [MM] = 2 AND [DD] = 1;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 2 Tết
Nguyên Đán' WHERE [MM] = 2 AND [DD] = 2;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 3 Tết
Nguyên Đán' WHERE [MM] = 2 AND [DD] = 3;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 4 Tết
Nguyên Đán' WHERE [MM] = 2 AND [DD] = 4;


UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Mùng 5 Tết
Nguyên Đán' WHERE [MM] = 2 AND [DD] = 5;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày lễ tình
yêu' WHERE [MM] = 2 AND [DD] = 14;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Tết Nguyên
Tiêu' WHERE [MM] = 2 AND [DD] = 15;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày Quốc
tế Phụ Nữ' WHERE [MM] = 3 AND [DD] = 8;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Tết Hàn
thực' WHERE [MM] = 4 AND [DD] = 3;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Giỗ Tổ
Hùng Vương' WHERE [MM] = 4 AND [DD] = 10;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Chủ nhật
phục sinh' WHERE [MM] =4 AND [DD] = 17;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày thống
nhất đất nước' WHERE [MM] = 4 AND [DD] = 30;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày quốc
tế lao động' WHERE [MM] = 5 AND [DD] =1 ;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Lễ Phật
Đản' WHERE [MM] = 5 AND [DD] = 15;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày Quốc
tế thiếu nhi' WHERE [MM] = 6 AND [DD] = 1;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Tết Đoan
Ngọ' WHERE [MM] = 6 AND [DD] = 3;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Lễ vu lan'
WHERE [MM] = 8 AND [DD] = 12;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày Cách mạng tháng 8' WHERE [MM] = 8 AND [DD] = 19;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Quốc khánh' WHERE [MM] = 9 AND [DD] = 1;


UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Quốc
khánh' WHERE [MM] = 9 AND [DD] = 2;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Tết Trung
Thu' WHERE [MM] = 9 AND [DD] = 10;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày Phụ
nữ Việt Nam' WHERE [MM] = 10 AND [DD] = 20;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày Nhà
giáo Việt Nam' WHERE [MM] = 11 AND [DD] = 20;
UPDATE Dim_Date SET [IsHoliday] = 1, [HolidayName] = 'Ngày lễ
Giáng sinh' WHERE [MM] = 12 AND [DD] = 25;
--1.6. Fact_Retail_Sales:
/****** Object:  Table [dbo].[Fact_Retail_Sales]    Script Date: 05/11/2023 3:44:19 CH ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [dbo].[Fact_Retail_Sales](
	[Date_ID] [int] NOT NULL,
	[Customer_key] [bigint] NOT NULL,
	[Product_key] [bigint] NOT NULL,
	[Store_key] [bigint] NOT NULL,
	[Staff_key] [bigint] NOT NULL,
	[Amount] decimal(5,2) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Fact_Retail_Sales]  WITH CHECK ADD FOREIGN KEY([Customer_key])
REFERENCES [dbo].[Dim_Customer] ([Customer_key])
GO

ALTER TABLE [dbo].[Fact_Retail_Sales]  WITH CHECK ADD FOREIGN KEY([Date_ID])
REFERENCES [dbo].[Dim_Date] ([Date_ID])
GO

ALTER TABLE [dbo].[Fact_Retail_Sales]  WITH CHECK ADD FOREIGN KEY([Product_key])
REFERENCES [dbo].[Dim_Product] ([Product_key])
GO

ALTER TABLE [dbo].[Fact_Retail_Sales]  WITH CHECK ADD FOREIGN KEY([Staff_key])
REFERENCES [dbo].[Dim_Staff] ([Staff_key])
GO

ALTER TABLE [dbo].[Fact_Retail_Sales]  WITH CHECK ADD FOREIGN KEY([Store_key])
REFERENCES [dbo].[Dim_Store] ([Store_key])
GO

-----2. Update dữ liệu: 
USE DB_Sakila_Nguon
GO
UPDATE staff 
SET password = '...'
WHERE staff_id = 2;
