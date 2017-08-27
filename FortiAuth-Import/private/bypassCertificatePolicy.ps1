function GetTrustAllCertsPolicy ()
{
    # Trust all certs as we don't use an internal CA
    add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

    return $(New-Object TrustAllCertsPolicy)
}

function SetCertificatePolicy ($Func)
{
    [System.Net.ServicePointManager]::CertificatePolicy = $Func
}

function GetCertificatePolicy ()
{
    return [System.Net.ServicePointManager]::CertificatePolicy
}