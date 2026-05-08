/*
PIPELINE OVERVIEW:
    1. Initialize database
    2. CREATE tables (12) and junction table (1) + constraints
    3. CREATE views (2)
    4. CREATE stored procedure (1)
    5. INSERT test data for all tables
    6. Configure security (CREATE user, login, role + GRANT/DENY permissions)
*/

CREATE DATABASE PatrikHellgren;

GO

USE PatrikHellgren;

GO

CREATE TABLE Authors (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    BirthDate DATE NULL,
    DateOfPassing DATE NULL
);

GO

CREATE TABLE Countries (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    Country CHAR(2) NOT NULL UNIQUE
        CONSTRAINT CK_Country_Valid CHECK (
            LEN(Country) = 2
            AND Country NOT LIKE '%[^A-Z]%')
);

GO

CREATE TABLE Genres (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    Genre NVARCHAR(25) NOT NULL UNIQUE
);

GO

CREATE TABLE Formats (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    Format NVARCHAR(25) NOT NULL UNIQUE
);

GO

CREATE TABLE SalesChannels (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    ChannelName NVARCHAR(50) NOT NULL UNIQUE
);

GO

CREATE TABLE Publishers (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    OrganizationNumber NVARCHAR(11) NULL
        CONSTRAINT CK_OrgNumberPublishers_ValidFormat CHECK (
            OrganizationNumber IS NULL
            OR (
                LEN(OrganizationNumber) = 11
                AND SUBSTRING(OrganizationNumber, 7, 1) = '-'
                AND OrganizationNumber NOT LIKE '%[^0-9-]%'
            )
        ),
    CountryId SMALLINT NULL
        CONSTRAINT FK_Publishers_Countries
            FOREIGN KEY (CountryId)
            REFERENCES Countries(ID),
    Website NVARCHAR(200) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL
);

CREATE UNIQUE INDEX UX_Publishers_OrganizationNumber
ON Publishers(OrganizationNumber)
WHERE OrganizationNumber IS NOT NULL;

GO

CREATE TABLE Books (
    ISBN13 CHAR(13) PRIMARY KEY
        CONSTRAINT CK_ISBN13_ValidFormat CHECK (
            LEN(ISBN13) = 13
            AND ISBN13 NOT LIKE '%[^0-9]%'
        ),
    Title NVARCHAR(100) NOT NULL,
    Edition NVARCHAR(50) NULL,
    Language NVARCHAR(25) NULL,
    Pages SMALLINT NULL,
    FormatId SMALLINT NULL
        CONSTRAINT FK_Books_Formats
            FOREIGN KEY (FormatId)
            REFERENCES Formats(ID),
    GenreId SMALLINT NULL
        CONSTRAINT FK_Books_Genres
            FOREIGN KEY (GenreId)
            REFERENCES Genres(ID),
    Price DECIMAL(7,2) NOT NULL,
    PurchasePrice DECIMAL(7,2) NOT NULL,
    PublisherId SMALLINT NULL
        CONSTRAINT FK_Books_Publishers
            FOREIGN KEY (PublisherId)
            REFERENCES Publishers(ID),
    PublishedDate DATE NULL
);

GO

CREATE TABLE Stores (
    ID SMALLINT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE,
    AddressLine1 NVARCHAR(25) NOT NULL,
    AddressLine2 NVARCHAR(25) NULL,
    PostalCode NVARCHAR(10) NOT NULL,
    City NVARCHAR(25) NOT NULL,
    CountryId SMALLINT NOT NULL
        CONSTRAINT FK_Stores_Countries
            FOREIGN KEY (CountryId)
            REFERENCES Countries(ID),
    
    CONSTRAINT CK_StorePostalCode_ValidFormatSE CHECK (
        (CountryId <> 1)
        OR
        (PostalCode LIKE '[0-9][0-9][0-9] [0-9][0-9]')
    )
);

GO

CREATE TABLE StockQuantities (
    StoreId SMALLINT NOT NULL
        CONSTRAINT FK_StockQuantities_Stores
            FOREIGN KEY (StoreId)
            REFERENCES Stores(ID),
    ISBN13 CHAR(13) NOT NULL
        CONSTRAINT FK_StockQuantities_Books
            FOREIGN KEY (ISBN13)
            REFERENCES Books(ISBN13),
    StockQuantity INT NOT NULL
        CONSTRAINT CK_StockQuantity_NonNegative CHECK (
            StockQuantity >= 0),
    CONSTRAINT PK_StockQuantities PRIMARY KEY (StoreID, ISBN13)
);

GO

