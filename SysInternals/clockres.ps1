#requires -version 2.0
Set-Alias clockres Get-ClockRes

function Get-ClockRes {
  <#
    .NOTES
        Author: greg zakharov
  #>
  begin {
    $cd = [AppDomain]::CurrentDomain
    $Attributes = 'AutoLayout, AnsiClass, Class, Public, Sealed, BeforeFieldInit'
    
    if (!($cd.GetAssemblies() | ? {
      $_.FullName.Split(',')[0].Equals('NativeUtils')
    })) {
      $type = (($cd.DefineDynamicAssembly(
        (New-Object Reflection.AssemblyName('NativeUtils')), [Reflection.Emit.AssemblyBuilderAccess]::Run
      )).DefineDynamicModule('NativeUtils', $false)).DefineType('ClockRes', $Attributes)
      [void]$type.DefinePINvokeMethod('GetSystemTimeAdjustment', 'kernel32.dll',
        [Reflection.MethodAttributes]'Public, Static, PinvokeImpl',
        [Reflection.CallingConventions]::Standard, [Boolean].GetType(),
        @([UInt32].MakeByRefType(), [UInt32].MakeByRefType(), [Boolean].MakeByRefType()),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Auto
      )
      $global:clockres = $type.CreateType()
    }
  }
  process {
    try {
      [UInt32]$a = $t = 0
      [Boolean]$r = $true
      [void]$clockres::GetSystemTimeAdjustment([ref]$a, [ref]$t, [ref]$r)
      Write-Host Current timer interval: $($t / 10000) ms. -fo Yellow
    }
    catch [Management.Automation.RuntimeException] {
      Write-Host $_.Exception.Message -fo Red
    }
  }
  end {}
}
