#Connect to Graph
$scopes = "User.Read.All","Group.ReadWrite.All"
Connect-MgGraph -scopes $scopes
#=================================================================#
#All Intune Licensed Users
$IntuneLicensedUsers = @{
	DisplayName = "Intune Licensed Users"
    Description = "All enabled users licensed for Intune"
    mailNickname = "IntuneLicensedUsers"
	MailEnabled = $false
	SecurityEnabled = $true
	GroupTypes = @(
		"DynamicMembership"
	)
	MembershipRule = 'user.assignedPlans -any (assignedPlan.servicePlanId -eq "c1ec4a95-1f05-45b3-a911-aa3fa01094f5" -and assignedPlan.capabilityStatus -eq "Enabled")'
	MembershipRuleProcessingState = "On"
}
New-MgGroup -BodyParameter $IntuneLicensedUsers
#=================================================================#
#All Windows Corporate Devices
$WindowsDevices = @{
	DisplayName = "All Windows Corporate Devices"
    Description = "All company owned Windows Devices"
    mailNickname = "wincorporate"
	MailEnabled = $false
	SecurityEnabled = $true
	GroupTypes = @(
		"DynamicMembership"
	)
	MembershipRule = '(device.deviceOwnership -eq "Company") and (device.deviceOSType -contains "Windows")'
	MembershipRuleProcessingState = "On"
}
New-MgGroup -BodyParameter $WindowsDevices
#=================================================================#
#All iOS Devices
$iOSDevices = @{
	DisplayName = "All iOS Devices"
    Description = "All iOS devices"
    mailNickname = "iosdevices"
	MailEnabled = $false
	SecurityEnabled = $true
	GroupTypes = @(
		"DynamicMembership"
	)
	MembershipRule = '(device.deviceOSType -contains "iPhone") or (device.deviceOSType -contains "iPad")'
	MembershipRuleProcessingState = "On"
}
New-MgGroup -BodyParameter $iOSDevices
#=================================================================#
#All Android Devices
$androiddevices = @{
	DisplayName = "All Android devices"
    Description = "All Android Devices"
    mailNickname = "androiddevices"
	MailEnabled = $false
	SecurityEnabled = $true
	GroupTypes = @(
		"DynamicMembership"
	)
	MembershipRule = '(device.deviceOSType -contains "android")'
	MembershipRuleProcessingState = "On"
}
New-MgGroup -BodyParameter $androiddevices
#=================================================================#
#Autopilot Group Tag
$autopilotgrouptag = @{
	DisplayName = "Autopilot Grouptag"
    Description = "All devices with the grouptag Autopilot"
    mailNickname = "autopilotdynamic"
	MailEnabled = $false
	SecurityEnabled = $true
	GroupTypes = @(
		"DynamicMembership"
	)
	MembershipRule = '(device.devicePhysicalIds -any _ -eq "[OrderID]:Autopilot")'
	MembershipRuleProcessingState = "On"
}
New-MgGroup -BodyParameter $autopilotgrouptag
#=================================================================#
Disconnect-MgGraph
