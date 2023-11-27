#Getting SO
$BIF023 = [AdvancedUtility.Services.BusinessObjects.ServiceOrder]::GetByServiceOrder($CisSession, $this.Input.Detail.HostOrderNumber)
$SOStatus=$BIF023.IsCompleted
$SOType=$this.Input.Detail.WorkTypeDone
$customer=$BIF023.Customer
$account=$BIF023.Account
$OldReading=$this.Input.Detail.FoundMeterReadingHi

$OldMeterNumber=$this.Input.Detail.FoundMeterNumber

$OldRemote=$this.Input.Detail.FoundRaidioId

$NewMeterNumber=$this.Input.Detail.NewMeterNumber
#Service Information
$ServGroup=[AdvancedUtility.Services.BusinessObjects.AccountServiceGroup]::GetByCustomerAccountService($CisSession,$customer,$account,'30')
$ServAcc=[AdvancedUtility.Services.BusinessObjects.AccountService]::GetByCustomerAccountService($CisSession,$customer,$account,'30')

if($SOStatus===$true){
    if($SOType -eq "S096"){
        # Old Meter Information
$BIF005Where = "d_DateRemoved is Null AND c_Meter = {0}" 
$BIF005 = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::GetByMeter($CisSession,$OldMeterNumber)
$BIF005R = [AdvancedUtility.Services.BusinessObjects.AccountMeterReadType]::GetByMeterId($CisSession,$BIF005.MeterId)


# New Meter Information for Change
$BIF005N=$BIF005.CreateMeterForAChange($true)
$BIF005N.Account=$BIF005.Account
$BIF005N.Meter=$this.Input.Detail.NewMeterNumber
$BIF005N.PopulateNewMeterReadings($BIF005,$ServGroup,$ServAcc)
$BIF005N.Latitude=$this.Input.Detail.Latitude
$BIF005N.Longitude=$this.Input.Detail.Longitude
$BIF005N.RemoteId=$this.Input.Detail.NewRadioIDhigh

# Create a new MeterChangeParameters object
$metParams = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+MeterChangeParameters"

# Set parameters for the meter change operation
$metParams.ActionType = "C"
$date=$this.Input.Detail.FinalCompletionDate
$time=$this.Input.Detail.FinalCompletiontime
$metParams.ChangeDate= [DateTime]::ParseExact("$date $time", 'M/d/yyyy H:mm', $null).ToString('MM/dd/yyyy hh:mm:ss tt')
$metParams.ExistingMeter = $BIF005
$metParams.ExistingMeterId = $BIF005.MeterId
$metParams.NewMeter = $BIF005N
$metParams.RemovedMeterInventoryStatus = "IN"
$metParams.RemovedMeterInventoryLocation = $BIF005.MeterInventory_Lookup.Location

$metParams.UpdateInventory=$true

# Create a new MeterInventoryInfo object
$mInv = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+MeterInventoryInfo"
$mInv.MeterType = $BIF005.MeterInventory_Lookup.MeterType
$mInv.SerialNumber = $BIF005.MeterInventory_Lookup.SerialNumber
$mInv.Status = $BIF005.MeterInventory_Lookup.Status

$metParams.MeterInventoryInfo = $mInv

# Create a RemoveMeterChangeInfo object
$ChangeInfo = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+RemoveMeterChangeInfo"
$ChangeInfo.ReadTypeId = $BIF005R.ReadTypeId
$ChangeInfo.RemoveReading = $OldReading
$metParams.RemoveMeterChangeInfo=$ChangeInfo

try{
# Perform the meter change operation
$meterOp = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::DoMeterAction($CisSession, $metParams)


# Return the result
return  $meterOp.fb[0]
    
}catch{

throw $_
}
    }elseif($SOType -eq "S027"){

$BIF005 = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::GetByMeter($CisSession,$OldMeterNumber)

$type =[AdvancedUtility.Services.BusinessObjects.RemoteType]::GetByCode($CisSession,'78')

$BIF005.MeterChangeType = 'Edit' 

$BIF005.SetRemoteType($type,$true)

$BIF005.Save($false,$false)

return $BIF005.RemoteType


    }elseif($SOType -eq "S180"){

   
#Service Information

        
        # New Meter Information
        $BIF005N=[AdvancedUtility.Services.BusinessObjects.AccountMeter]::{New}($CisSession)
        $BIF005N.Account=$account
        $BIF005N.Meter=$NewMeterNumber
        $BIF005N.PopulateNewMeterReadings($null,$ServGroup,$ServAcc)
        $accountMterReadType = $BIF005N.AddedReadTypes[0]
        $accountMterReadType.Dials = $this.Input.Detail.NewDialsHigh
        $accountMterReadType.CallNumber = '0'
        $BIF005N.PopulateNewMeterReadings($BIF005,$ServGroup,$ServAcc)
        $BIF005N.Latitude=$this.Input.Detail.Latitude
        $BIF005N.Longitude=$this.Input.Detail.Longitude
        $BIF005N.RemoteId=$this.Input.Detail.NewRadioIDhigh

        # Set parameters for the meter change operation
        $metParams = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+MeterChangeParameters"
        $metParams.ActionType = "A"
        $metParams.NewMeter = $BIF005N
         
        $metParams.UpdateInventory=$true
        $meterOp = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::DoMeterAction($CisSession, $metParams)
        
        # Return the result
        try{
            # Perform the meter change operation
            $meterOp = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::DoMeterAction($CisSession, $metParams)
            
            
            # Return the result
            return  $meterOp.fb[0]
                
            }catch{
            
            throw $error
            
            }

        
    }



}




