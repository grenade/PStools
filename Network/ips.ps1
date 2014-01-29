#requires -version 2.0
function Get-IPs([Switch]$External) {
  <#
    .EXAMPLE
        PS C:\>Get-IPs
    .EXAMPLE
        PS C:\>Get-IPs -e
    .NOTES
        Author: greg zakharov
  #>
  try {
    switch ($External) {
      $true {
        (New-Object Net.WebClient).DownloadString(
          'http://internet.yandex.ru'
        ) -match 'IPv\d\:\s(\d+\.){3}\d+' | Out-Null
        Write-Host $matches[0].Split(':')[1].Trim() -fo Magenta
      }
      default {
        Write-Host (ipconfig | ? {$_ -cmatch 'IP-'}).Split(':')[1].Trim() -fo Cyan
      }
    }
  }
  catch [Net.WebException] {
    Write-Host $_.Exception.Message -fo Red
  }
  catch [Management.Automation.RuntimeException] {
    Write-Host $_.Exception.Message -fo Red
  }
}
