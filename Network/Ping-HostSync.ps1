#requires -version 2.0
function Ping-HostSync {
  <#
     .EXAMPLE
         PS C:\>Ping-HostSync ya.ru
     .EXAMPLE
         PS C:\>Ping-HostSync "213.180.193.3" -t 120
     .NOTES
         Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [String]$Server,
    
    [Parameter(Position=1)]
    [ValidateRange(100, 10000)]
    [Int32]$Timeout = 1500
  )
  
  begin {
    $png = New-Object Net.NetworkInformation.Ping
    $opt = New-Object Net.NetworkInformation.PingOptions
    $opt.DontFragment = $true
    
    $raw = $host.UI.RawUI
    $old = $raw.WindowPosition
    $con = $raw.WindowSize
    
    function strip([Int32]$x, [Int32]$y, [Int32]$z, [ConsoleColor]$bc) {
      $pos = $old;$pos.X += $x;$pos.Y += $y
      $row = $raw.NewBufferCellArray(@(' ' * $z), $bc, $bc)
      $raw.SetBufferContents($pos, $row)
    }
  }
  process {
    try {
      $got = 0;$bad = 0
      for ($i = 0; $i -lt $con.Width; $i++) {
        $res = $png.Send(
          $Server, $Timeout, ([Text.Encoding]::ASCII.GetBytes((' ' * 32))), $opt
        )
        if ($res.Status -eq 'Success') {$col = 'Green';$got++} else {$col = 'Red';$bad++}
        strip 0 0 ($i + 1) $col
      }
    }
    catch [Management.Automation.MethodInvocationException] {
      $exp = ($_.Exception.Message.Split(':')[1] -replace '\"', '').Trim();$exp
    }
  }
  end {
    if ($exp -eq $null) {
      Write-Host ('Succesed: {0} ' -f $got) -fo Green -no
      Write-Host ('Failed: {0}' -f $bad) -fo Red
      'Press any key to continue...'
      [void]$host.UI.RawUI.ReadKey("NoEcho, IncludekeyDown")
      Clear-Host
    }
  }
}
