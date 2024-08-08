###
### Use this script to create  LTEmployees for CreativeBoyz Employees with out-of-scope names
###

# Input parameters
param (
    $inputFile = "InputEmpData.csv",
    $outputFile = "emp_migrate_data.sql",
    $templateFile = "template.sql"
)

# Console output
Write-Host "start time : $((Get-Date).ToString())"
Write-Host "Input file : $inputFile"
Write-Host "Output file  : $outputFile"
Write-Host "Template file : $templateFile"

# Variables
$existingEmployees = @()
$migrateEmployees = @()
# Loop through each line except for the first line which contains the headers
# list Employees that already exists in LT

$existingEmployees += "PRINT '------------------------------------------------'"
$existingEmployees += "PRINT 'Start checking for existing Employees...'"

$previousCreativeBoyzEmployeeId = ""

foreach ($dataLine in (Get-Content $inputFile | Select-Object -Skip 1)) {
    # Set Employee fields
    $fields = $dataLine.Split(';')
    $name = $fields[0]
    $phoneNumber = $fields[1]
    $address = $fields[2]
    $empId = $fields[3]

    if($address -ne $previousCreativeBoyzEmployeeId){
       Write-Host "Check if employee exists with phoneNumber $phoneNumber, CreativeBoyz EmpId $empId'"
       $existingEmployees += "SELECT 'Employee Exists' AS 'Exists', b.phoneNumber, a.address,  a.EmployeeSubmitDate, a.EmployeeApprovalDate, a.EmployeeStateId 
                            FROM Employee a INNER JOIN Department b ON a.LtEmployeeId = b.LtEmployeeId
                            WHERE b.phoneNumber = $phoneNumber AND a.empId = $empId 
                            AND b.Department = 'DEV'"
    }

    $previousCreativeBoyzEmployeeId = $address
}

$existingEmployees += "PRINT 'Done checking for existing Employees'"

# Loop through each line except for the first line which contains the headers
# Create Employees that do not exist yet.

$EmployeeCount = 0
$previousCreativeBoyzEmployeeId = ""

$migrateEmployees += "DECLARE @count INT"
$migrateEmployees += "PRINT '------------------------------------------------'"
$migrateEmployees += "PRINT 'Start inserting Employees that do not exist already...'" 

foreach ($dataLine in (Get-Content $inputFile | Select-Object -Skip 1)) {
    # Set Employee fields
    $fields = $dataLine.Split(';')
    $name = $fields[0]
    $phoneNumber = $fields[1]
    $address = $fields[2]
    $empId = $fields[3]

    $currentDateTime = Get-Date -Format "yyyyMMdd HH:mm:ss" 

    $EmployeeCount++;

    $newLtEmployeeId = New-Guid

    if($address -ne $previousCreativeBoyzEmployeeId){
       Write-Host "Inserting employee with phoneNumber $phoneNumber, Address $address, Emp id $empId and active 1"

       $insertStatement = "IF NOT EXISTS ( SELECT 1 FROM Employee a INNER JOIN Department b ON a.LtEmployeeId = b.LtEmployeeId
                            WHERE b.phoneNumber = '$phoneNumber' AND a.empId = '$empId' AND b.departmentName = 'DEV') `
           BEGIN `
            PRINT 'Inserting employee with phoneNumber $phoneNumber, business unit Employee id $address, CreativeBoyz scenario id $empId and status 1'`
              
            INSERT Employee (LtEmployeeId, address, EmployeeCreateDate, EmployeeSubmitDate, EmployeeStateId, empId, IsMigratedData) `
            VALUES ('$newLtEmployeeId', '$address', '$currentDateTime', '$currentDateTime', '$CreativeBoyzApprovalDate', 1, '$empId', 1) `

            INSERT Department (LtEmployeeId, departmentName, DepId, Location ) `
            VALUES ('$newLtEmployeeId', 'DEV', 1, 'Bengalore') `

           END"


       $migrateEmployees += $insertStatement
    }

    $previousCreativeBoyzEmployeeId = $address
}

$migrateEmployees += "PRINT 'Done inserting new Employees'"
$migrateEmployees += "PRINT '------------------------------------------------'"
$migrateEmployees += "PRINT 'Total no of employees : $EmployeeCount'"

Write-Host "Total Employees to be migrated : " $EmployeeCount

# Write outputfile
$content = Get-Content -Path $templateFile -Raw
$content = $content -replace '--CHECKEmployees--', ($existingEmployees -join "`n        ")
$content = $content -replace '--COPYEmployees--', ($migrateEmployees -join "`n        ")
$content | Set-Content -Path $outputFile
Write-Host "End time : $((Get-Date).ToString())"

