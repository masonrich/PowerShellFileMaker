#!/usr/bin/env pwsh
# Mason Rich
# Lab 8 - PowerShell Filemaker
# CS 3030 - Scripting Languages

#exit if path is null
if($args.Count -ne 3){
    Write-Host "Usage: ./filemaker INPUTCOMMANDFILE OUTPUTFILE RECORDCOUNT"
    exit 1
}

#open the command file
try {
    $commandFile = get-content -path $args[0] -erroraction stop
}
catch {
    write-output ("Error opening or reading command file")
    exit 1
}

#set the output file
try {
    $outputFile = $args[1]
    new-item -path $outputFile -erroraction stop | out-null
}
catch {
    write-output ("Error opening output file: $($_)")
    exit 1
}

#convert the record count to int
try {
    $recordCount = $args[2].toInt32($null)
}
catch {
    write-output ("Error converting record count to integer value")
    exit 1
}

#function to write to the file
function writeToFile ($outputFile, $outputString) {
    write-output("GOT TO output FUNCTION")
    $outputString = $outputString-replace [regex]::escape("\t"), "`t"
    $outputString = $outputString-replace [regex]::escape("\n"), "`n"
    try {
        add-content -path $outputFile -value $outputString -nonewline
    }
    catch {
        write-output("Write failed to file $($outputFile): $_")
        exit 1
    }
}


#create random files dictionary
#$randomFiles = @{}

foreach ($command in $commandFile) {

    $temp = $command.split(" ")

    #write HEADER to output file
    if ($command -match '^HEADER\s+"(.*)"$') {
        writeToFile $outputFile $matches.1
    }
    
    if($temp[0] -eq "FILEWORD"){
	$tempFileName = $temp[2].trim('"')
        try{
            $randomFiles = get-content -path $tempFileName -erroraction stop
        }
        catch {
            write-output ("Error opening or reading random file")
            exit 1
        }
    }

}

#write a record for however many the user specifies
for($i=0; $i -lt $recordCount; $i=$i+1){
    $randomData = @{}
    foreach ($command in $commandFile){
        
 	$temp = $command.split(" ")
        
	#write HEADER to output file
        if ($command -match'^STRING\s+"(.*)"$' -or $command-match'^STRING\s+''(.*)''$') {
            writeToFile $outputFile $matches.1
        }
	
	#if its FILEWORD
	if ($temp[0] -eq "FILEWORD") {
	    $label = $temp[1]
	    if ($randomData.ContainsKey($label)){
	        write-output("Error - found key for FILEWORD")
		exit 1
	    }
	    else{
		$randomString = get-random -inputobject $randomFiles
		$randomData[$temp[1]] = $randomString
		writeToFile $outputFile $randomData[$temp[1]]
	    }
	}
	
	#for NUMBERS
	if ($temp[0] -eq "NUMBER") {
	    $label = $temp[1]
	    $minNumber = $temp[2].toInt32($null)
	    $maxNumber = $temp[3].toInt32($null)
	    $maxNumber = $maxNumber+1
	    if ($randomData.ContainsKey($label)){
                write-output("Error - found key for NUMBER")
                exit 1
            }
            else{
		$randomNumber = Get-Random -Minimum $minNumber -Maximum $maxNumber
		$randomData[$temp[1]] = $randomNumber.ToString()
		writeToFile $outputFile $randomData[$temp[1]]
            }
	}
	
	#for REFER
	if ($temp[0] -eq "REFER") {
	    $label = $temp[1]
	    writeToFile $outputFile $randomData[$label]
	}
    }
}


