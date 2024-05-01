#MAM Configuration Script
    #Creates a MAM_PilotGroup policy with no members
    #Creates managed app filters for Unmanaged iOS and Unmanaged Android devices
    #Configures MAM baseline App Protection policies for iOS & Android and assigns to the MAM_PilotGroup group 
    #Creates Conditional Access Policy requiring app protection policy and assigns to the MAM_PilotGroup security group

Write-Host -ForegroundColor DarkYellow "Checking for log directory C:\temp for transcript"
$LogPath = "C:\Temp"
$LogPathExists = Test-Path $LogPath
If ($LogPathExists -ne $True) {
	New-Item -Path "C:\" -Name Temp -ItemType Directory
}

Start-Transcript -Path $LogPath\MAMAutoConfig.log -Force

#Check for and Import Modules:
Write-Host -ForegroundColor DarkYellow "Installing Required Modules if they're missing..."
if (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns) {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Identity.SignIns Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Identity.SignIns Module for Current User"
    Install-Module -Name Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Identity.SignIns Module"
}
if (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.DeviceManagement) {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Beta.DeviceManagement Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Beta.DeviceManagement Module for Current User"
    Install-Module -Name Microsoft.Graph.Beta.DeviceManagement -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Beta.DeviceManagement Module"
}
if (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.Groups) {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Beta.Groups Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Beta.Groups Module for Current User"
    Install-Module -Name Microsoft.Graph.Beta.Groups -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Beta.Groups Module"
}
if (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.Devices.CorporateManagement) {
    Write-Host -ForegroundColor Yellow "Microsoft.Graph.Beta.Devices.CorporateManagement Module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the Microsoft.Graph.Beta.Devices.CorporateManagement Module for Current User"
    Install-Module -Name Microsoft.Graph.Beta.Devices.CorporateManagement -Scope CurrentUser -Force 
    Write-Host "Installed Microsoft.Graph.Beta.Devices.CorporateManagement Module"
}

Write-Host -ForegroundColor DarkYellow "Importing Required Modules..."
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Beta.DeviceManagement
Import-Module Microsoft.Graph.Beta.Groups
Import-Module Microsoft.Graph.Beta.Devices.CorporateManagement

$scopes = "Policy.ReadWrite.ConditionalAccess", "Policy.Read.All", "Application.Read.All", "User.Read.All","Group.ReadWrite.All", "Directory.ReadWrite.All", "DeviceManagementConfiguration.ReadWrite.All", "DeviceManagementApps.ReadWrite.All"

Connect-MgGraph -Scopes $Scopes

#########Create MAM Pilot Security Group#####
Write-Host -ForegroundColor DarkYellow "Creating MAM_PilotGroup Security Group"
Try {
$params = @{
	displayName = "MAM_PilotGroup"
	mailEnabled = $false
	mailNickname = "mampilotgroup"
	securityEnabled = $true
}
New-MgBetaGroup -BodyParameter $params
}
Catch {
    Write-Host -ForegroundColor Red "Error while creating the managed app filter for Unmanaged Android Devices"
    Write-Host -ForegroundColor Red $_
}
$GroupID = Get-MgBetaGroup | Where-Object DisplayName -eq MAM_PilotGroup | Select-Object -ExpandProperty Id

#########Managed App Filters#################
#Managed App Filter - Unmanaged Android Devices
Write-Host -ForegroundColor DarkYellow "Creating Managed App Filter for Unmanaged Android Devices"
Try {
$params = @{
	displayName = "Unmanaged Android Devices"
	description = "Filter for all non-MDM Android devices"
	platform = "AndroidMobileApplicationManagement"
	rule = '(app.deviceManagementType -eq "Unmanaged")'
	roleScopeTags = @(
	)
}
New-MgBetaDeviceManagementAssignmentFilter -BodyParameter $params
}
Catch {
Write-Host -ForegroundColor Red "Error while creating the managed app filter for Unmanaged Android Devices"
Write-Host -ForegroundColor Red $_
}
$androidfilter = Get-MgBetaDeviceManagementAssignmentFilter | Where-Object DisplayName -eq "Unmanaged Android Devices" | Select-Object -expandproperty Id

