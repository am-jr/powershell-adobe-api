Function New-AdobeUser {
    <#
        .SYNOPSIS
            This function creates an Adobe user account.
        .DESCRIPTION
            By default this function creates a federated account which uses email as the username, in the US, and does not update existing accounts. If test is $true the the response json will return a whatif value.
        .EXAMPLE
            New-AdobeUser -orgID '282B0A4C98C6@AdobeOrg' -apiKey '3dEh_RLribldQPNRm2yw' -accessToken $accessToken -FirstName 'John' -LastName 'Smith' -Email 'jsmith@example.com' -test $true
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
        [string]$first_name,
        [Parameter(Mandatory = $true)]
        [string]$last_name,
        [Parameter(Mandatory = $true)]
        [string]$Email,
        [Parameter(Mandatory = $true)]
        [string]$UserID,
        [ValidateSet('enterprise', 'federated', 'adobe')]
        $IDType = 'federated',
        $Domain,
        [string]$Country = 'US',
        $AdditionalActions = @(),
        [ValidateSet('ignoreIfAlreadyExists', 'updateIfAlreadyExists')]
        $OptionOnDuplicate = 'ignoreIfAlreadyExists'
    )


    $headers = @{
        'Accept'        = 'application/json'
        'Content-Type'  = 'application/json'
        'x-api-key'     = $([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)))
        'Authorization' = "Bearer $accessToken"
    }

    $body = @(
        [ordered]@{
            'user'      = $UserID
            'requestID' = "$(Get-Date -UFormat %s -Millisecond 0)"
            'do'        = @(
                @{
                    'createFederatedID' = @{
                        'email'     = $Email
                        'lastname'  = $Last_Name
                        'firstname' = $First_Name
                        'country'   = $Country
                        'option'    = $OptionOnDuplicate
                    }
                }
            )
        }
    )


    $restArgs = @{
        'Uri'     = "https://usermanagement.adobe.io/v2/usermanagement/action/$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($orgID)))"
        'Body'    = ConvertTo-Json -InputObject $body -Depth 10
        'Headers' = $headers
        'Method'  = 'POST'
    }

    Invoke-RestMethod @restArgs
}
