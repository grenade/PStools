#requires -version 2.0
function Read-JSON {
  <#
    .EXAMPLE
        PS C:\>Read-JSON data.json
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    Add-Type -AssemblyName System.Web.Extensions
    $jss = New-Object Web.Script.Serialization.JavaScriptSerializer
  }
  process {
    try {
      $jss.DeserializeObject((cat (cvpa $FileName)))
    }
    catch [Management.Automation.MethodInvocationException] {
      Write-Host Invalid JSON primitive. -fo Red
    }
  }
  end {}
}
