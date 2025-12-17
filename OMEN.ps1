#Ranjit - added  below lines - start
param($round,$round_und,$round_hash,$start_dt,$end_dt)
$Global:Round = [string]$round
$Global:Round_und = [string]$round_und
$Global:Round_hash = [string]$round_hash
$Global:sdt = [string]$start_dt
$Global:edt = [string]$end_dt
#Ranjit - added  below lines - stop
function Set-PID {
    param(
        [parameter(Mandatory=$true)]$dest,
        [parameter(Mandatory=$true)]$src,
        [parameter(Mandatory=$true)]$sort		
        )
        $f = "yyyy-MM-dd HH:mm:ss"

        if ("DateOfBirth" -in ($src | Get-Member -MemberType NoteProperty).Name) {

            foreach ($dt in $src) {
                if ($dt.DateOfBirth -ne "") {
                    $dt.DateOfBirth = Get-Date($dt.DateOfBirth) -Format $f
                }
            }

        }

        if ("Extra:Version_Id" -in ($src | Get-Member -MemberType NoteProperty).Name) {

            foreach ($vID in $src) {
                $vID."Extra:Version_Id" = $Global:Round #"27.75" # Ranjit
            }

        }

        if (($Global:encfile)."Extra:LHDIdentifier" -match "x830" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x840" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x850") {

            foreach ($pat in $src) {
                $pat.PatientNumber = ($pat.PatientNumber[-7..-1] -join '')
            }
        }

        if ($sort -eq "unique") {

            $src | Sort-Object PatientNumber -Unique | Export-Csv $dest -NoTypeInformation -Force

        }

        if ($sort -eq "nounique") {
            
            $src | Export-Csv $dest -NoTypeInformation -Force

        }
    
    }
    
    function Set-Clinic {
    param(
        [parameter(Mandatory=$true)]$dest,
        [parameter(Mandatory=$true)]$src
        )

        $f = "yyyy-MM-dd HH:mm:ss"
        $trarr = [System.Collections.Generic.List[object]]::new()
        $trarr2 = [System.Collections.Generic.List[object]]::new()

        foreach ($dt in $src) {
            if ($dt.StartDateTime -ne "") {
                $dt.startdatetime = Get-Date($dt.startdatetime) -Format $f
            }
        }

        if (($Global:encfile)."Extra:LHDIdentifier" -match "x830" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x840" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x850") {

            foreach ($pat in $src) {
                $pat.PatientNumber = ($pat.PatientNumber[-7..-1] -join '')
            }
        }

        foreach ($cl in $src){ 
    
        if ($cl.Unit -eq "25") {
            $cl.Clinic = ($cl.Clinic + 'HITH')
        }
    
        if (($cl.Unit -eq "29") -AND (($Global:encfile)."Extra:LHDIdentifier" -notmatch "x690")) {
            $cl.Clinic = ($cl.Clinic).Insert(5,"V")
        }
    
        <# Maybe a safer way to go would be using the following if there are more than 1 dashes:
        if ($clinic.Unit -eq "29") {
            [regex]$pattern = '-'
            $clinic.Clinic = $pattern.Replace($clinic.Clinic, '-V', 1)
        } #>

        }

        foreach ($inctr in $src) {
    
                $chk = @($inctr.Clinic,$inctr.EncounterNumber,$inctr.PatientNumber,$inctr.StartDateTime,$inctr.Ward,$inctr.AttendingConsultant_Code,$inctr.AttendingConsultant_SpecialtyCode,$inctr.BedNumber,$inctr.Unit,$inctr.Leave,$inctr."Extra:SpecialtyPortal")
                $i = 0
                while ($i -lt $chk.Length){
                    if ($chk[$i] -contains "") {
                        $trarr.Add($inctr)
                    }
                $i++
                }
            }
      

        $trarr | ForEach-Object {
            $trarr2.Add([PSCustomObject]@{
                Clinic = $_.Clinic
                EncounterNumber = $_.EncounterNumber
                PatientNumber = $_.PatientNumber
                StartDateTime = $_.StartDateTime
                Ward = $_.Ward
                AttendingConsultant_Code = $_.AttendingConsultant_Code
                AttendingConsultant_SpecialtyCode = $_.AttendingConsultant_SpecialtyCode
                BedNumber = $_.BedNumber
                Unit = $_.Unit
                Leave = $_.Leave
                "Extra:SpecialtyPortal" = $_."Extra:SpecialtyPortal" })   
        }

            $trarr2 | Export-Csv -Path ($Global:qualDest+"incompletetransfers.csv") -NoTypeInformation -Force
            $src | Export-Csv -Path $dest -NoTypeInformation -Force
    
    }

    
    function Set-LengthOfStay {
    param(
        [parameter(Mandatory=$true)]$dest,
        [parameter(Mandatory=$true)]$src
        )

        $f = "yyyy-MM-dd HH:mm:ss"
        $losOut = [System.Collections.Generic.List[object]]::new()
        $mos = [System.Collections.Generic.List[object]]::new()
        $mosarr = [System.Collections.Generic.List[object]]::new()
        $arr3 = [System.Collections.Generic.List[object]]::new()

        foreach ($dt in $src) {
            if($dt.StartDateTime -ne "") {
                $dt.startdatetime = Get-Date($dt.startdatetime) -Format $f
            }
            if ($dt.EndDateTime -ne "") {
                $dt.enddatetime = Get-Date($dt.enddatetime) -Format $f
            }
            if ($dt."Extra:EDTriageDateTime" -ne "") {
                $dt."Extra:EDTriageDateTime" = Get-Date($dt."Extra:EDTriageDateTime") -Format $f
            }
        }

        if ("Extra:Version_Id" -in ($src | Get-Member -MemberType NoteProperty).Name) {

            foreach ($vID in $src) {
                $vID."Extra:Version_Id" = $Global:Round #"27.75" # Ranjit
            }

        }

        if (($Global:encfile)."Extra:LHDIdentifier" -match "x830" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x840" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x850") {

            foreach ($pat in $src) {
                $pat.PatientNumber = ($pat."Extra:AUID")
            }
        }

        foreach ($losRow in ($src)) {
        if (([int]$losRow.LengthofStay) -lt 0 -AND ([int]$losRow."Extra:ModeofSep") -notmatch 99) {
            $losOut.Add($losRow)
        }
        if (([int]$losRow.LengthofStay) -lt 0 -AND ([int]$losRow."Extra:ModeofSep") -match 99) { 
            $mos.Add($losRow)
            $src = [System.Collections.ArrayList]$src
            $src.Remove($losRow)
        }
        }

        $mos | ForEach-Object {
            $mosarr.Add([PSCustomObject]@{
                facility_identifier = $_.Hospital
                stay_number = "XXXXXXXX"
                episode_sequence_number = "0"
                ed_identifier = "XXXXXXXX"
                SNAP_encounter = "XXXX_XXXXXXXX"
                ReasonForExclusion = "Mode of Sep 99 Administrative Error - From OMEN"
                EncounterNumber = $_.EncounterNumber })
        }

            $mosarr | Export-Csv -Path ($Global:qualDest+"tbl_ExcludedEncounters.csv") -Append -NoTypeInformation -Force

       <#  foreach ($los in $src) {
    
            if ($los.EndDateTime -lt $los.StartDateTime) {
    
                    $format = "yyyy-MM-dd HH:mm:ss"
    
                    $los.StartDateTime = $los."Extra:EDTriageDateTime"
                    $los.LengthofStay = (New-TimeSpan -Start (Get-Date -Date $los.StartDateTime -Format $format) -End (Get-Date -Date $los.EndDateTime -Format $format)).Minutes
            }
        } #>

        if ($losOut -eq $null) {
        Write-Output "There are no Negative durations"
        }

        else {
            $losOut | Foreach-Object {
                $arr3.Add([PSCustomObject]@{
                    EncounterNumber = $_.EncounterNumber
                    PatientNumber = $_.PatientNumber
                    LengthofStay = $_.LengthofStay
                    StartDateTime = $_.StartDateTime
                    EndDateTime = $_.EndDateTime })
        }
        
        $arr3 | Export-Csv -Path ($Global:qualDest+"negativedurations.csv") -NoTypeInformation -Force | Out-Null
        Write-Output "Check Negative Durations File for Length of Stay errors (ED Encounter File)"
        }

        if (!(Test-Path ($Global:qualDest+"negativedurations.csv"))) {
            ("" | Select-Object 'EncounterNumber','PatientNumber','LengthofStay','StartDateTime','EndDateTime' | Export-Csv ($Global:qualDest+"negativedurations.csv") -NoTypeInformation -Force | Out-Null)
        }

        $src | Export-Csv -path $dest -NoTypeInformation -Force
    
    }

    function Set-Encounter {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]$dest,
        [parameter(Mandatory=$true)]$src
        )

        $f = "yyyy-MM-dd HH:mm:ss"
        $encneg = [System.Collections.Generic.List[object]]::new()
        $encarr3 = [System.Collections.Generic.List[object]]::new()
        $encArr = [System.Collections.Generic.List[object]]::new()
        $encArr2 = [System.Collections.Generic.List[object]]::new()
		#Ranjit - commented  below lines - start
        #$sdt = "2022-07-01 00:00:00"
        #$edt = "2023-03-31 23:59:59"
		#Ranjit - commented  below lines - stop
        foreach ($dt in $src) {

            if ($dt.StartDateTime -ne "") {
                $dt.startdatetime = Get-Date($dt.startdatetime) -Format $f
            }

            if ($dt.EndDateTime -ne "") {
                $dt.enddatetime = Get-Date($dt.enddatetime) -Format $f
            }

            if ((Get-Date $dt.StartDateTime -Format $f) -lt (Get-Date $Global:sdt -Format $f)) {
                $nsdt = $Global:sdt
            }

            else {
                $nsdt = $dt.StartDateTime
            }

            if ((Get-Date $dt.EndDateTime -Format $f) -gt (Get-Date $Global:edt -Format $f)) {
                $nedt = $Global:edt
            }

            else {
                $nedt = $dt.EndDateTime
            }

            $templosincp = (New-TimeSpan -Start $nsdt -End $nedt).TotalDays
            $losincp = [Math]::Round($templosincp,0)

            if ($losincp -eq 0) {
                $losincp = 1
            }

            $dt."Extra:LOSinCostingPeriod" = $losincp

        }

        if ("Extra:VersionID" -in ($src | Get-Member -MemberType NoteProperty).Name) {

            foreach ($vID in $src) {
                $vID."Extra:VersionID" = $Global:Round#"27.75"
            }

        }

        if (($Global:encfile)."Extra:LHDIdentifier" -match "x830" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x840" -OR ($Global:encfile)."Extra:LHDIdentifier" -match "x850") {

            foreach ($pat in $src) {
                $pat.PatientNumber = ($pat.PatientNumber[-7..-1] -join '')
            }
        }

        foreach ($ls in $src) {
    
            if ($ls.EndDateTime -lt $ls.StartDateTime) {
                $encneg.Add($ls)
            }
        }

        if ($encneg -ne $null) {

            $encneg | Foreach-Object {
                    $encarr3.Add([PSCustomObject]@{
                        EncounterNumber = $_.EncounterNumber
                        PatientNumber = $_.PatientNumber
                        LengthofStay = $_.LengthofStay
                        StartDateTime = $_.StartDateTime
                        EndDateTime = $_.EndDateTime })
            }
            
            $encarr3 | Export-Csv -Path ($Global:qualDest+"negativedurations.csv") -Append -NoTypeInformation -Force
            Write-Output "Check Negative Durations File for Length of Stay errors (IP Encounter File)"

        }

        $lhd = @("x170","x630","x700","x690","x710","x760","x770","x800","x810","x820")

        if (!($lhd -contains ($Global:encfile)."Extra:LHDIdentifier")) {

        foreach ($et in $src) {
            if ($et.EncounterType -like "X") {
                $encArr.Add($et)
            }
        }
    
            $encArr | ForEach-Object {
                $encArr2.Add([pscustomobject]@{
                    encounternumber = $_.EncounterNumber
                    encountertype = $_.encountertype
                    patientnumber = $_.patientnumber
                    startdatetime = $_.startdatetime
                    enddatetime = $_.enddatetime
                    'extra:mothersmrn' = $_.'extra:mothersmrn'
                    'extra:mothersstaynumber' = $_.'extra:mothersstaynumber'
                    'extra:mothersencounternumber' = $_.'extra:mothersencounternumber'
                    hospital = $_.hospital
                })
            }
    
            $encArr2 | Export-Csv -Path ($Global:workDest+"xencounters.csv") -NoTypeInformation -Force 
        }
            $src | Export-Csv -Path $dest -NoTypeInformation -Force
        }
    
   # Import Hash Table for location and file variables
    
    $Quality = @{
        File1 = 'QualityChecks_AgeAbove105.csv'
        File2 = 'QualityChecks_EdAgeMoreThan105.csv'
        File3 = 'QualityChecks_EdGt2880.csv'
        File4 = 'QualityChecks_EdGt2880AdmittedTransfer.csv'
        File5 = 'QualityChecks_EdLessThan5Min.csv'
        File6 = 'QualityChecks_GerAgeLess50.csv'
        File7 = 'QualityChecks_IcuHoursGt1000.csv'
        File8 = 'QualityChecks_L61zLess2Hours.csv'
        File9 = 'QualityChecks_LosGrt100.csv'
        File10 = 'QualityChecks_LosLessThan20.csv'
        File11 = 'QualityChecks_SubProgramNotAssigned.csv'
        File12 = 'QualityChecks_Wip3.csv'
        File13 = 'QualityChecks_X_EncounterType_Errors.csv'
        File14 = 'ReconcileEdPatientData.csv'
        File15 = 'ReconcileInpatientData.csv'
        File16 = 'SpecialtyPortalMapping.csv' # To Working Files
    }
    
    $WorkingFiles = @{
            # File1 = 'tbl_PPM_ICD_diagnoses_v25#2.csv'
            # File2 = 'tbl_PPM_ICD_procedures_v25#2.csv' 
            File3 = 'tbl_ExcludedEncounters.csv' 
            File4 = 'tbl_PPM_transfer_AMO.csv' 
            File5 = 'AMHCC_SNAP.txt'
            # Kylie informed that this step is not required anymore
            # File6 = 'DRGWeight.txt'
    }
    
    # Checks to find the correct Drive letter associated with PPM and assigns variables:

    
	#Ranjit - commented below lines - start
	#$vol = (Get-Volume).Driveletter
    #foreach ($v in $vol) {
    #    if (Test-Path -Path ($v+":\PHSData\PPM2\SourceFiles\The Omen\")) {
    #        $spath = $v+":\PHSData\PPM2\SourceFiles\The Omen\"
    #    }
    #}
    #    $srclocation = ($spath+"SourceFiles\Output\")
    #    $Global:loadDest = ($spath+"LoadingFiles\")
    #    $Global:workDest = ($spath+"WorkingFiles\")
    #    $Global:qualDest = ($spath+"QualityChecks\")	
	#Ranjit - commented below lines - stop
	
	
	#Ranjit - added  below lines - start
	$spath = Get-Location
	$spath = [string]$spath
	$opfile = "\SourceFiles\Output\"
	$loadfile = "\LoadingFiles\"
	$workfile = "\WorkingFiles\"
	$qcfile = "\QualityChecks\"
	$srclocation = $spath+$opfile
	$Global:loadDest = $spath+$loadfile
	$Global:workDest = $spath+$workfile
	$Global:qualDest = $spath+$qcfile
	Write-Output "In omen.ps1, round=$Global:Round, start date=$Global:sdt, end date=$Global:edt, path=$spath, Source location=$srclocation, Loading Files loation=$Global:loadDest, Working Files location=$Global:workDest, QC files location=$Global:qualDest"
	#Ranjit - added below lines - stop
	
	 
	
	
	# Get-ChildItem = Listing the Contents of a Directory
    Set-Location $srclocation
    Write-Output "Importing IP Patient File"
    # Ranjit
    #$Global:patfile = Import-Csv -Path ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppmpatient' }).Name)
	$ppmpatientfile = $srclocation+"tbl_PPM_Patient_V"+$Global:Round_hash+".csv"
	$Global:patfile = Import-Csv -Path $ppmpatientfile
	
    Write-Output "Importing Transfer File"
    # Ranjit
    #$Global:transfile = Import-Csv -Path ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_transfer_v' }).Name)
	$ppmtransferfile = $srclocation+"tbl_PPM_Transfer_V"+$Global:Round_hash+".csv"
	$Global:transfile = Import-Csv -Path $ppmtransferfile
	
    Write-Output "Importing IP Encounter File"
    # Ranjit
    #$Global:encfile = Import-Csv -Path ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_encounter_v' }).Name)
	$ppmencounterfile = $srclocation+"tbl_PPM_Encounter_V"+$Global:Round_und+".csv"
	$Global:encfile = Import-Csv -Path $ppmencounterfile
	
    Write-Output "Importing ED Encounter File"
    # Ranjit
    #$Global:encedfile = Import-Csv -Path ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_ed_encounter_v' -AND $_.Name -notlike "*EVT*" }).Name)
	$ppmedencounterfile = $srclocation+"tbl_ppm_ED_Encounter_V"+$Global:Round_und+".csv"
	$Global:encedfile = Import-Csv -Path $ppmedencounterfile
		
    Write-Output "Importing EVTL13 File"
    # Ranjit
    #$Global:evtfile = Import-Csv -Path ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_ed_encounter_v' -AND $_.Name -like "*EVT*" }).Name)
	$ppmedencounterevtfile = $srclocation+"tbl_ppm_ED_Encounter_V"+$Global:Round_und+"EVT13.csv"
	$Global:evtfile = Import-Csv -Path $ppmedencounterevtfile
		
    if (Test-Path $Global:loadDest+"tbl_PPM_Encounter.csv") {
    $Global:newencfile = (Import-Csv ($Global:loadDest+"tbl_PPM_Encounter.csv")).encounternumber
    }

    # Counts number of rows in IP and ED Encounter files.

    ((Get-ChildItem $srclocation | Where-Object { ($_ -match 'tbl_ppm_ed_encounter_v' -AND $_.Name -notlike "*EVT*") -OR ($_ -match 'tbl_ppm_encounter_v')}).Name) `
        | ForEach-Object {
            $file = (Get-Content $srclocation$_.) | Measure-Object -Line
            $total = $file.Lines -1

            $("$_ contains - $total total records") | out-file ($Global:loadDest+"EncRecordNums.txt") -Append

        }

    # Counts the number of X and I encounter types in the IP encounter file.

    $encType = "X","I"

    Foreach ($val in $encType) {

        $i = 0
        
        Foreach ($encval in $Global:encfile) {
            if ($encval.EncounterType -like $val) {
                $i ++
            }
        }
        
        $("$Global:encfile contains - $i $val encounters") | out-file ($Global:loadDest+"EncRecordNums.txt") -Append
    }
    
    # Added Try/Catch if the files exist. Do for ED Encounter and IP Encounter add to the same deleteencounterlist.csv file.

    $arr = [System.Collections.Generic.List[object]]::new()
    $arr2 = [System.Collections.Generic.List[object]]::new()

    if (Test-Path ($Global:loadDest+"tbl_PPM_Encounter.csv")) {
        # Ranjit
        Write-Output "tbl_PPM_Encounter.csv already exist in \LoadingFiles\. Comparing it with tbl_PPM_Encounter in \SourceFiles\Output\, to add to deleteencounterlist.csv."
        $hash = @{}
        
        foreach ($b2 in $Global:encfile.encounternumber){
            $hash[$b2] = $b2
        }
        
        foreach ($item in $Global:newencfile.encounternumber) {
            $b2item = $hash[$item]
                if ($item -notcontains $b2item) {$arr.Add($item)}
        
            }
        
        $arr | ForEach-Object {
            $arr2.Add([pscustomobject]@{
                encounternumber = $_ })
            }
        
        $arr2 | Export-Csv -Path ($Global:loadDest+"deleteencounterlist.csv") -NoTypeInformation -Force | Out-Null
    }

    else { 
        Write-Output "tbl_PPM_Encounter.csv has not yet been created, creating a blank deleteencounterlist.csv file anyway"
        ("" | Select-Object 'encounternumber' | Export-Csv ($Global:loadDest+"deleteencounterlist.csv") -NoTypeInformation | Out-Null)
       }

    # Copies files that don't require modification
    
    foreach ($I in ($Quality.GetEnumerator())) { 
        Copy-Item (($srclocation)+($I.value)) -Destination (($Global:qualDest)+($I.value)) -Force -ErrorAction SilentlyContinue
    }
    
    foreach ($O in ($WorkingFiles.GetEnumerator())) { 
        Copy-Item (($srclocation)+($O.value)) -Destination (($Global:workDest)+($O.value)) -Force -ErrorAction SilentlyContinue
    }
    
    # These will be added back into the above foreach loop (Copy) once the renaming issue has been resolved.
    
    Set-Location $srclocation
    Copy-Item ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_icd_diag' }).Name) -Destination ($Global:loadDest+"tbl_PPM_ICD_diagnoses.csv") -force
    Copy-Item ((Get-ChildItem -Path . | Where-Object { $_ -match 'tbl_ppm_icd_proc' }).Name) -Destination ($Global:loadDest+"tbl_PPM_ICD_procedures.csv") -force
    # Copy-Item ((Get-ChildItem -Path . | where { $_ -match 'EVT13' }).Name) -Destination ($Global:workDest+"tbl_PPM_ED_Encounter_EVT13.csv") -force
    #Copy-Item ((Get-ChildItem -Path . | Where-Object { $_ -match '_SUPPLEMENTARY' }).Name) -Destination ($Global:loadDest+"Tbl_PPM_Encounter_SUPPLEMENTARY.csv") -force
    
    # Formats Files based on requirements. Destination names will be modified once the exctractor application is built.

    Write-Output "Performing Transformations on Transfer File"
    Set-Clinic -src $Global:transfile -dest ($Global:loadDest+"tbl_ppm_transfer.csv") 
    Write-Output "Performing Transformations on ED Encounter File"
    Set-LengthOfStay -src $Global:encedfile -dest ($Global:loadDest+"tbl_PPM_ED_Encounter.csv")
    Write-Output "Performing Transformations on IP Patient File"
    Set-PID -src $Global:patfile -dest ($Global:loadDest+"tbl_PPMPatient.csv") -sort unique
    Write-Output "Performing Transformations on IP Encounter File"
    Set-Encounter -src $Global:encfile -dest ($Global:loadDest+"tbl_PPM_Encounter.csv")
    Write-Output "Performing Transformations on EVTL13 File"
    Set-PID -src $Global:evtfile -dest ($Global:workDest+"tbl_PPM_ED_Encounter_EVT13.csv") -sort nounique
	