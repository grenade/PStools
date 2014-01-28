#requires -version 2.0
Set-Alias which Get-CommandPath

function Get-CommandPath {
  <#
    .EXAMPLE
        PS C:\>which shell32.dll
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [Alias('n')]
    [String]$CommandName,
    
    [Parameter(Position=1)]
    [Alias('t')]
    [PSObject]$CommandType = 'Application'
  )
  
  Write-Host (gcm -c $CommandType | ? {$_.Name -eq $CommandName}).Definition`n -fo Yellow
}
