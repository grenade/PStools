#requires -version 2.0
set PSScriptRoot -val $(Split-Path $MyInvocation.MyCommand.Path) -opt Constant
set ExplorerPath -val $((gcm -c Application | ? {$_.Name -eq 'explorer.exe'}).Definition) -opt Constant

if ([PSObject].Assembly.GetType(
  'Microsoft.PowerShell.NativeCultureResolver'
).GetMethod(
  'IsVistaAndLater', [Reflection.BindingFlags]40
).Invoke($null, @())) {
  $key = 'Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache'
}
else {
  $key = 'Software\Microsoft\Windows\ShellNoRoam\MUICache' #WinXP
}

function Watch-Items {
  $sbLabel.Text = $lvItems.Items.Count.ToString() + ' item(s)'
}

function Invoke-Scan {
  $lvItems.Items.Clear()
  $mnuKill.Enabled = $true
  
  $rk = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($key)
  $rk.GetValueNames() | % {
    if ($rk.GetValueKind($_).ToString() -ne 'Binary') {
      if ($mnuHide.Checked) {
        if (!$_.StartsWith('@')) {
          $itm = $lvItems.Items.Add($_)
          $itm.SubItems.Add($rk.GetValue($_).ToString())
        }
      }
      else {
        if ($_.StartsWith('@')) {
          $i = -join $_[1..($_.LastIndexOf(',') - 1)]
          
          if ([RegEx]::Match($i, '%systemroot%',
            [Text.RegularExpressions.RegexOptions]::IgnoreCase).Success) {
            $i = $i -replace '%systemroot%', $env:systemroot
          }
          elseif ($i -match 'explorer.exe') {
            $i = $ExplorerPath
          }
        }
        else {$i = $_}
        
        $itm = $lvItems.Items.Add($i)
        $itm.SubItems.Add($rk.GetValue($_).ToString())
      }
    }
  }
  $rk.Close()
  
  $lvItems.AutoResizeColumns([Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuFile = New-Object Windows.Forms.ToolStripMenuItem
  $mnuScan = New-Object Windows.Forms.ToolStripMenuItem
  $mnuKill = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSave = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNull = New-Object Windows.Forms.ToolStripSeparator
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuView = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHide = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSBar = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripMenuItem
  $lvItems = New-Object Windows.Forms.ListView
  $chPaths = New-Object Windows.Forms.ColumnHeader
  $chNames = New-Object Windows.Forms.ColumnHeader
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common
  #
  $mnuMain.Items.AddRange(@($mnuFile, $mnuView, $mnuHelp))
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbLabel.AutoSize = $true
  #
  #mnuFile
  #
  $mnuFile.DropDownItems.AddRange(@($mnuScan, $mnuKill, $mnuSave, $mnuNull, $mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuScan
  #
  $mnuScan.ShortcutKeys = [Windows.Forms.Keys]::F5
  $mnuScan.Text = "S&can"
  $mnuScan.Add_Click({
    Invoke-Scan
    Watch-Items
  })
  #
  #mnuKill
  #
  $mnuKill.ShortcutKeys = [Windows.Forms.Keys]::Delete
  $mnuKill.Text = "&Delete Item"
  $mnuKill.Add_Click({
    $rk = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($key, $true)
    
    for($i = 0; $i -lt $lvItems.Items.Count; $i++) {
      if ($lvItems.Items[$i].Selected) {
        $rk.DeleteValue($lvItems.Items[$i].Text, $false)
        $lvItems.Items[$i].Remove()
        $i--
      }
    }
    
    Watch-Items
    $rk.Close()
  })
  #
  #mnuSave
  #
  $mnuSave.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::S
  $mnuSave.Text = "&Save Snapshot"
  $mnuSave.Add_Click({
    if ($lvItems.Items.Count -ne 0) {
      if (Test-Path ($log = Join-Path $PSScriptRoot 'MUICacheView.csv')) {
        Remove-Item $log -Force
      }
      
      $sw = New-Object IO.StreamWriter($log, [Text.Encoding]::Default)
      $sw.WriteLine("Path, Name")
      $lvItems.Items | % {
        $sw.WriteLine(($_.Text + ', ' + $_.SubItems[1].Text))
      }
      $sw.Flush()
      $sw.Close()
    }
  })
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::X
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuView
  #
  $mnuView.DropDownItems.AddRange(@($mnuHide, $mnuSBar))
  $mnuView.Text = "&View"
  #
  #mnuHide
  #
  $mnuHide.Checked = $true
  $mnuHide.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::H
  $mnuHide.Text = "&Hide System Entries"
  $mnuHide.Add_Click({
    $toggle =! $mnuHide.Checked
    $mnuHide.Checked = $toggle
    
    Invoke-Scan
    Watch-Items
  })
  #
  #mnuSBar
  #
  $mnuSBar.Checked = $true
  $mnuSBar.Text = "&Status Bar"
  $mnuSbar.Add_Click({
    $toggle =! $mnuSBar.Checked
    $mnuSBar.Checked = $toggle
    $sbStrip.Visible = $toggle
  })
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #lvItems
  #
  $lvItems.AllowColumnReorder = $true
  $lvItems.Columns.AddRange(@($chPaths, $chNames))
  $lvItems.Dock = [Windows.Forms.DockStyle]::Fill
  $lvItems.FullRowSelect = $true
  $lvItems.MultiSelect = $false
  $lvItems.ShowItemToolTips = $true
  $lvItems.Sorting = [Windows.Forms.SortOrder]::Ascending
  $lvItems.View = [Windows.Forms.View]::Details
  #
  #chPaths
  #
  $chPaths.Text = "Application Path"
  $chPaths.Width = 275
  #
  #chNames
  #
  $chNames.Text = "Application Name"
  $chNames.Width = 330
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(573, 217)
  $frmMain.Controls.AddRange(@($lvItems, $sbStrip, $mnuMain))
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "MUICacheView"
  $frmMain.Add_Load({
    $mnuKill.Enabled = $false
    Watch-Items
  })
  
  [void]$frmMain.ShowDialog()
}

function frmInfo_Show {
  $frmInfo = New-Object Windows.Forms.Form
  $pbImage = New-Object Windows.Forms.PictureBox
  $lblName = New-Object Windows.Forms.Label
  $lblCopy = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button
  #
  #pbImage
  #
  $pbImage.Image = $ico.ToBitmap()
  $pbImage.Location = New-Object Drawing.Point(16, 16)
  $pbImage.Size = New-Object Drawing.Size(32, 32)
  $pbImage.SizeMode = [Windows.Forms.PictureBoxSizeMode]::StretchImage
  #
  #lblName
  #
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "MUICacheView v3.01"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "Copyright (C) 2011-2014 greg zakharov"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 67)
  $btnExit.Text = "OK"
  #
  #frmInfo
  #
  $frmInfo.AcceptButton = $btnExit
  $frmInfo.CancelButton = $btnExit
  $frmInfo.ClientSize = New-Object Drawing.Size(350, 110)
  $frmInfo.ControlBox = $false
  $frmInfo.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmInfo.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedSingle
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = [Windows.Forms.FormStartPosition]::CenterParent
  $frmInfo.Text = "About..."

  [void]$frmInfo.ShowDialog()
}

frmMain_Show
