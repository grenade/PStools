#requires -version 2.0
function Set-RandomFile {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Position=0)]
    [ValidateScript({Test-Path $_})]
    [String]$Path = $pwd.Path,
    
    [Parameter(Position=1)]
    [ValidateRange(0, 31)]
    [Int32]$NameLength = 7
  )
  
  begin {
    $ext = cmd /c assoc | % {if ($_ -match '=\w+' -and $_ -notmatch '.\d+=') {$_.Split('=')[0]}}
    $itm = -join ([GUID]::NewGuid().Guid -replace '-', '')[0..$NameLength]
  }
  process {
    $rnd = Get-Random -max ($ext.Length - 1)
    [void](ni -p $Path -n $($itm + $ext[$rnd]) -t File -fo)
  }
  end {}
}