# # Old Meter Information
# $BIF005Where = "d_DateRemoved is Null AND c_Meter = {0}" 
# $BIF005 = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::GetByMeter($CisSession,$OldMeterNumber)
# $BIF005R = [AdvancedUtility.Services.BusinessObjects.AccountMeterReadType]::GetByMeterId($CisSession,$BIF005.MeterId)

# #Service Information
# $ServGroup=[AdvancedUtility.Services.BusinessObjects.AccountServiceGroup]::GetByCustomerAccountService($CisSession,$customer,$account,'30')
# $ServAcc=[AdvancedUtility.Services.BusinessObjects.AccountService]::GetByCustomerAccountService($CisSession,$customer,$account,'30')

# # New Meter Information for Change
# $BIF005N=$BIF005.CreateMeterForAChange($true)
# $BIF005N.Account=$BIF005.Account
# $BIF005N.Meter=$this.Input.Detail.NewMeterNumber
# $BIF005N.PopulateNewMeterReadings($BIF005,$ServGroup,$ServAcc)
# $BIF005N.Latitude=$this.Input.Detail.Latitude
# $BIF005N.Longitude=$this.Input.Detail.Longitude
# $BIF005N.RemoteId=$this.Input.Detail.NewRadioIDhigh

# # Create a new MeterChangeParameters object
# $metParams = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+MeterChangeParameters"

# # Set parameters for the meter change operation
# $metParams.ActionType = "C"
# $date=$this.Input.Detail.FinalCompletionDate
# $time=$this.Input.Detail.FinalCompletiontime
# $metParams.ChangeDate= [DateTime]::ParseExact("$date $time", 'M/d/yyyy H:mm', $null).ToString('MM/dd/yyyy hh:mm:ss tt')
# $metParams.ExistingMeter = $BIF005
# $metParams.ExistingMeterId = $BIF005.MeterId
# $metParams.NewMeter = $BIF005N
# $metParams.RemovedMeterInventoryStatus = "IN"
# $metParams.RemovedMeterInventoryLocation = $BIF005.MeterInventory_Lookup.Location

# $metParams.UpdateInventory=$true

# # Create a new MeterInventoryInfo object
# $mInv = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+MeterInventoryInfo"
# $mInv.MeterType = $BIF005.MeterInventory_Lookup.MeterType
# $mInv.SerialNumber = $BIF005.MeterInventory_Lookup.SerialNumber
# $mInv.Status = $BIF005.MeterInventory_Lookup.Status

# $metParams.MeterInventoryInfo = $mInv

# # Create a RemoveMeterChangeInfo object
# $ChangeInfo = New-Object "AdvancedUtility.Services.BusinessObjects.AccountMeter+RemoveMeterChangeInfo"
# $ChangeInfo.ReadTypeId = $BIF005R.ReadTypeId
# $ChangeInfo.RemoveReading = $OldReading
# $metParams.RemoveMeterChangeInfo=$ChangeInfo

# try{
# # Perform the meter change operation
# $meterOp = [AdvancedUtility.Services.BusinessObjects.AccountMeter]::DoMeterAction($CisSession, $metParams)


# # Return the result
# return  $meterOp.fb[0]
    
# }catch(error){

# throw error

# }
