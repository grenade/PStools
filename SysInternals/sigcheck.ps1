#requires -version 2.0
Set-Alias sigcheck Get-FileSignature

function Get-FileSignature {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Alias('h')]
    [Switch]$Hashes,
    
    [Alias('m')]
    [Switch]$ManifestDump,
    
    [Alias('n')]
    [Switch]$VersionNumber
  )
  
  begin {
    $FileName = cvpa $FileName
    $asm = 'System.Deployment'
    Add-Type -AssemblyName $asm
    
    function Get-Hashes([String]$HashKind, [String]$FileName) {
      if (([IO.FileInfo]$FileName).Length -ne 0) {
        try {
          $fs = [IO.File]::OpenRead($FileName)
          [Security.Cryptography.HashAlgorithm]::Create($HashKind).ComputeHash($fs) | % {
            $res = ''}{$res += $_.ToString('x2')}{'{0}: {1}' -f $HashKind, $res
          }
        }
        finally {
          if ($fs -ne $null) {$fs.Close()}
        }
      }
    } #hashes
    
    function Get-ManifestDump([String]$FileName) {
      begin {
        $su = ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
          $_.FullName.Split(',')[0] -eq $asm
        }).GetType(($asm + '.Application.Win32InterOp.SystemUtils'))
        $a = [Activator]::CreateInstance($su)
      }
      process {
        try {
          -join [Char[]]$a.GetType().InvokeMember('GetManifestFromPEResources',
                [Reflection.BindingFlags]280, $null, $su, @($FileName)
          )
        }
        catch [Management.Automation.RuntimeException] {}
      }
    } #manifest
    
    function Get-MachineType([String]$FileName) {
      begin {
        $bytes = New-Object "Byte[]" 1024
      }
      process {
        try {
          $fs = [IO.File]::OpenRead($FileName)
          [void]$fs.Read($bytes, 0, 1024)
          [Int32]$res = [BitConverter]::ToUInt16($bytes, ([BitConverter]::ToInt32($bytes, 0x3c) + 0x4))
        }
        catch [Management.Automation.RuntimeException] {
          $exp = [Boolean]$_.Exception
        }
        finally {
          if ($fs -ne $null) {$fs.Close()}
          if (!$exp) {[Reflection.ImageFileMachine]$res}
        }
      }
    } #mactype
  }
  process {
    if ($VersionNumber) {
      (Get-Item $FileName).VersionInfo.FileVersion
    }
    elseif ($ManifestDump) {
      Get-ManifestDump $FileName
    }
    else {
      $sig = Get-AuthenticodeSignature $FileName
      $pub = ([RegEx]'CN=([\w|\s])+').Match($sig.SignerCertificate.Subject).Value.Split('=')[1]
      
      $inf = [Diagnostics.FileVersionInfo]::GetVersionInfo($FileName) | select @{N='Verified';
      E={$sig.Status}},@{N='Publisher';E={switch(![String]::IsNullOrEmpty($pub)){$true{$pub
      }default{'n/a'}}}},@{N='Description';E={$_.FileDescription}},@{N='Product';E={$_.ProductName
      }},@{N='Prod version';E={$_.ProductVersion}},@{N='File version';E={$_.FileVersion}},@{
      N='MachineType';E={Get-MachineType $_.FileName}},@{N='Original Name';E={$_.OriginalFilename}},@{
      N='Internal Name';E={$_.InternalName}},@{N='Copyright';E={$_.LegalCopyright}},@{N='Comments';
      E={switch(![String]::IsNullOrEmpty($_.Comments)){$true{$_.Comments}default{'n/a'}}}}
      
      if ($Hashes) {
        Add-Member -mem ScriptProperty -nam Hashes -inp $inf -val {
          'MD5', 'SHA1', 'SHA256' | % {Get-Hashes $_ $FileName}
        }
      } #if
    }
  }
  end {$inf | fl}
}
