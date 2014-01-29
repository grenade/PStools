#requires -version 2.0
function Get-ProtectionInfo([String]$Computer = '.', [Switch]$Toggle) {
  <#
    .EXAMPLE
        PS C:\>Get-ProtectionInfo
    .EXAMPLE
        PS C:\>Get-ProtectionInfo -t
    .NOTES
        Author: greg zakharov
  #>
  switch ($Toggle) {
    $true   {$sig = 'FirewallProduct'}
    default {$sig = 'AntiVirusProduct'}
  }
  
  try {
    (New-Object Management.ManagementClass(
      [Management.ManagementPath]('\\' + $Computer + '\root\SecurityCenter:' + $sig)
    )).PSBase.GetInstances() | select displayName, companyName, versionNumber | fl
  }
  catch [Management.Automation.MethodInvocationException] {
    Write-Host Access denied. -fo Red
  }
}
