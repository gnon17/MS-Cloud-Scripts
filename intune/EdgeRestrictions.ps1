$modules = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Beta.DeviceManagement'
Foreach ($module in $modules) {
Try {
if (Get-Module -ListAvailable -Name $module) {
    Write-Host -ForegroundColor Yellow "$module module is already installed"
} 
else {
    Write-Host -ForegroundColor Yellow "Installing the $module Module for Current User"
    Install-Module -Name $module -Scope CurrentUser -Force 
    Write-Host "Installed $module module for current user"
}
}
Catch {
Write-Host -ForegroundColor Red $_
}
}

$params = @{
	name = "Restrict Edge Sites"
	description = "Restricts Edge to only outlook.microsoft.com"
	platforms = "windows10"
	technologies = "mdm"
	roleScopeTagIds = @(
		"0"
	)
	settings = @(
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
				settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlblocklist"
				choiceSettingValue = @{
					"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
					value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlblocklist_1"
					children = @(
						@{
							"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
							settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlblocklist_urlblocklistdesc"
							simpleSettingCollectionValue = @(
								@{
									value = "*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
							)
						}
					)
				}
			}
		}
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
				settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlallowlist"
				choiceSettingValue = @{
					"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
					value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlallowlist_1"
					children = @(
						@{
							"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
							settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge_urlallowlist_urlallowlistdesc"
							simpleSettingCollectionValue = @(
								@{
									value = "edge://*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://outlook.office365.com/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://outlook.office365.com/"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://login.microsoftonline.com/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://login.microsoftonline.com/"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://www.microsoft365.com/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://www.microsoft365.com/"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://nam.safelink.emails.azure.net/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "file:///C:/Users/kioskUser0/Downloads/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://outlook.office.com/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "File://*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://outlook.office.com/"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://outlook*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://attachments.office.net"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
								@{
									value = "https://attachments.office.net/*"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
							)
						}
					)
				}
			}
		}
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
				settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edgev80diff~policy~microsoft_edge_hidefirstrunexperience"
				choiceSettingValue = @{
					"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
					value = "device_vendor_msft_policy_config_microsoft_edgev80diff~policy~microsoft_edge_hidefirstrunexperience_1"
					children = @(
					)
				}
			}
		}
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
				settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup"
				choiceSettingValue = @{
					"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
					value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_1"
					children = @(
						@{
							"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
							settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_restoreonstartup"
							choiceSettingValue = @{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
								value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_restoreonstartup_4"
								children = @(
								)
							}
						}
					)
				}
			}
		}
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
				settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls"
				choiceSettingValue = @{
					"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
					value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls_1"
					children = @(
						@{
							"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
							settingDefinitionId = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls_restoreonstartupurlsdesc"
							simpleSettingCollectionValue = @(
								@{
									value = "https://outlook.office365.com/"
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
								}
							)
						}
					)
				}
			}
		}
	)
}
Try {
Connect-MgGraph
New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $params
}
Catch {
Write-Host -ForegroundColor Red $_
}
Disconnect-MgGraph