Function Add-AdobeGroupMember {

    <#
        .SYNOPSIS
            This function adds a user to an existing group in Adobe.
        .DESCRIPTION
            This function requires an already existing group, and an already existing user.
        .EXAMPLE
            Add-AdobeGroupMember -apiKey '3dEh_RLribldQPNRm2yw'  -orgID '282B0A4C98C6@AdobeOrg' -apiKey '3dEh_RLribldQPNRm2yw' -accessToken $accessToken -UserGroup 'Staff' -UserID 'jsmith@example.com'
        .LINK
            https://adobe-apiplatform.github.io/umapi-documentation/en/
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [securestring]$orgID,
        [Parameter(Mandatory = $true)]
        [securestring]$apiKey,
        [Parameter(Mandatory = $true)]
        [string]$accessToken,
        [Parameter(Mandatory = $true)]
        [string]$UserGroup,
        [Parameter(Mandatory = $true)]
        [string]$UserID
    )


    $headers = @{
        'Accept'        = 'application/json'
        'Content-Type'  = 'application/json'
        'x-api-key'     = $([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)))
        'Authorization' = "Bearer $accessToken"
    }

    $body = @(
        @{
            'user'      = $UserID
            'requestID' = "$(Get-Date -UFormat %s -Millisecond 0)"
            'do'        = @(
                @{
                    'add' = @{
                        'group' = @(
                            $UserGroup
                        )
                    }
                }
            )
        }
    )

    $restARgs = @{
        'Uri'     = "https://usermanagement.adobe.io/v2/usermanagement/action/$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($orgID)))"
        'Body'    = ConvertTo-Json -InputObject $body -Depth 10
        'Headers' = $headers
        'Method'  = 'POST'
    }

    Invoke-RestMethod @restArgs
}
