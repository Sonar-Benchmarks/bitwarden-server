CREATE TABLE [dbo].[UserSigningKeys] (
    [Id]                        UNIQUEIDENTIFIER NOT NULL,
    [UserId]                    UNIQUEIDENTIFIER,
    [KeyType]                   TINYINT NOT NULL,
    [VerifyingKey]              VARCHAR(MAX) NOT NULL,
    [SigningKey]                VARCHAR(MAX) NOT NULL,
    [CreationDate]              DATETIME2 (7) NOT NULL,
    [RevisionDate]              DATETIME2 (7) NOT NULL,
    CONSTRAINT [PK_UserSigningKeys] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UserSigningKeys_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);
GO

CREATE PROCEDURE [dbo].[UserSigningKeys_ReadByUserId]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT *
    FROM [dbo].[UserSigningKeys]
    WHERE [UserId] = @UserId;
END
GO

CREATE PROCEDURE [dbo].[UserSigningKeys_UpdateForRotation]
    @UserId UNIQUEIDENTIFIER,
    @KeyType TINYINT,
    @VerifyingKey VARCHAR(MAX),
    @SigningKey VARCHAR(MAX),
    @RevisionDate DATETIME2(7)
AS
BEGIN
    UPDATE [dbo].[UserSigningKeys]
    SET [KeyType] = @KeyType,
        [VerifyingKey] = @VerifyingKey,
        [SigningKey] = @SigningKey,
        [RevisionDate] = @RevisionDate
    WHERE [UserId] = @UserId;
END
GO

CREATE PROCEDURE [dbo].[UserSigningKeys_SetForRotation]
    @Id UNIQUEIDENTIFIER,
    @UserId UNIQUEIDENTIFIER,
    @KeyType TINYINT,
    @VerifyingKey VARCHAR(MAX),
    @SigningKey VARCHAR(MAX),
    @CreationDate DATETIME2(7),
    @RevisionDate DATETIME2(7)
AS
BEGIN
    INSERT INTO [dbo].[UserSigningKeys] ([Id], [UserId], [KeyType], [VerifyingKey], [SigningKey], [CreationDate], [RevisionDate])
    VALUES (@Id, @UserId, @KeyType, @VerifyingKey, @SigningKey, @CreationDate, @RevisionDate)
END
GO

IF COL_LENGTH('[dbo].[User]', 'SignedPublicKeyOwnershipClaim') IS NULL
BEGIN
    ALTER TABLE
        [dbo].[User]
    ADD
        [SignedPublicKeyOwnershipClaim] VARCHAR(MAX) NULL;
END
GO

EXECUTE sp_refreshview 'dbo.UserView'
GO

