#requires -version 2.0
function Get-ReversedString {
  <#
    .EXAMPLE
        PS C:\>Get-ReversedString ".gnirts gnol yrev ,gnol ,gnol ,gnol a si sihT"
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [String]$InputString
  )
  
  [Array]::Reverse(($arr = $InputString -split ''))
  return (-join $arr)
}
