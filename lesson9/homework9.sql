--��������� ������ ��� ������ � ������� �����
ALTER TABLE dbo.Country
ADD Code nvarchar(2) NOT NULL

--��������� �������� ����� � ������� ����� �� ���������������� ����� c mackaroo
INSERT INTO dbo.Country (Name, Code)
SELECT Name, Code
	FROM dbo.Countries

--��������� ���� ������� ��� ��������
ALTER TABLE dbo.Coach
ADD Gender nvarchar(1) NOT NULL

--��������� �������� �� ���������������� ����� c mackaroo
INSERT INTO [dbo].[Coach] (FirstName, LastName, PassportNumber, CountryID, Gender)
SELECT 
[FirstName] = [first_name], 
[LastName] = [last_name], 
[PassportNumber] = CONCAT(LEFT(first_name, 1), left(last_name, 1), '-', gender, '-', LEFT(NEWID(), 8), '-', FLOOR(RAND(CHECKSUM(NewId()))*(1000-1+1))+1), 
[CountryID] = FLOOR(RAND(CHECKSUM(NewId()))*(1000-1+1))+1, 
[Gender] = gender
FROM dbo.CoachNames

--��������� �������
--��������� �����������
ALTER TABLE dbo.swimmer NOCHECK CONSTRAINT ALL

--���������� ������ � ��������� �������
INSERT INTO [dbo].[Swimmer] (FirstName, LastName, PassportNumber, BirthDate, Gender, CountryID, CoachID)
SELECT 
[FirstName] = names.[First_Name], 
[LastName] = names.[Last_Name], 
[PassportNumber] = CONCAT(LEFT(names.[first_name], 1), 
					left(last_name, 1), '-', names.[gender], '-', 
					LEFT(NEWID(), 8), '-', 
					FLOOR(RAND(CHECKSUM(NewId()))*(1000-1+1))+1), --������ ����� ����� � ������� + ��������� id + ��������� 4-� ������� �����
[BirthDate] = DATEFROMPARTS(FLOOR(RAND(CHECKSUM(NewId()))*(2002-1980+1))+1980, 
		FLOOR(RAND(CHECKSUM(NewId()))*(12-1+1))+1, 
		FLOOR(RAND(CHECKSUM(NewId()))*(28-1+1))+1), --�������� ���������� ���� ������� � 1980 ����
[Gender] = names.[gender],
[CountryID] = FLOOR(RAND(CHECKSUM(NewId()))*(1000-1+1))+1, 
[CoachID] = FLOOR(RAND(CHECKSUM(NewId()))*(1000-1+1))+1 
FROM (
	SELECT TOP 100000 cn.[First_name], sn.[Last_name], cn. gender
	FROM [dbo].[CoachNames] cn
	CROSS JOIN [dbo].[SwimmerNames] sn
	WHERE cn.gender = sn.gender
) as names

--���������� �����������
ALTER TABLE tableName WITH CHECK CHECK CONSTRAINT ALL

--��������� ���� ��������
--������� 2 ��������� ������� ��� ����� �������� � ���������
CREATE TABLE #SwimmingTypesNames
(type_name nvarchar(100))

CREATE TABLE #Distances
(distance nvarchar(30))

--��������� ��������
INSERT INTO #SwimmingTypesNames
VALUES 
('Front Crawl'), ('Breaststroke'), ('Butterfly Stroke'),  ('Backstroke'), ('Sidestroke')

INSERT INTO #Distances
VALUES 
('50m'), ('100m'), ('200m'),  ('400m'), ('800m') 

--����������� ������ � ��������� �� � ������� ����� ��������
INSERT INTO [dbo].[SwimmingType] (Name, Distance)
SELECT
[Name] = types.[type_name],
[Distance] = types.[distance]
FROM
(
SELECT st.[type_name], d.[distance]
	FROM [dbo].#SwimmingTypesNames st
	CROSS JOIN [dbo].#Distances d
) as types

--��������� ������������, ���� ������������ ����� ���������� � 2001-�� ����
DECLARE @c1sd date
DECLARE @c1ed date
SET @c1sd = '2000-06-01'
SET @c1ed = '2000-06-25'

WHILE @c1sd < '2021-06-01'
BEGIN
INSERT INTO [dbo].[Competition] (StartDate, EndDate, CompetitionName)
SELECT
[StartDate] = DATEADD(year, 1, @c1sd),
[EndDate] = DATEADD(year, 1, @c1ed),
[CompetitionName] = CONCAT('Competition', ' ', 
					MONTH(DATEADD(year, 1, @c1sd)),'/', 
					RIGHT(YEAR(DATEADD(year, 1, @c1sd)), 2)) --���������� �������� ������������ �� ������ � ���� ����������
SET @c1sd = DATEADD(year, 1, @c1sd)
SET @c1ed = DATEADD(year, 1, @c1ed)
END

