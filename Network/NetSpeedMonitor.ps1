#requires -version 2.0
function Set-Opacity([Object]$obj) {
  $ops.Checked = $false
  $frmMain.Opacity = [Single]('.' + ($obj.Text)[0])
  $obj.Checked = $true
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  $fnt = New-Object Drawing.Font("Tahoma", 10, [Drawing.FontStyle]::Bold)
  $scr = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
  
  $ins = (New-Object Diagnostics.PerformanceCounterCategory("Network Interface")).GetInstanceNames()
  
  $frmMain = New-Object Windows.Forms.Form
  $lvCards = New-Object Windows.Forms.ListView
  $lblLbl1 = New-Object Windows.Forms.Label
  $lblLbl2 = New-Object Windows.Forms.Label
  $lblLbl3 = New-Object Windows.Forms.Label
  $mnuIcon = New-Object Windows.Forms.ContextMenuStrip
  $mnuCard = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOpac = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOp50 = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOp60 = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOp70 = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOp80 = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOp90 = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNull = New-Object Windows.Forms.ToolStripSeparator
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $niPopup = New-Object Windows.Forms.NotifyIcon
  $tmrTick = New-Object Windows.Forms.Timer
  #
  #common
  #
  $lblLbl2, $lblLbl3 | % {
    $_.Font = $fnt
    $_.Size = New-Object Drawing.Size(170, 19)
  }
  $mnuIcon.Items.AddRange(@($mnuCard, $mnuOpac, $mnuNull, $mnuExit))
  #
  #lvCards
  #
  $lvCards.Dock = [Windows.Forms.DockStyle]::Fill
  $lvCards.FullRowSelect = $true
  $ins | % {[void]$lvCards.Items.Add($_)}
  $lvCards.MultiSelect = $false
  $lvCards.Sorting = [Windows.Forms.SortOrder]::Ascending
  $lvCards.TileSize = New-Object Drawing.Size(190, 17)
  $lvCards.View = [Windows.Forms.View]::Tile
  $lvCards.Add_Click({
    for ($i = 0; $i -lt $lvCards.Items.Count; $i++) {
      if ($lvCards.Items[$i].Selected) {
        $card = $lvCards.Items[$i].Text
      }
    }
    $rec = New-Object Diagnostics.PerformanceCounter("Network Interface", "Bytes Received/Sec", $card)
    $sen = New-Object Diagnostics.PerformanceCounter("Network Interface", "Bytes Sent/Sec", $card)

    $lblLbl1.Text = $(if ($card.Length -gt 25) {-join ($card[0..25] + "...")} else {$card})
    $lvCards.Visible = $false
    $tmrTick.Start()
  })
  #
  #lblLbl1
  #
  $lblLbl1.BackColor = [Drawing.Color]::FromArgb(113, 12, 230)
  $lblLbl1.BorderStyle = [Windows.Forms.BorderStyle]::Fixed3D
  $lblLbl1.Dock = [Windows.Forms.DockStyle]::Top
  $lblLbl1.ForeColor = [Drawing.Color]::White
  $lblLbl1.Height = 17
  $lblLbl1.Text = "Choose Adapter"
  #
  #lblLbl2
  #
  $lblLbl2.ForeColor = [Drawing.Color]::Blue
  $lblLbl2.Location = New-Object Drawing.Point(7, 17)
  $lblLbl2.Text = "Received: 0,00 Kb/s"
  #
  #lblLbl3
  #
  $lblLbl3.ForeColor = [Drawing.Color]::Crimson
  $lblLbl3.Location = New-Object Drawing.Point(7, 35)
  $lblLbl3.Text = "Sent: 0,00 Kb/s"
  #
  #mnuCard
  #
  $mnuCard.Text = "&Choose Adapter"
  $mnuCard.Add_Click({
    $tmrTick.Stop()
    $lblLbl1.Text = "Choose Adapter"
    $lvCards.Visible = $true
  })
  #
  #mnuOpac
  #
  $mnuOpac.DropDownItems.AddRange(@($mnuOp50, $mnuOp60, $mnuOp70, $mnuOp80, $mnuOp90))
  $mnuOpac.Text = "&Opacity"
  #
  #mnuOp50
  #
  $mnuOp50.Text = "50%"
  $mnuOp50.Add_Click({Set-Opacity $mnuOp50;$ops = $mnuOp50})
  #
  #mnuOp60
  #
  $mnuOp60.Text = "60%"
  $mnuOp60.Add_Click({Set-Opacity $mnuOp60;$ops = $mnuOp60})
  #
  #mnuOp70
  #
  $ops = $mnuOp70
  $mnuOp70.Checked = $true
  $mnuOp70.Text = "70%"
  $mnuOp70.Add_Click({Set-Opacity $mnuOp70;$ops = $mnuOp70})
  #
  #mnuOp80
  #
  $mnuOp80.Text = "80%"
  $mnuOp80.Add_Click({Set-Opacity $mnuOp80;$ops = $mnuOp80})
  #
  #mnuOp90
  #
  $mnuOp90.Text = "90%"
  $mnuOp90.Add_Click({Set-Opacity $mnuOp90;$ops = $mnuOp90})
  #
  #mnuExit
  #
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({
    $tmrTick.Enabled = $false
    $niPopup.Visible = $false
    $frmMain.Close()
  })
  #
  #niPopup
  #
  $niPopup.ContextMenuStrip = $mnuIcon
  $niPopup.Icon = $ico
  $niPopup.Text = "NetSpeed Monitor"
  $niPopup.Visible = $true
  #
  #tmrTick
  #
  $tmrTick.Enabled = $true
  $tmrTick.Interval = 1000
  $tmrTick.Stop()
  $tmrTick.Add_Tick({
    try {
      $lblLbl2.Text = ('Received: {0:f2} Kb/s' -f ([Math]::Floor($rec.NextValue()) / 1024))
      $lblLbl3.Text = ('Sent: {0:f2} Kb/s' -f ([Math]::Floor($sen.NextValue()) / 1024))
    }
    catch {}
  })
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(200, 57)
  $frmMain.Controls.AddRange(@($lvCards, $lblLbl1, $lblLbl2, $lblLbl3))
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::None
  $frmMain.Icon = $ico
  $frmMain.Location = New-Object Drawing.Point(($scr.Width - 205), ($scr.Height - 62))
  $frmMain.Opacity = .7
  $frmMain.ShowInTaskbar = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::Manual
  $frmMain.Text = "NetSpeed Monitor"
  $frmMain.TopMost = $true
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
