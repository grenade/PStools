#requires -version 2.0
Set-Alias pipelist Get-PipeList

function Get-PipeList {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  [IO.Directory]::GetFiles('\\.\\pipe\') | % {
    Write-Host $(-join $_[($_.LastIndexOf('\') + 1)..$_.Length]) -fo Cyan
  }
}