#Managed App Filter - Unmanaged iOS Devices
Write-Host -ForegroundColor DarkYellow "Creating Managed App Filter for Unmanaged iOS Devices"
Try {
$params = @{
	displayName = "Unmanaged iOS Devices"
	description = "All non-MDM iOS devices"
	platform = "iOSMobileApplicationManagement"
	rule = '(app.deviceManagementType -eq "Unmanaged")'
	roleScopeTags = @(
	)
}
New-MgBetaDeviceManagementAssignmentFilter -BodyParameter $params
}
Catch {
Write-Host -ForegroundColor Red "Error while creating the managed app filter for Unmanaged iOS Devices"
Write-Host -ForegroundColor Red $_
}
$iosfilter = Get-MgBetaDeviceManagementAssignmentFilter | Where-Object DisplayName -eq "Unmanaged iOS Devices" | Select-Object -expandproperty Id

#############################################Android App Protecion Policy###################################################
############################################################################################################################
Write-Host -ForegroundColor DarkYellow "Creating Android App Protection Policy"
Try {
	$params = @{
		allowedDataStorageLocations = "oneDriveForBusiness","sharePoint"
		allowedInboundDataTransferSources = "allApps"
		allowedOutboundClipboardSharingLevel = "managedAppsWithPasteIn"
		allowedOutboundClipboardSharingExceptionLength = "0"
		allowedOutboundDataTransferDestinations = "managedApps"
		contactSyncBlocked = $true
		dataBackupBlocked = $true
		deviceComplianceRequired = $true
		displayName = "Unmanaged Android MAM"
		managedBrowserToOpenLinksRequired = $false
		managedBrowser = "notConfigured"
		maximumPinRetries = "9"
		minimumPinLength = "6"
		previousPinBlockCount = "0"
		notificationRestriction = "allow"
		organizationalCredentialsRequired = $false
		periodOfflineBeforeAccessCheck = "PT720M"
		periodOfflineBeforeWipeIsEnforced = "P90D"
		periodOnlineBeforeAccessCheck = "PT30M"
		pinRequiredInsteadOfBiometric = $true
		pinRequiredInsteadOfBiometricTimeout = "PT30M"
		periodBeforePinResetRequired = $false
		periodBeforePinReset = "P0D"
		pinCharacterSet = "numeric"
		pinRequired = $true
		printBlocked = $false
		saveAsBlocked = $true
		simplePinBlocked = $false
		fingerprintBlocked = $false
		disableAppPinIfDevicePinIsSet = $false
		targetedAppManagementLevels = "unspecified"
		appActionIfDeviceComplianceRequired = "block"
		appActionIfMaximumPinRetriesExceeded = "block"
		blockDataIngestionIntoOrganizationDocuments = $false
		allowedDataIngestionLocations = @(
			"oneDriveForBusiness"
			"sharePoint"
			"camera"
			"photoLibrary"
		)
		dialerRestrictionLevel = "allApps"
		protectedMessagingRedirectAppType = "anyApp"
		blockAfterCompanyPortalUpdateDeferralInDays = "0"
		warnAfterCompanyPortalUpdateDeferralInDays = "0"
		wipeAfterCompanyPortalUpdateDeferralInDays = "0"
		shareWithBrowserVirtualSetting = "anyApp"
		appGroupType = "allMicrosoftApps"
		screenCaptureBlocked = $false
		encryptAppData = $true
		disableAppEncryptionIfDeviceEncryptionIsEnabled = $false
		appActionIfAndroidDeviceManufacturerNotAllowed = "block"
		requiredAndroidSafetyNetDeviceAttestationType = "none"
		appActionIfAndroidSafetyNetDeviceAttestationFailed = "block"
		requiredAndroidSafetyNetAppsVerificationType = "none"
		appActionIfAndroidSafetyNetAppsVerificationFailed = "block"
		requiredAndroidSafetyNetEvaluationType = "basic"
		deviceLockRequired = $false
		appActionIfDeviceLockNotSet = "block"
		keyboardsRestricted = $false
		biometricAuthenticationBlocked = $false
		connectToVpnOnLaunch = $false
		fingerprintAndBiometricEnabled = $true
		requirePinAfterBiometricChange = $false
		requireClass3Biometrics = $false
		maximumAllowedDeviceThreatLevel = "notConfigured"
		mobileThreatDefenseRemediationAction = "block"
		assignments = @(
			@{
				target = @{
					groupId = "$GroupID"
					deviceAndAppManagementAssignmentFilterId = "$androidfilter"
					deviceAndAppManagementAssignmentFilterType = "include"
					"@odata.type" = "#microsoft.graph.groupAssignmentTarget"
				}
			}
		)
	}
	New-MgBetaDeviceAppManagementAndroidManagedAppProtection -BodyParameter $params
	}
	Catch {
		Write-Host -ForegroundColor Red "Error while creating the Android App Protection Policy"
		Write-Host -ForegroundColor Red $_
		}