CREATE OR ALTER PROCEDURE [dbo].[User_Create]
    @Id UNIQUEIDENTIFIER OUTPUT,
    @Name NVARCHAR(50),
    @Email NVARCHAR(256),
    @EmailVerified BIT,
    @MasterPassword NVARCHAR(300),
    @MasterPasswordHint NVARCHAR(50),
    @Culture NVARCHAR(10),
    @SecurityStamp NVARCHAR(50),
    @TwoFactorProviders NVARCHAR(MAX),
    @TwoFactorRecoveryCode NVARCHAR(32),
    @EquivalentDomains NVARCHAR(MAX),
    @ExcludedGlobalEquivalentDomains NVARCHAR(MAX),
    @AccountRevisionDate DATETIME2(7),
    @Key NVARCHAR(MAX),
    @PublicKey NVARCHAR(MAX),
    @SignedPublicKeyOwnershipClaim NVARCHAR(MAX),
    @PrivateKey NVARCHAR(MAX),
    @Premium BIT,
    @PremiumExpirationDate DATETIME2(7),
    @RenewalReminderDate DATETIME2(7),
    @Storage BIGINT,
    @MaxStorageGb SMALLINT,
    @Gateway TINYINT,
    @GatewayCustomerId VARCHAR(50),
    @GatewaySubscriptionId VARCHAR(50),
    @ReferenceData VARCHAR(MAX),
    @LicenseKey VARCHAR(100),
    @Kdf TINYINT,
    @KdfIterations INT,
    @KdfMemory INT = NULL,
    @KdfParallelism INT = NULL,
    @CreationDate DATETIME2(7),
    @RevisionDate DATETIME2(7),
    @ApiKey VARCHAR(30),
    @ForcePasswordReset BIT = 0,
    @UsesKeyConnector BIT = 0,
    @FailedLoginCount INT = 0,
    @LastFailedLoginDate DATETIME2(7),
    @AvatarColor VARCHAR(7) = NULL,
    @LastPasswordChangeDate DATETIME2(7) = NULL,
    @LastKdfChangeDate DATETIME2(7) = NULL,
    @LastKeyRotationDate DATETIME2(7) = NULL,
    @LastEmailChangeDate DATETIME2(7) = NULL,
    @VerifyDevices BIT = 1
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [dbo].[User]
    (
        [Id],
        [Name],
        [Email],
        [EmailVerified],
        [MasterPassword],
        [MasterPasswordHint],
        [Culture],
        [SecurityStamp],
        [TwoFactorProviders],
        [TwoFactorRecoveryCode],
        [EquivalentDomains],
        [ExcludedGlobalEquivalentDomains],
        [AccountRevisionDate],
        [Key],
        [PublicKey],
        [SignedPublicKeyOwnershipClaim],
        [PrivateKey],
        [Premium],
        [PremiumExpirationDate],
        [RenewalReminderDate],
        [Storage],
        [MaxStorageGb],
        [Gateway],
        [GatewayCustomerId],
        [GatewaySubscriptionId],
        [ReferenceData],
        [LicenseKey],
        [Kdf],
        [KdfIterations],
        [CreationDate],
        [RevisionDate],
        [ApiKey],
        [ForcePasswordReset],
        [UsesKeyConnector],
        [FailedLoginCount],
        [LastFailedLoginDate],
        [AvatarColor],
        [KdfMemory],
        [KdfParallelism],
        [LastPasswordChangeDate],
        [LastKdfChangeDate],
        [LastKeyRotationDate],
        [LastEmailChangeDate],
        [VerifyDevices]
    )
    VALUES
    (
        @Id,
        @Name,
        @Email,
        @EmailVerified,
        @MasterPassword,
        @MasterPasswordHint,
        @Culture,
        @SecurityStamp,
        @TwoFactorProviders,
        @TwoFactorRecoveryCode,
        @EquivalentDomains,
        @ExcludedGlobalEquivalentDomains,
        @AccountRevisionDate,
        @Key,
        @PublicKey,
        @SignedPublicKeyOwnershipClaim,
        @PrivateKey,
        @Premium,
        @PremiumExpirationDate,
        @RenewalReminderDate,
        @Storage,
        @MaxStorageGb,
        @Gateway,
        @GatewayCustomerId,
        @GatewaySubscriptionId,
        @ReferenceData,
        @LicenseKey,
        @Kdf,
        @KdfIterations,
        @CreationDate,
        @RevisionDate,
        @ApiKey,
        @ForcePasswordReset,
        @UsesKeyConnector,
        @FailedLoginCount,
        @LastFailedLoginDate,
        @AvatarColor,
        @KdfMemory,
        @KdfParallelism,
        @LastPasswordChangeDate,
        @LastKdfChangeDate,
        @LastKeyRotationDate,
        @LastEmailChangeDate,
        @VerifyDevices
    )
END
GO

