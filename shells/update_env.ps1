[CmdletBinding()]
param(
)

$3rdpartyBuilderDir = "d:\fulongtech_git\3rdparty-builder\"
$portsNameMap = @(
    @("openscenegraph-fx", "openscenegraph"),
    @("", "")
)

$myPorts = "f:\MyProjects\vcpkg_ports_ext\"

$modifiedFiles = git status -uno -s
if ($modifiedFiles) {
    foreach ($modifiedFile in $modifiedFiles) {
        $modifiedFile = $modifiedFile.Substring(3);
        Write-Host("git checkout HEAD " + $modifiedFile)
        git checkout HEAD $modifiedFile
    }
}


$beforPullLastCommitId = git rev-list -n 1 master toolsrc

git pull

$afterPullLastCommitId = git rev-list -n 1 master toolsrc

if ($beforPullLastCommitId -ne $afterPullLastCommitId) {
    & .\scripts\bootstrap.ps1
}

$builderPortsDir = Join-Path -Path $3rdpartyBuilderDir -ChildPath "vcpkg-ports" -Resolve
$builderPorts = Get-ChildItem -Path $builderPortsDir -Directory
foreach ($builderPort in $builderPorts) {
    $name = $builderPort.Name
    foreach ($temp in $portsNameMap) {
        if ($temp[0] -eq $name) {
            $name = $temp[1];
            break
        }
    }

    $vcpkgPort = ".\ports\" + $name
    if (!(Test-Path $vcpkgPort)) {
        cmd /c mklink /j $vcpkgPort $builderPort.FullName
    }
}

$portsPatchsDir = Join-Path -Path $3rdpartyBuilderDir -ChildPath "vcpkg-ports-patchs" -Resolve
$temp = $portsPatchsDir + "\*"
$ports_patchs = Get-ChildItem -Path $temp -Include *.patch
foreach ($patch in $ports_patchs) {
    Write-Host("git apply " + $patch.ToString())
    git apply $patch
}

$builderPortsDir = Join-Path -Path $myPorts -ChildPath "ports" -Resolve
$builderPorts = Get-ChildItem -Path $builderPortsDir -Directory
foreach ($builderPort in $builderPorts) {
    $name = $builderPort.Name
    foreach ($temp in $portsNameMap) {
        if ($temp[0] -eq $name) {
            $name = $temp[1];
            break
        }
    }

    $vcpkgPort = ".\ports\" + $name
    if (!(Test-Path $vcpkgPort)) {
        cmd /c mklink /j $vcpkgPort $builderPort.FullName
    }
}

$portsPatchsDir = Join-Path -Path $myPorts -ChildPath "patchs" -Resolve
$temp = $portsPatchsDir + "\*"
$ports_patchs = Get-ChildItem -Path $temp -Include *.patch
foreach ($patch in $ports_patchs) {
    Write-Host("git apply " + $patch.ToString())
    git apply $patch
}

$copysDir = Join-Path $myPorts -ChildPath "copys" -Resolve
Copy-Item -Path $copysDir -Destination . -Force -Recurse -Confirm