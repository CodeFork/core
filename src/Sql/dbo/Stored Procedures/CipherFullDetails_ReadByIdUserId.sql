﻿CREATE PROCEDURE [dbo].[CipherFullDetails_ReadByIdUserId]
    @Id UNIQUEIDENTIFIER,
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    SELECT TOP 1
        C.*,
        CASE 
            WHEN C.[OrganizationId] IS NULL THEN 1 
            ELSE [dbo].[UserCanEditCipher](@UserId, @Id)
        END [Edit]
    FROM
        [dbo].[CipherDetails](@UserId) C
    LEFT JOIN
        [dbo].[Organization] O ON C.[UserId] IS NULL AND O.[Id] = C.[OrganizationId]
    LEFT JOIN
        [dbo].[OrganizationUser] OU ON OU.[OrganizationId] = O.[Id] AND OU.[UserId] = @UserId
    LEFT JOIN
        [dbo].[CollectionCipher] CC ON C.[UserId] IS NULL AND OU.[AccessAll] = 0 AND CC.[CipherId] = C.[Id]
    LEFT JOIN
        [dbo].[CollectionUser] CU ON CU.[CollectionId] = CC.[CollectionId] AND CU.[OrganizationUserId] = OU.[Id]
    WHERE
        C.Id = @Id
        AND (
            C.[UserId] = @UserId
            OR (
                C.[UserId] IS NULL
                AND OU.[Status] = 2 -- 2 = Confirmed
                AND O.[Enabled] = 1
                AND (OU.[AccessAll] = 1 OR CU.[CollectionId] IS NOT NULL)
            )
        )
END