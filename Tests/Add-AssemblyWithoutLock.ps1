#requires -version 2.0
function Add-AssemblyWithoutLock {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$Assembly
  )
  
  if (Test-Path $Assembly) {
    [void][Reflection.Assembly]::Load([IO.File]::ReadAllBytes((cvpa $Assembly)))
  }
  else {Write-Warning "Assembly $($Assembly) does not exist."}
}
