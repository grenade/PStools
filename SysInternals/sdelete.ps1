#requires -version 2.0
Set-Alias sdelete Remove-FileAbnormally

function Remove-FileAbnormally {
  <#
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(DefaultParameterSetName="FileName", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Parameter(Position=1)]
    [ValidateRange(1, 3)]
    [Int32]$Passes = 1
  )
  
  begin {
    $FileName = cvpa $FileName
    
    $buf = New-Object "Byte[]" 512
    $rng = New-Object Security.Cryptography.RNGCryptoServiceProvider
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, 'Delete abnormally')) {
      if ([Security.Principal.WindowsIdentity]::GetCurrent().Name -ne
                 ([IO.FileInfo]$FileName).GetAccessControl().Owner) {
        Write-Host File is out of current context. -fo Red
        break
      }
  
      [IO.File]::SetAttributes($FileName, [IO.FileAttributes]::Normal)
      $sectors = [Math]::Ceiling((([IO.FileInfo]$FileName).Length / 512))
      
      try {
        $fs = New-Object IO.FileStream($FileName, [IO.FileMode]::Open, [IO.FileAccess]::Write)
        for ($i = 0; $i -lt $Passes; $i++) {
          for ($j = 0; $j -lt $sectors; $j++) {
            $rng.GetBytes($buf)
            $fs.Write($buf, 0, $buf.Length)
          }
        }
      }
      finally {
        if ($fs -ne $null) {$fs.Close()}
        
        $stamp = New-Object DateTime($([Int32](date -u %Y) + 23), 1, 1, 0, 0, 0)
      
        try {
          [IO.File]::SetCreationTime($FileName, $stamp)
          [IO.File]::SetLastWriteTime($FileName, $stamp)
          [IO.File]::SetLastAccessTime($FileName, $stamp)
      
          [IO.File]::Delete($FileName)
        }
        catch {
          Write-Host $_.Exception.Message -fo Red
        }
      }
    }
  }
  end {}
}
