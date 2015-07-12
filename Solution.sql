
--Problem 1- All Mountain Peaks
SELECT 
	PeakName 
FROM Peaks
ORDER BY PeakName

--Problem 2 - Biggest Countries by Population

SELECT top 30
	CountryName,
	Population
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY Population DESC

--Problem 3 - Countries and Currency (Euro / Not Euro) - NE

SELECT 
	CountryName as CountryName,
	CountryCode as CountryCode,
	CASE 
		WHEN CurrencyCode = 'EUR' THEN 'Euro'
		WHEN CurrencyCode <> 'EUR' THEN 'Not Euro'
		WHEN CurrencyCode IS NULL THEN 'Not Euro'
	END as Currency
FROM Countries
ORDER BY CountryName


--Problem 4.	Countries Holding 'A' 3 or More Times

SELECT 
	CountryName as [Country Name],
	IsoCode as [ISO Code]
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode


--Problem 5.	Peaks and Mountains

SELECT
	p.PeakName,
	m.MountainRange as Mountain,
	p.Elevation
FROM Peaks p
	JOIN Mountains m ON p.MountainId = m.Id 
ORDER BY p.Elevation DESC


--Problem 6.	Peaks with Their Mountain, Country and Continent

SELECT
	p.PeakName,
	m.MountainRange as Mountain,
	c.CountryName,
	con.ContinentName
FROM Peaks p
	JOIN MountainsCountries mc ON p.MountainId = mc.MountainId
	JOIN Mountains m ON p.MountainId = m.Id
	JOIN Countries c ON mc.CountryCode = c.CountryCode
	JOIN Continents con ON c.ContinentCode = con.ContinentCode
ORDER BY p.PeakName, c.CountryName


--Problem 7.    Rivers Passing through 3 or More Countries

SELECT 
	r.RiverName as River,
	COUNT(cr.CountryCode) as [Countries Count]
FROM Rivers r
	JOIN CountriesRivers cr ON r.Id = cr.RiverId
GROUP BY r.RiverName
HAVING COUNT(cr.CountryCode) >= 3
ORDER BY r.RiverName



--Problem 8.	Highest, Lowest and Average Peak Elevation

SELECT
	MAX(Elevation) as MaxElevation,
	MIN(Elevation) as MinElevation,
	AVG(Elevation) as AverageElevation
FROM Peaks



--Problem 9.	Rivers by Country

SELECT
	c.CountryName,
	con.ContinentName,
	ISNULL(COUNT(cr.RiverId), 0) as RiversCount,
	ISNULL(SUM(r.Length),0) as TotalLength
FROM Countries c
	LEFT JOIN CountriesRivers cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers r ON cr.RiverId = r.Id
	LEFT JOIN Continents con ON c.ContinentCode = con.ContinentCode
GROUP BY c.CountryName, con.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, c.CountryName



--Problem 10.	Count of Countries by Currency - NE

SELECT
	cur.CurrencyCode as CurrencyCode,
	cur.Description as Currency,
	COUNT(c.CountryCode) as NumberOfCountries
FROM Currencies cur
	LEFT OUTER JOIN Countries c ON c.CurrencyCode = cur.CurrencyCode
GROUP BY cur.CurrencyCode, cur.Description
ORDER BY NumberOfCountries DESC, cur.Description

--Problem 11.	* Population and Area by Continent

SELECT
	con.ContinentName,
	SUM(c.AreaInSqKm) as CountriesArea,
	SUM(CAST(c.Population as bigint)) as CountriesPopulation
FROM Countries c
	JOIN Continents con ON c.ContinentCode = con.ContinentCode
GROUP BY con.ContinentName
ORDER BY CountriesPopulation DESC

--Problem 12.	Highest Peak and Longest River by Country

SELECT
	c.CountryName,
	MAX(p.Elevation) as HighestPeakElevation,
	MAX(r.Length) as LongestRiverLength
FROM Countries c
	LEFT JOIN CountriesRivers cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers r ON cr.RiverId = r.Id
	LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Peaks p ON mc.MountainId = p.MountainId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

--Problem 13.	Mix of Peak and River Names

SELECT 
	p.PeakName,
	r.RiverName,
	LOWER(p.PeakName + SUBSTRING(r.RiverName, 2, LEN(r.RiverName))) as Mix
FROM 
	Peaks p,
	Rivers r
WHERE SUBSTRING(p.PeakName, LEN(p.PeakName), 1) = SUBSTRING(LOWER(r.RiverName), 1, 1)
ORDER BY Mix


--Problem 14.	** Highest Peak Name and Elevation by Country- NE

SELECT
	c.CountryName,
	p.PeakName,
	MAX(p.Elevation)
FROM Countries c
	JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	JOIN Peaks p ON mc.MountainId = p.MountainId
GROUP BY c.CountryName, p.PeakName
HAVING p.Elevation = (
	SELECT 
		MAX(p.Elevation)
	FROM Countries c
	JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	JOIN Peaks p ON mc.MountainId = p.MountainId
GROUP BY c.CountryName, p.PeakName
)

--PART II

--Problem 15.	Monasteries by Country

CREATE TABLE Monasteries(
	Id int NOT NULL IDENTITY PRIMARY KEY,
	Name nvarchar(50) NOT NULL,
	CountryCode nvarchar(max)
)
GO