#############################################iOS App Protecion Policy###################################################
########################################################################################################################
Write-Host -ForegroundColor DarkYellow "Creating iOS App Protection Policy"
Try {
$params = @{
	allowedDataStorageLocations = @(
		"sharePoint"
		"oneDriveForBusiness"
	)
	allowedInboundDataTransferSources = "allApps"
	allowedOutboundClipboardSharingLevel = "managedAppsWithPasteIn"
	allowedOutboundClipboardSharingExceptionLength = 0
	allowedOutboundDataTransferDestinations = "managedApps"
	contactSyncBlocked = $true
	dataBackupBlocked = $true
	description = "App Protection Policy for personally owned iOS devices"
	deviceComplianceRequired = $true
	displayName = "Unmanaged iOS MAM"
	managedBrowserToOpenLinksRequired = $false
	managedBrowser = "notConfigured"
	maximumPinRetries = 9
	minimumPinLength = 6
	previousPinBlockCount = 0
	notificationRestriction = "allow"
	organizationalCredentialsRequired = $false
	periodOfflineBeforeAccessCheck = "PT720M"
	periodOfflineBeforeWipeIsEnforced = "P90D"
	periodOnlineBeforeAccessCheck = "PT30M"
	pinRequiredInsteadOfBiometric = $true
	pinRequiredInsteadOfBiometricTimeout = "PT30M"
	periodBeforePinResetRequired = $false
	periodBeforePinReset = "P0D"
	pinCharacterSet = "numeric"
	pinRequired = $true
	printBlocked = $false
	saveAsBlocked = $true
	simplePinBlocked = $false
	fingerprintBlocked = $false
	disableAppPinIfDevicePinIsSet = $false
	exemptedAppProtocols = @(
		@{
			name = "Default"
			value = "skype;app-settings;calshow;itms;itmss;itms-apps;itms-appss;itms-services;"
		}
	)
	targetedAppManagementLevels = "unspecified"
	appActionIfDeviceComplianceRequired = "block"
	appActionIfMaximumPinRetriesExceeded = "block"
	roleScopeTagIds = @(
	)
	blockDataIngestionIntoOrganizationDocuments = $false
	allowedDataIngestionLocations = @(
		"oneDriveForBusiness"
		"sharePoint"
		"camera"
		"photoLibrary"
	)
	dialerRestrictionLevel = "allApps"
	protectedMessagingRedirectAppType = "anyApp"
	"@odata.type" = "#microsoft.graph.iosManagedAppProtection"
	shareWithBrowserVirtualSetting = "anyApp"
	appGroupType = "allMicrosoftApps"
	disableProtectionOfManagedOutboundOpenInData = $false
	protectInboundDataFromUnknownSources = $false
	appDataEncryptionType = "whenDeviceLocked"
	faceIdBlocked = $false
	appActionIfIosDeviceModelNotAllowed = "block"
	filterOpenInToOnlyManagedApps = $false
	thirdPartyKeyboardsBlocked = $false
	managedUniversalLinks = @(
		"http://*.appsplatform.us/*"
		"http://*.onedrive.com/*"
		"http://*.powerapps.cn/*"
		"http://*.powerapps.com/*"
		"http://*.powerapps.us/*"
		"http://*.powerbi.com/*"
		"http://*.service-now.com/*"
		"http://*.sharepoint-df.com/*"
		"http://*.sharepoint.com/*"
		"http://*.yammer.com/*"
		"http://*.zoom.us/*"
		"http://*collab.apps.mil/l/*"
		"http://*devspaces.skype.com/l/*"
		"http://*teams-fl.microsoft.com/l/*"
		"http://*teams.live.com/l/*"
		"http://*teams.microsoft.com/l/*"
		"http://*teams.microsoft.us/l/*"
		"http://app.powerbi.cn/*"
		"http://app.powerbi.de/*"
		"http://app.powerbigov.us/*"
		"http://msit.microsoftstream.com/video/*"
		"http://tasks.office.com/*"
		"http://to-do.microsoft.com/sharing*"
		"http://web.microsoftstream.com/video/*"
		"http://zoom.us/*"
		"https://*.appsplatform.us/*"
		"https://*.onedrive.com/*"
		"https://*.powerapps.cn/*"
		"https://*.powerapps.com/*"
		"https://*.powerapps.us/*"
		"https://*.powerbi.com/*"
		"https://*.service-now.com/*"
		"https://*.sharepoint-df.com/*"
		"https://*.sharepoint.com/*"
		"https://*.yammer.com/*"
		"https://*.zoom.us/*"
		"https://*collab.apps.mil/l/*"
		"https://*devspaces.skype.com/l/*"
		"https://*teams-fl.microsoft.com/l/*"
		"https://*teams.live.com/l/*"
		"https://*teams.microsoft.com/l/*"
		"https://*teams.microsoft.us/l/*"
		"https://app.powerbi.cn/*"
		"https://app.powerbi.de/*"
		"https://app.powerbigov.us/*"
		"https://msit.microsoftstream.com/video/*"
		"https://tasks.office.com/*"
		"https://to-do.microsoft.com/sharing*"
		"https://web.microsoftstream.com/video/*"
		"https://zoom.us/*"
	)
	exemptedUniversalLinks = @(
		"http://facetime.apple.com"
		"http://maps.apple.com"
		"https://facetime.apple.com"
		"https://maps.apple.com"
	)
	maximumAllowedDeviceThreatLevel = "notConfigured"
	mobileThreatDefenseRemediationAction = "block"
	assignments = @(
		@{
			target = @{
				groupId = $groupID
				deviceAndAppManagementAssignmentFilterId = $iOSFilter
				deviceAndAppManagementAssignmentFilterType = "include"
				"@odata.type" = "#microsoft.graph.groupAssignmentTarget"
			}
		}
	)
}
New-MgBetaDeviceAppManagementiOSManagedAppProtection -BodyParameter $params
}
Catch {
    Write-Host -ForegroundColor Red "Error while creating the iOS App Protection Policy"
    Write-Host -ForegroundColor Red $_
    }
