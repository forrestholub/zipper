Write-Host "Zippy Zipper sweeping through your logs...";
#validate which version of powershell is being used.
#$powerversion = get-host

# use winget to install 7zip console
# check if 32bit or 64bit os
# location to 32bit : https://www.7-zip.org/a/7z1900.msi
# location to 64bit : https://www.7-zip.org/a/7z1900-x64.msi

$OS_value = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

$doesHaveInstalled = $null;

#check for MSI file
$doesHaveMsiDownloaded = get-childitem $home -name -include "7zip*";

#Below if the whole thing is installed
$doesHaveInstalled = get-childitem 'C:\Program Files\' -name -include "7-Zip*"

if ($null -ne $doesHaveMsiDownloaded){
    write-host "Already found adequate 7zip file for use."
}
else {
    write-host "No 7zip file found, downloading now...";
    if ($OS_value -eq "32-bit"){
        write-host "Downloading 32-bit 7zip program"
        Invoke-WebRequest https://www.7-zip.org/a/7z1900.msi -OutFile $HOME\7zip.msi
    }
    if ($OS_value -eq "64-bit"){
        write-host "Downloading 64-bit 7zip program"
        Invoke-WebRequest https://www.7-zip.org/a/7z1900-x64.msi -OutFile $HOME\7zip.msi
    }
    else {
        write-host "Cannot determine operating system for 7zip download. Please download manually. Sorry."
    }
}
#verify that the global variables have been set



# ls = get-childitem
# grep = get-content

<# $progfile = 7zip.msi

$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $progfile.fullname,$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $progfile.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
 #>

#Start-Process msiexec.exe -Wait -ArgumentList '/I /a $pwd\7zip.msi /quiet /promptrestart /qn'

#with full path: breakdown: /a is administrator , program for exec, target directory, /passive = don't show user prompts, /L*v for logging
if ($null -ne $doesHaveInstalled){
    write-host "Already found adequate 7zip file installed."
}
Else {
msiexec /unregister
msiexec /regserver
$install_cmd = "/i " + "$HOME" + "\7zip.msi" + " /passive /promptrestart /L*v" + " $PWD" + "\install-logs.log"

write-host $install_cmd
# current dir ; C:\Users\forre\Desktop\tester
# Start-Process msiexec.exe -Wait -ArgumentList '/a C:\Users\forre\Desktop\tester\7zip.msi /passive /promptrestart /L*v $logFile'

write-host "Installing program"
Start-Process msiexec.exe -Wait -ArgumentList $install_cmd
}


# STEP 1: Find how many .isf files are in folder 
$filteredFiles = get-childitem . -name -include *.isf -r | sort-object -property lastwritetime

# STEP 2: Iterate through .isf files and compress each one individually
# -- add %filename%"_Iteration#.zip" to end of each filename
# -- file name example: 201218_turbo_12-18.17-57-14-333.isf

# $pwd = %cd%
# $home == %HOMEPATH%

# $7zippath="C:\Program Files\7-Zip\7z.exe"

$filteredFiles | 
    ForEach-Object {

        #$timestamp = get-date -format yyMMdd_hh:mm:ss

        $shortlog = $_.substring(0,$_.length-4)
        # "a" adds multiple files in folder to archive zip
        # "-t" types of archive (zip)
        C:\"Program Files"\7-Zip\7z.exe a -tzip "$pwd\$shortlog.zip" "$pwd\$_" -mx5
        }

# step 3 -- automatically upload files to FTP of your choice -- 
# - have text file named: (FTP.CONFIG) with pertinent info ; HOST, USR, PWD, PATH 
# -- status updates: 'pending' , 'receiving' , 'uploaded' , 'complete', 'failure', 'size-mismatch'
# --- additional features like auto retry, 