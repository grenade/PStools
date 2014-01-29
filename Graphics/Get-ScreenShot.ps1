#requires -version 2.0
function Get-ScreenShot {
  <#
    .EXAMPLE
        PS C:\>Get-ScreenShot
    .EXAMPLE
        PS C:\>Get-ScrenShot -p foo -ext png
    .EXAMPLE
        PS C:\>Get-ScreenShot -cur
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(DefaultParameterSetName="FileName")]
  param(
    [Parameter(Position=0)]
    [String]$FileName = $(date -u %d%m%Y_%H%M%S),
    
    [Parameter(Position=1)]
    [ValidateSet('bmp', 'gif', 'jpg', 'png', 'tif')]
    [String]$Extension = 'jpg',
    
    [Parameter(Position=2)]
    [String]$Path = $pwd.Path,
    
    [Parameter(Position=3)]
    [Switch]$Cursor = $false
  )
  
  begin {
    Add-Type -Assembly System.Windows.Forms
    
    function Expand-PictureFormat($Extention) {
      switch($Extension) {
        "jpg" {return [Drawing.Imaging.ImageFormat]::Jpeg}
        "tif" {return [Drawing.Imaging.ImageFormat]::Tiff}
        default {return [Drawing.Imaging.ImageFormat]::$Extension}
      }
    }
    
    $scr = [Windows.Forms.Screen]::PrimaryScreen.Bounds
    $pic = New-Object Drawing.Bitmap($scr.Width, $scr.Height)
  }
  process {
    if (-not (Test-Path $Path)) {
      [void](ni $Path -type Directory -force)
    }
    
    $gfx = [Drawing.Graphics]::FromImage($pic)
    $gfx.CopyFromScreen([Drawing.Point]::Empty, [Drawing.Point]::Empty, $pic.Size)
  
    if ($Cursor) {
      $cur = New-Object Drawing.Rectangle([Windows.Forms.Cursor]::Position, [Windows.Forms.Cursor]::Current.Size)
      [Windows.Forms.Cursors]::Default.Draw($gfx, $cur)
    }
  
    $pic.Save(($Path + '\' + $FileName + '.' + $Extension), (Expand-PictureFormat($Extension)))
    $gfx.Dispose()
    $pic.Dispose()
  }
  end {}
}
