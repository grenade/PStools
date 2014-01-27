#requires -version 2.0
Set-Alias strings Get-Strings

function Get-Strings {
  <#
    .EXAMPLE
        PS C:\>strings app.exe -b 100 -o 25
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(DefaultParameterSetName="FileName", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Alias("b")]
    [UInt32]$BytesToProcess = 0,
    
    [Alias("o")]
    [UInt32]$BytesOffset = 0,
    
    [Alias("n")]
    [UInt32]$StringLength = 3,
    
    [Alias("u")]
    [Switch]$Unicode
  )
  
  begin {
    $FileName = cvpa $FileName
    
    switch ($Unicode) {
      $true   {$enc = [Text.Encoding]::Unicode}
      default {$enc = [Text.Encoding]::UTF7}
    }
    
    function get([Byte[]]$Bytes) {
      ([RegEx]"[\x20-\x7E]{$StringLength,}").Matches(
        $enc.GetString($Bytes)
      ) | % {$_.Value}
    }
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, 'Looking for strings')) {
      try {
        $fs = New-Object IO.FileStream($FileName, [IO.FileMode]::Open, [IO.FileAccess]::Read)
        
        if ($BytesOffset -ne 0) {[void]$fs.Seek($BytesOffset, [IO.SeekOrigin]::Begin)}
        if ($BytesToProcess -ne 0) {
          $buf = New-Object "Byte[]" ($fs.Length - ($fs.Length - $BytesToProcess))
          [void]$fs.Read($buf, 0, $buf.Length)
          get $buf
        }
        else {
          $buf = New-Object "Byte[]" $fs.Length
          while ($fs.Read($buf, 0, $fs.Length) -gt 0) {get $buf}
        }
      }
      finally {
        if ($fs -ne $null) {$fs.Close()}
      }
    }
  }
  end {''}
}
