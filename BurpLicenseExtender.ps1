# Name is Important
echo "
               #     #   #     #   #######   #     #      #      #     #       #     # 
                #   #    #     #      #      #     #     # #     ##    #       #    #  
                 # #     #     #      #      #     #    #   #    # #   #       #   #   
                  #      #     #      #      #######   #######   #  #  #   #   ####    
                 #       #     #      #      #     #   #     #   #   # #       #   #   
                #        #     #      #      #     #   #     #   #    ##       #    #  
               #          #####       #      #     #   #     #   #     #       #     # 
	       -- B u r p -- S u i t e -- P r o -- L i c e n s e -- E x t e n d e r --
"

# Set Wget Progress to Silent, Becuase it slows down Downloading by +50x
echo "Setting Wget Progress to Silent, Becuase it slows down Downloading by +50x`n"
$ProgressPreference = 'SilentlyContinue'

# Check JDK-18 Availability or Download JDK-18
$jdk18 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java(TM) SE Development Kit 18*"
if (!($jdk18)){
    echo "`t`tDownnloading Java JDK-18 ...."
    wget "https://download.oracle.com/java/18/latest/jdk-18_windows-x64_bin.exe" -O jdk-18.exe    
    echo "`n`t`tJDK-18 Downloaded, lets start the Installation process"
    start -wait jdk-18.exe
    rm jdk-18.exe
}else{
    echo "Required JDK-18 is Installed"
    $jdk18
}

# Check JRE-8 Availability or Download JRE-8
$jre8 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java 8 Update *"
if (!($jre8)){
    echo "`n`t`tDownloading Java JRE ...."
    wget "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=246474_2dee051a5d0647d5be72a7c0abff270e" -O jre-8.exe
    echo "`n`t`tJRE-8 Downloaded, lets start the Installation process"
    start -wait jre-8.exe
    rm jre-8.exe
}else{
    echo "`n`nRequired JRE-8 is Installed`n"
    $jre8
}

# Downloading Burp Suite Professional
$response = Read-Host "Do you want to download BurpSuite Pro 2022.6.1 version? (Default answer will be [Yes], enter y/1/yes for [Yes] or n/0/no for [No])"
switch($response)
{
 {'y','Y','1','yes','Yes' -contains $_} {$Byear = "2022.6.1"}
 {'n','N','0','no','No' -contains $_} {echo "(Note: Enter the version deatils in the format YYYY.X.X, example 2022.6.1) `nIf you fail to provide the right version, I may fail to download the Burp jar and close without successful completion. `nYou may have to re-run me and specify the right version again."
		$Byear = Read-Host "Please enter the Burp version you are trying to download"}
 default {$Byear = "2022.6.1"}
}

if (Test-Path Burp-Suite-Pro.jar){
    echo "Burp Suite Professional JAR file is available.`nChecking its Integrity ...."
    if (((Get-Item Burp-Suite-Pro.jar).length/1MB) -lt 500 ){
        echo "`n`t`tFiles Seems to be corrupted `n`t`tDownloading Latest Burp Suite Professional ...."
        wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=$Byear&type=jar" -O "burpsuite_pro_v$Byear.jar"
        echo "`nBurp Suite Professional is Downloaded.`n"
    }else {echo "File Looks fine. Lets proceed for Execution"}
}else {
    echo "`n`t`tDownloading Latest Burp Suite Professional ...."
    wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=$Byear&type=jar" -O "burpsuite_pro_v$Byear.jar"
    echo "`nBurp Suite Professional is Downloaded.`n"
}


# Creating Burp.bat file with command for execution
if (Test-Path burp.bat) {rm burp.bat} 
$path = "@echo off"
$path | add-content -path Burp.bat
$path = "for /f `"delims=`" %%a in ('dir /b /a-d /o:d burpsuite_*.jar ') do set `"filename=%%a`""
$path | add-content -path Burp.bat
$path = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -javaagent:`"%cd%\leloader.jar`" -noverify -jar `"%cd%\%filename%`""
$path | add-content -path Burp.bat
echo "`nBurp.bat file is created"

# Creating Burp Pro Shortcut
wget "https://raw.githubusercontent.com/iamyuthan/BurpLE/Master/Burp%20Icon.ico" -O "Burp Icon.ico"
$SourceFilePath = "$pwd\Burp.bat"
$ShortcutPath = "$Home\Desktop\Burp Suite Professional.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$Shortcut.IconLocation = "$pwd\Burp Icon.ico"
$shortcut.Save()

# Remove Additional files
rm "Burp Icon.ico"
rm LICENSE
rm README.md
del -Recurse -Force .\.github\


# Lets Activate Burp Suite Professional with License Generator and License Extender Loader
echo "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
echo "`n`nStarting Burp Suite Professional"
cmd.exe /c '$pwd\Burp.bat'