ALTER TABLE Countries ADD MonasteryCode nvarchar(max)
GO

ALTER TABLE Countries ADD CONSTRAINT FK_Countries_Monasteries
FOREIGN KEY(CountryCode) REFERENCES Countries(CountryCode)
GO

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

ALTER TABLE Countries
ADD IsDeleted bit NOT NULL 
DEFAULT 0


UPDATE Countries
SET IsDeleted = 1
WHERE CountryName IN 
(
SELECT 
	CountryName
FROM Countries c
	JOIN CountriesRivers cr ON c.CountryCode = cr.CountryCode
GROUP BY c.CountryName
HAVING COUNT(cr.RiverId) > 3
)


SELECT
	m.Name as Monastery,
	c.CountryName as Country
FROM Monasteries m
	JOIN Countries c ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 0
ORDER BY m.Name


--Problem 16.	Monasteries by Continents and Countries

UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries(Name, CountryCode)
VALUES(
	'Hanga Abbey',
	(SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania')
)

INSERT INTO Monasteries(Name, CountryCode)
VALUES(
	'Myin-Tin-Daik',
	(SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar')
)

SELECT 
	cr.ContinentName as ContinentName,
	c.CountryName as CountryName,
	COUNT(m.Id) as MonasteriesCount
FROM Monasteries m
	FULL JOIN Countries c ON m.CountryCode = c.CountryCode
	FULL JOIN Continents cr ON c.ContinentCode = cr.ContinentCode
WHERE c.IsDeleted = 0
GROUP BY c.CountryName, cr.ContinentName
ORDER BY MonasteriesCount DESC, c.CountryName



--Problem 18 -- MySQL

DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings` CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;

DROP TABLE IF EXISTS `training_centers`;

CREATE TABLE `training_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` nvarchar(100) NOT NULL,
  `description` nvarchar(100) NULL,
  `URL` nvarchar(100) NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `courses`;


CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` nvarchar(100) NOT NULL,
  `description` nvarchar(100) NULL,
  PRIMARY KEY (`id`)
);


DROP TABLE IF EXISTS `timetable`;


CREATE TABLE `timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `training_center_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_timetable_courses_idx`(`course_id`),
  KEY `fk_timetable_training_center_idx`(`training_center_id`),
  CONSTRAINT `fk_timetable_courses` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_timetable_training_center` FOREIGN KEY (`training_center_id`) REFERENCES `training_centers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

INSERT INTO `training_centers` VALUES (1, 'Sofia Learning', NULL, 'http://sofialearning.org'), (2, 'Varna Innovations & Learning', 'Innovative training center, located in Varna. Provides trainings in software development and foreign languages', 'http://vil.edu'), (3, 'Plovdiv Trainings & Inspiration', NULL, NULL),
(4, 'Sofia West Adult Trainings', 'The best training center in Lyulin', 'https://sofiawest.bg'), (5, 'Software Trainings Ltd.', NULL, 'http://softtrain.eu'),
(6, 'Polyglot Language School', 'English, French, Spanish and Russian language courses', NULL), (7, 'Modern Dances Academy', 'Learn how to dance!', 'http://danceacademy.bg');

INSERT INTO `courses` VALUES (101, 'Java Basics', 'Learn more at https://softuni.bg/courses/java-basics/'), (102, 'English for beginners', '3-month English course'), (103, 'Salsa: First Steps', NULL), (104, 'Avancée Français', 'French language: Level III'), (105, 'HTML & CSS', NULL), (106, 'Databases', 'Introductionary course in databases, SQL, MySQL, SQL Server and MongoDB'), (107, 'C# Programming', 'Intro C# corse for beginners'), (108, 'Tango dances', NULL), (109, 'Spanish, Level II', 'Aprender Español');

INSERT INTO `timetable`(course_id, training_center_id, start_date) VALUES (101, 1, '2015-01-31'), (101, 5, '2015-02-28'), (102, 6, '2015-01-21'), (102, 4, '2015-01-07'), (102, 2, '2015-02-14'), (102, 1, '2015-03-05'), (102, 3, '2015-03-01'), (103, 7, '2015-02-25'), (103, 3, '2015-02-19'), (104, 5, '2015-01-07'), (104, 1, '2015-03-30'), (104, 3, '2015-04-01'), (105, 5, '2015-01-25'), (105, 4, '2015-03-23'), (105, 3, '2015-04-17'), (105, 2, '2015-03-19'), (106, 5, '2015-02-26'), (107, 2, '2015-02-20'), (107, 1, '2015-01-20'), (107, 3, '2015-03-01'), (109, 6, '2015-01-13');

UPDATE `timetable` t JOIN `courses` c ON t.course_id = c.id
SET t.start_date = DATE_SUB(t.start_date, INTERVAL 7 DAY)
WHERE c.name REGEXP '^[a-j]{1,5}.*s$';

SELECT 
	tc.name as `training center`,
	t.start_date as `start date`,
	c.name as `course name`,
	c.description as `more info`
FROM timetable t
	JOIN training_centers tc ON tc.id = t.training_center_id
	JOIN courses c ON c.id = t.course_id
ORDER BY t.start_date, t.id


