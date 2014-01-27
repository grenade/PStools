#requires -version 2.0
Set-Alias procdump Get-ProcessDump

function Get-ProcessDump {
  <#
    .EXAMPLE
        PS C:\>ps notepad | procdump
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(DefaultParameterSetName="Processes", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Diagnostics.Process[]]$Processes,
    
    [Parameter(Position=1)]
    [ValidateScript({Test-Path $_})]
    [Alias("pn")]
    [String]$PathName = $pwd.Path,
    
    [Parameter(Position=2)]
    [Alias("dt")]
    [UInt32]$DumpType = 0x2
  )
  
  begin {
    $wer = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting')
    $mdt = $wer.GetNestedType('MiniDumpType', 'NonPublic')
    $dbg = $wer.GetNestedType('NativeMethods', 'NonPublic').GetMethod(
      'MiniDumpWriteDump', [Reflection.BindingFlags]40
    )
  }
  process {
    $Processes | % {
      if ($PSCmdlet.ShouldProcess($('{0} PID:{1}' -f $_.Name, $_.Id), 'Create mini dump')) {
        if (([Enum]::GetNames($mdt)) -notcontains ($DumpType -as $mdt)) {
          Write-Host ("Unsupported mini dump type. The next types are available:`n" + (
            [Enum]::GetNames($mdt) | % {"{0, 39} = 0x{1:x}`n" -f $_, $mdt::$_.value__}
          )) -fo Red
          break
        }
        
        $dmp = Join-Path $PathName "$($_.Name)_$($_.Id)_$(date -u %d%m%Y_%H%M%S).dmp"
        
        try {
          $fs = New-Object IO.FileStream($dmp, [IO.FileMode]::Create)
          [void]$dbg.Invoke($null, @($_.Handle, $_.Id, $fs.SafeFileHandle, $DumpType,
                                     [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero))
        }
        finally {
          if ($fs -ne $null) {$fs.Close()}
        }
      }
    }
  }
  end {}
}
