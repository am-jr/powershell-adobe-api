Function Get-AdobeAccessToken {
    <#
        .SYNOPSIS
            This function uses the JWT, apikey, and client secret in order to obtain an Access Token.
        .DESCRIPTION
            This function requires a valid JWT, an API key, and a client secret.
        .EXAMPLE
            Get-AdobeAccessToken -apiKey '3dEh_RLribldQPNRm2yw' -jwt $jwt -clientSecret 'QPNRm2ywRLribldQ'
        .LINK
            https://adobe-apiplatform.github.io/umapi-documentation/en/
    #>

    [CmdletBinding()]
    param(
        [parameter(mandatory = $true)]
        [string]$jwt,
        [parameter(mandatory = $true)]
        [securestring]$apiKey,
        [parameter(mandatory = $true)]
        [securestring]$clientSecret
    )

    $headers = @{
        'Cache-Control' = 'no-cache'
        'Content-Type'  = 'application/x-www-form-urlencoded'
    }

    $body = "client_id=$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)))&client_secret=$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)))&jwt_token=$JWT"

    $adobeParams = @{
        'URI'     = 'https://ims-na1.adobelogin.com/ims/exchange/jwt'
        'Headers' = $headers
        'Body'    = $body
        'Method'  = 'POST'
    }

    $response = Invoke-RestMethod @adobeParams
    return $response.access_token
}