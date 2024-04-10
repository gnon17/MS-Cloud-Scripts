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
	name = "Block Browsers Internet"
	description = ""
	settings = @(
		@{
			"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
			settingInstance = @{
				"@odata.type" = "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance"
				groupSettingCollectionValue = @(
					@{
						children = @(
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "Block Chrome Internet"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_0"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance"
								choiceSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
										children = @(
										)
										value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_all"
									}
								)
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "C:\Program Files\Google\Chrome\Application\chrome.exe"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_localaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
									value = '6'
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "80"
									}
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "443"
									}
								)
							}
						)
					}
					@{
						children = @(
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "Block Brave Internet"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_0"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance"
								choiceSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
										children = @(
										)
										value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_all"
									}
								)
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_localaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
									value = '6'
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "80"
									}
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "443"
									}
								)
							}
						)
					}
					@{
						children = @(
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "Block Internet Explorer Internet"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_0"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance"
								choiceSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
										children = @(
										)
										value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_all"
									}
								)
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "C:\Program Files\Internet Explorer\iexplorer.exe"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "80"
									}
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "443"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_localaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
									value = '6'
								}
							}
						)
					}
					@{
						children = @(
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "Block Edge Internet"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_0"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance"
								choiceSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
										children = @(
										)
										value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_all"
									}
								)
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "80"
									}
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "443"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_localaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
									value = '6'
								}
							}
						)
					}
					@{
						children = @(
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "Block Firefox Internet"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_0"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
								choiceSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
									children = @(
									)
									value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1"
								}
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance"
								choiceSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
										children = @(
										)
										value = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_all"
									}
								)
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes"
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
									value = "C:\Program Files\Mozilla Firefox\firefox.exe"
								}
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "80"
									}
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "443"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_localaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteaddressranges"
								simpleSettingCollectionValue = @(
									@{
										"@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
										value = "*"
									}
								)
							}
							@{
								"@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
								settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol"
								simpleSettingValue = @{
									"@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
									value = '6'
								}
							}
						)
					}
				)
				settingInstanceTemplateReference = @{
					settingInstanceTemplateId = "76c7a8be-67d2-44bf-81a5-38c94926b1a1"
				}
				settingDefinitionId = "vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}"
			}
		}
	)
	roleScopeTagIds = @(
		"0"
	)
	platforms = "windows10"
	technologies = "mdm,microsoftSense"
	templateReference = @{
		templateId = "19c8aa67-f286-4861-9aa0-f23541d31680_1"
	}
}
Try {
Connect-MgGraph
New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $params
}
Catch {
Write-Host -ForegroundColor Red $_
}
Disconnect-MgGraph