CREATE TABLE Customers (
    ID INT IDENTITY(100000,1) PRIMARY KEY,
    IsCompany BIT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    OrganizationNumber NVARCHAR(11) NULL
        CONSTRAINT CK_OrgNumberCustomers_ValidFormat CHECK (
            OrganizationNumber IS NULL
            OR (
                LEN(OrganizationNumber) = 11
                AND SUBSTRING(OrganizationNumber, 7, 1) = '-'
                AND OrganizationNumber NOT LIKE '%[^0-9-]%'
            )
        ),
    PersonalIdentityNumber NVARCHAR(13) NULL
        CONSTRAINT CK_PersonalIdentityNumber_ValidFormat CHECK (
            PersonalIdentityNumber IS NULL
            OR (
                LEN(PersonalIdentityNumber) = 13
                AND SUBSTRING(PersonalIdentityNumber, 9, 1) = '-'
                AND PersonalIdentityNumber NOT LIKE '%[^0-9-]%'
                AND TRY_CONVERT(DATE, SUBSTRING(PersonalIdentityNumber, 1, 8)) IS NOT NULL
            )
        ),
    AddressLine1 NVARCHAR(25) NOT NULL,
    AddressLine2 NVARCHAR(25) NULL,
    PostalCode NVARCHAR(10) NOT NULL,
    City NVARCHAR(25) NOT NULL,
    CountryId SMALLINT NOT NULL
        CONSTRAINT FK_Customers_Countries
            FOREIGN KEY (CountryId)
            REFERENCES Countries(ID),
    PhoneNumber NVARCHAR(20) NULL,
    
    CONSTRAINT CK_CustomerPostalCode_ValidFormatSE CHECK (
        (CountryId <> 1)
        OR
        (PostalCode LIKE '[0-9][0-9][0-9] [0-9][0-9]')
    )
);

CREATE UNIQUE INDEX UX_Customers_OrganizationNumber
ON Customers(OrganizationNumber)
WHERE OrganizationNumber IS NOT NULL;

CREATE UNIQUE INDEX UX_Customers_PersonalIdentityNumber
ON Customers(PersonalIdentityNumber)
WHERE PersonalIdentityNumber IS NOT NULL;

GO
   
CREATE TABLE Orders (
    ID INT IDENTITY(50000,1234) PRIMARY KEY,
    CustomerId INT NULL
        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Customers(ID),
    OrderDate DATETIME2 NOT NULL,
    ChannelId SMALLINT NOT NULL
        CONSTRAINT FK_Orders_SalesChannels
            FOREIGN KEY (ChannelId)
            REFERENCES SalesChannels(ID),
    ShippedDate DATETIME2 NULL,
    FreightCost DECIMAL(6,2) NULL,
    CustomerIsCompany BIT NOT NULL,
    ShipVia SMALLINT NULL,
    ShipName NVARCHAR(50) NULL,
    ShipAddress NVARCHAR(100) NULL,
    ShipPostalCode NVARCHAR(10) NULL,
    ShipCity NVARCHAR(50) NULL,
    ShipCountryId SMALLINT NULL
        CONSTRAINT FK_Orders_Countries
            FOREIGN KEY (ShipCountryId)
            REFERENCES Countries(ID),

    CONSTRAINT CK_ShipPostalCode_ValidFormatSE CHECK (
        (ShipCountryId <> 1)
        OR
        (ShipPostalCode LIKE '[0-9][0-9][0-9] [0-9][0-9]')
    )
);

GO

CREATE TABLE OrderDetails (
    OrderId INT NOT NULL
        CONSTRAINT FK_OrderDetails_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Orders(ID),
    ISBN13 CHAR(13) NOT NULL
        CONSTRAINT FK_OrderDetails_Books
            FOREIGN KEY (ISBN13)
            REFERENCES Books(ISBN13),
    Quantity SMALLINT NOT NULL,
    DiscountRate DECIMAL(5,4) NOT NULL DEFAULT 0
        CONSTRAINT DiscountPercentrage_Valid CHECK (
            DiscountRate BETWEEN 0 AND 1),
    UnitPrice DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (OrderId, ISBN13)
);

GO

CREATE TABLE BookAuthors (
    ISBN13 CHAR(13) NOT NULL
        CONSTRAINT FK_BookAuthors_Books
            FOREIGN KEY (ISBN13)
            REFERENCES Books(ISBN13),
    AuthorId SMALLINT NOT NULL
        CONSTRAINT FK_BookAuthors_Authors
            FOREIGN KEY (AuthorId)
            REFERENCES Authors(ID),
    CONSTRAINT PK_BookAuthors PRIMARY KEY (ISBN13, AuthorId)
);

