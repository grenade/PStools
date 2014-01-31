#requires -version 2.0
Set-Alias paste Get-HostPaste

function Get-HostPaste {
  <#
    .NOTES
        Author: greg zakharov
  #>
  begin {
    function get([String]$Assembly, [String]$Class, [String]$Method, [Switch]$Flags) {
      $type = ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
        $_.FullName.Split(',')[0].Equals($Assembly)
      }).GetType($Class)
      
      switch ($Flags) {
        $true   {$res = $type.GetMethod($Method, [Reflection.BindingFlags]40)}
        default {$res = $type.GetMethod($Method)}
      }
      
      return $res
    } #get
  }
  process {
    $GetConsoleWindow = get `
      Microsoft.PowerShell.ConsoleHost Microsoft.PowerShell.ConsoleControl GetConsoleWindow -f
    $SendMessage = get System Microsoft.Win32.UnsafeNativeMethods SendMessage
    
    [Runtime.InteropServices.HandleRef]$href = New-Object Runtime.InteropServices.HandleRef(
      (New-Object IntPtr), $GetConsoleWindow.Invoke($null, @())
    )
  }
  end {
    [void]$SendMessage.Invoke($null, @($href, 0x0111, [IntPtr]0xfff1, [IntPtr]::Zero))
  }
}
