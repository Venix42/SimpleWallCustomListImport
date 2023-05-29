## 
##  Update SimpleWallBlock List from internet
##

## Lists
        #"https://raw.githubusercontent.com/stamparm/ipsum/master/levels/1.txt",
        #"https://raw.githubusercontent.com/stamparm/ipsum/master/levels/2.txt",
        #"https://raw.githubusercontent.com/stamparm/ipsum/master/levels/3.txt",
$lists =@(
            "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/4.txt",
            "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/5.txt",
            "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/6.txt",
            "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/7.txt",
            "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/8.txt"
        )
$simplewallConfigFolder=$env:APPDATA+"\Henry++\simplewall"
#$simplewallConfigFolder="D:\test"
$profileFile = $simplewallConfigFolder+"\profile.xml"
$backupProfile =$simplewallConfigFolder+"\profile.scriptupdate.bak.xml"
$scriptPath = $PSScriptRoot



## If not present Download CIDR merger
if (-Not(Test-Path "$scriptPath\cidr-merger-windows-amd64.exe")) {
    try{
        $latestRelease = Invoke-WebRequest https://github.com/zhanhb/cidr-merger/releases/latest -UseBasicParsing -Headers @{"Accept"="application/json"}
        $json = $latestRelease.Content | ConvertFrom-Json
        $latestVersion = $json.tag_name
        $url = "https://github.com/zhanhb/cidr-merger/releases/download/$latestVersion/cidr-merger-windows-amd64.exe"
        Invoke-WebRequest -Uri $url -OutFile "$scriptPath\cidr-merger-windows-amd64.exe"
    }catch {
        Write-Host "An error occurred:"
        Write-Host $_
    }
}

##Delete previous backup file
if (Test-Path $backupProfile) {
  Remove-Item $backupProfile 
}

##Copy previous file as backup
if (-Not(Test-Path $backupProfile)) {
    Copy-Item -Path $profileFile -Destination $backupProfile 
  }

##Delete Rules_Custom Content
$xml = [xml](Get-Content $profileFile)
$node = $xml.SelectSingleNode("//root/rules_custom")
$node.RemoveAll()

#Parsing list
$i=3
$lists | ForEach-Object {
    ## Copy data form source
    try {
        $uri = $_
        if(-Not(Test-Path "$scriptPath\cidr-merger-windows-amd64.exe")) {
            Remove-Item temp.txt
            Remove-Item temp2.txt
        }
        (Invoke-WebRequest -Uri $uri).Content | Out-File temp.txt
        ## Merge IP List to reduce size
        Start-Process “$scriptPath\cidr-merger-windows-amd64.exe" -ArgumentList "-o temp2.txt temp.txt"
        Start-Sleep -Seconds 1.5
        $data = Get-Content $scriptPath\temp2.txt
        ## Format Data as XML & Insert Data into SimpleWall Profile File
        ForEach ($line in $($data -split "`n"| Where-Object {$_ -notmatch "^#"}))
        {
            $newItem = [xml]@"
            <item name="CustomList$($i)-$(Get-Random)" rule="$($line)" dir="2" is_block="true" is_enabled="true"/>
"@
            Write-Debug $newItem.item.Name
            Write-Debug $node.AppendChild($xml.ImportNode($newItem.item,$true))
        }
    }
    catch [System.Net.WebException] {
        Write-Host $uri " not accessible!"
    }catch {
        Write-Host "An error occurred:"
         Write-Host $_
    }
    
    $i++
}

##Save file
$xml.Save($profileFile)