GO

CREATE VIEW TitlesPerAuthor AS
SELECT
    a.FirstName + ' ' + a.LastName AS Name,
    CASE
        WHEN a.BirthDate IS NULL THEN 'Unknown'
    ELSE
        CAST(
            DATEDIFF(
                YEAR, 
                a.BirthDate, 
                CASE
                    WHEN a.DateOfPassing IS NULL THEN GETDATE()
                    ELSE a.DateOfPassing
                END
            )
            - CASE
                WHEN FORMAT(
                    CASE
                        WHEN a.DateOfPassing IS NULL THEN GETDATE()
                        ELSE a.DateOfPassing
                    END, 'MMdd'
                ) < FORMAT(a.BirthDate, 'MMdd')
                    THEN 1
                    ELSE 0
            END
        AS NVARCHAR(3)) + ' years'
    END AS Age,
    CASE
        WHEN a.DateOfPassing IS NULL THEN 'Alive'
        ELSE 'Deceased'
    END AS LifeStatus,
    CAST(COUNT(DISTINCT b.ISBN13) AS NVARCHAR(10)) + ' st' AS NumberOfTitles,
    CAST(SUM(b.PurchasePrice * sq.StockQuantity) AS NVARCHAR(20)) + ' kr' AS StockValue
FROM Authors a
JOIN BookAuthors ba
    ON a.ID = ba.AuthorId
JOIN Books b
    ON ba.ISBN13 = b.ISBN13
JOIN StockQuantities sq
    ON ba.ISBN13 = sq.ISBN13 
GROUP BY a.FirstName, a.LastName, a.BirthDate, a.DateOfPassing;

GO

/*
Denna vy sammanställer försäljningsdata per kundtyp (företag respektive privatperson) och per försäljningskanal. 
Den visar hur många böcker som har sålts, den totala omsättningen och inköpskostnaden samt marginalen och 
täckningsgraden för varje kombination.

Syftet är att ge bokhandeln ett underlag för att förstå vilket kundsegment och vilka försäljningskanaler som 
genererar högst lönsamhet. På så sätt kan de prioritera marknadsföring och kampanjer till de segment och 
kanaler som är mest lönsamma. Vice versa kan underlaget även användas för att identifiera var bokhandeln 
behöver lägga resurser för att förbättra sin lönsamhet.
*/
CREATE VIEW SalesByCustomerTypeAndChannel AS
SELECT
    CASE
        WHEN c.IsCompany = 1 THEN 'Business'
        ELSE 'Consumer'
    END AS CustomerType,
    sc.ChannelName as SalesChannel,
    CAST(SUM(od.Quantity) AS NVARCHAR(20)) + ' st' AS NumberOfBooksSold,
    CAST(SUM(od.UnitPrice * od.Quantity) AS NVARCHAR(20)) + ' kr' AS TotalSales,
    CAST(SUM(b.PurchasePrice * od.Quantity) AS NVARCHAR(20)) + ' kr' AS TotalPurchasePrice,
    CAST(SUM((od.UnitPrice - b.PurchasePrice) * od.Quantity) AS NVARCHAR(20)) + ' kr' AS TotalMargin,
    CAST(CAST(
            AVG(
                CASE
                    WHEN od.UnitPrice = 0 THEN NULL
                    ELSE ((od.UnitPrice - b.PurchasePrice) / od.UnitPrice) * 100
                END
            ) AS DECIMAL(6,1))
        AS NVARCHAR(20)) + ' %' AS ContributionMarginRatio
FROM Customers c
JOIN Orders o
    ON c.ID = o.CustomerId
JOIN OrderDetails od
    ON o.ID = od.OrderId
JOIN SalesChannels sc
    ON o.ChannelId = sc.ID
JOIN Books b
    ON od.ISBN13 = b.ISBN13
GROUP BY c.IsCompany, sc.ChannelName;

GO

CREATE PROCEDURE MoveBook
    @FromStoreId INT,
    @ToStoreId INT,
    @ISBN13 CHAR(13),
    @QuantityToTransfer INT = 1
  
