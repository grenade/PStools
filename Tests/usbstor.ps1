#requires -version 2.0
function Get-CurrentUSBDevice {
  $dgvGrid.Columns.Clear()
  
  $dt = New-Object Data.DataTable
  $dr = $dt.NewRow()
  
  (gp $hash[$tsCombo.SelectedItem]).PSBase.Properties | % {
    if ($_.TypeNameOfValue -ne 'System.String[]') {
      $dc = New-Object Data.DataColumn
      $dc.ColumnName = $_.Name
      $dt.Columns.Add($dc)
      
      $dr.Item($_.Name) = $_.Value
    }
  } #foreach
  $dt.Rows.Add($dr)
  $dgvGrid.DataSource = $dt
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $tsStrip = New-Object Windows.Forms.ToolStrip
  $tsLabel = New-Object Windows.Forms.ToolStripLabel
  $tsCombo = New-Object Windows.Forms.ToolStripComboBox
  $dgvGrid = New-Object Windows.Forms.DataGridView
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripLabel
  #
  #common
  #
  $tsStrip.Items.AddRange(@($tsLabel, $tsCombo))
  $tsLabel.Text = "Registry Path:"
  #
  #tsCombo
  #
  gp HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\* | % {$hash = @{}}{
    $itm = $_.PSPath -split '\\';$itm = $itm[($itm.Count - 2)..($itm.Count - 1)] -join '\'
    [void]$tsCombo.Items.Add($itm)
    $hash[$itm] = $_.PSPath
  }
  $tsCombo.SelectedIndex = 0
  $tsCombo.Size = New-Object Drawing.Size(480, 23)
  $tsCombo.Add_SelectedIndexChanged({Get-CurrentUSBDevice})
  #
  #dgvGrid
  #
  $dgvGrid.AutoSizeColumnsMode = [Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCells
  $dgvGrid.Dock = [Windows.Forms.DockStyle]::Fill
  $dgvGrid.SelectionMode = [Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
  #
  #sbStrip
  #
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbStrip.SizingGrip = $false
  #
  #sbLabel
  #
  $sbLabel.ForeColor = [Drawing.Color]::DarkGreen
  $sbLabel.Text = "Author: greg zakharov"
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(570, 132)
  $frmMain.Controls.AddRange(@($dgvGrid, $sbStrip, $tsStrip))
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedSingle
  $frmMain.Icon = $ico
  #$frmMain.MaximizeBox = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "USB Devices"
  $frmMain.Add_Load({Get-CurrentUSBDevice})
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