CREATE OR ALTER PROCEDURE [dbo].[User_Update]
    @Id UNIQUEIDENTIFIER,
    @Name NVARCHAR(50),
    @Email NVARCHAR(256),
    @EmailVerified BIT,
    @MasterPassword NVARCHAR(300),
    @MasterPasswordHint NVARCHAR(50),
    @Culture NVARCHAR(10),
    @SecurityStamp NVARCHAR(50),
    @TwoFactorProviders NVARCHAR(MAX),
    @TwoFactorRecoveryCode NVARCHAR(32),
    @EquivalentDomains NVARCHAR(MAX),
    @ExcludedGlobalEquivalentDomains NVARCHAR(MAX),
    @AccountRevisionDate DATETIME2(7),
    @Key NVARCHAR(MAX),
    @PublicKey NVARCHAR(MAX),
    @SignedPublicKeyOwnershipClaim NVARCHAR(MAX),
    @PrivateKey NVARCHAR(MAX),
    @Premium BIT,
    @PremiumExpirationDate DATETIME2(7),
    @RenewalReminderDate DATETIME2(7),
    @Storage BIGINT,
    @MaxStorageGb SMALLINT,
    @Gateway TINYINT,
    @GatewayCustomerId VARCHAR(50),
    @GatewaySubscriptionId VARCHAR(50),
    @ReferenceData VARCHAR(MAX),
    @LicenseKey VARCHAR(100),
    @Kdf TINYINT,
    @KdfIterations INT,
    @KdfMemory INT = NULL,
    @KdfParallelism INT = NULL,
    @CreationDate DATETIME2(7),
    @RevisionDate DATETIME2(7),
    @ApiKey VARCHAR(30),
    @ForcePasswordReset BIT = 0,
    @UsesKeyConnector BIT = 0,
    @FailedLoginCount INT,
    @LastFailedLoginDate DATETIME2(7),
    @AvatarColor VARCHAR(7),
    @LastPasswordChangeDate DATETIME2(7) = NULL,
    @LastKdfChangeDate DATETIME2(7) = NULL,
    @LastKeyRotationDate DATETIME2(7) = NULL,
    @LastEmailChangeDate DATETIME2(7) = NULL,
    @VerifyDevices BIT = 1
AS
BEGIN
    SET NOCOUNT ON

    UPDATE
        [dbo].[User]
    SET
        [Name] = @Name,
        [Email] = @Email,
        [EmailVerified] = @EmailVerified,
        [MasterPassword] = @MasterPassword,
        [MasterPasswordHint] = @MasterPasswordHint,
        [Culture] = @Culture,
        [SecurityStamp] = @SecurityStamp,
        [TwoFactorProviders] = @TwoFactorProviders,
        [TwoFactorRecoveryCode] = @TwoFactorRecoveryCode,
        [EquivalentDomains] = @EquivalentDomains,
        [ExcludedGlobalEquivalentDomains] = @ExcludedGlobalEquivalentDomains,
        [AccountRevisionDate] = @AccountRevisionDate,
        [Key] = @Key,
        [PublicKey] = @PublicKey,
        [SignedPublicKeyOwnershipClaim] = @SignedPublicKeyOwnershipClaim,
        [PrivateKey] = @PrivateKey,
        [Premium] = @Premium,
        [PremiumExpirationDate] = @PremiumExpirationDate,
        [RenewalReminderDate] = @RenewalReminderDate,
        [Storage] = @Storage,
        [MaxStorageGb] = @MaxStorageGb,
        [Gateway] = @Gateway,
        [GatewayCustomerId] = @GatewayCustomerId,
        [GatewaySubscriptionId] = @GatewaySubscriptionId,
        [ReferenceData] = @ReferenceData,
        [LicenseKey] = @LicenseKey,
        [Kdf] = @Kdf,
        [KdfIterations] = @KdfIterations,
        [KdfMemory] = @KdfMemory,
        [KdfParallelism] = @KdfParallelism,
        [CreationDate] = @CreationDate,
        [RevisionDate] = @RevisionDate,
        [ApiKey] = @ApiKey,
        [ForcePasswordReset] = @ForcePasswordReset,
        [UsesKeyConnector] = @UsesKeyConnector,
        [FailedLoginCount] = @FailedLoginCount,
        [LastFailedLoginDate] = @LastFailedLoginDate,
        [AvatarColor] = @AvatarColor,
        [LastPasswordChangeDate] = @LastPasswordChangeDate,
        [LastKdfChangeDate] = @LastKdfChangeDate,
        [LastKeyRotationDate] = @LastKeyRotationDate,
        [LastEmailChangeDate] = @LastEmailChangeDate,
        [VerifyDevices] = @VerifyDevices
    WHERE
        [Id] = @Id
END
GO