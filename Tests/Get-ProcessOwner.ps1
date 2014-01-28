#requires -version 2.0
function Get-ProcessOwner {
  <#
    .EXAMPLE
        PS C:\>Get-ProcessOwner (ps notepad)
    .EXAMPLE
        PS C:\>ps notepad | Get-ProcessOwner
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Diagnostics.Process[]]$Processes
  )
  
  begin {
    $StopProcessCommand = ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
      $_.FullName.Split(',')[0].Equals('Microsoft.PowerShell.Commands.Management')
    }).GetType('Microsoft.PowerShell.Commands.StopProcessCommand')
    
    $GetProccessOwnerId = $StopProcessCommand.GetMethod('GetProcessOwnerId', [Reflection.BindingFlags]36)
    $type = New-Object $StopProcessCommand
  }
  process {
    try {
      $Processes | % {
        '{0} PID:{1} {2}' -f $_.ProcessName, $_.Id, $GetProccessOwnerId.Invoke($type, $_)
      }
    }
    catch {
      $_.Exception.Message.Split(':')[1].Trim() -replace '\"', ''
    }
  }
  end {}
}
