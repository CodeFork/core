﻿CREATE PROCEDURE [dbo].[CipherDetails_ReadByUserId]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        C.*
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
        C.[UserId] = @UserId
        OR (
            C.[UserId] IS NULL
            AND OU.[Status] = 2 -- 2 = Confirmed
            AND O.[Enabled] = 1
            AND (OU.[AccessAll] = 1 OR CU.[CollectionId] IS NOT NULL)
        )
END