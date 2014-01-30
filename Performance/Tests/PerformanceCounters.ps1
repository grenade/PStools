#requires -version 2.0
function Get-ImageFromString([String]$str) {
  [Drawing.Image]::FromStream(
    (New-Object IO.MemoryStream(($$ = [Convert]::FromBase64String($str)), 0, $$.Length))
  )
}

function frmMain_Show([String]$Computer = '.') {
  <#
    .NOTES
        Author: greg zakharov
  #>
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $bold = New-Object Drawing.Font("Tahoma", 9, [Drawing.FontStyle]::Bold)
  $norm = New-Object Drawing.Font("Tahoma", 9, [Drawing.FontStyle]::Regular)
  
  $img = "Qk02BQAAAAAAADYEAAAoAAAAEAAAABAAAAABAAgAAAAAAAABAAAAAAAAAAAAAAABAAAAAQAA////AN" + `
         "ju9gDYm1sA+O7jAMS3rQAUquEA/ez9ANrv9gDTZdIA2+/3AJeAbwCZMwAADGKBAI0tjAAOeJ4A/fD9" + `
         "AP/NmQD97f0A+q36ANxw2wAXmMgAbNbzAPuY+gCF4fUAUMvxAFDL8gA0wO8A997iAOm0fAC1YzUA+v" + `
         "TtABy17QDZbNgAa9f0AB217gA1wPAAHbXtALM8sgCF4PUAhuH0APnw5wD68uoAT8vxABy27gBr1vQA" + `
         "yXNDAIbh9QAvvu8ANMDwAPnx6QD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIyMjIyMjIyMjIAAwAyMjIyMjIyMjIyMjIAMQsDADIyMj" + `
         "IyMjIyMjIyHh0CCwMAMjIyMjIyMjIECgIQHAILAwAyMjIyMjIyBDIDAhAcAgsDMjIyADIyMgQyMgMC" + `
         "EC0oADIyAAcAMjIEMjIyGwIpADIyAAcOBwAyBDIyBg0bADIyAAcOKw4HAAQyBiUTDREAMgEOKhovDA" + `
         "oKCiASFhMNEQAFFyEYMCIMATIGCBIWEw0RAQUuFRkjHwwBMgYIEggGAAAJBSYVGRokDAEADwgPADIy" + `
         "AAkFJywYFAEAMgAPADIyMjIACQUXFAEAMjIyADIyMjIyMgAJBQEAMjIyMjIyMjI="
  
  $frmMain = New-Object Windows.Forms.Form
  $scSplit = New-Object Windows.Forms.SplitContainer
  $lvNames = New-Object Windows.Forms.ListView
  $rtbInfo = New-Object Windows.Forms.RichTextBox
  $imgList = New-Object Windows.Forms.ImageList
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common
  #
  $scSplit, $lvNames, $rtbInfo | % {$_.Dock = [Windows.Forms.DockStyle]::Fill}
  $imgList.Images.Add((Get-ImageFromString $img))
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbLabel.AutoSize = $true
  #
  #scSplit
  #
  $scSplit.Panel1.Controls.Add($lvNames)
  $scSplit.Panel2.Controls.Add($rtbInfo)
  $scSplit.SplitterWidth = 1
  #
  #lvNames
  #
  $lvNames.FullRowSelect = $true
  $lvNames.LargeImageList = $imgList
  $lvNames.MultiSelect = $true
  $lvNames.Sorting = [Windows.Forms.SortOrder]::Ascending
  $lvNames.TileSize = New-Object Drawing.Size(270, 17)
  $lvNames.View = [Windows.Forms.View]::Tile
  $lvNames.Add_Click({
    $rtbInfo.Clear()
    $sbLabel.Text = "Ready"
    
    for ($i = 0; $i -lt $lvNames.Items.Count; $i++) {
      if ($lvNames.Items[$i].Selected) {
        $rtbInfo.SelectionFont = $bold
        $rtbInfo.AppendText("$($lvNames.Items[$i].Text)`n")
        
        #retrieve category info
        $pcc = New-Object Diagnostics.PerformanceCounterCategory($lvNames.Items[$i].Text, $Computer)
        $rtbInfo.AppendText("$($pcc.CategoryHelp)`n`n$('=' * 55)`n`n")
        
        #category instances
        if ($pcc.GetInstanceNames() -ne $null) {
          $rtbInfo.SelectionFont = $bold
          $rtbInfo.AppendText("Instances:`n")
          
          $pcc.GetInstanceNames() | sort | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::Blue
            $rtbInfo.AppendText("`t$_`n")
          }
          $rtbInfo.AppendText("`n$('=' * 55)`n`n")
        }
        
        #counters
        $rtbInfo.SelectionFont = $bold
        $rtbInfo.AppendText("Counters:`n")
        
        try {
          $pcc.GetCounters() | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::FromArgb(125, 0, 255)
            $rtbInfo.AppendText("$((' ' * 3) + $_.CounterName)`n")
            $rtbInfo.AppendText("$((' ' * 3) + $_.CounterHelp)`n`n")
          }
        }
        catch [Management.Automation.MethodInvocationException] {
          $pcc.ReadCategory().GetEnumerator() | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::FromArgb(125, 0, 255)
            $rtbInfo.AppendText("$((' ' * 3) + $_.Key)`n")
          }
          $sbLabel.Text = "Can not read description in current context."
        }
      } #if
    } #for
  })
  #
  #rtbInfo
  #
  $rtbInfo.Font = $norm
  $rtbInfo.ReadOnly = $true
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(800, 470)
  $frmMain.Controls.AddRange(@($scSplit, $sbStrip))
  $frmMain.Icon = $ico
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "Performance Counters"
  $frmMain.Add_Load({
    [Diagnostics.PerformanceCounterCategory]::GetCategories($Computer) | % {
      $lvNames.Items.Add($_.CategoryName, 0)
    }
    $sbLabel.Text = "Ready"
  })
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