AS
BEGIN
    DECLARE @FromStoreName NVARCHAR(50);
    DECLARE @ToStoreName NVARCHAR(50);
    DECLARE @BookTitle NVARCHAR(100);
    DECLARE @FromStoreStock INT;

    DECLARE @FromStoreNotFoundError NVARCHAR(200);
    DECLARE @ToStoreNotFoundError NVARCHAR(200);
    DECLARE @BookNotFoundError NVARCHAR(200);
    DECLARE @BookNotInFromStoreError NVARCHAR(200);
    DECLARE @InsufficientStockError NVARCHAR(200);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Stores WHERE ID = @FromStoreId)
        BEGIN
            SET @FromStoreNotFoundError = 
                'FromStoreId ' + CAST(@FromStoreId AS NVARCHAR(10)) + ' does not exist.';
            THROW 50001, @FromStoreNotFoundError, 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM Stores WHERE ID = @ToStoreId)
        BEGIN
            SET @ToStoreNotFoundError = 
                'ToStoreId ' + CAST(@ToStoreId AS NVARCHAR(10)) + ' does not exist.';
            THROW 50002, @ToStoreNotFoundError, 1;
        END;

        SELECT @FromStoreName = Name
        FROM Stores
        WHERE ID = @FromStoreId;

        SELECT @ToStoreName = Name
        FROM Stores
        WHERE ID = @ToStoreId;

        IF NOT EXISTS (SELECT 1 FROM Books WHERE ISBN13 = @ISBN13)
        BEGIN
            SET @BookNotFoundError = 
                'Book with ISBN ' + @ISBN13 + ' does not exist in Books table.';
            THROW 50003, @BookNotFoundError, 1;
        END;

        SELECT @BookTitle = Title
        FROM Books
        WHERE ISBN13 = @ISBN13;

        IF NOT EXISTS (SELECT 1 FROM StockQuantities WHERE StoreId = @FromStoreId AND ISBN13 = @ISBN13)
        BEGIN
            SET @BookNotInFromStoreError = 
                'Book "' + @BookTitle + '" (ISBN: ' + @ISBN13 + ') is not available in store "' + @FromStoreName + '".';
            THROW 50004, @BookNotInFromStoreError, 1;
        END;

        SELECT @FromStoreStock = StockQuantity
        FROM StockQuantities WITH (UPDLOCK, ROWLOCK)
        WHERE StoreId = @FromStoreId
            AND ISBN13 = @ISBN13;

        IF @FromStoreStock < @QuantityToTransfer
        BEGIN
            SET @InsufficientStockError = 
                'Insufficient stock of book "' + @BookTitle + '" in store "' + @FromStoreName + '" (StoreId: ' + CAST(@FromStoreId AS NVARCHAR(10)) + ').';
            THROW 50005, @InsufficientStockError, 1;
        END;

        UPDATE StockQuantities
        SET StockQuantity = StockQuantity - @QuantityToTransfer
        WHERE StoreId = @FromStoreId
            AND ISBN13 = @ISBN13;

        IF EXISTS (SELECT 1 FROM StockQuantities WITH (UPDLOCK, ROWLOCK) WHERE StoreId = @ToStoreId AND ISBN13 = @ISBN13)
            BEGIN
                UPDATE StockQuantities
                SET StockQuantity = StockQuantity + @QuantityToTransfer
                WHERE StoreId = @ToStoreId
                    AND ISBN13 = @ISBN13;
            END
        ELSE
            BEGIN
                INSERT INTO StockQuantities (StoreId, ISBN13, StockQuantity)
                VALUES (@ToStoreId, @ISBN13, @QuantityToTransfer);
            END;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;

GO

/*
Testdata framtagen med hjälp av Copilot, via följande prompt:
    "Generera verklighetsbaserad testdata för min databas enligt tabellerna, kolumnerna och antalen nedan:
    [CREATE TABLE-kod]
    [antal] rader"
*/
INSERT INTO Countries (Country)
VALUES
('SE'),
('NO'),
('DK'),
('FI'),
('GB'),
('US');

GO

INSERT INTO Genres (Genre)
VALUES
('Fantasy'),
('Science Fiction'),
('Romance'),
('Thriller'),
('Horror'),
('Children'),
('Classic'),
('Non-fiction'),
('Mystery'),
('Historical');

GO

INSERT INTO Formats (Format)
VALUES
('Hardcover'),
('Paperback'),
('E-book'),
('Audiobook');

GO

INSERT INTO SalesChannels (ChannelName)
VALUES
('Store'),
('Online'),
('Fair'),
('Other');

GO

INSERT INTO Publishers (Name, OrganizationNumber, CountryId, Website)
VALUES
('Penguin Books', '556000-0010', 6, 'https://www.penguin.com'),
('HarperCollins', '556000-0020', 6, 'https://www.harpercollins.com'),
('Norstedts', '556000-0030', 1, 'https://www.norstedts.se'),
('Bonnier Carlsen', '556000-0040', 1, 'https://www.bonniercarlsen.se'),
('Albert Bonniers Förlag', '556000-0050', 1, 'https://www.albertbonniersforlag.se');

GO

