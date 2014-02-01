#requires -version 2.0
function Set-RadialPoint([Int32]$radius, [Int32]$seconds) {
  $center = New-Object Drawing.Point(($this.ClientRectangle.Width / 2), ($this.ClientRectangle.Height / 2))
  [Double]$angle =- (($seconds - 15) % 60) * [Math]::PI / 30
  $ret = New-Object Drawing.Point(($center.X + [Int32]($radius * [Math]::Cos($angle))),
                   ($center.Y - [Int32]($radius * [Math]::Sin($angle))))
  return $ret
}

function frmMain_Show {
  <#
    .NOTES
        Author: greg zakharov
  #>
  Add-Type -AssemblyName System.Windows.Forms
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $tmrTick = New-Object Windows.Forms.Timer
  #
  #tmrTick
  #
  $tmrTick.Enabled = $true
  $tmrTick.Interval = 1000
  $tmrTick.Add_Tick({$frmMain.Invalidate()})
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(150, 150)
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedSingle
  $frmMain.Icon = $ico
  $frmMain.MaximizeBox = $frmMain.MinimizeBox = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "PS Clock"
  $frmMain.Add_FormClosing({$tmrTick.Enabled = $false})
  $frmMain.Add_Paint({
    $now = [DateTime]::Now
    $gfx = $this.CreateGraphics()
    $cnt = New-Object Drawing.Point(($this.ClientRectangle.Width / 2), ($this.ClientRectangle.Height / 2))
    $rad = [Math]::Min($this.ClientRectangle.Width, $this.ClientRectangle.Height) / 2
    #background
    $lgb = New-Object Drawing.Drawing2D.LinearGradientBrush($this.ClientRectangle, [Drawing.Color]::Linen,
            [Drawing.Color]::DarkGreen, [Drawing.Drawing2D.LinearGradientMode]::BackwardDiagonal)
    $gfx.FillEllipse($lgb, $cnt.X - $rad, $cnt.Y - $rad, $rad * 2, $rad * 2)
    #points
    for ($min = 0; $min -lt 60; $min++) {
      [Drawing.Point]$pnt = Set-RadialPoint ($rad - 10) $min
      $sb = New-Object Drawing.SolidBrush([Drawing.Color]::Black)
      
      if (($min % 5) -eq 0) {
        $gfx.FillRectangle($sb, $pnt.X - 3, $pnt.Y - 3, 6, 6)
      }
      else {
        $gfx.FillRectangle($sb, $pnt.X - 1, $pnt.Y - 1, 2, 2)
      }
    } #for
    #pointers
    $hp = New-Object Drawing.Pen([Drawing.Color]::Black, 8)
    $mp = New-Object Drawing.Pen([Drawing.Color]::Black, 6)
    $sp = New-Object Drawing.Pen([Drawing.Color]::Red, 1)
    #tune and draw
    $hp, $mp | % {
      $_.StartCap = [Drawing.Drawing2D.LineCap]::Round
      $_.EndCap = [Drawing.Drawing2D.LineCap]::Round
    }
    $sp.CustomEndCap = New-Object Drawing.Drawing2D.AdjustableArrowCap(2, 3, $true)
    $pin = New-Object Drawing.SolidBrush([Drawing.Color]::Red)
    $gfx.DrawLine($hp, (Set-RadialPoint 15 (30 + $now.Hour * 5 + $now.Minute / 12)),
        (Set-RadialPoint ([Int32]($rad * 0.55)) ($now.Hour * 5 + $now.Minute / 12)))
    $gfx.DrawLine($mp, (Set-RadialPoint 15 (30 + $now.Minute)),
                                (Set-RadialPoint ([Int32]($rad * 0.8)) $now.Minute))
    $gfx.DrawLine($sp, (Set-RadialPoint 20 ($now.Second + 30)), (Set-RadialPoint ($rad - 2) $now.Second))
    $gfx.FillEllipse($pin, $cnt.X - 5, $cnt.Y - 5, 10, 10)
  })
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