----��������� �������
--������ PeakViewership NULL, ����� ����� ������� TotalUniqueViews ������� update ���� �������
ALTER TABLE dbo.race ALTER COLUMN peakviewership int NULL

--��������� �����������
ALTER TABLE dbo.race NOCHECK CONSTRAINT ALL

INSERT INTO dbo.Race (CompetitionID, SwimmingTypeID, TimeSlot, TotalUniqueViews)
SELECT
[CompetitionID] = comp.CompetitionID,
[SwimmingTypeID] = comp.SwimmingTypeID,
[TimeSlot] = (CASE		--�������� �������� � ����� ����� ��� ��������� ���������� �������
		WHEN FLOOR(RAND(CHECKSUM(NewId()))*(3-1+1))+1 = 1 THEN 'Morning'
		WHEN FLOOR(RAND(CHECKSUM(NewId()))*(3-1+1))+1 = 2 THEN 'Afternoon'
		WHEN FLOOR(RAND(CHECKSUM(NewId()))*(3-1+1))+1 = 3 THEN 'Evening'
		ELSE 'Evening'
	END),
[TotalUniqueViews] = FLOOR(RAND(CHECKSUM(NewId()))*(3000000-0+1))+0 
FROM (SELECT c.id as CompetitionID, st.id as SwimmingTypeID
	FROM dbo.Competition c
	cross join dbo.swimmingtype st) comp

--������ ������� ���� ������������ ���������� ������������, �� ������ ���� �� ������, ��� ����� ���������� ����������
UPDATE dbo.Race
SET PeakViewership = FLOOR(RAND(CHECKSUM(NewId()))*([TotalUniqueViews]-0+1))+0

--���������� �����������
ALTER TABLE dbo.race WITH CHECK CHECK CONSTRAINT ALL

--���������� Results
--��������� �����������
ALTER TABLE dbo.Result NOCHECK CONSTRAINT ALL
--���������� �������� � ������ �������� �������
INSERT INTO dbo.Result (RaceID, SwimmerID, Time)
SELECT TOP 1000000 
[RaceID] = race.RaceID,
[SwimmerID] = race.SwimmerID, 
[Time] = FLOOR(RAND(CHECKSUM(NewId()))*(300-59+1))+59 --������� ����� ��������� �����, 
											--�� ������� ����� �������� ��������� 5 �����, ������� 59 ������.
FROM (SELECT s.id as SwimmerID, r.id as RaceID, r.CompetitionID, DATEDIFF(hour, s.BirthDate, GETDATE())/8766 as Age, s.BirthDate
	FROM dbo.swimmer s
	cross join dbo.race r
	WHERE (DATEDIFF(hour, s.BirthDate, GETDATE())/8766) > 18) race --������ ������ ���� ������ 18-�� ���

--���������� �����������
ALTER TABLE dbo.Result WITH CHECK CHECK CONSTRAINT ALL

--���������� Advertister �� mockaroo� ��������� � �������
INSERT INTO Advertiser (Name)
SELECT CompanyName
FROM dbo.AdvertiserNames 

--���������� AdvertisterContracts
ALTER TABLE dbo.advertisercontract NOCHECK CONSTRAINT ALL
--��������� ��������� ��������������
INSERT INTO dbo.AdvertiserContract (StartDate, RatePerView, AdvertiserID)
SELECT 
[StartDate] = DATEFROMPARTS(FLOOR(RAND(CHECKSUM(NewId()))*(2020-2001+1))+2001, 
		FLOOR(RAND(CHECKSUM(NewId()))*(12-1+1))+1, 
		FLOOR(RAND(CHECKSUM(NewId()))*(28-1+1))+1),
[RatePerView] = FLOOR(RAND(CHECKSUM(NewId()))*(60-5+1))+5, --����� ��� �������� ����� ������������� �����, �.�. ������ �� ���� ��������
[AdvertiserID] = id
FROM dbo.advertiser
--��������� ���� ��������� ����������
UPDATE dbo.AdvertiserContract
SET EndDate = DATEADD(year, FLOOR(RAND(CHECKSUM(NewId()))*(3-1+1))+1, [StartDate])
--���������� �����������
ALTER TABLE dbo.AdvertiserContract WITH CHECK CHECK CONSTRAINT ALL

--��������� CompetitionBridgeAdvertiser, �.�. ������� �� �������� ���� �������� �� ���� �������������, 
--� ������� ��������� ���� ���������� � ������ ������������ ���������
INSERT INTO dbo.CompetitionBridgeAdvertiser (CompetitionID, AdvertiserID)
SELECT 
[CompetitionID] = c.id, 
[AdvertiserID] = adv_con.AdvertiserID
FROM dbo.Competition c
	CROSS JOIN 
	(SELECT ac.StartDate, a.id as AdvertiserID, ac.EndDate
	FROM dbo.AdvertiserContract ac
	JOIN dbo.Advertiser a ON ac.AdvertiserID=a.id) adv_con
	WHERE adv_con.StartDate < c.StartDate AND adv_con.EndDate > c.EndDate