INSERT INTO Stores (Name, AddressLine1, AddressLine2, PostalCode, City, CountryId)
VALUES
('Akademibokhandeln Nordstan', 'Norra Hamngatan 26', NULL, '411 06', 'Göteborg', 1),
('Akademibokhandeln Liljeholmen', 'Liljeholmstorget 5', NULL, '117 61', 'Stockholm', 1),
('Akademibokhandeln Center Syd', 'Marknadsvägen 7', NULL, '246 42', 'Löddeköpinge', 1),
('Akademibokhandeln Väla', 'Väla Centrum', NULL, '260 36', 'Ödåkra', 1),
('Akademibokhandeln Uppsala City', 'Svartbäcksgatan 9', NULL, '753 20', 'Uppsala', 1);

GO

INSERT INTO Authors (FirstName, LastName, BirthDate, DateOfPassing)
VALUES
('Astrid', 'Lindgren', '1907-11-14', '2002-01-28'),
('J.K.', 'Rowling', '1965-07-31', NULL),
('George', 'Orwell', '1903-06-25', '1950-01-21'),
('Jane', 'Austen', '1775-12-16', '1817-07-18'),
('Haruki', 'Murakami', '1949-01-12', NULL),
('Stephen', 'King', '1947-09-21', NULL),
('Selma', 'Lagerlöf', '1858-11-20', '1940-03-16'),
('Ernest', 'Hemingway', '1899-07-21', '1961-07-02'),
('Agatha', 'Christie', '1890-09-15', '1976-01-12'),
('Neil', 'Gaiman', '1960-11-10', NULL);

GO

INSERT INTO Books (ISBN13, Title, Edition, Language, Pages, FormatId, GenreId, Price, PurchasePrice, PublisherId, PublishedDate)
VALUES
('9780141036144', '1984', 'Penguin Modern Classics', 'English', 328, 2, 2, 129.00, 70.00, 1, '1949-06-08'),
('9780451526342', 'Animal Farm', 'Signet Classics Edition', 'English', 112, 2, 2, 99.00, 55.00, 1, '1945-08-17'),
('9789129707814', 'Pippi Långstrump', NULL, 'Swedish', 160, 2, 6, 149.00, 80.00, 4, '1945-11-26'),
('9780099448822', 'Norwegian Wood', NULL, 'English', 296, 2, 7, 149.00, 85.00, 1, '1987-09-04'),
('9780141439518', 'Pride and Prejudice', 'Penguin Classics Edition', 'English', 279, 2, 3, 119.00, 60.00, 1, '1813-01-28'),
('9780747532699', 'Harry Potter and the Philosopher''s Stone', 'Illustrated Edition', 'English', 223, 1, 1, 249.00, 150.00, 2, '1997-06-26'),
('9780747538493', 'Harry Potter and the Chamber of Secrets', NULL, 'English', 251, 1, 1, 199.00, 120.00, 2, '1998-07-02'),
('9780747542155', 'Harry Potter and the Prisoner of Azkaban', 'Collector''s Edition', 'English', 317, 1, 1, 299.00, 180.00, 2, '1999-07-08'),
('9789129727812', 'Mio min Mio', NULL, 'Swedish', 208, 1, 6, 149.00, 80.00, 4, '1954-10-15'),
('9781400079278', 'Kafka on the Shore', 'Vintage International Edition', 'English', 505, 1, 2, 159.00, 90.00, 1, '2002-09-12'),
('9780307743657', 'The Shining', NULL, 'English', 447, 1, 5, 159.00, 90.00, 2, '1977-01-28'),
('9781501142970', 'It', 'Anniversary Edition', 'English', 1138, 1, 5, 199.00, 110.00, 2, '1986-09-15'),
('9780007119318', 'Murder on the Orient Express', NULL, 'English', 256, 1, 9, 129.00, 70.00, 1, '1934-01-01'),
('9780007136834', 'And Then There Were None', NULL, 'English', 272, 1, 9, 129.00, 70.00, 1, '1939-11-06'),
('9780141439587', 'Emma', NULL, 'English', 474, 1, 3, 129.00, 65.00, 1, '1815-12-23'),
('9780684801223', 'The Old Man and the Sea', NULL, 'English', 127, 1, 7, 99.00, 50.00, 1, '1952-09-01'),
('9780099908500', 'The Sun Also Rises', 'Vintage International Edition', 'English', 251, 2, 7, 119.00, 60.00, 1, '1926-10-22'),
('9780062572233', 'American Gods', '10th Anniversary Edition', 'English', 465, 1, 2, 159.00, 90.00, 2, '2001-06-19'),
('9780380807345', 'Coraline', NULL, 'English', 192, 1, 6, 129.00, 70.00, 2, '2002-08-04'),
('9789174296044', 'Jerusalem', NULL, 'Swedish', 592, 1, 10, 149.00, 80.00, 5, '1901-01-01');

