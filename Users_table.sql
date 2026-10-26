-- Таблица пользователей приложения KabinetPsychologistApp
-- Выполнить в SSMS ДО создания модели ADO.NET Entity Data Model
USE KabinetPsychologist;
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        UserID         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
        [Login]        NVARCHAR(50)  NOT NULL,
        PasswordHash   CHAR(64)      NOT NULL,          -- SHA-256, 64 hex-символа
        FullName       NVARCHAR(200) NOT NULL,
        [Role]         NVARCHAR(20)  NOT NULL,          -- Admin или Psychologist
        PsychologistID INT NULL,
        CONSTRAINT CK_Users_Role CHECK ([Role] IN (N'Admin', N'Psychologist')),
        CONSTRAINT FK_Users_Psychologists FOREIGN KEY (PsychologistID) REFERENCES dbo.Psychologists(PsychologistID)
    );
    CREATE UNIQUE INDEX UX_Users_Login ON dbo.Users([Login]);
END
GO

-- Тестовые пользователи: admin / admin123 и psy / psy123 (привязан к первому психологу в таблице)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE [Login] = N'admin')
    INSERT dbo.Users([Login], PasswordHash, FullName, [Role], PsychologistID)
    VALUES (N'admin', CONVERT(CHAR(64), HASHBYTES('SHA2_256', 'admin123'), 2), N'Администратор системы', N'Admin', NULL);

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE [Login] = N'psy')
    INSERT dbo.Users([Login], PasswordHash, FullName, [Role], PsychologistID)
    SELECT N'psy', CONVERT(CHAR(64), HASHBYTES('SHA2_256', 'psy123'), 2), p.FullName, N'Psychologist', p.PsychologistID
    FROM (SELECT TOP (1) PsychologistID, FullName FROM dbo.Psychologists ORDER BY PsychologistID) AS p;
GO

SELECT UserID, [Login], FullName, [Role], PsychologistID FROM dbo.Users;
GO