#############################################MAM Conditional Access Policy##############################################
########################################################################################################################
Write-Host -ForegroundColor DarkYellow "Creating Conditional Access Policy for MAM"
Try {
$params = @{
	conditions = @{
		applications = @{
			includeApplications = @(
				"Office365"
			)
			excludeApplications = @(
			)
			includeUserActions = @(
			)
			includeAuthenticationContextClassReferences = @(
			)
			globalSecureAccess = $null
		}
		clients = $null
		users = @{
			includeUsers = @(
			)
			excludeUsers = @(
			)
			includeGroups = @(
				"$GroupID"
			)
			excludeGroups = @(
			)
			includeRoles = @(
			)
			excludeRoles = @(
			)
			includeGuestsOrExternalUsers = $null
			excludeGuestsOrExternalUsers = $null
		}
		clientApplications = $null
		platforms = @{
			includePlatforms = @(
				"android"
				"iOS"
			)
			excludePlatforms = @(
			)
		}
		locations = $null
		userRiskLevels = @(
		)
		signInRiskLevels = @(
		)
		signInRiskDetections = $null
		clientAppTypes = @(
			"all"
		)
		times = $null
		devices = @{
			deviceFilter = @{
				mode = "exclude"
				rule = '(device.deviceOwnership -eq "Company")'
			}
			includeDevices = @(
			)
			excludeDevices = @(
			)
		}
		servicePrincipalRiskLevels = @(
		)
		authenticationFlows = $null
	}
	displayName = "CA09 - Unmanaged iOS/Android MAM"
	grantControls = @{
		operator = "AND"
		builtInControls = @(
			"compliantApplication"
		)
		customAuthenticationFactors = @(
		)
		termsOfUse = @(
		)
		authenticationStrength = $null
	}
	sessionControls = $null
	state = "disabled"
}
New-MgIdentityConditionalAccessPolicy -BodyParameter $params
}
Catch {
    Write-Host -ForegroundColor Red "Error while creating the MAM Conditional Access Policy"
    Write-Host -ForegroundColor Red $_
    }

Disconnect-MgGraph
Stop-Transcript