GO

INSERT INTO BookAuthors (ISBN13, AuthorId)
VALUES
('9780141036144', 3),
('9780451526342', 3),
('9780747532699', 2),
('9780747538493', 2),
('9780747542155', 2),
('9789129707814', 1),
('9789129727812', 1),
('9781400079278', 5),
('9780099448822', 5),
('9780307743657', 6),
('9781501142970', 6),
('9780007119318', 9),
('9780007136834', 9),
('9780141439518', 4),
('9780141439587', 4),
('9780684801223', 8),
('9780099908500', 8),
('9780062572233', 10),
('9780380807345', 10),
('9789174296044', 7);

GO

INSERT INTO StockQuantities (StoreId, ISBN13, StockQuantity)
VALUES
(1,'9780141036144',12), (2,'9780141036144',8),  (3,'9780141036144',5),  (4,'9780141036144',10), (5,'9780141036144',7),
(1,'9780451526342',9),  (2,'9780451526342',6),  (3,'9780451526342',4),  (4,'9780451526342',7),  (5,'9780451526342',5),
(1,'9780747532699',15), (2,'9780747532699',12), (3,'9780747532699',10), (4,'9780747532699',8),  (5,'9780747532699',6),
(1,'9780747538493',14), (2,'9780747538493',11), (3,'9780747538493',9),  (4,'9780747538493',7),  (5,'9780747538493',5),
(1,'9780747542155',13), (2,'9780747542155',10), (3,'9780747542155',8),  (4,'9780747542155',6),  (5,'9780747542155',4),
(1,'9789129707814',10), (2,'9789129707814',8),  (3,'9789129707814',6),  (4,'9789129707814',5),  (5,'9789129707814',4),
(1,'9789129727812',9),  (2,'9789129727812',7),  (3,'9789129727812',5),  (4,'9789129727812',4),  (5,'9789129727812',3),
(1,'9781400079278',8),  (2,'9781400079278',6),  (3,'9781400079278',5),  (4,'9781400079278',4),  (5,'9781400079278',3),
(1,'9780099448822',7),  (2,'9780099448822',6),  (3,'9780099448822',4),  (4,'9780099448822',3),  (5,'9780099448822',2),
(1,'9780307743657',10), (2,'9780307743657',8),  (3,'9780307743657',6),  (4,'9780307743657',5),  (5,'9780307743657',4),
(1,'9781501142970',9),  (2,'9781501142970',7),  (3,'9781501142970',5),  (4,'9781501142970',4),  (5,'9781501142970',3),
(1,'9780007119318',8),  (2,'9780007119318',6),  (3,'9780007119318',5),  (4,'9780007119318',4),  (5,'9780007119318',3),
(1,'9780007136834',7),  (2,'9780007136834',6),  (3,'9780007136834',4),  (4,'9780007136834',3),  (5,'9780007136834',2),
(1,'9780141439518',10), (2,'9780141439518',8),  (3,'9780141439518',6),  (4,'9780141439518',5),  (5,'9780141439518',4),
(1,'9780141439587',9),  (2,'9780141439587',7),  (3,'9780141439587',5),  (4,'9780141439587',4),  (5,'9780141439587',3),
(1,'9780684801223',8),  (2,'9780684801223',6),  (3,'9780684801223',5),  (4,'9780684801223',4),  (5,'9780684801223',3),
(1,'9780099908500',7),  (2,'9780099908500',6),  (3,'9780099908500',4),  (4,'9780099908500',3),  (5,'9780099908500',2),
(1,'9780062572233',10), (2,'9780062572233',8),  (3,'9780062572233',6),  (4,'9780062572233',5),  (5,'9780062572233',4),
(1,'9780380807345',9),  (2,'9780380807345',7),  (3,'9780380807345',5),  (4,'9780380807345',4),  (5,'9780380807345',3),
(1,'9789174296044',8),  (2,'9789174296044',6),  (3,'9789174296044',5),  (4,'9789174296044',4),  (5,'9789174296044',3);

GO

