#requires -version 2.0
function Get-WmiNSTree([String]$NameSpace = 'root') {
  <#
    .EXAMPLE
        PS C:\>Get-WmiNSTree root\RSOP
    .NOTES
        Author: greg zakharov
  #>
  
  begin {
    function get([String]$root, [Int32]$deep = 1) {
      (New-Object Management.ManagementClass(
        $root, [Management.ManagementPath]'__NAMESPACE', $null)
      ).PSBase.GetInstances() | sort | % {
        '{0}{1}--{2}' -f (' ' * 3 * $deep), [Char]31, $_.Name
        get $($root + '\' + $_.Name) (++$deep)
        --$deep
      }
    } #get
  }
  process {
    try {
      get $NameSpace
    }
    catch [Management.Automation.MethodInvocationException] {
      $_.Exception.Message
    }
  }
  end {}
}
