function New-AdobeJWT {
    <#
        .SYNOPSIS
            A function that returns a JWT using a certificate provided by Adobe.
        .DESCRIPTION
            This function will accept an Adobe Developer certificate and password, along with developer identifying information and return a valid JWT. The default expiration time is exactly 24 hours from the run date.
        .EXAMPLE
            New-AdobeJWT -apiKey '3dEh_RLribldQPNRm2yw' -orgId '0A4C98C6@AdobeOrg' -technicalAccountId 'BF00A495F91@techacct.adobe.com'
        .LINK
            https://adobe-apiplatform.github.io/umapi-documentation/en/
    #>

    [CmdletBinding()]
    param (
        [parameter(mandatory = $true)]
        [securestring]$apiKey,
        [parameter(mandatory = $true)]
        [securestring]$orgId,
        [parameter(mandatory = $true)]
        [securestring]$technicalAccountId,
        [parameter(mandatory = $true)]
        [System.IO.FileInfo]$Certificate,
        [SecureString]$Password
    )

    <#
    For the correct format use the following command in openssl while providing the private.key and certificate from Adobe:
        openssl pkcs12 -export -aes256 -CSP "Microsoft Enhanced RSA and AES Cryptographic Provider" -inkey private.key -in certificate_pub.crt -out AdobeCertPS.pfx
    #>
    $Cert = [Security.Cryptography.X509Certificates.X509Certificate2]::new($Certificate, $password)


    $expirationTime = (Get-Date) + (New-TimeSpan -Days 1)
    $unixExpiration = [int][double]::parse((Get-Date "$expirationTime" -UFormat %s -Millisecond 0))

    $Header = @{
        'alg' = 'RS256'
    } | ConvertTo-Json

    $payloadJSON = [ordered]@{
        'exp'                                           = $unixExpiration
        'iss'                                           = "$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($orgID)))"
        'sub'                                           = "$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($technicalAccountId)))"
        'https://ims-na1.adobelogin.com/s/ent_user_sdk' = $true
        'aud'                                           = "https://ims-na1.adobelogin.com/c/$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)))"
    } | ConvertTo-Json

    $encodedHeader = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Header)) -replace '\+', '-' -replace '/', '_' -replace '='
    $encodedPayload = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($PayloadJson)) -replace '\+', '-' -replace '/', '_' -replace '='

    $jwt = $encodedHeader + '.' + $encodedPayload

    $toSign = [System.Text.Encoding]::UTF8.GetBytes($jwt)

    $rsa = $Cert.PrivateKey
    $sig = [Convert]::ToBase64String($rsa.SignData($toSign, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1)) -replace '\+', '-' -replace '/', '_' -replace '='

    $jwt = $jwt + '.' + $sig
    return $jwt
}