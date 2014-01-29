#requires -version 2.0
function Find-InstalledNETFrameworks {
  $asm = [PSObject].Assembly.GetType('System.Management.Automation.PsUtils')
  $dot = $asm.GetMethod('IsDotNetFrameworkVersionInstalled', [Reflection.BindingFlags]40)
  $asm.GetNestedType('FrameworkRegistryInstallation', 'NonPublic').GetFields(
    [Reflection.BindingFlags]40
  ) | % {
    'Version {0, 13} -> Installed {1}' -f $_.Name, $dot.Invoke($null, @([Version]$_.GetValue($null)))
  }
}
