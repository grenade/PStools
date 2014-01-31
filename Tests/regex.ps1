#requires -version 2.0
function Clear-MatchesSelection {
  $rtbText.SelectAll()
  $rtbText.SelectionColor = [Drawing.Color]::Black
  $rtbText.SelectionBackColor = [Drawing.Color]::White
  $rtbText.DeselectAll()
  
  $sbLabel.Text = "Editing RegEx..."
}

function Clear-All {
  $tsRegEx, $rtbText | % {$_.Clear()}
  $tsCombo.SelectedIndex = 1
  $sbLabel.Text = "Cleared..."
}

function Get-ImageFromString([String]$str) {
  [Drawing.Image]::FromStream(
    (New-Object IO.MemoryStream(($$ = [Convert]::FromBase64String($str)), 0, $$.Length))
  )
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $img = "Qk32AgAAAAAAADYAAAAoAAAADgAAABAAAAABABgAAAAAAMACAAAAAAAAAAAAAAAAAAAAAAAA//////" + `
         "//////////////////////////////////////////////////AAD/////////////////////////" + `
         "//////////////////////////////8AAP///////////////////////wAAAAAAAP////////////" + `
         "///////////wAA////////////////////////AAAAAAAA////////////////////////AAD/////" + `
         "//////////////////////////////////////////////////8AAP///////////////////////w" + `
         "AAAAAAAP///////////////////////wAA////////////////////////aGhoAAAAsrKy////////" + `
         "////////////AAD////////////////////////Z2dkAAAAAAACnp6f///////////////8AAP////" + `
         "///////////////////////9nZ2U1NTQAAALKysv///////////wAA////////////////////////" + `
         "////////8PDwAAAAAAAA////////////AAD///////////9NTU0AAADHx8f////////Hx8cAAABNTU" + `
         "3///////////8AAP///////////9DQ0AAAAAAAAAAAAAAAAAAAAAAAANDQ0P///////////wAA////" + `
         "////////////2dnZfHx8AAAAAAAAfHx82dnZ////////////////AAD///////////////////////" + `
         "////////////////////////////////8AAP//////////////////////////////////////////" + `
         "/////////////wAA////////////////////////////////////////////////////////AAA="
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuFile = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOpen = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNone = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNull = New-Object Windows.Forms.ToolStripSeparator
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuView = New-Object Windows.Forms.ToolStripMenuItem
  $mnuFont = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSBar = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuMans = New-Object Windows.Forms.ToolStripmenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripmenuItem
  $tsStrip = New-Object Windows.Forms.ToolStrip
  $tsLbl_1 = New-Object Windows.Forms.ToolStripLabel
  $tsLbl_2 = New-Object Windows.Forms.ToolStripLabel
  $tsCombo = New-Object Windows.Forms.ToolStripComboBox
  $tsRegEx = New-Object Windows.Forms.ToolStripTextBox
  $tsTryIt = New-Object Windows.Forms.ToolStripButton
  $rtbText = New-Object Windows.Forms.RichTextBox
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common
  #
  $mnuMain.Items.AddRange(@($mnuFile, $mnuView, $mnuHelp))
  $tsStrip.Items.AddRange(@($tsLbl_1, $tsCombo, $tsLbl_2, $tsregEx, $tsTryIt))
  $tsLbl_1.Text = "Mode:"
  $tsLbl_2.Text = "RegEx:"
  $sbStrip.Items.AddRange(@($sbLabel))
  #
  #mnuFile
  #
  $mnuFile.DropDownItems.AddRange(@($mnuOpen, $mnuNone, $mnuNull, $mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuOpen
  #
  $mnuOpen.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::O
  $mnuOpen.Text = "&Open..."
  $mnuOpen.Add_Click({
    (New-Object Windows.Forms.OpenFileDialog) | % {
      $_.Filter = "Text files (*.txt)|*.txt"
      $_.InitialDirectory = $pwd.Path
      
      if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $rtbText.Clear()
        cat $_.FileName | % {$rtbText.AppendText("$($_)`n")}
      }
      $sbLabel.Text = "Loaded..."
    }
  })
  #
  #mnuNone
  #
  $mnuNone.ShortcutKeys = [Windows.Forms.Keys]::F5
  $mnuNone.Text = "&Clear All"
  $mnuNone.Add_Click({Clear-All})
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::X
  $mnuexit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuView
  #
  $mnuView.DropDownItems.AddRange(@($mnuFont, $mnuSBar))
  $mnuView.Text = "&View"
  #
  #mnuFont
  #
  $mnuFont.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::F
  $mnuFont.Text = "&Font..."
  $mnuFont.Add_Click({
    (New-Object Windows.Forms.FontDialog) | % {
      $_.Font = "Lucida Console"
      $_.MinSize = 8
      $_.MaxSize = 12
      $_.ShowEffects = $false
      
      if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $rtbText.Font = $_.Font
      }
    }
  })
  #
  #mnuSBar
  #
  $mnuSBar.Checked = $true
  $mnuSBar.Text = "&Status Bar"
  $mnuSBar.Add_Click({
    $toggle =! $mnuSBar.Checked
    $mnuSbar.Checked = $toggle
    $sbStrip.Visible = $toggle
  })
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuMans, $mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuMans
  #
  $mnuMans.ShortcutKeys = [Windows.Forms.Keys]::F1
  $mnuMans.Text = "Help..."
  $mnuMans.Add_Click({
    $tsregEx, $rtbText | % {
      cat ($PSHome + '\' + (Get-Culture).TwoLetterISOLanguageName + 
                       '\about_regular_expressions.help.txt') | % {
        $rtbText.AppendText("$($_)`n")
      }
    }
    $sbLabel.Text = "Available man page"
  })
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #tsCombo
  #
  $tsCombo.Items.AddRange(@('cmatch', 'match'))
  $tsCombo.SelectedIndex = 1
  $tsCombo.Size = New-Object Drawing.Size(30, 19)
  $tsCombo.Add_SelectedIndexChanged({
    $tsRegEx.Clear()
    Clear-MatchesSelection
  })
  #
  #tsRegEx
  #
  $tsRegEx.Size = New-Object Drawing.Size(373, 19)
  $tsRegEx.Add_TextChanged({Clear-MatchesSelection})
  #
  #tsTryIt
  #
  $tsTryIt.Image = (Get-ImageFromString $img)
  $tsTryIt.Add_Click({
    if (![String]::IsNullOrEmpty($rtbText.Text) -and ![String]::IsNullOrEmpty($tsRegEx.Text)) {
      switch ($tsCombo.SelectedIndex) {
        0 {$opt = 'None'}
        1 {$opt = 'IgnoreCase'}
      }
      
      try {
        $mat = [RegEx]::Matches($rtbText.Text, $tsRegEx.Text, $opt)
        
        if ($mat.Count -ge 0) {
          $mat | % {
            $rtbText.Select($_.Index, $_.Length)
            $rtbText.SelectionBackColor = [Drawing.Color]::FromArgb(220, 160, 225)
          }
          $sbLabel.Text = $('Matches: {0}' -f $mat.Count)
        }
        $rtbText.DeselectAll()
      }
      catch [Management.Automation.MethodInvocationException] {
        $sbLabel.Text = $_.Exception.Message
      }
    } #if
  })
  #
  #rtbText
  #
  $rtbText.Dock = [Windows.Forms.DockStyle]::Fill
  $rtbText.Font = New-Object Drawing.Font("Tahoma", 9, [Drawing.FontStyle]::Regular)
  $rtbText.Add_TextChanged({$sbLabel.Text = "Changed..."})
  #
  #sbLabel
  #
  $sbLabel.AutoSize = $true
  $sbLabel.ForeColor = [Drawing.Color]::DarkGreen
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(570, 347)
  $frmMain.Controls.AddRange(@($rtbText, $sbStrip, $tsStrip, $mnuMain))
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "PS RegEx"
  
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
  $lblName.Text = "PS RegEx v1.00"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "Copyright (C) 2013-2014 greg zakharov"
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