INSERT INTO Customers (IsCompany, Name, OrganizationNumber, PersonalIdentityNumber, AddressLine1, AddressLine2, PostalCode, City, CountryId, PhoneNumber)
VALUES
(0, 'Anna Svensson', NULL, '19850312-1234', 'Storgatan 11', NULL, '411 20', 'Göteborg', 1, '070-1112233'),
(0, 'Johan Karlsson', NULL, '19920422-5678', 'Ringvägen 44', NULL, '118 61', 'Stockholm', 1, '073-9988776'),
(0, 'Maria Lind', NULL, '19781105-3344', 'Tallvägen 7', NULL, '903 45', 'Umeå', 1, '070-5566778'),
(0, 'Peter Holm', NULL, '19960115-9988', 'Ängsvägen 3', NULL, '504 52', 'Borås', 1, '076-1122334'),
(0, 'Sara Ek', NULL, '19891201-1122', 'Solgatan 19', NULL, '214 32', 'Malmö', 1, '070-7788991'),
(0, 'Daniel Berg', NULL, '19930530-4455', 'Kustvägen 2', NULL, '302 45', 'Halmstad', 1, '073-5566442'),
(0, 'Emma Dahl', NULL, '19870214-7788', 'Lundavägen 55', NULL, '212 18', 'Malmö', 1, '070-9988775'),
(0, 'Oskar Nyström', NULL, '19981122-3344', 'Parkgatan 8', 'c/o Hans Segerstedt', '411 38', 'Göteborg', 1, '076-2233445'),
(0, 'Linda Persson', NULL, '19740303-5566', 'Hagagatan 12', NULL, '113 47', 'Stockholm', 1, '070-6677889'),
(0, 'Fredrik Olsson', NULL, '19800125-7788', 'Björkvägen 6', NULL, '903 22', 'Umeå', 1, '070-3344556'),
(0, 'Caroline Åberg', NULL, '19950719-1122', 'Kyrkogatan 3', NULL, '411 15', 'Göteborg', 1, '073-4455667'),
(0, 'Henrik Sand', NULL, '19821010-8899', 'Sjövägen 10', NULL, '136 45', 'Haninge', 1, '070-5566771'),
(0, 'Mikael Ström', NULL, '19911230-2233', 'Skogsvägen 14', 'c/o Ebba Skoog', '541 32', 'Skövde', 1, '076-7788992'),
(0, 'Elin Fors', NULL, '19860606-6677', 'Backavägen 9', NULL, '903 54', 'Umeå', 1, '070-8899001'),
(1, 'TechNordic AB', '560000-0010', NULL, 'Industrigatan 12', NULL, '417 05', 'Göteborg', 1, '031-555100'),
(1, 'Svenska Bokgrossisten AB', '560000-0020', NULL, 'Bokvägen 4', 'Våning 2, andra dörren', '112 45', 'Stockholm', 1, '08-4457788'),
(1, 'Nordic IT Solutions AB', '560000-0030', NULL, 'Datavägen 22', NULL, '421 32', 'Västra Frölunda', 1, '031-998877'),
(1, 'ScandiLogistics AB', '560000-0040', NULL, 'Terminalgatan 5', NULL, '212 39', 'Malmö', 1, '040-778899'),
(1, 'GreenFuture Consulting AB', '560000-0050', NULL, 'Miljögatan 9', NULL, '753 21', 'Uppsala', 1, '018-556677'),
(1, 'Arctic Engineering AB', '560000-0060', NULL, 'Teknikvägen 3', NULL, '972 38', 'Luleå', 1, '0920-445566');

GO

INSERT INTO Orders (CustomerId, OrderDate, ChannelId, ShippedDate, FreightCost, CustomerIsCompany,
                    ShipVia, ShipName, ShipAddress, ShipPostalCode, ShipCity, ShipCountryId)
VALUES
(100000, '2025-01-12', 1, '2025-01-15', 49.00, 1, 1, 'TechNordic AB', 'Industrigatan 12', '417 05', 'Göteborg', 1),
(100001, '2025-02-03', 2, '2025-02-06', 39.00, 1, 2, 'Svenska Bokgrossisten AB', 'Bokvägen 4', '112 45', 'Stockholm', 1),
(100002, '2025-03-18', 1, '2025-03-20', 59.00, 1, 1, 'Nordic IT Solutions AB', 'Datavägen 22', '421 32', 'Västra Frölunda', 1),
(100003, '2025-04-10', 3, '2025-04-14', 29.00, 1, 3, 'ScandiLogistics AB', 'Terminalgatan 5', '212 39', 'Malmö', 1),
(100004, '2025-05-22', 2, '2025-05-25', 39.00, 1, 2, 'GreenFuture Consulting AB', 'Miljögatan 9', '753 21', 'Uppsala', 1),
(100005, '2025-06-01', 1, '2025-06-04', 49.00, 1, 1, 'Arctic Engineering AB', 'Teknikvägen 3', '972 38', 'Luleå', 1),
(100006, '2025-01-05', 1, '2025-01-07', 29.00, 0, 1, 'Anna Svensson', 'Storgatan 11', '411 20', 'Göteborg', 1),
(100007, '2025-02-14', 2, '2025-02-17', 39.00, 0, 2, 'Johan Karlsson', 'Ringvägen 44', '118 61', 'Stockholm', 1),
(100008, '2025-03-03', 1, '2025-03-06', 49.00, 0, 1, 'Maria Lind', 'Tallvägen 7', '903 45', 'Umeå', 1),
(100009, '2025-03-28', 4, '2025-04-01', 19.00, 0, 4, 'Peter Holm', 'Ängsvägen 3', '504 52', 'Borås', 1),
(100010, '2025-04-12', 2, '2025-04-15', 39.00, 0, 2, 'Sara Ek', 'Solgatan 19', '214 32', 'Malmö', 1),
(100011, '2025-05-01', 1, '2025-05-03', 29.00, 0, 1, 'Daniel Berg', 'Kustvägen 2', '302 45', 'Halmstad', 1),
(100012, '2025-05-19', 3, '2025-05-23', 29.00, 0, 3, 'Emma Dahl', 'Lundavägen 55', '212 18', 'Malmö', 1),
(100013, '2025-06-02', 1, '2025-06-05', 49.00, 0, 1, 'Oskar Nyström', 'Parkgatan 8', '411 38', 'Göteborg', 1),
(100014, '2025-06-15', 2, '2025-06-18', 39.00, 0, 2, 'Linda Persson', 'Hagagatan 12', '113 47', 'Stockholm', 1),
(100015, '2025-07-01', 1, '2025-07-03', 29.00, 0, 1, 'Fredrik Olsson', 'Björkvägen 6', '903 22', 'Umeå', 1),
(100016, '2025-07-12', 4, '2025-07-16', 19.00, 0, 4, 'Caroline Åberg', 'Kyrkogatan 3', '411 15', 'Göteborg', 1),
(100017, '2025-08-03', 2, '2025-08-06', 39.00, 0, 2, 'Henrik Sand', 'Sjövägen 10', '136 45', 'Haninge', 1),
(100018, '2025-08-20', 1, '2025-08-22', 29.00, 0, 1, 'Mikael Ström', 'Skogsvägen 14', '541 32', 'Skövde', 1),
(100019, '2025-09-01', 3, '2025-09-04', 29.00, 0, 3, 'Elin Fors', 'Backavägen 9', '903 54', 'Umeå', 1);

GO

INSERT INTO OrderDetails (OrderId, ISBN13, Quantity, DiscountRate, UnitPrice)
VALUES
(50000, '9780141036144', 2, 0.10, 116.10),
(51234, '9780451526342', 1, 0.00, 99.00),
(52468, '9780747532699', 1, 0.15, 211.65),
(53702, '9780747538493', 3, 0.00, 199.00),
(54936, '9780747542155', 1, 0.20, 239.20),
(56170, '9789129707814', 2, 0.00, 149.00),
(57404, '9789129727812', 1, 0.00, 149.00),
(58638, '9781400079278', 1, 0.00, 159.00),
(59872, '9780099448822', 2, 0.00, 149.00),
(61106, '9780307743657', 1, 0.00, 159.00),
(62340, '9781501142970', 1, 0.25, 149.25),
(63574, '9780007119318', 2, 0.00, 129.00),
(64808, '9780007136834', 1, 0.00, 129.00),
(66042, '9780141439518', 1, 0.00, 119.00),
(67276, '9780141439587', 1, 0.00, 129.00),
(68510, '9780684801223', 1, 0.00, 99.00),
(69744, '9780099908500', 2, 0.00, 119.00),
(70978, '9780062572233', 1, 0.00, 159.00),
(72212, '9780380807345', 1, 0.00, 129.00),
(73446, '9789174296044', 1, 0.00, 149.00);

GO

CREATE ROLE RestrictedUser;

GO

GRANT SELECT ON Books TO RestrictedUser;
GRANT SELECT ON Stores TO RestrictedUser;
GRANT SELECT ON StockQuantities TO RestrictedUser;

DENY SELECT (PurchasePrice) ON Books TO RestrictedUser;
DENY SELECT (PersonalIdentityNumber) ON Customers TO RestrictedUser;

CREATE LOGIN PythonLogin WITH PASSWORD = 'MyUltraStrongPassword123!';

GO

CREATE USER PythonUser FOR LOGIN PythonLogin;

GO

ALTER ROLE RestrictedUser ADD MEMBER PythonUser;

GO
