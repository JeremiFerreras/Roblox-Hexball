# Analiza la carpeta Codex del 17

> Analiza todo el contexto que puedas de la carpeta y si quieres conectate al mcp de roblox, usa la carpeta codex del 17

<details><summary>4 previous messages</summary>

> Voy a revisar la carpeta del 17 para encontrar el proyecto, sus instrucciones y archivos relevantes; después consultaré Roblox Studio si el contexto indica que está conectado y aporta información útil.
>
> <details><summary>Ran 2 commands, called 5 tools</summary>
>
> - Ran `Get-ChildItem -Force | Select-Object Mode,Length,LastWriteTime,Name; rg --files -g AGENTS.md -g '*.md' -g '*.lua' -g '*.luau' -g '*.rbxl' -g '*.rbxlx' -g '*.json' -g '*.toml' -g '*.txt' | Select-Object -First 200`
>
> - Ran `Get-Content README.md; Get-Content default.project.json; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\HAXBALL_PROJECT_CONTEXT.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_FINAL_GO_NO_GO.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_NEXT_DECISION.md; git status --short; rg --files src`
>
> MCP tool call
>
> Roblox_Studio.list_roblox_studios
>
> ```json
> {}
> ```
>
> ```text
> {"studios":[{"id":"3e731d6a-4da2-40c5-a4e1-74d65208d2b0","mode":"Edit","name":"Football, hexball (placeId: 85137916104328)","persistedToCloud":true,"placeId":85137916104328,"state":"- Current Studio Mode: Edit\n- Available DataModels: Edit\n- Focused DataModel in the viewport: Edit","universeId":10777655598}]}
> ```
>
> MCP tool call
>
> Roblox_Studio.get_studio_state
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0"
> }
> ```
>
> ```text
> - Current Studio Mode: Edit
> - Available DataModels: Edit
> - Focused DataModel in the viewport: Edit
> ```
>
> MCP tool call
>
> Roblox_Studio.search_game_tree
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "datamodel_type": "Edit",
>   "max_depth": 5
> }
> ```
>
> ```text
> Note: Output limited to 200 nodes (results truncated)
>
> [{"fullPath":"Football, hexball","name":"Football, hexball","className":"DataModel"},{"parentName":"Football, hexball","fullPath":"Workspace","name":"Workspace","className":"Workspace"},{"parentName":"Football, hexball","fullPath":"Run Service","name":"Run Service","className":"RunService"},{"parentName":"Football, hexball","fullPath":"GuiService","name":"GuiService","className":"GuiService"},{"parentName":"Football, hexball","fullPath":"Stats","name":"Stats","className":"Stats"},{"parentName":"Football, hexball","fullPath":"Instance","name":"Instance","className":"TimerService"},{"parentName":"Football, hexball","fullPath":"CollectionService","name":"CollectionService","className":"CollectionService"},{"parentName":"Football, hexball","fullPath":"SoundService","name":"SoundService","className":"SoundService"},{"parentName":"Football, hexball","fullPath":"VideoCaptureService","name":"VideoCaptureService","className":"VideoCaptureService"},{"parentName":"Football, hexball","fullPath":"LogService","name":"LogService","className":"LogService"},{"parentName":"Football, hexball","fullPath":"MicroProfilerService","name":"MicroProfilerService","className":"MicroProfilerService"},{"parentName":"Football, hexball","fullPath":"ContentProvider","name":"ContentProvider","className":"ContentProvider"},{"parentName":"Football, hexball","fullPath":"KeyframeSequenceProvider","name":"KeyframeSequenceProvider","className":"KeyframeSequenceProvider"},{"parentName":"Football, hexball","fullPath":"AnimationClipProvider","name":"AnimationClipProvider","className":"AnimationClipProvider"},{"parentName":"Football, hexball","fullPath":"Chat","name":"Chat","className":"Chat"},{"parentName":"Football, hexball","fullPath":"MarketplaceService","name":"MarketplaceService","className":"MarketplaceService"},{"parentName":"Football, hexball","fullPath":"Players","name":"Players","className":"Players"},{"parentName":"Football, hexball","fullPath":"PointsService","name":"PointsService","className":"PointsService"},{"parentName":"Football, hexball","fullPath":"NotificationService","name":"NotificationService","className":"NotificationService"},{"parentName":"Football, hexball","fullPath":"ReplicatedFirst","name":"ReplicatedFirst","className":"ReplicatedFirst"},{"parentName":"Football, hexball","fullPath":"HttpRbxApiService","name":"HttpRbxApiService","className":"HttpRbxApiService"},{"parentName":"Football, hexball","fullPath":"TweenService","name":"TweenService","className":"TweenService"},{"parentName":"Football, hexball","fullPath":"MaterialService","name":"MaterialService","className":"MaterialService"},{"parentName":"Football, hexball","fullPath":"TextChatService","name":"TextChatService","className":"TextChatService"},{"parentName":"Football, hexball","fullPath":"TextService","name":"TextService","className":"TextService"},{"parentName":"Football, hexball","fullPath":"PermissionsService","name":"PermissionsService","className":"PermissionsService"},{"parentName":"Football, hexball","fullPath":"PlayerEmulatorService","name":"PlayerEmulatorService","className":"PlayerEmulatorService"},{"parentName":"Football, hexball","fullPath":"CorePackages","name":"CorePackages","className":"CorePackages"},{"parentName":"Football, hexball","fullPath":"StudioData","name":"StudioData","className":"StudioData"},{"parentName":"Football, hexball","fullPath":"SharedTableRegistry","name":"SharedTableRegistry","className":"SharedTableRegistry"},{"parentName":"Football, hexball","fullPath":"StarterPlayer","name":"StarterPlayer","className":"StarterPlayer"},{"parentName":"Football, hexball","fullPath":"StarterPack","name":"StarterPack","className":"StarterPack"},{"parentName":"Football, hexball","fullPath":"StarterGui","name":"StarterGui","className":"StarterGui"},{"parentName":"Football, hexball","fullPath":"LocalizationService","name":"LocalizationService","className":"LocalizationService"},{"parentName":"Football, hexball","fullPath":"PolicyService","name":"PolicyService","className":"PolicyService"},{"parentName":"Football, hexball","fullPath":"Teleport Service","name":"Teleport Service","className":"TeleportService"},{"parentName":"Football, hexball","fullPath":"JointsService","name":"JointsService","className":"JointsService"},{"parentName":"Football, hexball","fullPath":"PhysicsService","name":"PhysicsService","className":"PhysicsService"},{"parentName":"Football, hexball","fullPath":"BadgeService","name":"BadgeService","className":"BadgeService"},{"parentName":"Football, hexball","fullPath":"FriendService","name":"FriendService","className":"FriendService"},{"parentName":"Football, hexball","fullPath":"InsertService","name":"InsertService","className":"InsertService"},{"parentName":"Football, hexball","fullPath":"GamePassService","name":"GamePassService","className":"GamePassService"},{"parentName":"Football, hexball","fullPath":"Debris","name":"Debris","className":"Debris"},{"parentName":"Football, hexball","fullPath":"CookiesService","name":"CookiesService","className":"CookiesService"},{"parentName":"Football, hexball","fullPath":"Selection","name":"Selection","className":"Selection"},{"parentName":"Football, hexball","fullPath":"UserInputService","name":"UserInputService","className":"UserInputService"},{"parentName":"Football, hexball","fullPath":"KeyboardService","name":"KeyboardService","className":"KeyboardService"},{"parentName":"Football, hexball","fullPath":"MouseService","name":"MouseService","className":"MouseService"},{"parentName":"Football, hexball","fullPath":"VRService","name":"VRService","className":"VRService"},{"parentName":"Football, hexball","fullPath":"ContextActionService","name":"ContextActionService","className":"ContextActionService"},{"parentName":"Football, hexball","fullPath":"Instance","name":"Instance","className":"ScriptService"},{"parentName":"Football, hexball","fullPath":"AssetService","name":"AssetService","className":"AssetService"},{"parentName":"Football, hexball","fullPath":"TouchInputService","name":"TouchInputService","className":"TouchInputService"},{"parentName":"Football, hexball","fullPath":"BrowserService","name":"BrowserService","className":"BrowserService"},{"parentName":"Football, hexball","fullPath":"CaptureService","name":"CaptureService","className":"CaptureService"},{"parentName":"Football, hexball","fullPath":"AppStorageService","name":"AppStorageService","className":"AppStorageService"},{"parentName":"Football, hexball","fullPath":"AnalyticsService","name":"AnalyticsService","className":"AnalyticsService"},{"parentName":"Football, hexball","fullPath":"HeatmapService","name":"HeatmapService","className":"HeatmapService"},{"parentName":"Football, hexball","fullPath":"AvatarSettings","name":"AvatarSettings","className":"AvatarSettings"},{"parentName":"Football, hexball","fullPath":"SlimContentProvider","name":"SlimContentProvider","className":"SlimContentProvider"},{"parentName":"Football, hexball","fullPath":"Packages","name":"Packages","className":"Packages"},{"parentName":"Football, hexball","fullPath":"GuidRegistryService","name":"GuidRegistryService","className":"GuidRegistryService"},{"parentName":"Football, hexball","fullPath":"PublishService","name":"PublishService","className":"PublishService"},{"parentName":"Football, hexball","fullPath":"ChangeHistoryService","name":"ChangeHistoryService","className":"ChangeHistoryService"},{"parentName":"Football, hexball","fullPath":"LuaWebService","name":"LuaWebService","className":"LuaWebService"},{"parentName":"Football, hexball","fullPath":"ProcessInstancePhysicsService","name":"ProcessInstancePhysicsService","className":"ProcessInstancePhysicsService"},{"parentName":"Football, hexball","fullPath":"ReplicatedStorage","name":"ReplicatedStorage","className":"ReplicatedStorage"},{"parentName":"Football, hexball","fullPath":"ServerScriptService","name":"ServerScriptService","className":"ServerScriptService"},{"parentName":"Football, hexball","fullPath":"ServerStorage","name":"ServerStorage","className":"ServerStorage"},{"parentName":"Football, hexball","fullPath":"StudioService","name":"StudioService","className":"StudioService"},{"parentName":"Football, hexball","fullPath":"ScriptRegistrationService","name":"ScriptRegistrationService","className":"ScriptRegistrationService"},{"parentName":"Football, hexball","fullPath":"StudioDeviceEmulatorService","name":"StudioDeviceEmulatorService","className":"StudioDeviceEmulatorService"},{"parentName":"Football, hexball","fullPath":"StudioDeviceSimulatorService","name":"StudioDeviceSimulatorService","className":"StudioDeviceSimulatorService"},{"parentName":"Football, hexball","fullPath":"ExplorerServiceVisibilityService","name":"ExplorerServiceVisibilityService","className":"ExplorerServiceVisibilityService"},{"parentName":"Football, hexball","fullPath":"ScriptCloneWatcherHelper","name":"ScriptCloneWatcherHelper","className":"ScriptCloneWatcherHelper"},{"parentName":"Football, hexball","fullPath":"TutorialService","name":"TutorialService","className":"TutorialService"},{"parentName":"Football, hexball","fullPath":"PluginGuiService","name":"PluginGuiService","className":"PluginGuiService"},{"parentName":"Football, hexball","fullPath":"RobloxPluginGuiService","name":"RobloxPluginGuiService","className":"RobloxPluginGuiService"},{"parentName":"Football, hexball","fullPath":"PlacesService","name":"PlacesService","className":"PlacesService"},{"parentName":"Football, hexball","fullPath":"Script Context","name":"Script Context","className":"ScriptContext"},{"parentName":"Football, hexball","fullPath":"ServiceVisibilityService","name":"ServiceVisibilityService","className":"ServiceVisibilityService"},{"parentName":"Football, hexball","fullPath":"TeamCreateService","name":"TeamCreateService","className":"TeamCreateService"},{"parentName":"Football, hexball","fullPath":"SelectionHighlightManager","name":"SelectionHighlightManager","className":"SelectionHighlightManager"},{"parentName":"Football, hexball","fullPath":"CollaboratorsService","name":"CollaboratorsService","className":"CollaboratorsService"},{"parentName":"Football, hexball","fullPath":"PathfindingService","name":"PathfindingService","className":"PathfindingService"},{"parentName":"Football, hexball","fullPath":"AssetManagerService","name":"AssetManagerService","className":"AssetManagerService"},{"parentName":"Football, hexball","fullPath":"VideoService","name":"VideoService","className":"VideoService"},{"parentName":"Football, hexball","fullPath":"HttpService","name":"HttpService","className":"HttpService"},{"parentName":"Football, hexball","fullPath":"PackageService","name":"PackageService","className":"PackageService"},{"parentName":"Football, hexball","fullPath":"StudioTestService","name":"StudioTestService","className":"StudioTestService"},{"parentName":"Football, hexball","fullPath":"RemoteDebuggerServer","name":"RemoteDebuggerServer","className":"RemoteDebuggerServer"},{"parentName":"Football, hexball","fullPath":"DebuggerManager","name":"DebuggerManager","className":"DebuggerManager"},{"parentName":"Football, hexball","fullPath":"ScriptDebuggerService","name":"ScriptDebuggerService","className":"ScriptDebuggerService"},{"parentName":"Football, hexball","fullPath":"ScriptChangeService","name":"ScriptChangeService","className":"ScriptChangeService"},{"parentName":"Football, hexball","fullPath":"ScriptEditorService","name":"ScriptEditorService","className":"ScriptEditorService"},{"parentName":"Football, hexball","fullPath":"LanguageService","name":"LanguageService","className":"LanguageService"},{"parentName":"Football, hexball","fullPath":"PluginDebugService","name":"PluginDebugService","className":"PluginDebugService"},{"parentName":"Football, hexball","fullPath":"Visit","name":"Visit","className":"Visit"},{"parentName":"Football, hexball","fullPath":"DataStoreService","name":"DataStoreService","className":"DataStoreService"},{"parentName":"Football, hexball","fullPath":"Lighting","name":"Lighting","className":"Lighting"},{"parentName":"Football, hexball","fullPath":"ProximityPromptService","name":"ProximityPromptService","className":"ProximityPromptService"},{"parentName":"Football, hexball","fullPath":"SerializationService","name":"SerializationService","className":"SerializationService"},{"parentName":"Football, hexball","fullPath":"Teams","name":"Teams","className":"Teams"},{"parentName":"Football, hexball","fullPath":"TestService","name":"TestService","className":"TestService"},{"parentName":"Football, hexball","fullPath":"UGCAvatarService","name":"UGCAvatarService","className":"UGCAvatarService"},{"parentName":"Football, hexball","fullPath":"VideoScreenCaptureService","name":"VideoScreenCaptureService","className":"VideoScreenCaptureService"},{"parentName":"Football, hexball","fullPath":"VirtualInputManager","name":"VirtualInputManager","className":"VirtualInputManager"},{"parentName":"Football, hexball","fullPath":"VoiceChatService","name":"VoiceChatService","className":"VoiceChatService"},{"parentName":"Football, hexball","fullPath":"SpawnerService","name":"SpawnerService","className":"SpawnerService"},{"parentName":"Football, hexball","fullPath":"CoreScriptSyncService","name":"CoreScriptSyncService","className":"CoreScriptSyncService"},{"parentName":"Football, hexball","fullPath":"CrossDMScriptChangeListener","name":"CrossDMScriptChangeListener","className":"CrossDMScriptChangeListener"},{"parentName":"Football, hexball","fullPath":"RuntimeScriptService","name":"RuntimeScriptService","className":"RuntimeScriptService"},{"parentName":"Football, hexball","fullPath":"HapticService","name":"HapticService","className":"HapticService"},{"parentName":"Football, hexball","fullPath":"MeshContentProvider","name":"MeshContentProvider","className":"MeshContentProvider"},{"parentName":"Football, hexball","fullPath":"SolidModelContentProvider","name":"SolidModelContentProvider","className":"SolidModelContentProvider"},{"parentName":"Football, hexball","fullPath":"HSRDataContentProvider","name":"HSRDataContentProvider","className":"HSRDataContentProvider"},{"parentName":"Football, hexball","fullPath":"AvatarCreationService","name":"AvatarCreationService","className":"AvatarCreationService"},{"parentName":"Football, hexball","fullPath":"InstanceFileSyncService","name":"InstanceFileSyncService","className":"InstanceFileSyncService"},{"parentName":"Football, hexball","fullPath":"LiveSyncService","name":"LiveSyncService","className":"LiveSyncService"},{"parentName":"Football, hexball","fullPath":"StudioAssetService","name":"StudioAssetService","className":"StudioAssetService"},{"parentName":"Football, hexball","fullPath":"StudioPublishService","name":"StudioPublishService","className":"StudioPublishService"},{"parentName":"Football, hexball","fullPath":"GenerationService","name":"GenerationService","className":"GenerationService"},{"parentName":"Football, hexball","fullPath":"StudioCaptureService","name":"StudioCaptureService","className":"StudioCaptureService"},{"parentName":"Football, hexball","fullPath":"UniqueIdLookupService","name":"UniqueIdLookupService","className":"UniqueIdLookupService"},{"parentName":"Football, hexball","fullPath":"MemStorageService","name":"MemStorageService","className":"MemStorageService"},{"parentName":"Football, hexball","fullPath":"StylingService","name":"StylingService","className":"StylingService"},{"parentName":"Football, hexball","fullPath":"GamepadService","name":"GamepadService","className":"GamepadService"},{"parentName":"Football, hexball","fullPath":"FilteredSelection","name":"FilteredSelection","className":""},{"parentName":"Football, hexball","fullPath":"FilteredSelection","name":"FilteredSelection","className":""},{"parentName":"Football, hexball","fullPath":"FilteredSelection","name":"FilteredSelection","className":""},{"parentName":"Football, hexball","fullPath":"FilteredSelection","name":"FilteredSelection","className":""},{"parentName":"Football, hexball","fullPath":"TextBoxService","name":"TextBoxService","className":"TextBoxService"},{"parentName":"Football, hexball","fullPath":"ControllerService","name":"ControllerService","className":"ControllerService"},{"parentName":"Football, hexball","fullPath":"RbxAnalyticsService","name":"RbxAnalyticsService","className":"RbxAnalyticsService"},{"parentName":"Football, hexball","fullPath":"StudioWidgetsService","name":"StudioWidgetsService","className":"StudioWidgetsService"},{"parentName":"Football, hexball","fullPath":"TelemetryService","name":"TelemetryService","className":"TelemetryService"},{"parentName":"Football, hexball","fullPath":"Instance","name":"Instance","className":"StartPageService"},{"parentName":"Football, hexball","fullPath":"MessageBusService","name":"MessageBusService","className":"MessageBusService"},{"parentName":"Football, hexball","fullPath":"PackageUIService","name":"PackageUIService","className":"PackageUIService"},{"parentName":"Football, hexball","fullPath":"UIDragDetectorService","name":"UIDragDetectorService","className":"UIDragDetectorService"},{"parentName":"Football, hexball","fullPath":"DraggerService","name":"DraggerService","className":"DraggerService"},{"parentName":"Football, hexball","fullPath":"HeightmapImporterService","name":"HeightmapImporterService","className":"HeightmapImporterService"},{"parentName":"Football, hexball","fullPath":"PluginPolicyService","name":"PluginPolicyService","className":"PluginPolicyService"},{"parentName":"Football, hexball","fullPath":"UGCValidationService","name":"UGCValidationService","className":"UGCValidationService"},{"parentName":"Football, hexball","fullPath":"AssetQualityService","name":"AssetQualityService","className":"AssetQualityService"},{"parentName":"Football, hexball","fullPath":"StudioSdkService","name":"StudioSdkService","className":"StudioSdkService"},{"parentName":"Football, hexball","fullPath":"IXPService","name":"IXPService","className":"IXPService"},{"parentName":"Football, hexball","fullPath":"AssetImportService","name":"AssetImportService","className":"AssetImportService"},{"parentName":"Football, hexball","fullPath":"EncodingService","name":"EncodingService","className":"EncodingService"},{"parentName":"Football, hexball","fullPath":"VisualizationModeService","name":"VisualizationModeService","className":"VisualizationModeService"},{"parentName":"Football, hexball","fullPath":"Instance","name":"Instance","className":"StudioCameraService"},{"parentName":"Football, hexball","fullPath":"DraftsService","name":"DraftsService","className":"DraftsService"},{"parentName":"Football, hexball","fullPath":"UserService","name":"UserService","className":"UserService"},{"parentName":"Football, hexball","fullPath":"SafetyService","name":"SafetyService","className":"SafetyService"},{"parentName":"Football, hexball","fullPath":"GroupService","name":"GroupService","className":"GroupService"},{"parentName":"Football, hexball","fullPath":"ReflectionService","name":"ReflectionService","className":"ReflectionService"},{"parentName":"Football, hexball","fullPath":"ExplorerFilter","name":"ExplorerFilter","className":"ExplorerFilter"},{"parentName":"Football, hexball","fullPath":"PluginManagementService","name":"PluginManagementService","className":"PluginManagementService"},{"parentName":"Football, hexball","fullPath":"InstanceExtensionsService","name":"InstanceExtensionsService","className":"InstanceExtensionsService"},{"parentName":"Football, hexball","fullPath":"RemoteCommandService","name":"RemoteCommandService","className":"RemoteCommandService"},{"parentName":"Football, hexball","fullPath":"ExplorerFilter","name":"ExplorerFilter","className":"ExplorerFilter"},{"parentName":"Football, hexball","fullPath":"Instance","name":"Instance","className":"LuauExpressionService"},{"parentName":"Football, hexball","fullPath":"MaterialGenerationService","name":"MaterialGenerationService","className":"MaterialGenerationService"},{"parentName":"Football, hexball","fullPath":"PluginConnectionService","name":"PluginConnectionService","className":"PluginConnectionService"},{"parentName":"Workspace","fullPath":"Workspace.Camera","name":"Camera","className":"Camera"},{"parentName":"Workspace","fullPath":"Workspace.Baseplate","name":"Baseplate","className":"Part"},{"parentName":"Workspace","fullPath":"Workspace.Terrain","name":"Terrain","className":"Terrain"},{"parentName":"Workspace","fullPath":"Workspace.SpawnLocation","name":"SpawnLocation","className":"SpawnLocation"},{"parentName":"Workspace","fullPath":"Workspace.HaxballLab","name":"HaxballLab","className":"Model"},{"parentName":"GuiService","fullPath":"GuiService.ScreenshotHud","name":"ScreenshotHud","className":"ScreenshotHud"},{"parentName":"Stats","fullPath":"Stats.PerformanceStats","name":"PerformanceStats","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.RenderBreakdown","name":"RenderBreakdown","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.Workspace","name":"Workspace","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.Sound","name":"Sound","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.ChangeHistory","name":"ChangeHistory","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.Luau","name":"Luau","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.FrameRateManager","name":"FrameRateManager","className":"StatsItem"},{"parentName":"Stats","fullPath":"Stats.Render","name":"Render","className":"StatsItem"},{"parentName":"TextChatService","fullPath":"TextChatService.ChatWindowConfiguration","name":"ChatWindowConfiguration","className":"ChatWindowConfiguration"},{"parentName":"TextChatService","fullPath":"TextChatService.ChatInputBarConfiguration","name":"ChatInputBarConfiguration","className":"ChatInputBarConfiguration"},{"parentName":"TextChatService","fullPath":"TextChatService.BubbleChatConfiguration","name":"BubbleChatConfiguration","className":"BubbleChatConfiguration"},{"parentName":"TextChatService","fullPath":"TextChatService.ChannelTabsConfiguration","name":"ChannelTabsConfiguration","className":"ChannelTabsConfiguration"},{"parentName":"StarterPlayer","fullPath":"StarterPlayer.StarterPlayerScripts","name":"StarterPlayerScripts","className":"StarterPlayerScripts"},{"parentName":"StarterPlayer","fullPath":"StarterPlayer.StarterCharacterScripts","name":"StarterCharacterScripts","className":"StarterCharacterScripts"},{"parentName":"InsertService","fullPath":"InsertService.InsertionHash","name":"InsertionHash","className":"StringValue"},{"parentName":"AvatarSettings","fullPath":"AvatarSettings.DefaultAvatarRules","name":"DefaultAvatarRules","className":"AvatarRules"},{"parentName":"ReplicatedStorage","fullPath":"ReplicatedStorage.Shared","name":"Shared","className":"Folder"},{"parentName":"ReplicatedStorage","fullPath":"ReplicatedStorage.HaxballLab","name":"HaxballLab","className":"Folder"},{"parentName":"ReplicatedStorage","fullPath":"ReplicatedStorage.Inputs","name":"Inputs","className":"Folder"},{"parentName":"ServerScriptService","fullPath":"ServerScriptService.Server","name":"Server","className":"Script"},{"parentName":"ServerScriptService","fullPath":"ServerScriptService.HaxballLab","name":"HaxballLab","className":"Folder"},{"parentName":"PluginGuiService","fullPath":"PluginGuiService.Rojo_soundPlayer","name":"Rojo_soundPlayer","className":"DockWidgetPluginGui"},{"parentName":"PluginGuiService","fullPath":"PluginGuiService.Rojo 7.7.1","name":"Rojo 7.7.1","className":"DockWidgetPluginGui"},{"parentName":"PluginGuiService","fullPath":"PluginGuiService.Rojo_ConnectedTableDiff","name":"Rojo_ConnectedTableDiff","className":"DockWidgetPluginGui"},{"parentName":"PluginGuiService","fullPath":"PluginGuiService.Rojo_ConnectedStringDiff","name":"Rojo_ConnectedStringDiff","className":"DockWidgetPluginGui"},{"parentName":"PluginGuiService","fullPath":"PluginGuiService.Rojo_ChangesViewer","name":"Rojo_ChangesViewer","className":"DockWidgetPluginGui"},{"parentName":"RobloxPluginGuiService","fullPath":"RobloxPluginGuiService.PluginGui","name":"PluginGui","className":"DockWidgetPluginGui"},{"parentName":"RobloxPluginGuiService","fullPath":"RobloxPluginGuiService.AnimationClipEditor","name":"AnimationClipEditor","className":"DockWidgetPluginGui"},{"parentName":"RobloxPluginGuiService","fullPath":"RobloxPluginGuiService.PluginGui","name":"PluginGui","className":"DockWidgetPluginGui"},{"parentName":"RobloxPluginGuiService","fullPath":"RobloxPluginGuiService.PluginGui","name":"PluginGui","className":"DockWidgetPluginGui"}]
> ```
>
> MCP tool call
>
> Roblox_Studio.inspect_instance
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "path": "ReplicatedStorage"
> }
> ```
>
> ```text
> {"path":"ReplicatedStorage","name":"ReplicatedStorage","className":"ReplicatedStorage","uniqueId":"69681943-1a01-660b-0b0e-2950000003c0","children":{"immediateChildren":[{"path":"ReplicatedStorage.Shared","className":"Folder"},{"path":"ReplicatedStorage.HaxballLab","className":"Folder"},{"path":"ReplicatedStorage.Inputs","className":"Folder"}],"totalDescendants":16,"childrenCount":3},"properties":[]}
> ```
>
> MCP tool call
>
> Roblox_Studio.inspect_instance
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "path": "ServerScriptService"
> }
> ```
>
> ```text
> {"path":"ServerScriptService","name":"ServerScriptService","className":"ServerScriptService","uniqueId":"69681943-1a01-660b-0b0e-2950000003c1","children":{"immediateChildren":[{"path":"ServerScriptService.Server","className":"Script"},{"path":"ServerScriptService.HaxballLab","className":"Folder"}],"totalDescendants":9,"childrenCount":2},"properties":[]}
> ```
>
> </details>
>
> La carpeta confirma que esto es un laboratorio de física 2D para “Football, hexball”, y que el juego real vive en la instancia de Studio. La instancia abierta coincide con el PlaceId y está en Edit; ahora estoy contrastando la jerarquía/código actuales con los informes de continuidad para separar lo vigente de lo histórico.
>
> <details><summary>Ran a command, called 29 tools</summary>
>
> MCP tool call
>
> Roblox_Studio.search_game_tree
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "datamodel_type": "Edit",
>   "path": "Workspace.HaxballLab",
>   "max_depth": 5
> }
> ```
>
> ```text
> [{"parentName":"Workspace","fullPath":"Workspace.HaxballLab","name":"HaxballLab","className":"Model"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.Field","name":"Field","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BoundaryNorth","name":"BoundaryNorth","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BoundarySouth","name":"BoundarySouth","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BoundaryWest","name":"BoundaryWest","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BoundaryEast","name":"BoundaryEast","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.CenterLine","name":"CenterLine","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.CenterMark","name":"CenterMark","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.PlayerDisc","name":"PlayerDisc","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BallDisc","name":"BallDisc","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.DebugLine","name":"DebugLine","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.PlayerDisc2","name":"PlayerDisc2","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.PairDebugLine","name":"PairDebugLine","className":"Part"},{"parentName":"HaxballLab","fullPath":"Workspace.HaxballLab.BallP2DebugLine","name":"BallP2DebugLine","className":"Part"}]
> ```
>
> MCP tool call
>
> Roblox_Studio.inspect_instance
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "path": "game"
> }
> ```
>
> ```text
> Error: Could not find any instances at path 'game'
> ```
>
> MCP tool call
>
> Roblox_Studio.search_game_tree
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "datamodel_type": "Edit",
>   "path": "ReplicatedStorage.HaxballLab",
>   "max_depth": 5
> }
> ```
>
> ```text
> [{"parentName":"ReplicatedStorage","fullPath":"ReplicatedStorage.HaxballLab","name":"HaxballLab","className":"Folder"},{"parentName":"HaxballLab","fullPath":"ReplicatedStorage.HaxballLab.Remotes","name":"Remotes","className":"Folder"},{"parentName":"HaxballLab","fullPath":"ReplicatedStorage.HaxballLab.LabClient","name":"LabClient","className":"Script"},{"parentName":"HaxballLab","fullPath":"ReplicatedStorage.HaxballLab.PredictionLab2D","name":"PredictionLab2D","className":"ModuleScript"},{"parentName":"HaxballLab","fullPath":"ReplicatedStorage.HaxballLab.StadiumReference2D","name":"StadiumReference2D","className":"ModuleScript"},{"parentName":"Remotes","fullPath":"ReplicatedStorage.HaxballLab.Remotes.Input","name":"Input","className":"RemoteEvent"},{"parentName":"Remotes","fullPath":"ReplicatedStorage.HaxballLab.Remotes.Snapshot","name":"Snapshot","className":"RemoteEvent"},{"parentName":"Remotes","fullPath":"ReplicatedStorage.HaxballLab.Remotes.DebugCommand","name":"DebugCommand","className":"RemoteEvent"}]
> ```
>
> MCP tool call
>
> Roblox_Studio.search_game_tree
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "datamodel_type": "Edit",
>   "path": "ServerScriptService.HaxballLab",
>   "max_depth": 5
> }
> ```
>
> ```text
> [{"parentName":"ServerScriptService","fullPath":"ServerScriptService.HaxballLab","name":"HaxballLab","className":"Folder"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.Physics2D","name":"Physics2D","className":"ModuleScript"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.LabServer","name":"LabServer","className":"Script"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.DebugState","name":"DebugState","className":"BindableFunction"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.LabRegression","name":"LabRegression","className":"ModuleScript"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.PhysicsCore2D","name":"PhysicsCore2D","className":"ModuleScript"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.ClassicStadium2D","name":"ClassicStadium2D","className":"ModuleScript"},{"parentName":"HaxballLab","fullPath":"ServerScriptService.HaxballLab.MatchRules2D","name":"MatchRules2D","className":"ModuleScript"}]
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabServer",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Players = game:GetService("Players")
>      2→local ReplicatedStorage = game:GetService("ReplicatedStorage")
>      3→local RunService = game:GetService("RunService")
>      4→
>      5→local lab = ReplicatedStorage:WaitForChild("HaxballLab")
>      6→local remotes = lab.Remotes
>      7→local inputRemote = remotes.Input
>      8→local snapshotRemote = remotes.Snapshot
>      9→local commandRemote = remotes.DebugCommand
>     10→local Physics2D = require(script.Parent:WaitForChild("Physics2D"))
>     11→local PhysicsCore2D = Physics2D.MatchCore
>     12→local ClassicStadium2D = require(script.Parent:WaitForChild("ClassicStadium2D"))
>     13→local StadiumProfile2D = require(lab:WaitForChild("StadiumReference2D"))
>     14→local MatchRules2D = require(script.Parent:WaitForChild("MatchRules2D"))
>     15→local LabRegression = require(script.Parent:WaitForChild("LabRegression"))
>     16→local debugState = script.Parent:WaitForChild("DebugState")
>     17→
>     18→Players.CharacterAutoLoads = false
>     19→local state = Physics2D.newState()
>     20→local matchState = MatchRules2D.newMatch()
>     21→local currentInput = { x = 0, y = 0, kick = false }
>     22→local currentInputs = {[1]=currentInput}
>     23→local lastCoreKickInputs = {}
>     24→local touchingCoreBall = {}
>     25→local playerUserSlots = {}
>     26→local slotUserIds = {}
>     27→local lastKick = false
>     28→local facingX, facingY = 1, 0
>     29→local controlledPlayer = nil
>     30→local accumulator = 0
>     31→local stepDt = 1 / Physics2D.Config.tickRate
>     32→local recording = true
>     33→local historyCapacity = 3600
>     34→local historyBuffer = {}
>     35→local historyWrite = 1
>     36→local historyCount = 0
>     37→local events = {}
>     38→local eventCapacity = 300
>     39→local pairMode = false
>     40→local crowdMode = false
>     41→local legacyMode = false
>     42→local speedRunRemaining = 0
>     43→local touchingBall = false
>     44→local touchingPlayers = false
>     45→local touchingCrowdPairs = {}
>     46→local metrics = {
>     47→    kickAttempts=0, successfulKicks=0, ballContacts=0,
>     48→    ballWallBounces=0, playerWallBounces=0, lastKickSuccessTick=-1,
>     49→    playerContacts=0, maxPlayerPenetration=0, maxPlayerCorrection=0,
>     50→    lastPlayerContactTick=-1, lastPlayerImpulse=0,
>     51→    crowdContacts=0, crowdContactsP1P2=0, crowdContactsP1Ball=0, crowdContactsP2Ball=0,
>     52→    crowdPeakPenetration=0, crowdLastResidualPenetration=0, crowdWorstResidualPenetration=0,
>     53→    crowdLastSolverIterations=0, crowdMaxSolverIterations=0,
>     54→    lastCollisionSubsteps=0, maxCollisionSubsteps=0,
>     55→    regressionRan=false, regressionPassed=0, regressionFailed=0, regressionTotal=0,
>     56→}
>     57→local function clearHistory()
>     58→    table.clear(historyBuffer)
>     59→    historyWrite, historyCount = 1, 0
>     60→end
>     61→local function logEvent(kind, data, eventTick)
>     62→    local event = data or {}
>     63→    event.kind = kind
>     64→    event.tick = eventTick or state.tick + 1
>     65→    table.insert(events, event)
>     66→    if #events > eventCapacity then table.remove(events, 1) end
>     67→end
>     68→local function clearMetrics()
>     69→    metrics.kickAttempts=0; metrics.successfulKicks=0; metrics.ballContacts=0
>     70→    metrics.ballWallBounces=0; metrics.playerWallBounces=0; metrics.lastKickSuccessTick=-1
>     71→    metrics.playerContacts=0; metrics.maxPlayerPenetration=0; metrics.maxPlayerCorrection=0
>     72→    metrics.lastPlayerContactTick=-1; metrics.lastPlayerImpulse=0
>     73→    metrics.crowdContacts=0; metrics.crowdContactsP1P2=0; metrics.crowdContactsP1Ball=0; metrics.crowdContactsP2Ball=0
>     74→    metrics.crowdPeakPenetration=0; metrics.crowdLastResidualPenetration=0; metrics.crowdWorstResidualPenetration=0
>     75→    metrics.crowdLastSolverIterations=0; metrics.crowdMaxSolverIterations=0
>     76→    metrics.lastCollisionSubsteps=0; metrics.maxCollisionSubsteps=0
>     77→    metrics.regressionRan=false; metrics.regressionPassed=0; metrics.regressionFailed=0; metrics.regressionTotal=0
>     78→    table.clear(events); clearHistory()
>     79→    touchingBall=false; touchingPlayers=false; touchingCrowdPairs={}
>     80→end
>     81→local function finite(n)
>     82→    return typeof(n)=="number" and n==n and math.abs(n)<1e6
>     83→end
>     84→
>     85→local function setController(player)
>     86→    if controlledPlayer==nil then controlledPlayer=player end
>     87→    if not playerUserSlots[player.UserId] then
>     88→        for slot=1,10 do
>     89→            if slotUserIds[slot]==nil then
>     90→                playerUserSlots[player.UserId]=slot
>     91→                slotUserIds[slot]=player.UserId
>     92→                if state.players and state.players[slot] then state.players[slot].ownerUserId=player.UserId end
>     93→                break
>     94→            end
>     95→        end
>     96→    end
>     97→    if player.Character then player.Character:Destroy() end
>     98→end
>     99→Players.PlayerAdded:Connect(setController)
>    100→for _,player in Players:GetPlayers() do setController(player) end
>    101→Players.PlayerRemoving:Connect(function(player)
>    102→    local slot=playerUserSlots[player.UserId]
>    103→    if slot then
>    104→        playerUserSlots[player.UserId]=nil
>    105→        slotUserIds[slot]=nil
>    106→        currentInputs[slot]={x=0,y=0,kick=false}
>    107→        lastCoreKickInputs[slot]=nil
>    108→        touchingCoreBall[slot]=nil
>    109→        if state.players and state.players[slot] then state.players[slot].ownerUserId=nil end
>    110→    end
>    111→    if player==controlledPlayer then
>    112→        controlledPlayer=nil
>    113→        for _,candidate in Players:GetPlayers() do
>    114→            if candidate~=player then controlledPlayer=candidate;break end
>    115→        end
>    116→        currentInput={x=0,y=0,kick=false}
>    117→        currentInputs[1]=currentInput
>    118→        lastKick=false
>    119→        if state.players then
>    120→            local newSlot=controlledPlayer and playerUserSlots[controlledPlayer.UserId]
>    121→            if newSlot and state.players[newSlot] then state.players[newSlot].ownerUserId=controlledPlayer.UserId end
>    122→        elseif state.player then
>    123→            state.player.ownerUserId=controlledPlayer and controlledPlayer.UserId or nil
>    124→        end
>    125→    end
>    126→end)
>    127→
>    128→local function allocateInput(playerSlot,x,y,kick)
>    129→    if not finite(x) or not finite(y) then return nil end
>    130→    local magnitude=math.sqrt(x*x+y*y)
>    131→    if magnitude>1 then x,y=x/magnitude,y/magnitude end
>    132→    local value={x=x,y=y,kick=kick==true}
>    133→    local old=currentInputs[playerSlot] or {x=0,y=0,kick=false}
>    134→    if x~=old.x or y~=old.y or value.kick~=old.kick then
>    135→        logEvent("input",{playerId=playerSlot,x=x,y=y,kick=value.kick})
>    136→    end
>    137→    currentInputs[playerSlot]=value
>    138→    return value
>    139→end
>    140→inputRemote.OnServerEvent:Connect(function(player,x,y,kick)
>    141→    local slot=playerUserSlots[player.UserId]
>    142→    if not slot then return end
>    143→    if state.coreWorld and matchState.phase~="playing" then return end
>    144→    if pairMode or crowdMode or legacyMode then
>    145→        if player~=controlledPlayer then return end
>    146→        local value=allocateInput(1,x,y,kick)
>    147→        if value then currentInput=value end
>    148→        if value and x*x+y*y>0.01 then
>    149→            local magnitude=math.sqrt(x*x+y*y)
>    150→            facingX,facingY=x/magnitude,y/magnitude
>    151→        end
>    152→        return
>    153→    end
>    154→    local value=allocateInput(slot,x,y,kick)
>    155→    if value and slot==1 then currentInput=value end
>    156→end)
>    157→
>    158→local function speed(d) return math.sqrt(d.vx*d.vx+d.vy*d.vy) end
>    159→local function makeCoreState()
>    160→    local legacy=Physics2D.newState()
>    161→    local world=PhysicsCore2D.newWorld({
>    162→        tickRate=Physics2D.Config.tickRate,
>    163→        fieldHalfWidth=Physics2D.Config.fieldHalfWidth,
>    164→        fieldHalfHeight=Physics2D.Config.fieldHalfHeight,
>    165→        useBounds=false,
>    166→    })
>    167→    -- Preserve stadium order: ball, static posts, then ten player discs.
>    168→    local ball=PhysicsCore2D.addDisc(world,{
>    169→        id="ball",kind="ball",x=0,y=0,radius=Physics2D.Config.ballRadius,
>    170→        invMass=Physics2D.Config.ballInvMass,damping=Physics2D.Config.ballDamping,traceMotion=true,
>    171→        bCoef=Physics2D.Config.ballBounce,kickable=true,
>    172→        collisionGroup=ClassicStadium2D.Groups.ball,
>    173→    })
>    174→    local stadiumGeometry=ClassicStadium2D.install(PhysicsCore2D,world)
>    175→    local spawnPoints = table.clone(StadiumProfile2D.SpawnPoints)
>    176→    local players={}
>    177→    local playerCollisionMasks={}
>    178→    for slot=1,10 do
>    179→        local position=spawnPoints[slot]
>    180→        local disc=PhysicsCore2D.addDisc(world,{
>    181→            id=slot,kind="player",team=slot<=5 and "red" or "blue",
>    182→            x=position.x,y=position.y,radius=Physics2D.Config.playerRadius,
>    183→            invMass=Physics2D.Config.playerInvMass,damping=Physics2D.Config.playerDamping,
>    184→            kickDamping=Physics2D.Config.playerDamping,bCoef=Physics2D.Config.playerBounce,
>    185→            acceleration=Physics2D.Config.playerAcceleration,
>    186→            kickAcceleration=Physics2D.Config.playerKickAcceleration,
>    187→            kickStrength=Physics2D.Config.kickStrength,kickback=Physics2D.Config.kickback,
>    188→            kickRangeExtra=Physics2D.Config.kickRangeExtra,
>    189→            collisionGroup=slot<=5 and ClassicStadium2D.Groups.red or ClassicStadium2D.Groups.blue,
>    190→            collisionMask=StadiumProfile2D.CollisionMasks.player,
>    191→        })
>    192→        disc.ownerUserId=slotUserIds[slot]
>    193→        players[slot]=disc
>    194→        playerCollisionMasks[slot]=disc.collisionMask
>    195→    end
>    196→    return {tick=0,player=players[1],player2=players[6],players=players,ball=ball,score=legacy.score,coreWorld=world,stadiumGeometry=stadiumGeometry,spawnPoints=spawnPoints,playerCollisionMasks=playerCollisionMasks}
>    197→end
>    198→
>    199→local function newState(pairEnabled,crowdEnabled,legacyPhysicsEnabled)
>    200→    local useLegacy=pairEnabled==true or crowdEnabled==true or legacyPhysicsEnabled==true
>    201→    local new=useLegacy and Physics2D.newState() or makeCoreState()
>    202→    if not new.coreWorld then new.player.ownerUserId=controlledPlayer and controlledPlayer.UserId or nil end
>    203→    pairMode=pairEnabled==true
>    204→    crowdMode=crowdEnabled==true
>    205→    legacyMode=legacyPhysicsEnabled==true
>    206→    state=new
>    207→    matchState=MatchRules2D.newMatch()
>    208→    currentInputs={}
>    209→    for slot=1,10 do currentInputs[slot]={x=0,y=0,kick=false} end
>    210→    currentInput=currentInputs[1]
>    211→    lastCoreKickInputs={}
>    212→    touchingCoreBall={}
>    213→    lastKick=false
>    214→    facingX,facingY=1,0
>    215→    accumulator=0
>    216→    speedRunRemaining=0
>    217→    clearMetrics()
>    218→    touchingCrowdPairs={}
>    219→    return new
>    220→end
>    221→newState(false,false,false)
>    222→commandRemote.OnServerEvent:Connect(function(player,command)
>    223→    if player~=controlledPlayer then return end
>    224→    if command=="reset" then
>    225→        newState(false)
>    226→        logEvent("scenarioReset",{scenario="default"})
>    227→    elseif command=="setupKick" then
>    228→        local new=newState(false)
>    229→        new.player.x=-27
>    230→        logEvent("scenarioReset",{scenario="kickFromRest",separation=27})
>    231→    elseif command=="setupWall" then
>    232→        local new=newState(false)
>    233→        new.ball.x=0
>    234→        new.ball.y=156
>    235→        new.ball.vy=5
>    236→        logEvent("scenarioReset",{scenario="ballWallBounce",ballY=new.ball.y,ballVy=new.ball.vy})
>    237→    elseif command=="setupGoalTest" then
>    238→        local new=newState(false)
>    239→        new.ball.x=340; new.ball.y=0; new.ball.vx=12
>    240→        logEvent("scenarioReset",{scenario="goalCrossing",ballX=new.ball.x,ballY=new.ball.y,ballVx=new.ball.vx})
>    241→    elseif command=="setupSpeedRun" then
>    242→        local new=newState(false)
>    243→        new.player.x=-200; new.player.y=100
>    244→        currentInput={x=1,y=0,kick=false}
>    245→        currentInputs[1]=currentInput
>    246→        speedRunRemaining=120
>    247→        logEvent("scenarioReset",{scenario="freeAccelerationRun",playerX=-200,playerY=100,inputX=1,inputY=0})
>    248→    elseif command=="setupBallFastCrossing" then
>    249→        local new=newState(false,false,true)
>    250→        new.player.x=-40; new.player.vx=100
>    251→        new.ball.x=0; new.ball.y=0
>    252→        logEvent("scenarioReset",{scenario="fastPlayerBallCrossing",playerX=-40,playerVx=100,ballX=0})
>    253→    elseif command=="setupBallFastDiagonal" then
>    254→        local new=newState(false,false,true)
>    255→        new.player.x=-40; new.player.y=-40; new.player.vx=100; new.player.vy=100
>    256→        new.ball.x=0; new.ball.y=0
>    257→        logEvent("scenarioReset",{scenario="fastDiagonalPlayerBallCrossing",playerX=-40,playerY=-40,playerVx=100,playerVy=100,ballX=0,ballY=0})
>    258→    elseif command=="setupMultiWall" then
>    259→        local new=newState(false,false,true)
>    260→        new.player.y=100
>    261→        new.ball.x=0; new.ball.y=0; new.ball.vx=3000
>    262→        logEvent("scenarioReset",{scenario="multiWallBouncesInTick",ballX=0,ballVx=3000})
>    263→    elseif command=="setupPairHeadOn" then
>    264→        local new=newState(true)
>    265→        new.player.x=-40; new.player.vx=2
>    266→        new.player2.x=40; new.player2.vx=-2
>    267→        logEvent("scenarioReset",{scenario="playerHeadOn",p1x=-40,p1vx=2,p2x=40,p2vx=-2})
>    268→    elseif command=="setupPairFastCrossing" then
>    269→        local new=newState(true)
>    270→        new.player.x=-40; new.player.vx=80
>    271→        new.player2.x=40; new.player2.vx=-80
>    272→        logEvent("scenarioReset",{scenario="fastPairCrossing",p1x=-40,p1vx=80,p2x=40,p2vx=-80})
>    273→    elseif command=="setupPairOblique" then
>    274→        local new=newState(true)
>    275→        new.player.x=-40; new.player.y=-10; new.player.vx=2
>    276→        new.player2.x=0; new.player2.y=15; new.player2.vy=-0.8
>    277→        logEvent("scenarioReset",{scenario="playerOblique",p1x=-40,p1y=-10,p1vx=2,p2x=0,p2y=15,p2vy=-0.8})
>    278→    elseif command=="setupPairOverlap" then
>    279→        local new=newState(true)
>    280→        new.player.x=0; new.player.y=0
>    281→        new.player2.x=0; new.player2.y=0
>    282→        logEvent("scenarioReset",{scenario="playerCoincidentCenters"})
>    283→    elseif command=="setupCrowdOverlap" then
>    284→        local new=newState(false,true)
>    285→        new.player.x=-14; new.player2.x=14
>    286→        new.ball.x=0; new.ball.y=0
>    287→        logEvent("scenarioReset",{scenario="threeDiscOverlap",p1x=-14,p2x=14,ballX=0})
>    288→    elseif command=="setupCrowdApproach" then
>    289→        local new=newState(false,true)
>    290→        new.player.x=-32; new.player.vx=2
>    291→        new.player2.x=32; new.player2.vx=-2
>    292→        new.ball.x=0; new.ball.y=0
>    293→        logEvent("scenarioReset",{scenario="twoPlayersApproachBall",p1x=-32,p1vx=2,p2x=32,p2vx=-2,ballX=0})
>    294→    elseif command=="runRegressionSuite" then
>    295→        local report=LabRegression.Run(Physics2D)
>    296→        metrics.regressionRan=true
>    297→        metrics.regressionPassed=report.passed
>    298→        metrics.regressionFailed=report.failed
>    299→        metrics.regressionTotal=report.total
>    300→        logEvent("regressionSuiteCompleted",{passed=report.passed,failed=report.failed,total=report.total,allPassed=report.allPassed})
>    301→    elseif command=="toggleRecording" then
>    302→        recording=not recording
>    303→        logEvent("recordingChanged",{recording=recording})
>    304→    end
>    305→end)
>    306→
>    307→local function snapshot()
>    308→    local p,p2,b=state.player,state.player2,state.ball
>    309→    local dx,dy=p.x-b.x,p.y-b.y
>    310→    local p2dx,p2dy=p.x-p2.x,p.y-p2.y
>    311→    local p2bdx,p2bdy=p2.x-b.x,p2.y-b.y
>    312→    local playerSnapshots={}
>    313→    local redCount,blueCount=0,0
>    314→    if state.players then
>    315→        for slot,disc in ipairs(state.players) do
>    316→            if disc.team=="red" then redCount+=1 elseif disc.team=="blue" then blueCount+=1 end
>    317→            table.insert(playerSnapshots,{playerId=slot,team=disc.team,ownerUserId=disc.ownerUserId,x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy,speed=speed(disc),radius=disc.radius,collisionGroup=disc.collisionGroup,collisionMask=disc.collisionMask})
>    318→        end
>    319→    end
>    320→    return {
>    321→        tick=state.tick, gameTime=state.tick/Physics2D.Config.tickRate,
>    322→        matchPhase=matchState.phase,pauseTicksRemaining=matchState.remainingTicks,kickoffTeam=matchState.kickoffTeam,lastGoal=matchState.lastGoal,lastTouch=matchState.lastTouch,
>    323→        player={x=p.x,y=p.y,vx=p.vx,vy=p.vy,speed=speed(p),radius=p.radius},
>    324→        predictionParams={acceleration=p.acceleration or Physics2D.Config.playerAcceleration,kickAcceleration=p.kickAcceleration or Physics2D.Config.playerKickAcceleration,damping=p.damping or Physics2D.Config.playerDamping,kickDamping=p.kickDamping or Physics2D.Config.playerDamping,maxSpeed=p.maxSpeed},
>    325→        player2={x=p2.x,y=p2.y,vx=p2.vx,vy=p2.vy,speed=speed(p2)},
>    326→        players=playerSnapshots,playerCount=#playerSnapshots,redCount=redCount,blueCount=blueCount,
>    327→        ball={x=b.x,y=b.y,vx=b.vx,vy=b.vy,speed=speed(b),radius=b.radius,collisionGroup=b.collisionGroup,collisionMask=b.collisionMask},
>    328→        score={red=state.score.red,blue=state.score.blue},
>    329→        ownerUserId=p.ownerUserId,physicsDiscCount=state.coreWorld and #state.coreWorld.discs or 0,
>    330→        input={x=currentInput.x,y=currentInput.y,kick=currentInput.kick},
>    331→        separation=math.sqrt(dx*dx+dy*dy),
>    332→        playerSeparation=math.sqrt(p2dx*p2dx+p2dy*p2dy),
>    333→        player2BallSeparation=math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy),
>    334→        touchingBall=not pairMode and math.sqrt(dx*dx+dy*dy)<=p.radius+b.radius+0.02,
>    335→        touchingPlayer2Ball=crowdMode and math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy)<=p2.radius+b.radius+0.02,
>    336→        touchingPlayers=math.sqrt(p2dx*p2dx+p2dy*p2dy)<=p.radius+p2.radius+0.02,
>    337→        pairMode=pairMode,
>    338→        crowdMode=crowdMode,
>    339→        coreMode=state.coreWorld~=nil,
>    340→        legacyMode=legacyMode,
>    341→        ballActive=not pairMode,
>    342→        metrics=table.clone(metrics),
>    343→        recording=recording,
>    344→        crowdMode=crowdMode,
>    345→        historySamples=historyCount,
>    346→    }
>    347→end
>    348→debugState.OnInvoke=function(request)
>    349→    local current=snapshot()
>    350→    if request=="regression" then
>    351→        return LabRegression.Run(Physics2D)
>    352→    end
>    353→    if request=="summary" then
>    354→        return {current=current,metrics=table.clone(metrics),eventCount=#events,historyCount=historyCount,recording=recording}
>    355→    end
>    356→    local chronological={}
>    357→    local limit=type(request)=="table" and math.clamp(request.limit or 600,1,1200) or 600
>    358→    local hasAfterTick=type(request)=="table" and type(request.afterTick)=="number"
>    359→    local afterTick=hasAfterTick and request.afterTick or -1
>    360→    local first=historyCount<historyCapacity and 1 or historyWrite
>    361→    local skip=hasAfterTick and 0 or math.max(0,historyCount-limit)
>    362→    for i=skip+1,historyCount do
>    363→        local index=((first+i-2)%historyCapacity)+1
>    364→        local sample=historyBuffer[index]
>    365→        if sample and sample.tick>afterTick then
>    366→            table.insert(chronological,table.clone(sample))
>    367→            if #chronological>=limit then break end
>    368→        end
>    369→    end
>    370→    local eventCopies={}
>    371→    for _,event in events do table.insert(eventCopies,table.clone(event)) end
>    372→    return {current=current,metrics=table.clone(metrics),events=eventCopies,history=chronological,recording=recording}
>    373→end
>    374→
>    375→RunService.Heartbeat:Connect(function(dt)
>    376→    accumulator+=dt
>    377→    local iterations=0
>    378→    while accumulator>=stepDt and iterations<8 do
>    379→        local p,p2,b=state.player,state.player2,state.ball
>    380→        local beforeBallVx,beforeBallVy=b.vx,b.vy
>    381→        local beforePlayerVx,beforePlayerVy=p.vx,p.vy
>    382→        local pairResolution=nil
>    383→        local crowdResiduals=nil
>    384→        local physicsStepInfo=nil
>    385→        local pairBeforeSeparation=math.sqrt((p.x-p2.x)^2+(p.y-p2.y)^2)
>    386→
>    387→        if pairMode then
>    388→            local _,resolution=Physics2D.stepPlayerPair(state)
>    389→            pairResolution=resolution
>    390→            local separation=math.sqrt((p.x-p2.x)^2+(p.y-p2.y)^2)
>    391→            local nowTouching=separation<=p.radius+p2.radius+0.02
>    392→            if resolution then
>    393→                metrics.maxPlayerPenetration=math.max(metrics.maxPlayerPenetration,resolution.penetration)
>    394→                metrics.maxPlayerCorrection=math.max(metrics.maxPlayerCorrection,resolution.correctionA+resolution.correctionB)
>    395→                if resolution and not touchingPlayers and (nowTouching or resolution.swept==true) then
>    396→                    metrics.playerContacts+=1
>    397→                    metrics.lastPlayerContactTick=state.tick
>    398→                    metrics.lastPlayerImpulse=resolution.impulse
>    399→                    logEvent("playerPlayerContact",{
>    400→                        separation=resolution.swept and (p.radius+p2.radius-resolution.penetration) or separation,
>    401→                        postStepSeparation=separation, penetration=resolution.penetration,
>    402→                        correctionA=resolution.correctionA, correctionB=resolution.correctionB,
>    403→                        normalX=resolution.normalX, normalY=resolution.normalY,
>    404→                        normalSpeedBefore=resolution.normalSpeedBefore, impulse=resolution.impulse,
>    405→                        swept=resolution.swept==true, impactFraction=resolution.impactFraction,
>    406→                        p1x=p.x,p1y=p.y,p1vx=p.vx,p1vy=p.vy,
>    407→                        p2x=p2.x,p2y=p2.y,p2vx=p2.vx,p2vy=p2.vy,
>    408→                    },state.tick)
>    409→                end
>    410→            end
>    411→            touchingPlayers=nowTouching
>    412→        elseif crowdMode then
>    413→            local _, impacts, residuals, maxResidual, iterationsUsed = Physics2D.stepThreeBody(state, Physics2D.Config.collisionIterations)
>    414→            crowdResiduals=residuals
>    415→            metrics.crowdLastSolverIterations=iterationsUsed
>    416→            metrics.crowdMaxSolverIterations=math.max(metrics.crowdMaxSolverIterations,iterationsUsed)
>    417→            local pairDefinitions = {
>    418→                {key="player1-player2", a=p, b=p2, metric="crowdContactsP1P2"},
>    419→                {key="player1-ball", a=p, b=b, metric="crowdContactsP1Ball"},
>    420→                {key="player2-ball", a=p2, b=b, metric="crowdContactsP2Ball"},
>    421→            }
>    422→            for _, definition in pairDefinitions do
>    423→                local dx,dy=definition.a.x-definition.b.x,definition.a.y-definition.b.y
>    424→                local separation=math.sqrt(dx*dx+dy*dy)
>    425→                local isTouching=separation<=definition.a.radius+definition.b.radius+0.02
>    426→                local impact=impacts[definition.key]
>    427→                if impact then
>    428→                    metrics.crowdPeakPenetration=math.max(metrics.crowdPeakPenetration,impact.maxPenetration)
>    429→                end
>    430→                if isTouching and not touchingCrowdPairs[definition.key] then
>    431→                    metrics.crowdContacts+=1
>    432→                    metrics[definition.metric]+=1
>    433→                    logEvent("threeDiscContact",{
>    434→                        pair=definition.key,separation=separation,
>    435→                        penetration=impact and impact.maxPenetration or 0,
>    436→                        correctionA=impact and impact.correctionA or 0,
>    437→                        correctionB=impact and impact.correctionB or 0,
>    438→                        normalX=impact and impact.normalX or 0,
>    439→                        normalY=impact and impact.normalY or 0,
>    440→                        normalSpeedBefore=impact and impact.normalSpeedBefore or 0,
>    441→                        impulseTotal=impact and impact.impulseTotal or 0,
>    442→                        peakImpulseIncrement=impact and impact.peakImpulseIncrement or 0,
>    443→                        lastImpulse=impact and impact.lastImpulse or 0,
>    444→                        resolutionCount=impact and impact.resolutionCount or 0,
>    445→                        residualPenetration=residuals[definition.key] or 0,
>    446→                        p1x=p.x,p1y=p.y,p1vx=p.vx,p1vy=p.vy,
>    447→                        p2x=p2.x,p2y=p2.y,p2vx=p2.vx,p2vy=p2.vy,
>    448→                        ballX=b.x,ballY=b.y,ballVx=b.vx,ballVy=b.vy,
>    449→                    },state.tick)
>    450→                end
>    451→                touchingCrowdPairs[definition.key]=isTouching
>    452→            end
>    453→            metrics.crowdLastResidualPenetration=maxResidual
>    454→            metrics.crowdWorstResidualPenetration=math.max(metrics.crowdWorstResidualPenetration,maxResidual)
>    455→            touchingPlayers=touchingCrowdPairs["player1-player2"]==true
>    456→        elseif state.coreWorld then
>    457→            local coreInputs,kickAttempts={},{}
>    458→            local pausedAtStart=matchState.phase=="goalPause"
>    459→            local kickoffAtStart=matchState.phase=="kickoff"
>    460→            local inputsLocked=pausedAtStart or kickoffAtStart
>    461→            for slot=1,10 do
>    462→                local input=inputsLocked and {x=0,y=0,kick=false} or (currentInputs[slot] or {x=0,y=0,kick=false})
>    463→                if not inputsLocked then
>    464→                    input=MatchRules2D.filterKickoffInput(matchState,state.players[slot].team,input)
>    465→                end
>    466→                coreInputs[slot]=input
>    467→                if not inputsLocked and input.kick and not lastCoreKickInputs[slot] then table.insert(kickAttempts,slot) end
>    468→                lastCoreKickInputs[slot]=inputsLocked and false or input.kick
>    469→            end
>    470→            for slot,actor in ipairs(state.players) do
>    471→                actor.collisionMask=MatchRules2D.kickoffCollisionMask(matchState,actor.team,state.playerCollisionMasks[slot],ClassicStadium2D.Groups.ball)
>    472→            end
>    473→            local _,coreEvents,coreSubsteps=PhysicsCore2D.stepWorld(state.coreWorld,coreInputs)
>    474→            state.tick=state.coreWorld.tick
>    475→            local stepInfo={substeps=coreSubsteps or 1,ballWallBounces=0,playerWallBounces=0,playerBallContacts=0,lastPlayerBallContact=nil}
>    476→            local acceptedKicks,currentTouches,contactsByPlayer={},{},{}
>    477→            for _,event in ipairs(coreEvents) do
>    478→                if event.kind=="kick" then
>    479→                    acceptedKicks[event.playerId]=true
>    480→                    metrics.successfulKicks+=1
>    481→                    metrics.lastKickSuccessTick=state.tick
>    482→                    logEvent("kickApplied",{playerId=event.playerId,targetId=event.targetId,normalX=event.normalX,normalY=event.normalY},state.tick)
>    483→                    local kicker=state.players[event.playerId]
>    484→                    if kicker then MatchRules2D.recordTouch(matchState,event.playerId,kicker.team,state.tick,"kick") end
>    485→                    if kicker and MatchRules2D.completeKickoff(matchState,kicker.team) then
>    486→                        logEvent("kickoffTaken",{playerId=event.playerId,team=kicker.team},state.tick)
>    487→                    end
>    488→                elseif event.kind=="boundaryContact" then
>    489→                    local count=event.count or 1
>    490→                    if event.discId=="ball" then stepInfo.ballWallBounces+=count
>    491→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=count end
>    492→                elseif event.kind=="planeContact" or event.kind=="segmentContact" then
>    493→                    if event.discId=="ball" then stepInfo.ballWallBounces+=1
>    494→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=1 end
>    495→                elseif event.kind=="discContact" then
>    496→                    local playerId
>    497→                    if event.discA=="ball" and type(event.discB)=="number" then playerId=event.discB
>    498→                    elseif event.discB=="ball" and type(event.discA)=="number" then playerId=event.discA end
>    499→                    if playerId then
>    500→                        stepInfo.playerBallContacts+=1
>    501→                        local nx,ny=event.normalX,event.normalY
>    502→                        if event.discA=="ball" then nx,ny=-nx,-ny end
>    503→                        local contact={playerId=playerId,normalX=nx,normalY=ny,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse}
>    504→                        stepInfo.lastPlayerBallContact=contact
>    505→                        contactsByPlayer[playerId]=contact
>    506→                        currentTouches[playerId]=true
>    507→                        local toucher=state.players[playerId]
>    508→                        if toucher then MatchRules2D.recordTouch(matchState,playerId,toucher.team,state.tick,"contact") end
>    509→                    elseif type(event.discA)=="number" and type(event.discB)=="number" then
>    510→                        metrics.playerContacts+=1
>    511→                        metrics.lastPlayerContactTick=state.tick
>    512→                        metrics.maxPlayerPenetration=math.max(metrics.maxPlayerPenetration,event.penetration or 0)
>    513→                        metrics.lastPlayerImpulse=event.impulse or 0
>    514→                        logEvent("playerPlayerContact",{playerA=event.discA,playerB=event.discB,normalX=event.normalX,normalY=event.normalY,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse},state.tick)
>    515→                    end
>    516→                end
>    517→            end
>    518→            metrics.kickAttempts+=#kickAttempts
>    519→            for _,slot in ipairs(kickAttempts) do
>    520→                local accepted=acceptedKicks[slot]==true
>    521→                local actor=state.players[slot]
>    522→                local separation=math.sqrt((actor.x-b.x)^2+(actor.y-b.y)^2)
>    523→                logEvent("kickAttempt",{playerId=slot,accepted=accepted,separation=separation,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    524→            end
>    525→            for slot,actor in ipairs(state.players) do
>    526→                local dx,dy=actor.x-b.x,actor.y-b.y
>    527→                local touching=math.sqrt(dx*dx+dy*dy)<=actor.radius+b.radius+0.02
>    528→                if currentTouches[slot] and not touchingCoreBall[slot] then
>    529→                    metrics.ballContacts+=1
>    530→                    local contact=contactsByPlayer[slot] or {}
>    531→                    logEvent("playerBallContact",{playerId=slot,separation=actor.radius+b.radius-(contact.penetration or 0),normalX=contact.normalX,normalY=contact.normalY,normalSpeedBefore=contact.normalSpeedBefore,impulse=contact.impulse,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    532→                end
>    533→                touchingCoreBall[slot]=touching
>    534→            end
>    535→            if pausedAtStart then
>    536→                if MatchRules2D.advancePause(matchState) then
>    537→                    MatchRules2D.resetKickoff(b,state.players,state.spawnPoints)
>    538→                    local teamToKick=matchState.lastGoal and (matchState.lastGoal.team=="red" and "blue" or "red") or "red"
>    539→                    MatchRules2D.beginKickoff(matchState,teamToKick)
>    540→                    touchingCoreBall={}
>    541→                    touchingBall=false
>    542→                    logEvent("kickoffReset",{teamToKick=teamToKick,lockTicks=matchState.remainingTicks},state.tick)
>    543→                end
>    544→            elseif kickoffAtStart then
>    545→                if MatchRules2D.advanceKickoff(matchState) then
>    546→                    local teamToKick=matchState.kickoffTeam
>    547→                    MatchRules2D.resume(matchState)
>    548→                    logEvent("kickoffComplete",{teamToKick=teamToKick},state.tick)
>    549→                end
>    550→            else
>    551→                local goal=MatchRules2D.findGoalCrossing(state.coreWorld.motionSegments,"ball")
>    552→                if goal then
>    553→                    goal.tick=state.tick
>    554→                    MatchRules2D.beginGoalPause(matchState,state.score,goal,b,state.players)
>    555→                    currentInputs={}
>    556→                    for slot=1,10 do currentInputs[slot]={x=0,y=0,kick=false} end
>    557→                    currentInput=currentInputs[1]
>    558→                    lastCoreKickInputs={}
>    559→                    touchingCoreBall={}
>    560→                    touchingBall=false
>    561→                    logEvent("goalScored",{team=goal.team,side=goal.side,x=goal.x,y=goal.y,substep=goal.substep,substeps=goal.substeps,fraction=goal.fraction},state.tick)
>    562→                end
>    563→            end
>    564→            physicsStepInfo=stepInfo
>    565→            if speedRunRemaining>0 then
>    566→                speedRunRemaining-=1
>    567→                if speedRunRemaining==0 then
>    568→                    currentInput={x=0,y=0,kick=false}
>    569→                    currentInputs[1]=currentInput
>    570→                    logEvent("speedRunFinished",{ticks=120,playerX=p.x,playerVx=p.vx,playerSpeed=speed(p)},state.tick)
>    571→                end
>    572→            end
>    573→            metrics.lastCollisionSubsteps=stepInfo.substeps
>    574→            metrics.maxCollisionSubsteps=math.max(metrics.maxCollisionSubsteps,stepInfo.substeps)
>    575→            if stepInfo.ballWallBounces>0 then
>    576→                metrics.ballWallBounces+=stepInfo.ballWallBounces
>    577→                logEvent("ballBoundaryBounce",{count=stepInfo.ballWallBounces,x=b.x,y=b.y,vx=b.vx,vy=b.vy,substeps=stepInfo.substeps},state.tick)
>    578→            end
>    579→            if stepInfo.playerWallBounces>0 then
>    580→                metrics.playerWallBounces+=stepInfo.playerWallBounces
>    581→                logEvent("playerBoundaryBounce",{count=stepInfo.playerWallBounces,x=p.x,y=p.y,vx=p.vx,vy=p.vy,substeps=stepInfo.substeps},state.tick)
>    582→            end
>    583→            local separation=math.sqrt((p.x-b.x)^2+(p.y-b.y)^2)
>    584→            local nowTouching=separation<=p.radius+b.radius+0.02
>    585→            touchingBall=nowTouching
>    586→        else
>    587→            if currentInput.kick
>    588→ and not lastKick then
>    589→                metrics.kickAttempts+=1
>    590→                local dx,dy=b.x-p.x,b.y-p.y
>    591→                local separation=math.sqrt(dx*dx+dy*dy)
>    592→                local accepted=Physics2D.tryKick(state,facingX,facingY)
>    593→                if accepted then
>    594→                    metrics.successfulKicks+=1
>    595→                    metrics.lastKickSuccessTick=state.tick+1
>    596→                end
>    597→                logEvent("kickAttempt",{accepted=accepted,separation=separation,playerX=p.x,playerY=p.y,ballX=b.x,ballY=b.y})
>    598→            end
>    599→            lastKick=currentInput.kick
>    600→            local _,stepInfo=Physics2D.step(state,currentInput)
>    601→            physicsStepInfo=stepInfo
>    602→            if speedRunRemaining>0 then
>    603→                speedRunRemaining-=1
>    604→                if speedRunRemaining==0 then
>    605→                    currentInput={x=0,y=0,kick=false}
>    606→                    currentInputs[1]=currentInput
>    607→                    logEvent("speedRunFinished",{ticks=120,playerX=p.x,playerVx=p.vx,playerSpeed=speed(p)},state.tick)
>    608→                end
>    609→            end
>    610→            metrics.lastCollisionSubsteps=stepInfo.substeps
>    611→            metrics.maxCollisionSubsteps=math.max(metrics.maxCollisionSubsteps,stepInfo.substeps)
>    612→            if stepInfo.ballWallBounces>0 then
>    613→                metrics.ballWallBounces+=stepInfo.ballWallBounces
>    614→                logEvent("ballBoundaryBounce",{count=stepInfo.ballWallBounces,x=b.x,y=b.y,vx=b.vx,vy=b.vy,substeps=stepInfo.substeps},state.tick)
>    615→            end
>    616→            if stepInfo.playerWallBounces>0 then
>    617→                metrics.playerWallBounces+=stepInfo.playerWallBounces
>    618→                logEvent("playerBoundaryBounce",{count=stepInfo.playerWallBounces,x=p.x,y=p.y,vx=p.vx,vy=p.vy,substeps=stepInfo.substeps},state.tick)
>    619→            end
>    620→            local separation=math.sqrt((p.x-b.x)^2+(p.y-b.y)^2)
>    621→            local nowTouching=separation<=p.radius+b.radius+0.02
>    622→            if stepInfo.playerBallContacts>0 and not touchingBall then
>    623→                metrics.ballContacts+=1
>    624→                local contact=stepInfo.lastPlayerBallContact or {}
>    625→                logEvent("playerBallContact",{
>    626→                    separation=p.radius+b.radius-(contact.penetration or 0),postStepSeparation=separation,
>    627→                    contactsThisTick=stepInfo.playerBallContacts,substep=contact.substep,substeps=stepInfo.substeps,
>    628→                    normalX=contact.normalX,normalY=contact.normalY,normalSpeedBefore=contact.normalSpeedBefore,
>    629→                    impulse=contact.impulse,penetration=contact.penetration,playerX=p.x,playerY=p.y,ballX=b.x,ballY=b.y,
>    630→                },state.tick)
>    631→            end
>    632→            touchingBall=nowTouching
>    633→        end
>    634→
>    635→        accumulator-=stepDt
>    636→        iterations+=1
>    637→        local current=snapshot()
>    638→        if recording then
>    639→            historyBuffer[historyWrite]={
>    640→                tick=current.tick,gameTime=current.gameTime,pairMode=pairMode,crowdMode=crowdMode,
>    641→                inputX=current.input.x,inputY=current.input.y,kick=current.input.kick,
>    642→                playerX=p.x,playerY=p.y,playerVx=p.vx,playerVy=p.vy,playerSpeed=current.player.speed,
>    643→                player2X=p2.x,player2Y=p2.y,player2Vx=p2.vx,player2Vy=p2.vy,player2Speed=current.player2.speed,
>    644→                players=current.players,
>    645→                ballX=b.x,ballY=b.y,ballVx=b.vx,ballVy=b.vy,ballSpeed=current.ball.speed,
>    646→                separation=current.separation,playerSeparation=current.playerSeparation,player2BallSeparation=current.player2BallSeparation,
>    647→                pairPenetration=pairResolution and pairResolution.penetration or 0,
>    648→                crowdContacts=metrics.crowdContacts,crowdResidual=metrics.crowdLastResidualPenetration,solverIterations=metrics.crowdLastSolverIterations,
>    649→                physicsSubsteps=physicsStepInfo and physicsStepInfo.substeps or 0,
>    650→                residualP1P2=crowdResiduals and crowdResiduals["player1-player2"] or 0,
>    651→                residualP1Ball=crowdResiduals and crowdResiduals["player1-ball"] or 0,
>    652→                residualP2Ball=crowdResiduals and crowdResiduals["player2-ball"] or 0,
>    653→                pairNormalX=pairResolution and pairResolution.normalX or 0,
>    654→                pairNormalY=pairResolution and pairResolution.normalY or 0,
>    655→                pairImpulse=pairResolution and pairResolution.impulse or 0,
>    656→                touchingBall=current.touchingBall,touchingPlayers=current.touchingPlayers,
>    657→            }
>    658→            historyWrite=(historyWrite%historyCapacity)+1
>    659→            historyCount=math.min(historyCapacity,historyCount+1)
>    660→        end
>    661→        snapshotRemote:FireAllClients(current)
>    662→    end
>    663→end)
>    664→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.PhysicsCore2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→-- Deterministic 2D match core.
>      2→-- Logical coordinates use Haxball stadium units. One call to stepWorld is one fixed game tick.
>      3→-- Collision order follows the explicit disc insertion order: dynamic pairs, then static geometry per disc.
>      4→local Core = {}
>      5→
>      6→local DEFAULTS = {
>      7→    tickRate = 60,
>      8→    playerAcceleration = 0.1,
>      9→    playerKickAcceleration = 0.07,
>     10→    playerDamping = 0.96,
>     11→    playerKickDamping = 0.96,
>     12→    ballDamping = 0.99,
>     13→    defaultBounce = 0.5,
>     14→    maxSubsteps = 64,
>     15→    kickRangeExtra = 4,
>     16→    kickCooldownTicks = 2,
>     17→    fieldHalfWidth = 420,
>     18→    fieldHalfHeight = 200,
>     19→}
>     20→
>     21→local function finite(value)
>     22→    return type(value) == "number" and value == value and math.abs(value) < 1e12
>     23→end
>     24→
>     25→local function validMask(value)
>     26→    return finite(value) and value >= 0 and value <= 0xFFFFFFFF and math.floor(value) == value
>     27→end
>     28→
>     29→local function idKey(id)
>     30→    return typeof(id) .. ":" .. tostring(id)
>     31→end
>     32→
>     33→function Core.newWorld(config)
>     34→    config = config or {}
>     35→    local settings = table.clone(DEFAULTS)
>     36→    for key, value in pairs(config) do
>     37→        settings[key] = value
>     38→    end
>     39→    assert(finite(settings.tickRate) and settings.tickRate > 0, "tickRate must be positive")
>     40→    assert(finite(settings.fieldHalfWidth) and settings.fieldHalfWidth > 0, "fieldHalfWidth must be positive")
>     41→    assert(finite(settings.fieldHalfHeight) and settings.fieldHalfHeight > 0, "fieldHalfHeight must be positive")
>     42→    assert(finite(settings.maxSubsteps) and settings.maxSubsteps>=1 and settings.maxSubsteps<=256 and math.floor(settings.maxSubsteps)==settings.maxSubsteps, "maxSubsteps must be an integer from 1 to 256")
>     43→    return {
>     44→        tick = 0,
>     45→        config = settings,
>     46→        discs = {},
>     47→        discById = {},
>     48→        events = {},
>     49→        planes = {},
>     50→        segments = {},
>     51→        geometryById = {},
>     52→        useBounds = settings.useBounds ~= false,
>     53→        lastSubsteps = 0,
>     54→        motionSegments = {},
>     55→    }
>     56→end
>     57→
>     58→function Core.newDisc(spec)
>     59→    assert(type(spec) == "table", "disc spec must be a table")
>     60→    assert(spec.id ~= nil and (type(spec.id)=="number" or type(spec.id)=="string"), "disc id must be a number or string")
>     61→    local disc = {
>     62→        id = spec.id,
>     63→        kind = spec.kind or "disc",
>     64→        team = spec.team,
>     65→        x = spec.x or 0,
>     66→        y = spec.y or 0,
>     67→        vx = spec.vx or 0,
>     68→        vy = spec.vy or 0,
>     69→        gravityX = spec.gravityX or 0,
>     70→        gravityY = spec.gravityY or 0,
>     71→        radius = spec.radius or 10,
>     72→        invMass = spec.invMass == nil and 1 or spec.invMass,
>     73→        damping = spec.damping == nil and 1 or spec.damping,
>     74→        bCoef = spec.bCoef == nil and DEFAULTS.defaultBounce or spec.bCoef,
>     75→        collisionGroup = spec.collisionGroup == nil and 1 or spec.collisionGroup,
>     76→        collisionMask = spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
>     77→        acceleration = spec.acceleration or DEFAULTS.playerAcceleration,
>     78→        kickAcceleration = spec.kickAcceleration or DEFAULTS.playerKickAcceleration,
>     79→        kickDamping = spec.kickDamping == nil and (spec.damping or DEFAULTS.playerDamping) or spec.kickDamping,
>     80→        kickStrength = spec.kickStrength or 0,
>     81→        kickback = spec.kickback or 0,
>     82→        kickRangeExtra = spec.kickRangeExtra == nil and DEFAULTS.kickRangeExtra or spec.kickRangeExtra,
>     83→        kickable = spec.kickable == true,
>     84→        kickHeld = false,
>     85→        kickArmed = false,
>     86→        kickCooldown = 0,
>     87→        maxSpeed = spec.maxSpeed,
>     88→        enabled = spec.enabled ~= false,
>     89→        traceMotion = spec.traceMotion == true,
>     90→    }
>     91→    for _, key in ipairs({"x","y","vx","vy","gravityX","gravityY","radius","invMass","damping","bCoef","acceleration","kickAcceleration","kickDamping","kickStrength","kickback","kickRangeExtra"}) do
>     92→        assert(finite(disc[key]), "disc field must be finite: " .. key)
>     93→    end
>     94→    assert(disc.radius > 0, "disc radius must be positive")
>     95→    assert(disc.invMass >= 0, "inverse mass cannot be negative")
>     96→    assert(disc.damping >= 0 and disc.kickDamping >= 0, "damping cannot be negative")
>     97→    assert(validMask(disc.collisionGroup) and validMask(disc.collisionMask), "collision flags must be unsigned 32-bit integers")
>     98→    if disc.maxSpeed ~= nil then
>     99→        assert(finite(disc.maxSpeed) and disc.maxSpeed > 0, "maxSpeed must be positive")
>    100→    end
>    101→    return disc
>    102→end
>    103→
>    104→function Core.addDisc(world, spec)
>    105→    assert(type(world) == "table" and type(world.discs) == "table", "invalid world")
>    106→    local disc = Core.newDisc(spec)
>    107→    local key = idKey(disc.id)
>    108→    assert(world.discById[key] == nil, "duplicate disc id: " .. tostring(disc.id))
>    109→    world.discById[key] = disc
>    110→    -- Insertion order is the solver order; build worlds in their intended physical order.
>    111→    table.insert(world.discs, disc)
>    112→    return disc
>    113→end
>    114→
>    115→function Core.addPlane(world, spec)
>    116→    assert(type(spec) == "table" and spec.id ~= nil, "plane id is required")
>    117→    local nx, ny = spec.normalX, spec.normalY
>    118→    assert(finite(nx) and finite(ny), "plane normal must be finite")
>    119→    local length = math.sqrt(nx*nx+ny*ny)
>    120→    assert(length > 1e-12, "plane normal cannot be zero")
>    121→    local plane = {
>    122→        id=spec.id, normalX=nx/length, normalY=ny/length,
>    123→        offset=spec.offset or 0, bCoef=spec.bCoef == nil and 0.5 or spec.bCoef,
>    124→        collisionGroup=spec.collisionGroup == nil and 1 or spec.collisionGroup,
>    125→        collisionMask=spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
>    126→    }
>    127→    assert(finite(plane.offset) and finite(plane.bCoef), "plane values must be finite")
>    128→    assert(validMask(plane.collisionGroup) and validMask(plane.collisionMask), "plane collision flags must be unsigned 32-bit integers")
>    129→    local key="plane:"..idKey(plane.id)
>    130→    assert(not world.geometryById[key], "duplicate plane id")
>    131→    world.geometryById[key]=true
>    132→    table.insert(world.planes,plane)
>    133→    return plane
>    134→end
>    135→
>    136→local function segmentArcData(x1,y1,x2,y2,curveDegrees)
>    137→    if math.abs(curveDegrees)<1e-9 then return nil end
>    138→    assert(math.abs(curveDegrees)<360, "segment curve must be between -360 and 360 degrees")
>    139→    local dx,dy=x2-x1,y2-y1
>    140→    local chord=math.sqrt(dx*dx+dy*dy)
>    141→    local sweep=math.rad(curveDegrees)
>    142→    local half=sweep*0.5
>    143→    local offset
>    144→    if math.abs(math.abs(curveDegrees)-180)<1e-8 then
>    145→        offset=0
>    146→    else
>    147→        local tangent=math.tan(half)
>    148→        assert(math.abs(tangent)>1e-12, "invalid curved segment")
>    149→        offset=chord/(2*tangent)
>    150→    end
>    151→    local midX,midY=(x1+x2)*0.5,(y1+y2)*0.5
>    152→    local leftX,leftY=-dy/chord,dx/chord
>    153→    local centerX,centerY=midX+leftX*offset,midY+leftY*offset
>    154→    local radius=math.sqrt((x1-centerX)^2+(y1-centerY)^2)
>    155→    assert(finite(radius) and radius>1e-9, "invalid curved segment radius")
>    156→    return {centerX=centerX,centerY=centerY,radius=radius,startAngle=math.atan2(y1-centerY,x1-centerX),sweep=sweep}
>    157→end
>    158→
>    159→function Core.addSegment(world, spec)
>    160→    assert(type(spec) == "table" and spec.id ~= nil, "segment id is required")
>    161→    local segment = {
>    162→        id=spec.id, x1=spec.x1, y1=spec.y1, x2=spec.x2, y2=spec.y2,
>    163→        bCoef=spec.bCoef == nil and 0.5 or spec.bCoef,
>    164→        collisionGroup=spec.collisionGroup == nil and 1 or spec.collisionGroup,
>    165→        collisionMask=spec.collisionMask == nil and 0xFFFFFFFF or spec.collisionMask,
>    166→        twoSided=spec.twoSided ~= false,
>    167→        kickoffOnly=spec.kickoffOnly == true,
>    168→        curveDegrees=spec.curveDegrees or spec.curve or 0,
>    169→    }
>    170→    for _, key in ipairs({"x1","y1","x2","y2","bCoef","curveDegrees"}) do
>    171→        assert(finite(segment[key]), "segment field must be finite: "..key)
>    172→    end
>    173→    assert(validMask(segment.collisionGroup) and validMask(segment.collisionMask), "segment collision flags must be unsigned 32-bit integers")
>    174→    local dx,dy=segment.x2-segment.x1,segment.y2-segment.y1
>    175→    assert(dx*dx+dy*dy>1e-16, "segment endpoints must differ")
>    176→    local key="segment:"..idKey(segment.id)
>    177→    assert(not world.geometryById[key], "duplicate segment id")
>    178→    world.geometryById[key]=true
>    179→    segment.arc=segmentArcData(segment.x1,segment.y1,segment.x2,segment.y2,segment.curveDegrees)
>    180→    table.insert(world.segments,segment)
>    181→    return segment
>    182→end
>    183→
>    184→local function collisionAllowed(a, b)
>    185→    return bit32.band(a.collisionGroup, b.collisionMask) ~= 0
>    186→        and bit32.band(b.collisionGroup, a.collisionMask) ~= 0
>    187→end
>    188→
>    189→local function applyInputAndKick(world, inputs, events)
>    190→    local cfg = world.config
>    191→    for _, player in ipairs(world.discs) do
>    192→        if player.enabled and player.kind == "player" then
>    193→            local input = inputs[player.id] or inputs[idKey(player.id)] or {}
>    194→            if type(input) ~= "table" then input = {} end
>    195→            local ix = finite(input.x) and input.x or 0
>    196→            local iy = finite(input.y) and input.y or 0
>    197→            local magnitude = math.sqrt(ix*ix + iy*iy)
>    198→            if magnitude > 1 then ix, iy = ix/magnitude, iy/magnitude end
>    199→
>    200→            local kickHeld = input.kick == true
>    201→            if kickHeld and not player.kickHeld then
>    202→                player.kickArmed = true
>    203→            elseif not kickHeld then
>    204→                player.kickArmed = false
>    205→            end
>    206→            player.kickHeld = kickHeld
>    207→            if player.kickCooldown > 0 then player.kickCooldown -= 1 end
>    208→
>    209→            if player.kickArmed and player.kickCooldown <= 0 then
>    210→                for _, target in ipairs(world.discs) do
>    211→                    if target.enabled and target.kickable and target.invMass > 0 then
>    212→                        local dx, dy = target.x-player.x, target.y-player.y
>    213→                        local distance = math.sqrt(dx*dx+dy*dy)
>    214→                        local extra = player.kickRangeExtra
>    215→                        if distance > 0 and distance-player.radius-target.radius < extra then
>    216→                            local nx, ny = dx/distance, dy/distance
>    217→                            target.vx += nx*player.kickStrength*target.invMass
>    218→                            target.vy += ny*player.kickStrength*target.invMass
>    219→                            player.vx -= nx*player.kickback*player.invMass
>    220→                            player.vy -= ny*player.kickback*player.invMass
>    221→                            player.kickArmed = false
>    222→                            player.kickCooldown = cfg.kickCooldownTicks
>    223→                            table.insert(events, {kind="kick", tick=world.tick+1, playerId=player.id, targetId=target.id, normalX=nx, normalY=ny})
>    224→                            break
>    225→                        end
>    226→                    end
>    227→                end
>    228→            end
>    229→
>    230→            local accel = player.kickArmed and player.kickAcceleration or player.acceleration
>    231→            player.vx += ix*accel
>    232→            player.vy += iy*accel
>    233→            if player.maxSpeed then
>    234→                local speed = math.sqrt(player.vx*player.vx+player.vy*player.vy)
>    235→                if speed > player.maxSpeed then
>    236→                    local scale = player.maxSpeed/speed
>    237→                    player.vx *= scale
>    238→                    player.vy *= scale
>    239→                end
>    240→            end
>    241→        end
>    242→    end
>    243→end
>    244→
>    245→local function integrate(world)
>    246→    for _, disc in ipairs(world.discs) do
>    247→        if disc.enabled and disc.invMass > 0 then
>    248→            disc.x += disc.vx
>    249→            disc.y += disc.vy
>    250→            local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping
>    251→            disc.vx = (disc.vx+disc.gravityX)*damping
>    252→            disc.vy = (disc.vy+disc.gravityY)*damping
>    253→        end
>    254→    end
>    255→end
>    256→
>    257→local function resolveBoundsForDisc(world, disc, events, eventKeys)
>    258→    if not world.useBounds or not disc.enabled or disc.invMass<=0 then return end
>    259→    local cfg=world.config
>    260→    local minX,maxX=-cfg.fieldHalfWidth+disc.radius,cfg.fieldHalfWidth-disc.radius
>    261→    local minY,maxY=-cfg.fieldHalfHeight+disc.radius,cfg.fieldHalfHeight-disc.radius
>    262→    local bounceCount=0
>    263→    if disc.x<minX then disc.x=minX;if disc.vx<0 then disc.vx=-disc.vx*disc.bCoef;bounceCount+=1 end
>    264→    elseif disc.x>maxX then disc.x=maxX;if disc.vx>0 then disc.vx=-disc.vx*disc.bCoef;bounceCount+=1 end end
>    265→    if disc.y<minY then disc.y=minY;if disc.vy<0 then disc.vy=-disc.vy*disc.bCoef;bounceCount+=1 end
>    266→    elseif disc.y>maxY then disc.y=maxY;if disc.vy>0 then disc.vy=-disc.vy*disc.bCoef;bounceCount+=1 end end
>    267→    if bounceCount>0 then
>    268→        local key="boundary:"..idKey(disc.id)
>    269→        local event=eventKeys[key]
>    270→        if event then event.count+=bounceCount
>    271→        else
>    272→            event={kind="boundaryContact",tick=world.tick+1,discId=disc.id,count=bounceCount}
>    273→            eventKeys[key]=event
>    274→            table.insert(events,event)
>    275→        end
>    276→    end
>    277→end
>    278→
>    279→local function resolveDiscPair(a, b)
>    280→    local dx, dy = a.x-b.x, a.y-b.y
>    281→    local d2 = dx*dx+dy*dy
>    282→    local radii = a.radius+b.radius
>    283→    if d2 > radii*radii then return nil end
>    284→
>    285→    local distance, nx, ny
>    286→    if d2 > 1e-16 then
>    287→        distance = math.sqrt(d2)
>    288→        nx, ny = dx/distance, dy/distance
>    289→    else
>    290→        -- Deterministic fallback for coincident centers. Original Haxball behavior
>    291→        -- at exact coincidence must still be verified against an official oracle.
>    292→        distance = 0
>    293→        nx, ny = -1, 0
>    294→    end
>    295→
>    296→    local overlap = radii-distance
>    297→    local invSum = a.invMass+b.invMass
>    298→    if invSum <= 0 then return nil end
>    299→    local mf = a.invMass/invSum
>    300→    local shareA = overlap*mf
>    301→    a.x += nx*shareA
>    302→    a.y += ny*shareA
>    303→    local shareB = overlap-shareA
>    304→    b.x -= nx*shareB
>    305→    b.y -= ny*shareB
>    306→
>    307→    local normalSpeedBefore=nx*(a.vx-b.vx)+ny*(a.vy-b.vy)
>    308→    local normalVelocity=normalSpeedBefore
>    309→    local impulseMagnitude = 0
>    310→    if normalVelocity < 0 then
>    311→        -- Haxball-style restitution uses the product of disk bounce coefficients.
>    312→        normalVelocity *= (a.bCoef*b.bCoef+1)
>    313→        local changeA = mf*normalVelocity
>    314→        a.vx -= nx*changeA
>    315→        a.vy -= ny*changeA
>    316→        local changeB = normalVelocity-changeA
>    317→        b.vx += nx*changeB
>    318→        b.vy += ny*changeB
>    319→        impulseMagnitude = math.abs(normalVelocity)/invSum
>    320→    end
>    321→    return {normalX=nx,normalY=ny,penetration=overlap,normalSpeedBefore=normalSpeedBefore,impulse=impulseMagnitude}
>    322→end
>    323→
>    324→local function resolveStaticGeometryForDisc(world, disc, events, eventKeys)
>    325→    if not disc.enabled or disc.invMass<=0 then return end
>    326→    local function collide(geometry, kind, nx, ny, penetration)
>    327→        if not collisionAllowed(disc,geometry) or penetration<=0 then return end
>    328→        disc.x+=nx*penetration
>    329→        disc.y+=ny*penetration
>    330→        local normalVelocity=disc.vx*nx+disc.vy*ny
>    331→        local impulse=0
>    332→        if normalVelocity<0 then
>    333→            local change=-(1+disc.bCoef*geometry.bCoef)*normalVelocity
>    334→            disc.vx+=nx*change
>    335→            disc.vy+=ny*change
>    336→            impulse=change/disc.invMass
>    337→        end
>    338→        local key=kind..":"..idKey(disc.id)..":"..idKey(geometry.id)
>    339→        local event=eventKeys[key]
>    340→        if event then
>    341→            event.penetration=math.max(event.penetration,penetration)
>    342→            event.impulse=math.max(event.impulse,impulse)
>    343→        else
>    344→            event={kind=kind,tick=world.tick+1,discId=disc.id,geometryId=geometry.id,normalX=nx,normalY=ny,penetration=penetration,impulse=impulse}
>    345→            eventKeys[key]=event
>    346→            table.insert(events,event)
>    347→        end
>    348→    end
>    349→
>    350→    for _,plane in ipairs(world.planes) do
>    351→        local signed=disc.x*plane.normalX+disc.y*plane.normalY-plane.offset
>    352→        local penetration=disc.radius-signed
>    353→        if penetration>0 then collide(plane,"planeContact",plane.normalX,plane.normalY,penetration) end
>    354→    end
>    355→    for _,segment in ipairs(world.segments) do
>    356→        local qx,qy
>    357→        if segment.arc then
>    358→            local arc=segment.arc
>    359→            local angle=math.atan2(disc.y-arc.centerY,disc.x-arc.centerX)
>    360→            local delta=arc.sweep>=0 and ((angle-arc.startAngle)%(2*math.pi)) or ((arc.startAngle-angle)%(2*math.pi))
>    361→            if delta<=math.abs(arc.sweep)+1e-9 then
>    362→                qx=arc.centerX+arc.radius*math.cos(angle)
>    363→                qy=arc.centerY+arc.radius*math.sin(angle)
>    364→            else
>    365→                local dStart=(disc.x-segment.x1)^2+(disc.y-segment.y1)^2
>    366→                local dEnd=(disc.x-segment.x2)^2+(disc.y-segment.y2)^2
>    367→                if dStart<=dEnd then qx,qy=segment.x1,segment.y1 else qx,qy=segment.x2,segment.y2 end
>    368→            end
>    369→        else
>    370→            local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
>    371→            local length2=sx*sx+sy*sy
>    372→            local t=math.clamp(((disc.x-segment.x1)*sx+(disc.y-segment.y1)*sy)/length2,0,1)
>    373→            qx,qy=segment.x1+t*sx,segment.y1+t*sy
>    374→        end
>    375→        local dx,dy=disc.x-qx,disc.y-qy
>    376→        local distance2=dx*dx+dy*dy
>    377→        if distance2<disc.radius*disc.radius then
>    378→            local distance,nx,ny
>    379→            if distance2>1e-16 then
>    380→                distance=math.sqrt(distance2);nx,ny=dx/distance,dy/distance
>    381→            elseif segment.arc then
>    382→                local arc=segment.arc
>    383→                local angle=arc.startAngle+arc.sweep*0.5
>    384→                nx,ny=math.cos(angle),math.sin(angle)
>    385→                distance=0
>    386→            else
>    387→                local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
>    388→                local length=math.sqrt(sx*sx+sy*sy)
>    389→                nx,ny=-sy/length,sx/length
>    390→                if not segment.twoSided and (disc.x-segment.x1)*nx+(disc.y-segment.y1)*ny<0 then nx,ny=-nx,-ny end
>    391→            end
>    392→            local allowed=segment.arc~=nil or segment.twoSided
>    393→            if not allowed then
>    394→                local sx,sy=segment.x2-segment.x1,segment.y2-segment.y1
>    395→                local length=math.sqrt(sx*sx+sy*sy)
>    396→                allowed=(disc.x-segment.x1)*(-sy/length)+(disc.y-segment.y1)*(sx/length)>=-1e-9
>    397→            end
>    398→            if allowed then collide(segment,"segmentContact",nx,ny,disc.radius-(distance or 0)) end
>    399→        end
>    400→    end
>    401→end
>    402→
>    403→function Core.stepWorld(world, inputs)
>    404→    assert(type(world) == "table" and type(world.discs) == "table", "invalid world")
>    405→    inputs = inputs or {}
>    406→    local events,eventKeys = {},{}
>    407→    world.motionSegments={}
>    408→    applyInputAndKick(world, inputs, events)
>    409→
>    410→    local maxSpeed,minRadius=0,math.huge
>    411→    for _,disc in ipairs(world.discs) do
>    412→        if disc.enabled and disc.invMass>0 then
>    413→            maxSpeed=math.max(maxSpeed,math.sqrt(disc.vx*disc.vx+disc.vy*disc.vy))
>    414→            minRadius=math.min(minRadius,disc.radius)
>    415→        end
>    416→    end
>    417→    local substeps=1
>    418→    if minRadius<math.huge then
>    419→        local maxDistance=math.max(0.5,minRadius*0.5)
>    420→        substeps=math.clamp(math.ceil(maxSpeed/maxDistance),1,world.config.maxSubsteps)
>    421→    end
>    422→    world.lastSubsteps=substeps
>    423→
>    424→    -- Adaptive microsteps reduce discrete tunneling while preserving one input,
>    425→    -- gravity, and damping application per logical tick.
>    426→    for substep=1,substeps do
>    427→        for _,disc in ipairs(world.discs) do
>    428→            if disc.enabled and disc.invMass>0 then
>    429→                local startX,startY=disc.x,disc.y
>    430→                disc.x+=disc.vx/substeps
>    431→                disc.y+=disc.vy/substeps
>    432→                if disc.traceMotion then
>    433→                    table.insert(world.motionSegments,{discId=disc.id,x0=startX,y0=startY,x1=disc.x,y1=disc.y,substep=substep,substeps=substeps})
>    434→                end
>    435→            end
>    436→        end
>    437→
>    438→        -- Preserve declared solver order inside each microstep.
>    439→        for i=1,#world.discs do
>    440→            local a=world.discs[i]
>    441→            if a.enabled then
>    442→                for j=i+1,#world.discs do
>    443→                    local b=world.discs[j]
>    444→                    if b.enabled and (a.invMass>0 or b.invMass>0) and collisionAllowed(a,b) then
>    445→                        local contact=resolveDiscPair(a,b)
>    446→                        if contact then
>    447→                            local key="pair:"..idKey(a.id)..":"..idKey(b.id)
>    448→                            local existing=eventKeys[key]
>    449→                            if existing then
>    450→                                existing.penetration=math.max(existing.penetration,contact.penetration)
>    451→                                existing.impulse=math.max(existing.impulse,contact.impulse)
>    452→                            else
>    453→                                contact.kind="discContact"
>    454→                                contact.tick=world.tick+1
>    455→                                contact.discA=a.id
>    456→                                contact.discB=b.id
>    457→                                eventKeys[key]=contact
>    458→                                table.insert(events,contact)
>    459→                            end
>    460→                        end
>    461→                    end
>    462→                end
>    463→                resolveBoundsForDisc(world,a,events,eventKeys)
>    464→                resolveStaticGeometryForDisc(world,a,events,eventKeys)
>    465→            end
>    466→        end
>    467→    end
>    468→
>    469→    -- Retain the reference's per-tick velocity update after position and contacts.
>    470→    for _,disc in ipairs(world.discs) do
>    471→        if disc.enabled and disc.invMass>0 then
>    472→            local damping=(disc.kind=="player" and disc.kickArmed) and disc.kickDamping or disc.damping
>    473→            disc.vx=(disc.vx+disc.gravityX)*damping
>    474→            disc.vy=(disc.vy+disc.gravityY)*damping
>    475→        end
>    476→    end
>    477→
>    478→    world.tick += 1
>    479→    world.events = events
>    480→    return world, events, substeps
>    481→end
>    482→
>    483→function Core.snapshot(world)
>    484→    local discs = table.create(#world.discs)
>    485→    for index, disc in ipairs(world.discs) do
>    486→        discs[index] = {
>    487→            id=disc.id, kind=disc.kind, team=disc.team, x=disc.x, y=disc.y,
>    488→            vx=disc.vx, vy=disc.vy, radius=disc.radius, invMass=disc.invMass,
>    489→            damping=disc.damping, bCoef=disc.bCoef, collisionGroup=disc.collisionGroup,
>    490→            collisionMask=disc.collisionMask, kickCooldown=disc.kickCooldown,
>    491→        }
>    492→    end
>    493→    return {tick=world.tick, tickRate=world.config.tickRate, substeps=world.lastSubsteps, discs=discs, events=table.clone(world.events)}
>    494→end
>    495→
>    496→return Core
>    497→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.Physics2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local ReplicatedStorage = game:GetService("ReplicatedStorage")
>      2→local Profile = require(ReplicatedStorage:WaitForChild("HaxballLab"):WaitForChild("StadiumReference2D"))
>      3→local Physics2D = {}
>      4→Physics2D.MatchCore = require(script.Parent:WaitForChild("PhysicsCore2D"))
>      5→
>      6→local P = Profile.PhysicsBaseline.active
>      7→local Solver = Profile.PhysicsBaseline.labSolver
>      8→Physics2D.Config = {
>      9→    tickRate = Profile.Simulation.tickRate.value,
>     10→    playerRadius = P.player.radius,
>     11→    playerInvMass = P.player.invMass,
>     12→    playerDamping = P.player.damping,
>     13→    playerBounce = P.player.bounce,
>     14→    playerAcceleration = P.player.acceleration,
>     15→    playerKickAcceleration = P.player.kickAcceleration,
>     16→    playerKickDamping = P.player.kickDamping,
>     17→    ballRadius = P.ball.radius,
>     18→    ballInvMass = P.ball.invMass,
>     19→    ballDamping = P.ball.damping,
>     20→    ballBounce = P.ball.bounce,
>     21→    kickStrength = P.player.kickStrength,
>     22→    kickback = P.player.kickback,
>     23→    kickRangeExtra = P.kickRangeExtra,
>     24→    fieldHalfWidth = Profile.Bounds.halfWidth,
>     25→    fieldHalfHeight = Profile.Bounds.halfHeight,
>     26→    collisionIterations = Solver.collisionIterations,
>     27→    maxCollisionSubsteps = Solver.maxSubsteps,
>     28→    collisionSubstepRadiusFraction = Solver.substepRadiusFraction,
>     29→}
>     30→
>     31→local C = Physics2D.Config
>     32→local function clampMagnitude(x, y, maxMagnitude)
>     33→    local m = math.sqrt(x*x + y*y)
>     34→    if m > maxMagnitude and m > 0 then
>     35→        local scale = maxMagnitude / m
>     36→        return x * scale, y * scale
>     37→    end
>     38→    return x, y
>     39→end
>     40→
>     41→local function newPlayer(id, x, y)
>     42→    return {
>     43→        id=id, x=x, y=y, vx=0, vy=0,
>     44→        radius=C.playerRadius, invMass=C.playerInvMass,
>     45→        damping=C.playerDamping, bounce=C.playerBounce,
>     46→    }
>     47→end
>     48→
>     49→function Physics2D.newState()
>     50→    return {
>     51→        tick = 0,
>     52→        player = newPlayer(1, -80, 0),
>     53→        player2 = newPlayer(2, 0, 0),
>     54→        ball = { id=3, x=0, y=0, vx=0, vy=0, radius=C.ballRadius, invMass=C.ballInvMass, damping=C.ballDamping, bounce=C.ballBounce },
>     55→        score = { red = 0, blue = 0 },
>     56→    }
>     57→end
>     58→
>     59→local function resolveDiscs(a, b)
>     60→    local dx, dy = a.x - b.x, a.y - b.y
>     61→    local d2 = dx*dx + dy*dy
>     62→    local radii = a.radius + b.radius
>     63→    if d2 > radii*radii then return nil end
>     64→
>     65→    local d = math.sqrt(d2)
>     66→    local nx, ny
>     67→    if d > 1e-8 then
>     68→        nx, ny = dx/d, dy/d
>     69→    else
>     70→        local aId, bId = a.id or 1, b.id or 2
>     71→        nx, ny = aId <= bId and -1 or 1, 0
>     72→    end
>     73→
>     74→    local penetration = math.max(0, radii - d)
>     75→    local invSum = a.invMass + b.invMass
>     76→    if invSum <= 0 then
>     77→        return {
>     78→            normalX=nx, normalY=ny, penetration=penetration,
>     79→            correctionA=0, correctionB=0, normalSpeedBefore=0, impulse=0,
>     80→        }
>     81→    end
>     82→
>     83→    local moveA = penetration * (a.invMass / invSum)
>     84→    local moveB = penetration * (b.invMass / invSum)
>     85→    a.x, a.y = a.x + nx*moveA, a.y + ny*moveA
>     86→    b.x, b.y = b.x - nx*moveB, b.y - ny*moveB
>     87→
>     88→    local rvx, rvy = a.vx - b.vx, a.vy - b.vy
>     89→    local normalSpeed = rvx*nx + rvy*ny
>     90→    local impulse = 0
>     91→    if normalSpeed < 0 then
>     92→        local restitution = math.min(a.bounce, b.bounce)
>     93→        impulse = -(1 + restitution) * normalSpeed / invSum
>     94→        a.vx, a.vy = a.vx + nx*impulse*a.invMass, a.vy + ny*impulse*a.invMass
>     95→        b.vx, b.vy = b.vx - nx*impulse*b.invMass, b.vy - ny*impulse*b.invMass
>     96→    end
>     97→
>     98→    return {
>     99→        normalX=nx, normalY=ny, penetration=penetration,
>    100→        correctionA=moveA, correctionB=moveB,
>    101→        normalSpeedBefore=normalSpeed, impulse=impulse,
>    102→    }
>    103→end
>    104→Physics2D.resolveDiscs = resolveDiscs
>    105→
>    106→local function wall(d, halfW, halfH)
>    107→    local minX, maxX = -halfW + d.radius, halfW - d.radius
>    108→    local minY, maxY = -halfH + d.radius, halfH - d.radius
>    109→    if d.x < minX then d.x = minX; if d.vx < 0 then d.vx = -d.vx*d.bounce end end
>    110→    if d.x > maxX then d.x = maxX; if d.vx > 0 then d.vx = -d.vx*d.bounce end end
>    111→    if d.y < minY then d.y = minY; if d.vy < 0 then d.vy = -d.vy*d.bounce end end
>    112→    if d.y > maxY then d.y = maxY; if d.vy > 0 then d.vy = -d.vy*d.bounce end end
>    113→end
>    114→
>    115→local function advanceAxis(position,velocity,minBound,maxBound,dt,bounce)
>    116→    local remaining=dt
>    117→    local hits=0
>    118→    local guard=0
>    119→    while remaining>1e-9 and guard<256 do
>    120→        guard+=1
>    121→        local timeToWall=math.huge
>    122→        if velocity>1e-9 then
>    123→            timeToWall=(maxBound-position)/velocity
>    124→        elseif velocity< -1e-9 then
>    125→            timeToWall=(minBound-position)/velocity
>    126→        end
>    127→        if timeToWall< -1e-8 then
>    128→            if position<minBound then position=minBound else position=maxBound end
>    129→            timeToWall=0
>    130→        end
>    131→        if timeToWall>remaining or timeToWall==math.huge then
>    132→            position+=velocity*remaining
>    133→            remaining=0
>    134→        else
>    135→            position+=velocity*timeToWall
>    136→            remaining-=timeToWall
>    137→            position=velocity>0 and maxBound or minBound
>    138→            velocity=-velocity*bounce
>    139→            hits+=1
>    140→            if math.abs(velocity)<=1e-9 then velocity=0; remaining=0 end
>    141→        end
>    142→    end
>    143→    if remaining>1e-9 then position+=velocity*remaining end
>    144→    return position,velocity,hits
>    145→end
>    146→
>    147→function Physics2D.step(state, input)
>    148→    state.tick+=1
>    149→    local p,b=state.player,state.ball
>    150→    local ix,iy=clampMagnitude(input.x or 0,input.y or 0,1)
>    151→    local accel=input.kick and C.playerKickAcceleration or C.playerAcceleration
>    152→    p.vx,p.vy=p.vx+ix*accel,p.vy+iy*accel
>    153→
>    154→    local relX,relY=p.vx-b.vx,p.vy-b.vy
>    155→    local maxTravel=math.max(
>    156→        math.sqrt(p.vx*p.vx+p.vy*p.vy),
>    157→        math.sqrt(b.vx*b.vx+b.vy*b.vy),
>    158→        math.sqrt(relX*relX+relY*relY)
>    159→    )
>    160→    local featureSize=math.max(0.5,math.min(p.radius,b.radius)*C.collisionSubstepRadiusFraction)
>    161→    local substeps=math.clamp(math.ceil(maxTravel/featureSize),1,C.maxCollisionSubsteps)
>    162→    local info={substeps=substeps,playerBallContacts=0,ballWallBounces=0,playerWallBounces=0,lastPlayerBallContact=nil}
>    163→    local dt=1/substeps
>    164→    local minPX,maxPX=-C.fieldHalfWidth+p.radius,C.fieldHalfWidth-p.radius
>    165→    local minPY,maxPY=-C.fieldHalfHeight+p.radius,C.fieldHalfHeight-p.radius
>    166→    local minBX,maxBX=-C.fieldHalfWidth+b.radius,C.fieldHalfWidth-b.radius
>    167→    local minBY,maxBY=-C.fieldHalfHeight+b.radius,C.fieldHalfHeight-b.radius
>    168→
>    169→    for substep=1,substeps do
>    170→        local localPlayerX,localPlayerY,localBallX,localBallY
>    171→        p.x,p.vx,localPlayerX=advanceAxis(p.x,p.vx,minPX,maxPX,dt,p.bounce)
>    172→        p.y,p.vy,localPlayerY=advanceAxis(p.y,p.vy,minPY,maxPY,dt,p.bounce)
>    173→        b.x,b.vx,localBallX=advanceAxis(b.x,b.vx,minBX,maxBX,dt,b.bounce)
>    174→        b.y,b.vy,localBallY=advanceAxis(b.y,b.vy,minBY,maxBY,dt,b.bounce)
>    175→        info.playerWallBounces+=localPlayerX+localPlayerY
>    176→        info.ballWallBounces+=localBallX+localBallY
>    177→
>    178→        local contact=resolveDiscs(p,b)
>    179→        if contact and (contact.penetration>0 or contact.impulse>0) then
>    180→            info.playerBallContacts+=1
>    181→            info.lastPlayerBallContact={
>    182→                normalX=contact.normalX,normalY=contact.normalY,
>    183→                penetration=contact.penetration,correctionPlayer=contact.correctionA,
>    184→                correctionBall=contact.correctionB,normalSpeedBefore=contact.normalSpeedBefore,
>    185→                impulse=contact.impulse,substep=substep,
>    186→            }
>    187→        end
>    188→    end
>    189→
>    190→    p.vx,p.vy=p.vx*p.damping,p.vy*p.damping
>    191→    b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
>    192→    return state,info
>    193→end
>    194→
>    195→function Physics2D.stepPlayerPair(state)
>    196→    state.tick += 1
>    197→    local a, b = state.player, state.player2
>    198→    local ax, ay, avx, avy = a.x, a.y, a.vx, a.vy
>    199→    local bx, by, bvx, bvy = b.x, b.y, b.vx, b.vy
>    200→
>    201→    a.x, a.y = ax+avx, ay+avy
>    202→    b.x, b.y = bx+bvx, by+bvy
>    203→
>    204→    local dx,dy=a.x-b.x,a.y-b.y
>    205→    local radiusSum=a.radius+b.radius
>    206→    if dx*dx+dy*dy <= radiusSum*radiusSum then
>    207→        a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
>    208→        b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
>    209→        wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
>    210→        wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
>    211→        return state,resolveDiscs(a,b)
>    212→    end
>    213→
>    214→    local rx, ry = ax-bx, ay-by
>    215→    local rvx, rvy = avx-bvx, avy-bvy
>    216→    local qa = rvx*rvx+rvy*rvy
>    217→    local qb = 2*(rx*rvx+ry*rvy)
>    218→    local qc = rx*rx+ry*ry-radiusSum*radiusSum
>    219→    local discriminant = qb*qb-4*qa*qc
>    220→    if qc > 0 and qa > 1e-12 and qb < 0 and discriminant >= 0 then
>    221→        local hitTime = (-qb-math.sqrt(discriminant))/(2*qa)
>    222→        if hitTime >= 0 and hitTime <= 1 then
>    223→            a.x, a.y = ax+avx*hitTime, ay+avy*hitTime
>    224→            b.x, b.y = bx+bvx*hitTime, by+bvy*hitTime
>    225→            a.vx, a.vy, b.vx, b.vy = avx, avy, bvx, bvy
>    226→            local contact=resolveDiscs(a,b)
>    227→            if contact then
>    228→                local remaining=1-hitTime
>    229→                a.x,a.y=a.x+a.vx*remaining,a.y+a.vy*remaining
>    230→                b.x,b.y=b.x+b.vx*remaining,b.y+b.vy*remaining
>    231→                a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
>    232→                b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
>    233→                wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
>    234→                wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
>    235→                contact.swept=true
>    236→                contact.impactFraction=hitTime
>    237→            end
>    238→            return state,contact
>    239→        end
>    240→    end
>    241→
>    242→    a.vx,a.vy=a.vx*a.damping,a.vy*a.damping
>    243→    b.vx,b.vy=b.vx*b.damping,b.vy*b.damping
>    244→    wall(a,C.fieldHalfWidth,C.fieldHalfHeight)
>    245→    wall(b,C.fieldHalfWidth,C.fieldHalfHeight)
>    246→    return state,nil
>    247→end
>    248→
>    249→function Physics2D.stepThreeBody(state, iterationCount)
>    250→    state.tick += 1
>    251→    local p1,p2,ball=state.player,state.player2,state.ball
>    252→    for _,disc in {p1,p2,ball} do
>    253→        disc.x,disc.y=disc.x+disc.vx,disc.y+disc.vy
>    254→        disc.vx,disc.vy=disc.vx*disc.damping,disc.vy*disc.damping
>    255→        wall(disc,C.fieldHalfWidth,C.fieldHalfHeight)
>    256→    end
>    257→
>    258→    local pairs={
>    259→        {key="player1-player2",a=p1,b=p2},
>    260→        {key="player1-ball",a=p1,b=ball},
>    261→        {key="player2-ball",a=p2,b=ball},
>    262→    }
>    263→    local iterations=math.clamp(iterationCount or C.collisionIterations,1,24)
>    264→    local initialNormalSpeeds={}
>    265→    local contactPairs={}
>    266→    local impacts={}
>    267→    for _,pair in ipairs(pairs) do
>    268→        local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
>    269→        local d2=dx*dx+dy*dy
>    270→        local radii=pair.a.radius+pair.b.radius
>    271→        local d=math.sqrt(d2)
>    272→        local nx,ny
>    273→        if d>1e-8 then
>    274→            nx,ny=dx/d,dy/d
>    275→        else
>    276→            local aId,bId=pair.a.id or 1,pair.b.id or 2
>    277→            nx,ny=aId<=bId and -1 or 1,0
>    278→        end
>    279→        local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
>    280→        initialNormalSpeeds[pair.key]=vn
>    281→        if d2<=radii*radii then
>    282→            table.insert(contactPairs,pair)
>    283→            impacts[pair.key]={
>    284→                maxPenetration=math.max(0,radii-d),correctionA=0,correctionB=0,
>    285→                normalX=nx,normalY=ny,normalSpeedBefore=vn,
>    286→                impulseTotal=0,peakImpulseIncrement=0,lastImpulse=0,resolutionCount=0,
>    287→            }
>    288→        end
>    289→    end
>    290→
>    291→    local positionIterations=0
>    292→    for iteration=1,iterations do
>    293→        positionIterations=iteration
>    294→        local deltas={}
>    295→        for _,disc in {p1,p2,ball} do deltas[disc]={x=0,y=0} end
>    296→        local maxPenetration=0
>    297→        for _,pair in ipairs(pairs) do
>    298→            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
>    299→            local distance=math.sqrt(dx*dx+dy*dy)
>    300→            local radii=pair.a.radius+pair.b.radius
>    301→            if distance<radii then
>    302→                local nx,ny
>    303→                if distance>1e-8 then nx,ny=dx/distance,dy/distance
>    304→                else
>    305→                    local aId,bId=pair.a.id or 1,pair.b.id or 2
>    306→                    nx,ny=aId<=bId and -1 or 1,0
>    307→                end
>    308→                local penetration=radii-distance
>    309→                maxPenetration=math.max(maxPenetration,penetration)
>    310→                local invSum=pair.a.invMass+pair.b.invMass
>    311→                if invSum>0 then
>    312→                    local ca=penetration*(pair.a.invMass/invSum)
>    313→                    local cb=penetration*(pair.b.invMass/invSum)
>    314→                    local da,db=deltas[pair.a],deltas[pair.b]
>    315→                    da.x+=nx*ca; da.y+=ny*ca
>    316→                    db.x-=nx*cb; db.y-=ny*cb
>    317→                    local impact=impacts[pair.key]
>    318→                    if impact then
>    319→                        impact.maxPenetration=math.max(impact.maxPenetration,penetration)
>    320→                        impact.correctionA=math.max(impact.correctionA,ca)
>    321→                        impact.correctionB=math.max(impact.correctionB,cb)
>    322→                        impact.normalX,impact.normalY=nx,ny
>    323→                    end
>    324→                end
>    325→            end
>    326→        end
>    327→        for disc,delta in deltas do disc.x+=delta.x; disc.y+=delta.y end
>    328→        if maxPenetration<=1e-5 then break end
>    329→    end
>    330→
>    331→    local velocityIterations=0
>    332→    local accumulated={}
>    333→    local targets={}
>    334→    for _,pair in ipairs(contactPairs) do
>    335→        accumulated[pair.key]=0
>    336→        local vn=initialNormalSpeeds[pair.key]
>    337→        targets[pair.key]=vn<0 and -math.min(pair.a.bounce,pair.b.bounce)*vn or 0
>    338→    end
>    339→    for iteration=1,iterations do
>    340→        velocityIterations=iteration
>    341→        local maxViolation=0
>    342→        for orderIndex=1,#contactPairs do
>    343→            local pairIndex=iteration%2==1 and orderIndex or (#contactPairs-orderIndex+1)
>    344→            local pair=contactPairs[pairIndex]
>    345→            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
>    346→            local distance=math.sqrt(dx*dx+dy*dy)
>    347→            local nx,ny
>    348→            if distance>1e-8 then nx,ny=dx/distance,dy/distance
>    349→            else
>    350→                local aId,bId=pair.a.id or 1,pair.b.id or 2
>    351→                nx,ny=aId<=bId and -1 or 1,0
>    352→            end
>    353→            local invSum=pair.a.invMass+pair.b.invMass
>    354→            if invSum>0 then
>    355→                local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
>    356→                local target=targets[pair.key] or 0
>    357→                local oldTotal=accumulated[pair.key]
>    358→                local newTotal=math.max(0,oldTotal+(target-vn)/invSum)
>    359→                local delta=newTotal-oldTotal
>    360→                if math.abs(delta)>1e-12 then
>    361→                    accumulated[pair.key]=newTotal
>    362→                    pair.a.vx+=nx*delta*pair.a.invMass
>    363→                    pair.a.vy+=ny*delta*pair.a.invMass
>    364→                    pair.b.vx-=nx*delta*pair.b.invMass
>    365→                    pair.b.vy-=ny*delta*pair.b.invMass
>    366→                    local impact=impacts[pair.key]
>    367→                    if impact then
>    368→                        impact.impulseTotal=newTotal
>    369→                        impact.lastImpulse=delta
>    370→                        impact.peakImpulseIncrement=math.max(impact.peakImpulseIncrement,math.abs(delta))
>    371→                        impact.resolutionCount+=1
>    372→                        impact.normalX,impact.normalY=nx,ny
>    373→                    end
>    374→                end
>    375→            end
>    376→        end
>    377→        for _,pair in ipairs(contactPairs) do
>    378→            local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
>    379→            local distance=math.sqrt(dx*dx+dy*dy)
>    380→            local nx,ny
>    381→            if distance>1e-8 then nx,ny=dx/distance,dy/distance
>    382→            else
>    383→                local aId,bId=pair.a.id or 1,pair.b.id or 2
>    384→                nx,ny=aId<=bId and -1 or 1,0
>    385→            end
>    386→            local vn=(pair.a.vx-pair.b.vx)*nx+(pair.a.vy-pair.b.vy)*ny
>    387→            maxViolation=math.max(maxViolation,math.max(0,(targets[pair.key] or 0)-vn))
>    388→        end
>    389→        if maxViolation<=1e-6 then break end
>    390→    end
>    391→
>    392→    local residuals={}
>    393→    local maxResidual=0
>    394→    for _,pair in ipairs(pairs) do
>    395→        local dx,dy=pair.a.x-pair.b.x,pair.a.y-pair.b.y
>    396→        local distance=math.sqrt(dx*dx+dy*dy)
>    397→        local residual=math.max(0,pair.a.radius+pair.b.radius-distance)
>    398→        residuals[pair.key]=residual
>    399→        maxResidual=math.max(maxResidual,residual)
>    400→    end
>    401→    return state,impacts,residuals,maxResidual,math.max(positionIterations,velocityIterations)
>    402→end
>    403→
>    404→function Physics2D.tryKick(state, facingX, facingY)
>    405→    local p, b = state.player, state.ball
>    406→    local dx, dy = b.x - p.x, b.y - p.y
>    407→    local d = math.sqrt(dx*dx + dy*dy)
>    408→    if d > p.radius + b.radius + C.kickRangeExtra then return false end
>    409→    if d > 1e-8 then dx, dy = dx/d, dy/d else dx, dy = facingX, facingY end
>    410→    if dx*dx + dy*dy < 1e-8 then dx, dy = 1, 0 end
>    411→    b.vx, b.vy = b.vx + dx*C.kickStrength, b.vy + dy*C.kickStrength
>    412→    p.vx, p.vy = p.vx - dx*C.kickback, p.vy - dy*C.kickback
>    413→    return true
>    414→end
>    415→
>    416→return Physics2D
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.ClassicStadium2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local ReplicatedStorage = game:GetService("ReplicatedStorage")
>      2→local Profile = require(ReplicatedStorage:WaitForChild("HaxballLab"):WaitForChild("StadiumReference2D"))
>      3→local Stadium = {}
>      4→Stadium.Metadata = Profile.Metadata
>      5→Stadium.Groups = Profile.CollisionGroups
>      6→
>      7→local function copyRecord(record)
>      8→    return table.clone(record)
>      9→end
>     10→
>     11→function Stadium.install(Core, world)
>     12→    assert(type(Core) == "table" and type(world) == "table", "Core and world are required")
>     13→    world.useBounds = false
>     14→
>     15→    for _, spec in ipairs(Profile.Geometry.planes) do
>     16→        Core.addPlane(world, copyRecord(spec))
>     17→    end
>     18→    for _, spec in ipairs(Profile.Geometry.segments) do
>     19→        Core.addSegment(world, copyRecord(spec))
>     20→    end
>     21→
>     22→    local hbsAll = Profile.CollisionMasks.all
>     23→    for _, post in ipairs(Profile.Geometry.posts) do
>     24→        Core.addDisc(world, {
>     25→            id = post.id,
>     26→            kind = "post",
>     27→            x = post.x,
>     28→            y = post.y,
>     29→            radius = post.radius,
>     30→            invMass = 0,
>     31→            damping = 1,
>     32→            bCoef = post.bCoef,
>     33→            collisionGroup = Profile.CollisionGroups.post,
>     34→            collisionMask = hbsAll,
>     35→        })
>     36→    end
>     37→
>     38→    return {
>     39→        planes = #Profile.Geometry.planes,
>     40→        segments = #Profile.Geometry.segments,
>     41→        posts = #Profile.Geometry.posts,
>     42→        profileId = Profile.Metadata.id,
>     43→        sourceCommit = Profile.Metadata.sourceCommit,
>     44→    }
>     45→end
>     46→
>     47→return Stadium
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ReplicatedStorage.HaxballLab.StadiumReference2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Profile = {}
>      2→
>      3→Profile.Metadata = {
>      4→    id = "haxball-classic-reference",
>      5→    name = "Classic",
>      6→    sourceRepository = "haxball/haxball-issues",
>      7→    sourceFile = "stadiums/classic.hbs",
>      8→    sourceCommit = "4b9724f49fe0ff87ad3f111eb91b208020d96d73",
>      9→    sourcePermalink = "https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs",
>     10→    geometryStatus = "FROZEN_REFERENCE",
>     11→    logicalUnits = "Haxball stadium units",
>     12→    note = "HBS width/height are 420/200; physical geometry spans x=[-420,420], y=[-200,200].",
>     13→}
>     14→
>     15→Profile.StadiumProperties = {
>     16→    width = 420,
>     17→    height = 200,
>     18→    spawnDistance = 170,
>     19→    bg = { width = 370, height = 170, kickOffRadius = 75 },
>     20→}
>     21→
>     22→Profile.Bounds = {
>     23→    minX = -420, maxX = 420,
>     24→    minY = -200, maxY = 200,
>     25→    halfWidth = 420, halfHeight = 200,
>     26→    spanWidth = 840, spanHeight = 400,
>     27→}
>     28→
>     29→Profile.PlayArea = {
>     30→    minX = -370, maxX = 370,
>     31→    minY = -170, maxY = 170,
>     32→    width = 740, height = 340,
>     33→}
>     34→
>     35→Profile.Goals = {
>     36→    leftX = -370,
>     37→    rightX = 370,
>     38→    halfHeight = 64,
>     39→    openingWidth = 128,
>     40→    netBackX = 400,
>     41→    postRadius = 8,
>     42→    goalOwnerTeams = { left = "red", right = "blue" },
>     43→    scoringTeams = { left = "blue", right = "red" },
>     44→}
>     45→
>     46→Profile.CollisionGroups = {
>     47→    -- Haxball collision flag bit values.
>     48→    ball = 1,
>     49→    red = 2,
>     50→    blue = 4,
>     51→    player = 6,
>     52→    redKO = 8,
>     53→    blueKO = 16,
>     54→    kickoffBarrier = 24,
>     55→    wall = 32,
>     56→    outerWall = 32,
>     57→    post = 32,
>     58→    ballArea = 32,
>     59→    goalNet = 32,
>     60→    kick = 64,
>     61→    score = 128,
>     62→}
>     63→
>     64→Profile.CollisionMasks = {
>     65→    all = 63,
>     66→    player = 39,
>     67→    ball = 63,
>     68→    post = 63,
>     69→    kickoffBarrier = 6,
>     70→}
>     71→
>     72→Profile.Geometry = {
>     73→    planes = {
>     74→        { id = "classic:ballArea:bottom", normalX = 0, normalY = 1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     75→        { id = "classic:ballArea:top", normalX = 0, normalY = -1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     76→        { id = "classic:outer:bottom", normalX = 0, normalY = 1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     77→        { id = "classic:outer:top", normalX = 0, normalY = -1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     78→        { id = "classic:outer:left", normalX = 1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     79→        { id = "classic:outer:right", normalX = -1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     80→    },
>     81→    segments = {
>     82→        { id = "classic:ballArea:left:upper", x1 = -370, y1 = 170, x2 = -370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     83→        { id = "classic:ballArea:left:lower", x1 = -370, y1 = -64, x2 = -370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     84→        { id = "classic:ballArea:right:upper", x1 = 370, y1 = 170, x2 = 370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     85→        { id = "classic:ballArea:right:lower", x1 = 370, y1 = -64, x2 = 370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     86→        { id = "classic:goalNet:left:lowerCurve", x1 = -380, y1 = -64, x2 = -400, y2 = -44, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     87→        { id = "classic:goalNet:left:back", x1 = -400, y1 = -44, x2 = -400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     88→        { id = "classic:goalNet:left:upperCurve", x1 = -400, y1 = 44, x2 = -380, y2 = 64, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     89→        { id = "classic:goalNet:right:lowerCurve", x1 = 380, y1 = -64, x2 = 400, y2 = -44, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     90→        { id = "classic:goalNet:right:back", x1 = 400, y1 = -44, x2 = 400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     91→        { id = "classic:goalNet:right:upperCurve", x1 = 400, y1 = 44, x2 = 380, y2 = 64, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     92→        { id = "classic:kickoff:upperLine", x1 = 0, y1 = 200, x2 = 0, y2 = 75, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
>     93→        { id = "classic:kickoff:circleBlueKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = 180, bCoef = 0.1, collisionGroup = 16, collisionMask = 6, kickoffOnly = true },
>     94→        { id = "classic:kickoff:circleRedKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = -180, bCoef = 0.1, collisionGroup = 8, collisionMask = 6, kickoffOnly = true },
>     95→        { id = "classic:kickoff:lowerLine", x1 = 0, y1 = -75, x2 = 0, y2 = -200, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
>     96→    },
>     97→    posts = {
>     98→        { id = "classic:post:left:upper", x = -370, y = 64, radius = 8, bCoef = 0.5 },
>     99→        { id = "classic:post:left:lower", x = -370, y = -64, radius = 8, bCoef = 0.5 },
>    100→        { id = "classic:post:right:upper", x = 370, y = 64, radius = 8, bCoef = 0.5 },
>    101→        { id = "classic:post:right:lower", x = 370, y = -64, radius = 8, bCoef = 0.5 },
>    102→    },
>    103→}
>    104→
>    105→Profile.SpawnPoints = {
>    106→    -- Current 5v5 lab formation; a project choice, not a claim about HBS default spawns.
>    107→    { x = -80, y = 0 },
>    108→    { x = -150, y = -54 }, { x = -150, y = -18 }, { x = -150, y = 18 }, { x = -150, y = 54 },
>    109→    { x = 150, y = -72 }, { x = 150, y = -36 }, { x = 150, y = 0 }, { x = 150, y = 36 }, { x = 150, y = 72 },
>    110→}
>    111→
>    112→Profile.Simulation = {
>    113→    tickRate = { value = 60, evidence = "DOCUMENTED_LOGICAL_TICK", source = "Headless Host onGameTick documentation; does not prove internal substeps or render/network rates." },
>    114→}
>    115→
>    116→Profile.PhysicsBaseline = {
>    117→    evidenceReplay = {
>    118→        format = "HBR2",
>    119→        version = 3,
>    120→        frames = 12368,
>    121→        stadium = "Small",
>    122→        sha256 = "60a184ca3e33f763424960e407bc7d898cbf13a0a5e54eb85f811661e4d478d5",
>    123→        engine = "Node-Haxball",
>    124→        engineCommit = "4d4b88f1e5e25d484d27819ee6a4699720bda164",
>    125→        evidenceLevel = "RECONSTRUCTED_INDEPENDENT_IMPLEMENTATION",
>    126→        note = "Replay stadium is Small, not the frozen Classic geometry profile; values remain candidates until cross-validated.",
>    127→    },
>    128→    active = {
>    129→        status = "PROJECT_PROVISIONAL",
>    130→        note = "Existing lab runtime defaults retained; not certified against the official Haxball engine.",
>    131→        player = {
>    132→            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
>    133→            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
>    134→            kickStrength = 5, kickback = 0,
>    135→        },
>    136→        ball = { radius = 10, invMass = 1, damping = 0.99, bounce = 0.5 },
>    137→        kickRangeExtra = 4,
>    138→        evidence = {
>    139→            player = "Values match the independent replay reconstruction; official comparison pending.",
>    140→            ball = "radius and damping match the replay reconstruction; active invMass/bounce are retained project defaults and differ from that replay candidate.",
>    141→            kickRangeExtra = "UNKNOWN_PROJECT_PROVISIONAL",
>    142→        },
>    143→    },
>    144→    replayCandidate = {
>    145→        status = "RECONSTRUCTED_NOT_OFFICIAL_MEASUREMENT",
>    146→        source = "replay_metadata.json roomData physics metadata",
>    147→        player = {
>    148→            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
>    149→            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
>    150→            kickStrength = 5, kickback = 0,
>    151→        },
>    152→        ball = { radius = 10, invMass = 0.5, damping = 0.99, bounce = 1 },
>    153→    },
>    154→    labSolver = {
>    155→        collisionIterations = 24,
>    156→        maxSubsteps = 128,
>    157→        substepRadiusFraction = 0.2,
>    158→        evidence = "PROJECT_IMPLEMENTATION_TUNING_NOT_ORIGINAL_ENGINE_PARAMETERS",
>    159→    },
>    160→}
>    161→
>    162→Profile.Calibration = {
>    163→    status = "IN_PROGRESS",
>    164→    reference = {
>    165→        class = "VERIFIED_FROM_FROZEN_HBS",
>    166→        source = Profile.Metadata.sourcePermalink,
>    167→        confidence = "high for map data",
>    168→        geometryCounts = { planes = 6, segments = 14, kickoffSegments = 4, posts = 4 },
>    169→    },
>    170→    replayComparison = {
>    171→        class = "RECONSTRUCTED_AND_MEASURED_ON_NODE_HAXBALL",
>    172→        sourceSha256 = Profile.PhysicsBaseline.evidenceReplay.sha256,
>    173→        sourceStadium = "Small",
>    174→        frames = 12368,
>    175→        directOfficialComparison = false,
>    176→        playerFreeFlight = {
>    177→            eligiblePairs = 10002,
>    178→            noInputPairs = 762,
>    179→            medianPositionResidual = 6.8e-15,
>    180→            medianVelocityResidual = 0,
>    181→            dampingRatioMedian = 0.96,
>    182→        },
>    183→        ballFreeFlight = {
>    184→            eligiblePairs = 10998,
>    185→            medianPositionResidual = 2.6e-15,
>    186→            dampingRatioMedian = 0.99,
>    187→        },
>    188→        kicks = { callbacks = 28, medianCenterDistance = 27.64, medianDeltaVelocityMagnitude = 4.944 },
>    189→    },
>    190→    parameterDelta = {
>    191→        playerCandidateValuesMatchActive = true,
>    192→        ballRadius = { active = 10, replayCandidate = 10, status = "MATCH" },
>    193→        ballInvMass = { active = 1, replayCandidate = 0.5, status = "DISAGREEMENT" },
>    194→        ballDamping = { active = 0.99, replayCandidate = 0.99, status = "MATCH" },
>    195→        ballBounce = { active = 0.5, replayCandidate = 1, status = "DISAGREEMENT" },
>    196→        kickRangeExtra = { active = 4, replayCandidate = nil, status = "UNKNOWN" },
>    197→    },
>    198→    separateTelemetry = {
>    199→        stadium = "Big",
>    200→        records = 21912,
>    201→        events = 78,
>    202→        sameMatchAsReplay = false,
>    203→        usableForDirectParameterCalibration = false,
>    204→        reason = "Separate stadium/session, no per-tick inputs, repeated gameTime and resets prevent direct physical fitting.",
>    205→    },
>    206→    unresolved = {
>    207→        "Official-engine trajectory comparison on Classic",
>    208→        "Kick range and failed-kick boundary",
>    209→        "Solver order and internal substeps",
>    210→        "Player-to-player calibration on controlled original-engine data",
>    211→    },
>    212→}
>    213→
>    214→Profile.Presentation = {
>    215→    studsPerUnit = 0.5,
>    216→    logicalOrigin = { x = 0, y = 0 },
>    217→    worldOrigin = { x = 0, z = 0 },
>    218→    floorY = 11,
>    219→    invertLogicalY = true,
>    220→    evidence = "Presentation-only scale; physics coordinates remain in stadium units.",
>    221→}
>    222→
>    223→return Profile
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ReplicatedStorage.HaxballLab.LabClient",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Players=game:GetService("Players")
>      2→local ReplicatedStorage=game:GetService("ReplicatedStorage")
>      3→local RunService=game:GetService("RunService")
>      4→
>      5→local player=Players.LocalPlayer
>      6→local camera=workspace.CurrentCamera
>      7→local lab=ReplicatedStorage:WaitForChild("HaxballLab")
>      8→local remotes=lab.Remotes
>      9→local inputRemote=remotes.Input
>     10→local snapshotRemote=remotes.Snapshot
>     11→local commandRemote=remotes.DebugCommand
>     12→local PredictionLab2D=require(lab:WaitForChild("PredictionLab2D"))
>     13→local StadiumProfile2D=require(lab:WaitForChild("StadiumReference2D"))
>     14→local inputContext=ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("HaxballGameplay")
>     15→local moveAction=inputContext:WaitForChild("Move")
>     16→local kickAction=inputContext:WaitForChild("Kick")
>     17→local field=workspace:WaitForChild("HaxballLab")
>     18→local playerDisc=field:WaitForChild("PlayerDisc")
>     19→local playerDisc2=field:WaitForChild("PlayerDisc2")
>     20→local ballDisc=field:WaitForChild("BallDisc")
>     21→local debugLine=field:WaitForChild("DebugLine")
>     22→local pairDebugLine=field:WaitForChild("PairDebugLine")
>     23→local ballP2DebugLine=field:WaitForChild("BallP2DebugLine")
>     24→
>     25→local playerVisuals={[1]=playerDisc,[2]=playerDisc2}
>     26→for playerId=3,10 do
>     27→    local visual=Instance.new("Part")
>     28→    visual.Name="PlayerDisc"..playerId
>     29→    visual.Shape=Enum.PartType.Ball
>     30→    visual.Size=playerDisc.Size
>     31→    visual.Anchored=true
>     32→    visual.CanCollide=false
>     33→    visual.CanTouch=false
>     34→    visual.CanQuery=false
>     35→    visual.CastShadow=false
>     36→    visual.Material=playerDisc.Material
>     37→    visual.Parent=field
>     38→    playerVisuals[playerId]=visual
>     39→end
>     40→local predictionGhost=Instance.new("Part")
>     41→predictionGhost.Name="PredictionGhost"
>     42→predictionGhost.Shape=Enum.PartType.Ball
>     43→predictionGhost.Size=playerDisc.Size
>     44→predictionGhost.Anchored=true
>     45→predictionGhost.CanCollide=false
>     46→predictionGhost.CanTouch=false
>     47→predictionGhost.CanQuery=false
>     48→predictionGhost.CastShadow=false
>     49→predictionGhost.Material=Enum.Material.Neon
>     50→predictionGhost.Color=Color3.fromRGB(255,220,70)
>     51→predictionGhost.Transparency=1
>     52→predictionGhost.Parent=field
>     53→
>     54→local Presentation=StadiumProfile2D.Presentation
>     55→local SCALE=Presentation.studsPerUnit
>     56→local function toWorld(logicalX,logicalY)
>     57→    local origin=Presentation.logicalOrigin
>     58→    local worldOrigin=Presentation.worldOrigin
>     59→    local visualY=Presentation.invertLogicalY and -1 or 1
>     60→    return Vector3.new(worldOrigin.x+(logicalX-origin.x)*SCALE,Presentation.floorY,worldOrigin.z+visualY*(logicalY-origin.y)*SCALE)
>     61→end
>     62→camera.CameraType=Enum.CameraType.Scriptable
>     63→camera.CFrame=CFrame.new(0,340,0)*CFrame.Angles(-math.pi/2,0,0)
>     64→camera.FieldOfView=35
>     65→
>     66→local gui=Instance.new("ScreenGui")
>     67→gui.Name="HaxballLabDebug"
>     68→gui.ResetOnSpawn=false
>     69→gui.Parent=player:WaitForChild("PlayerGui")
>     70→local label=Instance.new("TextLabel")
>     71→label.Size=UDim2.fromOffset(500,190)
>     72→label.Position=UDim2.fromOffset(14,14)
>     73→label.BackgroundTransparency=0.18
>     74→label.BackgroundColor3=Color3.fromRGB(15,20,25)
>     75→label.TextColor3=Color3.new(1,1,1)
>     76→label.Font=Enum.Font.Code
>     77→label.TextSize=14
>     78→label.TextXAlignment=Enum.TextXAlignment.Left
>     79→label.TextYAlignment=Enum.TextYAlignment.Top
>     80→label.Text="Haxball lab | WASD move | X kick"
>     81→label.Parent=gui
>     82→local predictionLabel=Instance.new("TextLabel")
>     83→predictionLabel.Name="NetworkPredictionDebug"
>     84→predictionLabel.Size=UDim2.fromOffset(370,72)
>     85→predictionLabel.Position=UDim2.new(1,-384,0,14)
>     86→predictionLabel.BackgroundTransparency=0.18
>     87→predictionLabel.BackgroundColor3=Color3.fromRGB(15,20,25)
>     88→predictionLabel.TextColor3=Color3.fromRGB(255,235,150)
>     89→predictionLabel.Font=Enum.Font.Code
>     90→predictionLabel.TextSize=13
>     91→predictionLabel.TextXAlignment=Enum.TextXAlignment.Left
>     92→predictionLabel.TextYAlignment=Enum.TextYAlignment.Top
>     93→predictionLabel.TextWrapped=true
>     94→predictionLabel.Text="Predicción experimental | input delay 0 ms"
>     95→predictionLabel.Parent=gui
>     96→local calibrationLabel=Instance.new("TextLabel")
>     97→calibrationLabel.Name="StadiumCalibrationDebug"
>     98→calibrationLabel.Size=UDim2.fromOffset(760,82)
>     99→calibrationLabel.Position=UDim2.fromOffset(14,466)
>    100→calibrationLabel.BackgroundTransparency=0.18
>    101→calibrationLabel.BackgroundColor3=Color3.fromRGB(15,20,25)
>    102→calibrationLabel.TextColor3=Color3.fromRGB(190,225,255)
>    103→calibrationLabel.Font=Enum.Font.Code
>    104→calibrationLabel.TextSize=12
>    105→calibrationLabel.TextXAlignment=Enum.TextXAlignment.Left
>    106→calibrationLabel.TextYAlignment=Enum.TextYAlignment.Top
>    107→calibrationLabel.TextWrapped=true
>    108→local meta=StadiumProfile2D.Metadata
>    109→local bounds=StadiumProfile2D.Bounds
>    110→local playArea=StadiumProfile2D.PlayArea
>    111→local goals=StadiumProfile2D.Goals
>    112→local activePhysics=StadiumProfile2D.PhysicsBaseline.active
>    113→local replayPhysics=StadiumProfile2D.PhysicsBaseline.replayCandidate
>    114→calibrationLabel.Text=string.format("REFERENCE %s | HBS %s\nLogical %dx%d | play area %dx%d | goal opening %d | geometry 6P/14S/4D\nVisual %.2f studs/unit only | player values match independent replay candidate\nBall active vs replay Small: invMass %.2f/%.2f, bounce %.2f/%.2f | official comparison pending",meta.name,string.sub(meta.sourceCommit,1,12),bounds.spanWidth,bounds.spanHeight,playArea.width,playArea.height,goals.openingWidth,SCALE,activePhysics.ball.invMass,replayPhysics.ball.invMass,activePhysics.ball.bounce,replayPhysics.ball.bounce)
>    115→calibrationLabel.Parent=gui
>    116→
>    117→local function makeButton(name,text,x,width,y)
>    118→    local button=Instance.new("TextButton")
>    119→    button.Name=name
>    120→    button.Size=UDim2.fromOffset(width,30)
>    121→    button.Position=UDim2.fromOffset(x,y)
>    122→    button.BackgroundColor3=Color3.fromRGB(35,55,70)
>    123→    button.TextColor3=Color3.new(1,1,1)
>    124→    button.Font=Enum.Font.GothamMedium
>    125→    button.TextSize=13
>    126→    button.Text=text
>    127→    button.Parent=gui
>    128→    return button
>    129→end
>    130→local resetButton=makeButton("ResetScenario","Reiniciar",14,92,212)
>    131→local kickSetupButton=makeButton("KickScenario","Preparar patada",112,122,212)
>    132→local wallSetupButton=makeButton("WallScenario","Probar pared",240,102,212)
>    133→local recordButton=makeButton("RecordingToggle","Pausar registro",348,120,212)
>    134→local headOnButton=makeButton("PairHeadOn","Choque frontal",14,132,248)
>    135→local obliqueButton=makeButton("PairOblique","Choque oblicuo",152,132,248)
>    136→local overlapButton=makeButton("PairOverlap","Centros coincidentes",290,178,248)
>    137→local crowdOverlapButton=makeButton("CrowdOverlap","Trío solapado",14,132,284)
>    138→local crowdApproachButton=makeButton("CrowdApproach","Dos al balón",152,132,284)
>    139→local fastCrossingButton=makeButton("FastCrossing","Cruce rápido",290,132,284)
>    140→local fastBallButton=makeButton("FastBall","Jugador-balón rápido",14,142,320)
>    141→local speedRunButton=makeButton("SpeedRun","Velocidad constante",14,152,356)
>    142→local regressionButton=makeButton("RegressionSuite","Ejecutar pruebas",174,160,356)
>    143→local fastDiagonalButton=makeButton("FastDiagonal","Diagonal rápida",162,132,320)
>    144→local multiWallButton=makeButton("MultiWall","Rebotes múltiples",300,160,320)
>    145→local goalTestButton=makeButton("GoalTest","Tiro a gol",14,120,392)
>    146→local latencyButtons={}
>    147→for index,delayMs in ipairs({0,50,100,150,200,300,500}) do
>    148→    latencyButtons[delayMs]=makeButton("InputDelay"..delayMs,delayMs==0 and "Delay 0" or (tostring(delayMs).." ms"),14+(index-1)*70,66,428)
>    149→end
>    150→resetButton.Activated:Connect(function() commandRemote:FireServer("reset") end)
>    151→kickSetupButton.Activated:Connect(function() commandRemote:FireServer("setupKick") end)
>    152→wallSetupButton.Activated:Connect(function() commandRemote:FireServer("setupWall") end)
>    153→recordButton.Activated:Connect(function() commandRemote:FireServer("toggleRecording") end)
>    154→headOnButton.Activated:Connect(function() commandRemote:FireServer("setupPairHeadOn") end)
>    155→obliqueButton.Activated:Connect(function() commandRemote:FireServer("setupPairOblique") end)
>    156→overlapButton.Activated:Connect(function() commandRemote:FireServer("setupPairOverlap") end)
>    157→crowdOverlapButton.Activated:Connect(function() commandRemote:FireServer("setupCrowdOverlap") end)
>    158→crowdApproachButton.Activated:Connect(function() commandRemote:FireServer("setupCrowdApproach") end)
>    159→fastCrossingButton.Activated:Connect(function() commandRemote:FireServer("setupPairFastCrossing") end)
>    160→fastBallButton.Activated:Connect(function() commandRemote:FireServer("setupBallFastCrossing") end)
>    161→speedRunButton.Activated:Connect(function() commandRemote:FireServer("setupSpeedRun") end)
>    162→regressionButton.Activated:Connect(function() commandRemote:FireServer("runRegressionSuite") end)
>    163→fastDiagonalButton.Activated:Connect(function() commandRemote:FireServer("setupBallFastDiagonal") end)
>    164→multiWallButton.Activated:Connect(function() commandRemote:FireServer("setupMultiWall") end)
>    165→goalTestButton.Activated:Connect(function() commandRemote:FireServer("setupGoalTest") end)
>    166→
>    167→local latest,previous
>    168→local snapshotAge=0
>    169→local lastSentX,lastSentY,lastSentKick=0,0,false
>    170→local syntheticInputDelayMs=0
>    171→local delayedInputQueue={}
>    172→local function setSyntheticInputDelay(delayMs)
>    173→    syntheticInputDelayMs=delayMs
>    174→    table.clear(delayedInputQueue)
>    175→    lastSentX,lastSentY,lastSentKick=nil,nil,nil
>    176→    for value,button in pairs(latencyButtons) do
>    177→        button.BackgroundColor3=value==delayMs and Color3.fromRGB(130,95,30) or Color3.fromRGB(35,55,70)
>    178→    end
>    179→end
>    180→for delayMs,button in pairs(latencyButtons) do
>    181→    button.Activated:Connect(function() setSyntheticInputDelay(delayMs) end)
>    182→end
>    183→local function readAction(action,fallback)
>    184→    local ok,value=pcall(function() return action:GetState() end)
>    185→    if not ok then return fallback end
>    186→    if typeof(value)=="Vector2" or typeof(value)=="boolean" then return value end
>    187→    if type(value)=="table" and value.Value~=nil then return value.Value end
>    188→    return fallback
>    189→end
>    190→snapshotRemote.OnClientEvent:Connect(function(s)
>    191→    previous,latest=latest,s
>    192→    snapshotAge=0
>    193→end)
>    194→
>    195→local function renderLine(part,a,b,color,visible)
>    196→    local delta=b-a
>    197→    local length=delta.Magnitude
>    198→    part.Transparency=visible and 0.2 or 1
>    199→    if visible and length>0.05 then
>    200→        part.Size=Vector3.new(.18,.18,length)
>    201→        part.CFrame=CFrame.lookAt((a+b)*.5,b)
>    202→        part.Color=color
>    203→    end
>    204→end
>    205→
>    206→RunService.RenderStepped:Connect(function(dt)
>    207→    snapshotAge+=dt
>    208→    local move=readAction(moveAction,Vector2.zero)
>    209→    if typeof(move)~="Vector2" then move=Vector2.zero end
>    210→    local kick=readAction(kickAction,false)==true
>    211→    local now=os.clock()
>    212→    if move.X~=lastSentX or move.Y~=lastSentY or kick~=lastSentKick then
>    213→        lastSentX,lastSentY,lastSentKick=move.X,move.Y,kick
>    214→        local packet={x=move.X,y=move.Y,kick=kick}
>    215→        if syntheticInputDelayMs<=0 then
>    216→            inputRemote:FireServer(packet.x,packet.y,packet.kick)
>    217→        else
>    218→            table.insert(delayedInputQueue,{due=now+syntheticInputDelayMs/1000,packet=packet})
>    219→        end
>    220→    end
>    221→    while delayedInputQueue[1] and delayedInputQueue[1].due<=now do
>    222→        local queued=table.remove(delayedInputQueue,1).packet
>    223→        inputRemote:FireServer(queued.x,queued.y,queued.kick)
>    224→    end
>    225→    if not latest then return end
>    226→
>    227→    local predictedState,predictedContact
>    228→    local predictionTicks=math.clamp(math.ceil(syntheticInputDelayMs*60/1000),0,24)
>    229→    if syntheticInputDelayMs>0 and latest.coreMode and latest.matchPhase=="playing" and latest.predictionParams then
>    230→        predictedState=PredictionLab2D.predict(latest.player,{x=move.X,y=move.Y,kick=kick},latest.predictionParams,predictionTicks)
>    231→        local targets={}
>    232→        for _,disc in ipairs(latest.players or {}) do
>    233→            if disc.playerId~=1 then table.insert(targets,{id=disc.playerId,kind="player",x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy,radius=disc.radius}) end
>    234→        end
>    235→        table.insert(targets,{id="ball",kind="ball",x=latest.ball.x,y=latest.ball.y,vx=latest.ball.vx,vy=latest.ball.vy,radius=latest.ball.radius})
>    236→        predictedContact=PredictionLab2D.firstContact(predictedState.path,latest.player.radius or 15,targets)
>    237→        local lead=math.sqrt((predictedState.x-latest.player.x)^2+(predictedState.y-latest.player.y)^2)
>    238→        local forecast=predictedContact and string.format("%s %s in %d ticks",predictedContact.kind=="ball" and "BALL" or "PLAYER",tostring(predictedContact.targetId),predictedContact.tick) or "no predicted contact"
>    239→        predictionGhost.Position=toWorld(predictedState.x,predictedState.y)
>    240→        predictionGhost.Transparency=0.38
>    241→        predictionLabel.Text=string.format("SIMULATED INPUT DELAY %d ms | horizon %d ticks\nGhost lead %.2f units | ball gap %.2f\nForecast: %s | server touch now: %s",syntheticInputDelayMs,predictionTicks,lead,latest.separation,forecast,tostring(latest.touchingBall))
>    242→    else
>    243→        predictionGhost.Transparency=1
>    244→        predictionLabel.Text=syntheticInputDelayMs>0 and string.format("Input delay %d ms | prediction active in 5v5 core only",syntheticInputDelayMs) or "Predicción experimental | input delay 0 ms"
>    245→    end
>    246→
>    247→    local alpha=math.clamp(snapshotAge*60,0,1)
>    248→    local a=previous and previous.tick<latest.tick and previous or latest
>    249→    local function lerp(disc,axis)
>    250→        return a[disc][axis]+(latest[disc][axis]-a[disc][axis])*alpha
>    251→    end
>    252→    local p1=toWorld(lerp("player","x"),lerp("player","y"))
>    253→    local p2=toWorld(lerp("player2","x"),lerp("player2","y"))
>    254→    local ball=toWorld(lerp("ball","x"),lerp("ball","y"))
>    255→    playerDisc.Position=p1
>    256→    playerDisc2.Position=p2
>    257→    local extraDiscMode=latest.pairMode or latest.crowdMode
>    258→    if latest.players and #latest.players>0 then
>    259→        for slot,disc in ipairs(latest.players) do
>    260→            local previousDisc=a.players and a.players[slot]
>    261→            local px=previousDisc and (previousDisc.x+(disc.x-previousDisc.x)*alpha) or disc.x
>    262→            local py=previousDisc and (previousDisc.y+(disc.y-previousDisc.y)*alpha) or disc.y
>    263→            local visual=playerVisuals[slot]
>    264→            if visual then
>    265→                visual.Position=toWorld(px,py)
>    266→                visual.Transparency=0
>    267→                visual.Color=disc.team=="red" and Color3.fromRGB(238,90,80) or Color3.fromRGB(75,155,255)
>    268→            end
>    269→        end
>    270→        for slot=#latest.players+1,#playerVisuals do
>    271→            if playerVisuals[slot] then playerVisuals[slot].Transparency=1 end
>    272→        end
>    273→    else
>    274→        for slot=2,#playerVisuals do
>    275→            if playerVisuals[slot] then playerVisuals[slot].Transparency=slot==2 and (extraDiscMode and 0 or 1) or 1 end
>    276→        end
>    277→    end
>    278→    ballDisc.Transparency=latest.pairMode and 1 or 0
>    279→    renderLine(debugLine,p1,ball,latest.touchingBall and Color3.fromRGB(70,255,130) or Color3.fromRGB(255,220,70),not latest.pairMode)
>    280→    renderLine(pairDebugLine,p1,p2,latest.touchingPlayers and Color3.fromRGB(70,255,130) or Color3.fromRGB(80,220,255),extraDiscMode)
>    281→    renderLine(ballP2DebugLine,p2,ball,latest.touchingPlayer2Ball and Color3.fromRGB(70,255,130) or Color3.fromRGB(255,110,90),latest.crowdMode)
>    282→
>    283→    local m=latest.metrics
>    284→    local lastTouchLine=latest.lastTouch and string.format("Last: %s #%d (%s)",string.upper(latest.lastTouch.team),latest.lastTouch.playerId,latest.lastTouch.kind) or "Last: -" 
>    285→    local p2Line=(latest.players and #latest.players>0) and string.format("Roster: %d | RED %d / BLUE %d | %s",latest.playerCount,latest.redCount,latest.blueCount,lastTouchLine) or ((latest.pairMode or latest.crowdMode) and string.format("P2: (%.2f, %.2f) speed %.2f | %s",latest.player2.x,latest.player2.y,latest.player2.speed,lastTouchLine) or ("P2: inactive | "..lastTouchLine))
>    286→    local ballLine=latest.pairMode and "Ball: inactive in player-pair test" or string.format("Ball: (%.2f, %.2f) speed %.2f",latest.ball.x,latest.ball.y,latest.ball.speed)
>    287→    local contactLine=latest.crowdMode and string.format("Separations P1-P2 %.2f | P1-ball %.2f | P2-ball %.2f",latest.playerSeparation,latest.separation,latest.player2BallSeparation) or (latest.pairMode and string.format("P1-P2: %.2f | contacts: %d",latest.playerSeparation,m.playerContacts) or string.format("P1-ball: %.2f | contacts: %d | ball walls: %d",latest.separation,m.ballContacts,m.ballWallBounces))
>    288→    local diagnosticsLine=latest.crowdMode and string.format("3D %d contacts | peak overlap %.3f | residual %.4f/max %.4f | iter %d/%d",m.crowdContacts,m.crowdPeakPenetration,m.crowdLastResidualPenetration,m.crowdWorstResidualPenetration,m.crowdLastSolverIterations,m.crowdMaxSolverIterations) or string.format("Max penetration %.3f | correction %.3f | impulse %.3f | substeps %d/%d | suite %s",m.maxPlayerPenetration,m.maxPlayerCorrection,m.lastPlayerImpulse,m.lastCollisionSubsteps,m.maxCollisionSubsteps,m.regressionRan and string.format("%d/%d",m.regressionPassed,m.regressionTotal) or "pendiente")
>    289→    local matchStatus=latest.matchPhase=="goalPause" and string.format("GOAL PAUSE %d",latest.pauseTicksRemaining) or (latest.matchPhase=="kickoff" and string.format("KICKOFF %s %d",string.upper(latest.kickoffTeam or "-"),latest.pauseTicksRemaining) or (latest.kickoffTeam and ("WAIT KICK "..string.upper(latest.kickoffTeam)) or "PLAYING"))
>    290→    local matchLine=string.format("Score RED %d - %d BLUE | %s",latest.score.red,latest.score.blue,matchStatus)
>    291→    label.Text=string.format(
>    292→        "Haxball lab | WASD move | X kick\nTick: %d | t=%.2f s | %s\n%s\nKicks: %d attempts / %d accepted (last %d)\nP1: (%.2f, %.2f) speed %.2f\n%s\n%s\n%s\n%s\n%s | samples %d",
>    293→        latest.tick,latest.gameTime,latest.crowdMode and "THREE-DISC TEST" or (latest.pairMode and "PAIR TEST" or (latest.coreMode and ("CORE v1 | owner "..tostring(latest.ownerUserId or "-")) or (latest.legacyMode and "LEGACY CCD TEST" or ("owner "..tostring(latest.ownerUserId or "-"))))),
>    294→        matchLine,
>    295→        m.kickAttempts,m.successfulKicks,m.lastKickSuccessTick,
>    296→        latest.player.x,latest.player.y,latest.player.speed,
>    297→        p2Line,ballLine,contactLine,diagnosticsLine,
>    298→        latest.recording and "recording" or "paused",latest.historySamples or 0
>    299→    )
>    300→    recordButton.Text=latest.recording and "Pausar registro" or "Reanudar registro"
>    301→end)
>    302→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ReplicatedStorage.HaxballLab.PredictionLab2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→-- Client-only free-motion micro-prediction for isolated latency experiments.
>      2→-- Predicted contacts are forecasts, never authoritative collision results.
>      3→local Prediction = {}
>      4→
>      5→local function clampInput(x,y)
>      6→    x=type(x)=="number" and x or 0
>      7→    y=type(y)=="number" and y or 0
>      8→    local magnitude=math.sqrt(x*x+y*y)
>      9→    if magnitude>1 then return x/magnitude,y/magnitude end
>     10→    return x,y
>     11→end
>     12→
>     13→function Prediction.predict(state,input,params,ticks)
>     14→    assert(type(state)=="table" and type(input)=="table" and type(params)=="table","state, input, and params are required")
>     15→    ticks=math.clamp(math.floor(tonumber(ticks) or 0),0,24)
>     16→    local x,y,vx,vy=state.x,state.y,state.vx,state.vy
>     17→    local ix,iy=clampInput(input.x,input.y)
>     18→    local path=table.create(ticks)
>     19→    for tick=1,ticks do
>     20→        local acceleration=input.kick and params.kickAcceleration or params.acceleration
>     21→        vx+=ix*acceleration
>     22→        vy+=iy*acceleration
>     23→        if params.maxSpeed then
>     24→            local speed=math.sqrt(vx*vx+vy*vy)
>     25→            if speed>params.maxSpeed then
>     26→                local scale=params.maxSpeed/speed
>     27→                vx*=scale
>     28→                vy*=scale
>     29→            end
>     30→        end
>     31→        x+=vx
>     32→        y+=vy
>     33→        local damping=input.kick and params.kickDamping or params.damping
>     34→        vx*=damping
>     35→        vy*=damping
>     36→        path[tick]={tick=tick,x=x,y=y,vx=vx,vy=vy}
>     37→    end
>     38→    return {x=x,y=y,vx=vx,vy=vy,path=path,ticks=ticks}
>     39→end
>     40→
>     41→function Prediction.firstContact(path,playerRadius,targets)
>     42→    for _,sample in ipairs(path or {}) do
>     43→        for _,target in ipairs(targets or {}) do
>     44→            local tx=target.x+(target.vx or 0)*sample.tick
>     45→            local ty=target.y+(target.vy or 0)*sample.tick
>     46→            local dx,dy=sample.x-tx,sample.y-ty
>     47→            local distance=math.sqrt(dx*dx+dy*dy)
>     48→            if distance<=playerRadius+(target.radius or 0) then
>     49→                return {tick=sample.tick,targetId=target.id,kind=target.kind,distance=distance}
>     50→            end
>     51→        end
>     52→    end
>     53→    return nil
>     54→end
>     55→
>     56→return Prediction
>     57→
> ```
>
> - Ran `Get-ChildItem referenced-chatgpt-conversation-this-is-an\outputs -File | Sort-Object LastWriteTime -Descending | Select-Object -First 30 LastWriteTime,Length,Name; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_DYNAMIC_CALIBRATION_DECISION.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_FIRST_DIVERGENCE_REPORT.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_PLAYER_KICK_VALIDATION_PLAN.md`
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabServer",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Players = game:GetService("Players")
>      2→local ReplicatedStorage = game:GetService("ReplicatedStorage")
>      3→local RunService = game:GetService("RunService")
>      4→
>      5→local lab = ReplicatedStorage:WaitForChild("HaxballLab")
>      6→local remotes = lab.Remotes
>      7→local inputRemote = remotes.Input
>      8→local snapshotRemote = remotes.Snapshot
>      9→local commandRemote = remotes.DebugCommand
>     10→local Physics2D = require(script.Parent:WaitForChild("Physics2D"))
>     11→local PhysicsCore2D = Physics2D.MatchCore
>     12→local ClassicStadium2D = require(script.Parent:WaitForChild("ClassicStadium2D"))
>     13→local StadiumProfile2D = require(lab:WaitForChild("StadiumReference2D"))
>     14→local MatchRules2D = require(script.Parent:WaitForChild("MatchRules2D"))
>     15→local LabRegression = require(script.Parent:WaitForChild("LabRegression"))
>     16→local debugState = script.Parent:WaitForChild("DebugState")
>     17→
>     18→Players.CharacterAutoLoads = false
>     19→local state = Physics2D.newState()
>     20→local matchState = MatchRules2D.newMatch()
>     21→local currentInput = { x = 0, y = 0, kick = false }
>     22→local currentInputs = {[1]=currentInput}
>     23→local lastCoreKickInputs = {}
>     24→local touchingCoreBall = {}
>     25→local playerUserSlots = {}
>     26→local slotUserIds = {}
>     27→local lastKick = false
>     28→local facingX, facingY = 1, 0
>     29→local controlledPlayer = nil
>     30→local accumulator = 0
>     31→local stepDt = 1 / Physics2D.Config.tickRate
>     32→local recording = true
>     33→local historyCapacity = 3600
>     34→local historyBuffer = {}
>     35→local historyWrite = 1
>     36→local historyCount = 0
>     37→local events = {}
>     38→local eventCapacity = 300
>     39→local pairMode = false
>     40→local crowdMode = false
>     41→local legacyMode = false
>     42→local speedRunRemaining = 0
>     43→local touchingBall = false
>     44→local touchingPlayers = false
>     45→local touchingCrowdPairs = {}
>     46→local metrics = {
>     47→    kickAttempts=0, successfulKicks=0, ballContacts=0,
>     48→    ballWallBounces=0, playerWallBounces=0, lastKickSuccessTick=-1,
>     49→    playerContacts=0, maxPlayerPenetration=0, maxPlayerCorrection=0,
>     50→    lastPlayerContactTick=-1, lastPlayerImpulse=0,
>     51→    crowdContacts=0, crowdContactsP1P2=0, crowdContactsP1Ball=0, crowdContactsP2Ball=0,
>     52→    crowdPeakPenetration=0, crowdLastResidualPenetration=0, crowdWorstResidualPenetration=0,
>     53→    crowdLastSolverIterations=0, crowdMaxSolverIterations=0,
>     54→    lastCollisionSubsteps=0, maxCollisionSubsteps=0,
>     55→    regressionRan=false, regressionPassed=0, regressionFailed=0, regressionTotal=0,
>     56→}
>     57→local function clearHistory()
>     58→    table.clear(historyBuffer)
>     59→    historyWrite, historyCount = 1, 0
>     60→end
>     61→local function logEvent(kind, data, eventTick)
>     62→    local event = data or {}
>     63→    event.kind = kind
>     64→    event.tick = eventTick or state.tick + 1
>     65→    table.insert(events, event)
>     66→    if #events > eventCapacity then table.remove(events, 1) end
>     67→end
>     68→local function clearMetrics()
>     69→    metrics.kickAttempts=0; metrics.successfulKicks=0; metrics.ballContacts=0
>     70→    metrics.ballWallBounces=0; metrics.playerWallBounces=0; metrics.lastKickSuccessTick=-1
>     71→    metrics.playerContacts=0; metrics.maxPlayerPenetration=0; metrics.maxPlayerCorrection=0
>     72→    metrics.lastPlayerContactTick=-1; metrics.lastPlayerImpulse=0
>     73→    metrics.crowdContacts=0; metrics.crowdContactsP1P2=0; metrics.crowdContactsP1Ball=0; metrics.crowdContactsP2Ball=0
>     74→    metrics.crowdPeakPenetration=0; metrics.crowdLastResidualPenetration=0; metrics.crowdWorstResidualPenetration=0
>     75→    metrics.crowdLastSolverIterations=0; metrics.crowdMaxSolverIterations=0
>     76→    metrics.lastCollisionSubsteps=0; metrics.maxCollisionSubsteps=0
>     77→    metrics.regressionRan=false; metrics.regressionPassed=0; metrics.regressionFailed=0; metrics.regressionTotal=0
>     78→    table.clear(events); clearHistory()
>     79→    touchingBall=false; touchingPlayers=false; touchingCrowdPairs={}
>     80→end
>     81→local function finite(n)
>     82→    return typeof(n)=="number" and n==n and math.abs(n)<1e6
>     83→end
>     84→
>     85→local function setController(player)
>     86→    if controlledPlayer==nil then controlledPlayer=player end
>     87→    if not playerUserSlots[player.UserId] then
>     88→        for slot=1,10 do
>     89→            if slotUserIds[slot]==nil then
>     90→                playerUserSlots[player.UserId]=slot
>     91→                slotUserIds[slot]=player.UserId
>     92→                if state.players and state.players[slot] then state.players[slot].ownerUserId=player.UserId end
>     93→                break
>     94→            end
>     95→        end
>     96→    end
>     97→    if player.Character then player.Character:Destroy() end
>     98→end
>     99→Players.PlayerAdded:Connect(setController)
>    100→for _,player in Players:GetPlayers() do setController(player) end
>    101→Players.PlayerRemoving:Connect(function(player)
>    102→    local slot=playerUserSlots[player.UserId]
>    103→    if slot then
>    104→        playerUserSlots[player.UserId]=nil
>    105→        slotUserIds[slot]=nil
>    106→        currentInputs[slot]={x=0,y=0,kick=false}
>    107→        lastCoreKickInputs[slot]=nil
>    108→        touchingCoreBall[slot]=nil
>    109→        if state.players and state.players[slot] then state.players[slot].ownerUserId=nil end
>    110→    end
>    111→    if player==controlledPlayer then
>    112→        controlledPlayer=nil
>    113→        for _,candidate in Players:GetPlayers() do
>    114→            if candidate~=player then controlledPlayer=candidate;break end
>    115→        end
>    116→        currentInput={x=0,y=0,kick=false}
>    117→        currentInputs[1]=currentInput
>    118→        lastKick=false
>    119→        if state.players then
>    120→            local newSlot=controlledPlayer and playerUserSlots[controlledPlayer.UserId]
>    121→            if newSlot and state.players[newSlot] then state.players[newSlot].ownerUserId=controlledPlayer.UserId end
>    122→        elseif state.player then
>    123→            state.player.ownerUserId=controlledPlayer and controlledPlayer.UserId or nil
>    124→        end
>    125→    end
>    126→end)
>    127→
>    128→local function allocateInput(playerSlot,x,y,kick)
>    129→    if not finite(x) or not finite(y) then return nil end
>    130→    local magnitude=math.sqrt(x*x+y*y)
>    131→    if magnitude>1 then x,y=x/magnitude,y/magnitude end
>    132→    local value={x=x,y=y,kick=kick==true}
>    133→    local old=currentInputs[playerSlot] or {x=0,y=0,kick=false}
>    134→    if x~=old.x or y~=old.y or value.kick~=old.kick then
>    135→        logEvent("input",{playerId=playerSlot,x=x,y=y,kick=value.kick})
>    136→    end
>    137→    currentInputs[playerSlot]=value
>    138→    return value
>    139→end
>    140→inputRemote.OnServerEvent:Connect(function(player,x,y,kick)
>    141→    local slot=playerUserSlots[player.UserId]
>    142→    if not slot then return end
>    143→    if state.coreWorld and matchState.phase~="playing" then return end
>    144→    if pairMode or crowdMode or legacyMode then
>    145→        if player~=controlledPlayer then return end
>    146→        local value=allocateInput(1,x,y,kick)
>    147→        if value then currentInput=value end
>    148→        if value and x*x+y*y>0.01 then
>    149→            local magnitude=math.sqrt(x*x+y*y)
>    150→            facingX,facingY=x/magnitude,y/magnitude
>    151→        end
>    152→        return
>    153→    end
>    154→    local value=allocateInput(slot,x,y,kick)
>    155→    if value and slot==1 then currentInput=value end
>    156→end)
>    157→
>    158→local function speed(d) return math.sqrt(d.vx*d.vx+d.vy*d.vy) end
>    159→local function makeCoreState()
>    160→    local legacy=Physics2D.newState()
>    161→    local world=PhysicsCore2D.newWorld({
>    162→        tickRate=Physics2D.Config.tickRate,
>    163→        fieldHalfWidth=Physics2D.Config.fieldHalfWidth,
>    164→        fieldHalfHeight=Physics2D.Config.fieldHalfHeight,
>    165→        useBounds=false,
>    166→    })
>    167→    -- Preserve stadium order: ball, static posts, then ten player discs.
>    168→    local ball=PhysicsCore2D.addDisc(world,{
>    169→        id="ball",kind="ball",x=0,y=0,radius=Physics2D.Config.ballRadius,
>    170→        invMass=Physics2D.Config.ballInvMass,damping=Physics2D.Config.ballDamping,traceMotion=true,
>    171→        bCoef=Physics2D.Config.ballBounce,kickable=true,
>    172→        collisionGroup=ClassicStadium2D.Groups.ball,
>    173→    })
>    174→    local stadiumGeometry=ClassicStadium2D.install(PhysicsCore2D,world)
>    175→    local spawnPoints = table.clone(StadiumProfile2D.SpawnPoints)
>    176→    local players={}
>    177→    local playerCollisionMasks={}
>    178→    for slot=1,10 do
>    179→        local position=spawnPoints[slot]
>    180→        local disc=PhysicsCore2D.addDisc(world,{
>    181→            id=slot,kind="player",team=slot<=5 and "red" or "blue",
>    182→            x=position.x,y=position.y,radius=Physics2D.Config.playerRadius,
>    183→            invMass=Physics2D.Config.playerInvMass,damping=Physics2D.Config.playerDamping,
>    184→            kickDamping=Physics2D.Config.playerDamping,bCoef=Physics2D.Config.playerBounce,
>    185→            acceleration=Physics2D.Config.playerAcceleration,
>    186→            kickAcceleration=Physics2D.Config.playerKickAcceleration,
>    187→            kickStrength=Physics2D.Config.kickStrength,kickback=Physics2D.Config.kickback,
>    188→            kickRangeExtra=Physics2D.Config.kickRangeExtra,
>    189→            collisionGroup=slot<=5 and ClassicStadium2D.Groups.red or ClassicStadium2D.Groups.blue,
>    190→            collisionMask=StadiumProfile2D.CollisionMasks.player,
>    191→        })
>    192→        disc.ownerUserId=slotUserIds[slot]
>    193→        players[slot]=disc
>    194→        playerCollisionMasks[slot]=disc.collisionMask
>    195→    end
>    196→    return {tick=0,player=players[1],player2=players[6],players=players,ball=ball,score=legacy.score,coreWorld=world,stadiumGeometry=stadiumGeometry,spawnPoints=spawnPoints,playerCollisionMasks=playerCollisionMasks}
>    197→end
>    198→
>    199→local function newState(pairEnabled,crowdEnabled,legacyPhysicsEnabled)
>    200→    local useLegacy=pairEnabled==true or crowdEnabled==true or legacyPhysicsEnabled==true
>    201→    local new=useLegacy and Physics2D.newState() or makeCoreState()
>    202→    if not new.coreWorld then new.player.ownerUserId=controlledPlayer and controlledPlayer.UserId or nil end
>    203→    pairMode=pairEnabled==true
>    204→    crowdMode=crowdEnabled==true
>    205→    legacyMode=legacyPhysicsEnabled==true
>    206→    state=new
>    207→    matchState=MatchRules2D.newMatch()
>    208→    currentInputs={}
>    209→    for slot=1,10 do currentInputs[slot]={x=0,y=0,kick=false} end
>    210→    currentInput=currentInputs[1]
>    211→    lastCoreKickInputs={}
>    212→    touchingCoreBall={}
>    213→    lastKick=false
>    214→    facingX,facingY=1,0
>    215→    accumulator=0
>    216→    speedRunRemaining=0
>    217→    clearMetrics()
>    218→    touchingCrowdPairs={}
>    219→    return new
>    220→end
>    221→newState(false,false,false)
>    222→commandRemote.OnServerEvent:Connect(function(player,command)
>    223→    if player~=controlledPlayer then return end
>    224→    if command=="reset" then
>    225→        newState(false)
>    226→        logEvent("scenarioReset",{scenario="default"})
>    227→    elseif command=="setupKick" then
>    228→        local new=newState(false)
>    229→        new.player.x=-27
>    230→        logEvent("scenarioReset",{scenario="kickFromRest",separation=27})
>    231→    elseif command=="setupWall" then
>    232→        local new=newState(false)
>    233→        new.ball.x=0
>    234→        new.ball.y=156
>    235→        new.ball.vy=5
>    236→        logEvent("scenarioReset",{scenario="ballWallBounce",ballY=new.ball.y,ballVy=new.ball.vy})
>    237→    elseif command=="setupGoalTest" then
>    238→        local new=newState(false)
>    239→        new.ball.x=340; new.ball.y=0; new.ball.vx=12
>    240→        logEvent("scenarioReset",{scenario="goalCrossing",ballX=new.ball.x,ballY=new.ball.y,ballVx=new.ball.vx})
>    241→    elseif command=="setupSpeedRun" then
>    242→        local new=newState(false)
>    243→        new.player.x=-200; new.player.y=100
>    244→        currentInput={x=1,y=0,kick=false}
>    245→        currentInputs[1]=currentInput
>    246→        speedRunRemaining=120
>    247→        logEvent("scenarioReset",{scenario="freeAccelerationRun",playerX=-200,playerY=100,inputX=1,inputY=0})
>    248→    elseif command=="setupBallFastCrossing" then
>    249→        local new=newState(false,false,true)
>    250→        new.player.x=-40; new.player.vx=100
>    251→        new.ball.x=0; new.ball.y=0
>    252→        logEvent("scenarioReset",{scenario="fastPlayerBallCrossing",playerX=-40,playerVx=100,ballX=0})
>    253→    elseif command=="setupBallFastDiagonal" then
>    254→        local new=newState(false,false,true)
>    255→        new.player.x=-40; new.player.y=-40; new.player.vx=100; new.player.vy=100
>    256→        new.ball.x=0; new.ball.y=0
>    257→        logEvent("scenarioReset",{scenario="fastDiagonalPlayerBallCrossing",playerX=-40,playerY=-40,playerVx=100,playerVy=100,ballX=0,ballY=0})
>    258→    elseif command=="setupMultiWall" then
>    259→        local new=newState(false,false,true)
>    260→        new.player.y=100
>    261→        new.ball.x=0; new.ball.y=0; new.ball.vx=3000
>    262→        logEvent("scenarioReset",{scenario="multiWallBouncesInTick",ballX=0,ballVx=3000})
>    263→    elseif command=="setupPairHeadOn" then
>    264→        local new=newState(true)
>    265→        new.player.x=-40; new.player.vx=2
>    266→        new.player2.x=40; new.player2.vx=-2
>    267→        logEvent("scenarioReset",{scenario="playerHeadOn",p1x=-40,p1vx=2,p2x=40,p2vx=-2})
>    268→    elseif command=="setupPairFastCrossing" then
>    269→        local new=newState(true)
>    270→        new.player.x=-40; new.player.vx=80
>    271→        new.player2.x=40; new.player2.vx=-80
>    272→        logEvent("scenarioReset",{scenario="fastPairCrossing",p1x=-40,p1vx=80,p2x=40,p2vx=-80})
>    273→    elseif command=="setupPairOblique" then
>    274→        local new=newState(true)
>    275→        new.player.x=-40; new.player.y=-10; new.player.vx=2
>    276→        new.player2.x=0; new.player2.y=15; new.player2.vy=-0.8
>    277→        logEvent("scenarioReset",{scenario="playerOblique",p1x=-40,p1y=-10,p1vx=2,p2x=0,p2y=15,p2vy=-0.8})
>    278→    elseif command=="setupPairOverlap" then
>    279→        local new=newState(true)
>    280→        new.player.x=0; new.player.y=0
>    281→        new.player2.x=0; new.player2.y=0
>    282→        logEvent("scenarioReset",{scenario="playerCoincidentCenters"})
>    283→    elseif command=="setupCrowdOverlap" then
>    284→        local new=newState(false,true)
>    285→        new.player.x=-14; new.player2.x=14
>    286→        new.ball.x=0; new.ball.y=0
>    287→        logEvent("scenarioReset",{scenario="threeDiscOverlap",p1x=-14,p2x=14,ballX=0})
>    288→    elseif command=="setupCrowdApproach" then
>    289→        local new=newState(false,true)
>    290→        new.player.x=-32; new.player.vx=2
>    291→        new.player2.x=32; new.player2.vx=-2
>    292→        new.ball.x=0; new.ball.y=0
>    293→        logEvent("scenarioReset",{scenario="twoPlayersApproachBall",p1x=-32,p1vx=2,p2x=32,p2vx=-2,ballX=0})
>    294→    elseif command=="runRegressionSuite" then
>    295→        local report=LabRegression.Run(Physics2D)
>    296→        metrics.regressionRan=true
>    297→        metrics.regressionPassed=report.passed
>    298→        metrics.regressionFailed=report.failed
>    299→        metrics.regressionTotal=report.total
>    300→        logEvent("regressionSuiteCompleted",{passed=report.passed,failed=report.failed,total=report.total,allPassed=report.allPassed})
>    301→    elseif command=="toggleRecording" then
>    302→        recording=not recording
>    303→        logEvent("recordingChanged",{recording=recording})
>    304→    end
>    305→end)
>    306→
>    307→local function snapshot()
>    308→    local p,p2,b=state.player,state.player2,state.ball
>    309→    local dx,dy=p.x-b.x,p.y-b.y
>    310→    local p2dx,p2dy=p.x-p2.x,p.y-p2.y
>    311→    local p2bdx,p2bdy=p2.x-b.x,p2.y-b.y
>    312→    local playerSnapshots={}
>    313→    local redCount,blueCount=0,0
>    314→    if state.players then
>    315→        for slot,disc in ipairs(state.players) do
>    316→            if disc.team=="red" then redCount+=1 elseif disc.team=="blue" then blueCount+=1 end
>    317→            table.insert(playerSnapshots,{playerId=slot,team=disc.team,ownerUserId=disc.ownerUserId,x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy,speed=speed(disc),radius=disc.radius,collisionGroup=disc.collisionGroup,collisionMask=disc.collisionMask})
>    318→        end
>    319→    end
>    320→    return {
>    321→        tick=state.tick, gameTime=state.tick/Physics2D.Config.tickRate,
>    322→        matchPhase=matchState.phase,pauseTicksRemaining=matchState.remainingTicks,kickoffTeam=matchState.kickoffTeam,lastGoal=matchState.lastGoal,lastTouch=matchState.lastTouch,
>    323→        player={x=p.x,y=p.y,vx=p.vx,vy=p.vy,speed=speed(p),radius=p.radius},
>    324→        predictionParams={acceleration=p.acceleration or Physics2D.Config.playerAcceleration,kickAcceleration=p.kickAcceleration or Physics2D.Config.playerKickAcceleration,damping=p.damping or Physics2D.Config.playerDamping,kickDamping=p.kickDamping or Physics2D.Config.playerDamping,maxSpeed=p.maxSpeed},
>    325→        player2={x=p2.x,y=p2.y,vx=p2.vx,vy=p2.vy,speed=speed(p2)},
>    326→        players=playerSnapshots,playerCount=#playerSnapshots,redCount=redCount,blueCount=blueCount,
>    327→        ball={x=b.x,y=b.y,vx=b.vx,vy=b.vy,speed=speed(b),radius=b.radius,collisionGroup=b.collisionGroup,collisionMask=b.collisionMask},
>    328→        score={red=state.score.red,blue=state.score.blue},
>    329→        ownerUserId=p.ownerUserId,physicsDiscCount=state.coreWorld and #state.coreWorld.discs or 0,
>    330→        input={x=currentInput.x,y=currentInput.y,kick=currentInput.kick},
>    331→        separation=math.sqrt(dx*dx+dy*dy),
>    332→        playerSeparation=math.sqrt(p2dx*p2dx+p2dy*p2dy),
>    333→        player2BallSeparation=math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy),
>    334→        touchingBall=not pairMode and math.sqrt(dx*dx+dy*dy)<=p.radius+b.radius+0.02,
>    335→        touchingPlayer2Ball=crowdMode and math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy)<=p2.radius+b.radius+0.02,
>    336→        touchingPlayers=math.sqrt(p2dx*p2dx+p2dy*p2dy)<=p.radius+p2.radius+0.02,
>    337→        pairMode=pairMode,
>    338→        crowdMode=crowdMode,
>    339→        coreMode=state.coreWorld~=nil,
>    340→        legacyMode=legacyMode,
>    341→        ballActive=not pairMode,
>    342→        metrics=table.clone(metrics),
>    343→        recording=recording,
>    344→        crowdMode=crowdMode,
>    345→        historySamples=historyCount,
>    346→    }
>    347→end
>    348→debugState.OnInvoke=function(request)
>    349→    local current=snapshot()
>    350→    if request=="regression" then
>    351→        return LabRegression.Run(Physics2D)
>    352→    end
>    353→    if request=="summary" then
>    354→        return {current=current,metrics=table.clone(metrics),eventCount=#events,historyCount=historyCount,recording=recording}
>    355→    end
>    356→    local chronological={}
>    357→    local limit=type(request)=="table" and math.clamp(request.limit or 600,1,1200) or 600
>    358→    local hasAfterTick=type(request)=="table" and type(request.afterTick)=="number"
>    359→    local afterTick=hasAfterTick and request.afterTick or -1
>    360→    local first=historyCount<historyCapacity and 1 or historyWrite
>    361→    local skip=hasAfterTick and 0 or math.max(0,historyCount-limit)
>    362→    for i=skip+1,historyCount do
>    363→        local index=((first+i-2)%historyCapacity)+1
>    364→        local sample=historyBuffer[index]
>    365→        if sample and sample.tick>afterTick then
>    366→            table.insert(chronological,table.clone(sample))
>    367→            if #chronological>=limit then break end
>    368→        end
>    369→    end
>    370→    local eventCopies={}
>    371→    for _,event in events do table.insert(eventCopies,table.clone(event)) end
>    372→    return {current=current,metrics=table.clone(metrics),events=eventCopies,history=chronological,recording=recording}
>    373→end
>    374→
>    375→RunService.Heartbeat:Connect(function(dt)
>    376→    accumulator+=dt
>    377→    local iterations=0
>    378→    while accumulator>=stepDt and iterations<8 do
>    379→        local p,p2,b=state.player,state.player2,state.ball
>    380→        local beforeBallVx,beforeBallVy=b.vx,b.vy
>    381→        local beforePlayerVx,beforePlayerVy=p.vx,p.vy
>    382→        local pairResolution=nil
>    383→        local crowdResiduals=nil
>    384→        local physicsStepInfo=nil
>    385→        local pairBeforeSeparation=math.sqrt((p.x-p2.x)^2+(p.y-p2.y)^2)
>    386→
>    387→        if pairMode then
>    388→            local _,resolution=Physics2D.stepPlayerPair(state)
>    389→            pairResolution=resolution
>    390→            local separation=math.sqrt((p.x-p2.x)^2+(p.y-p2.y)^2)
>    391→            local nowTouching=separation<=p.radius+p2.radius+0.02
>    392→            if resolution then
>    393→                metrics.maxPlayerPenetration=math.max(metrics.maxPlayerPenetration,resolution.penetration)
>    394→                metrics.maxPlayerCorrection=math.max(metrics.maxPlayerCorrection,resolution.correctionA+resolution.correctionB)
>    395→                if resolution and not touchingPlayers and (nowTouching or resolution.swept==true) then
>    396→                    metrics.playerContacts+=1
>    397→                    metrics.lastPlayerContactTick=state.tick
>    398→                    metrics.lastPlayerImpulse=resolution.impulse
>    399→                    logEvent("playerPlayerContact",{
>    400→                        separation=resolution.swept and (p.radius+p2.radius-resolution.penetration) or separation,
>    401→                        postStepSeparation=separation, penetration=resolution.penetration,
>    402→                        correctionA=resolution.correctionA, correctionB=resolution.correctionB,
>    403→                        normalX=resolution.normalX, normalY=resolution.normalY,
>    404→                        normalSpeedBefore=resolution.normalSpeedBefore, impulse=resolution.impulse,
>    405→                        swept=resolution.swept==true, impactFraction=resolution.impactFraction,
>    406→                        p1x=p.x,p1y=p.y,p1vx=p.vx,p1vy=p.vy,
>    407→                        p2x=p2.x,p2y=p2.y,p2vx=p2.vx,p2vy=p2.vy,
>    408→                    },state.tick)
>    409→                end
>    410→            end
>    411→            touchingPlayers=nowTouching
>    412→        elseif crowdMode then
>    413→            local _, impacts, residuals, maxResidual, iterationsUsed = Physics2D.stepThreeBody(state, Physics2D.Config.collisionIterations)
>    414→            crowdResiduals=residuals
>    415→            metrics.crowdLastSolverIterations=iterationsUsed
>    416→            metrics.crowdMaxSolverIterations=math.max(metrics.crowdMaxSolverIterations,iterationsUsed)
>    417→            local pairDefinitions = {
>    418→                {key="player1-player2", a=p, b=p2, metric="crowdContactsP1P2"},
>    419→                {key="player1-ball", a=p, b=b, metric="crowdContactsP1Ball"},
>    420→                {key="player2-ball", a=p2, b=b, metric="crowdContactsP2Ball"},
>    421→            }
>    422→            for _, definition in pairDefinitions do
>    423→                local dx,dy=definition.a.x-definition.b.x,definition.a.y-definition.b.y
>    424→                local separation=math.sqrt(dx*dx+dy*dy)
>    425→                local isTouching=separation<=definition.a.radius+definition.b.radius+0.02
>    426→                local impact=impacts[definition.key]
>    427→                if impact then
>    428→                    metrics.crowdPeakPenetration=math.max(metrics.crowdPeakPenetration,impact.maxPenetration)
>    429→                end
>    430→                if isTouching and not touchingCrowdPairs[definition.key] then
>    431→                    metrics.crowdContacts+=1
>    432→                    metrics[definition.metric]+=1
>    433→                    logEvent("threeDiscContact",{
>    434→                        pair=definition.key,separation=separation,
>    435→                        penetration=impact and impact.maxPenetration or 0,
>    436→                        correctionA=impact and impact.correctionA or 0,
>    437→                        correctionB=impact and impact.correctionB or 0,
>    438→                        normalX=impact and impact.normalX or 0,
>    439→                        normalY=impact and impact.normalY or 0,
>    440→                        normalSpeedBefore=impact and impact.normalSpeedBefore or 0,
>    441→                        impulseTotal=impact and impact.impulseTotal or 0,
>    442→                        peakImpulseIncrement=impact and impact.peakImpulseIncrement or 0,
>    443→                        lastImpulse=impact and impact.lastImpulse or 0,
>    444→                        resolutionCount=impact and impact.resolutionCount or 0,
>    445→                        residualPenetration=residuals[definition.key] or 0,
>    446→                        p1x=p.x,p1y=p.y,p1vx=p.vx,p1vy=p.vy,
>    447→                        p2x=p2.x,p2y=p2.y,p2vx=p2.vx,p2vy=p2.vy,
>    448→                        ballX=b.x,ballY=b.y,ballVx=b.vx,ballVy=b.vy,
>    449→                    },state.tick)
>    450→                end
>    451→                touchingCrowdPairs[definition.key]=isTouching
>    452→            end
>    453→            metrics.crowdLastResidualPenetration=maxResidual
>    454→            metrics.crowdWorstResidualPenetration=math.max(metrics.crowdWorstResidualPenetration,maxResidual)
>    455→            touchingPlayers=touchingCrowdPairs["player1-player2"]==true
>    456→        elseif state.coreWorld then
>    457→            local coreInputs,kickAttempts={},{}
>    458→            local pausedAtStart=matchState.phase=="goalPause"
>    459→            local kickoffAtStart=matchState.phase=="kickoff"
>    460→            local inputsLocked=pausedAtStart or kickoffAtStart
>    461→            for slot=1,10 do
>    462→                local input=inputsLocked and {x=0,y=0,kick=false} or (currentInputs[slot] or {x=0,y=0,kick=false})
>    463→                if not inputsLocked then
>    464→                    input=MatchRules2D.filterKickoffInput(matchState,state.players[slot].team,input)
>    465→                end
>    466→                coreInputs[slot]=input
>    467→                if not inputsLocked and input.kick and not lastCoreKickInputs[slot] then table.insert(kickAttempts,slot) end
>    468→                lastCoreKickInputs[slot]=inputsLocked and false or input.kick
>    469→            end
>    470→            for slot,actor in ipairs(state.players) do
>    471→                actor.collisionMask=MatchRules2D.kickoffCollisionMask(matchState,actor.team,state.playerCollisionMasks[slot],ClassicStadium2D.Groups.ball)
>    472→            end
>    473→            local _,coreEvents,coreSubsteps=PhysicsCore2D.stepWorld(state.coreWorld,coreInputs)
>    474→            state.tick=state.coreWorld.tick
>    475→            local stepInfo={substeps=coreSubsteps or 1,ballWallBounces=0,playerWallBounces=0,playerBallContacts=0,lastPlayerBallContact=nil}
>    476→            local acceptedKicks,currentTouches,contactsByPlayer={},{},{}
>    477→            for _,event in ipairs(coreEvents) do
>    478→                if event.kind=="kick" then
>    479→                    acceptedKicks[event.playerId]=true
>    480→                    metrics.successfulKicks+=1
>    481→                    metrics.lastKickSuccessTick=state.tick
>    482→                    logEvent("kickApplied",{playerId=event.playerId,targetId=event.targetId,normalX=event.normalX,normalY=event.normalY},state.tick)
>    483→                    local kicker=state.players[event.playerId]
>    484→                    if kicker then MatchRules2D.recordTouch(matchState,event.playerId,kicker.team,state.tick,"kick") end
>    485→                    if kicker and MatchRules2D.completeKickoff(matchState,kicker.team) then
>    486→                        logEvent("kickoffTaken",{playerId=event.playerId,team=kicker.team},state.tick)
>    487→                    end
>    488→                elseif event.kind=="boundaryContact" then
>    489→                    local count=event.count or 1
>    490→                    if event.discId=="ball" then stepInfo.ballWallBounces+=count
>    491→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=count end
>    492→                elseif event.kind=="planeContact" or event.kind=="segmentContact" then
>    493→                    if event.discId=="ball" then stepInfo.ballWallBounces+=1
>    494→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=1 end
>    495→                elseif event.kind=="discContact" then
>    496→                    local playerId
>    497→                    if event.discA=="ball" and type(event.discB)=="number" then playerId=event.discB
>    498→                    elseif event.discB=="ball" and type(event.discA)=="number" then playerId=event.discA end
>    499→                    if playerId then
>    500→                        stepInfo.playerBallContacts+=1
>    501→                        local nx,ny=event.normalX,event.normalY
>    502→                        if event.discA=="ball" then nx,ny=-nx,-ny end
>    503→                        local contact={playerId=playerId,normalX=nx,normalY=ny,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse}
>    504→                        stepInfo.lastPlayerBallContact=contact
>    505→                        contactsByPlayer[playerId]=contact
>    506→                        currentTouches[playerId]=true
>    507→                        local toucher=state.players[playerId]
>    508→                        if toucher then MatchRules2D.recordTouch(matchState,playerId,toucher.team,state.tick,"contact") end
>    509→                    elseif type(event.discA)=="number" and type(event.discB)=="number" then
>    510→                        metrics.playerContacts+=1
>    511→                        metrics.lastPlayerContactTick=state.tick
>    512→                        metrics.maxPlayerPenetration=math.max(metrics.maxPlayerPenetration,event.penetration or 0)
>    513→                        metrics.lastPlayerImpulse=event.impulse or 0
>    514→                        logEvent("playerPlayerContact",{playerA=event.discA,playerB=event.discB,normalX=event.normalX,normalY=event.normalY,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse},state.tick)
>    515→                    end
>    516→                end
>    517→            end
>    518→            metrics.kickAttempts+=#kickAttempts
>    519→            for _,slot in ipairs(kickAttempts) do
>    520→                local accepted=acceptedKicks[slot]==true
>    521→                local actor=state.players[slot]
>    522→                local separation=math.sqrt((actor.x-b.x)^2+(actor.y-b.y)^2)
>    523→                logEvent("kickAttempt",{playerId=slot,accepted=accepted,separation=separation,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    524→            end
>    525→            for slot,actor in ipairs(state.players) do
>    526→                local dx,dy=actor.x-b.x,actor.y-b.y
>    527→                local touching=math.sqrt(dx*dx+dy*dy)<=actor.radius+b.radius+0.02
>    528→                if currentTouches[slot] and not touchingCoreBall[slot] then
>    529→                    metrics.ballContacts+=1
>    530→                    local contact=contactsByPlayer[slot] or {}
>    531→                    logEvent("playerBallContact",{playerId=slot,separation=actor.radius+b.radius-(contact.penetration or 0),normalX=contact.normalX,normalY=contact.normalY,normalSpeedBefore=contact.normalSpeedBefore,impulse=contact.impulse,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    532→                end
>    533→                touchingCoreBall[slot]=touching
>    534→            end
>    535→            if pausedAtStart then
>    536→                if MatchRules2D.advancePause(matchState) then
>    537→                    MatchRules2D.resetKickoff(b,state.players,state.spawnPoints)
>    538→                    local teamToKick=matchState.lastGoal and (matchState.lastGoal.team=="red" and "blue" or "red") or "red"
>    539→                    MatchRules2D.beginKickoff(matchState,teamToKick)
>    540→                    touchingCoreBall={}
>    541→                    touchingBall=false
>    542→                    logEvent("kickoffReset",{teamToKick=teamToKick,lockTicks=matchState.remainingTicks},state.tick)
>    543→                end
>    544→            elseif kickoffAtStart then
>    545→                if MatchRules2D.advanceKickoff(matchState) then
>    546→                    local teamToKick=matchState.kickoffTeam
>    547→                    MatchRules2D.resume(matchState)
>    548→                    logEvent("kickoffComplete",{teamToKick=teamToKick},state.tick)
>    549→                end
>    550→            else
>    551→                local goal=MatchRules2D.findGoalCrossing(state.coreWorld.motionSegments,"ball")
>    552→                if goal then
>    553→                    goal.tick=state.tick
>    554→                    MatchRules2D.beginGoalPause(matchState,state.score,goal,b,state.players)
>    555→                    currentInputs={}
>    556→                    for slot=1,10 do currentInputs[slot]={x=0,y=0,kick=false} end
>    557→                    currentInput=currentInputs[1]
>    558→                    lastCoreKickInputs={}
>    559→                    touchingCoreBall={}
>    560→                    touchingBall=false
>    561→                    logEvent("goalScored",{team=goal.team,side=goal.side,x=goal.x,y=goal.y,substep=goal.substep,substeps=goal.substeps,fraction=goal.fraction},state.tick)
>    562→                end
>    563→            end
>    564→            physicsStepInfo=stepInfo
>    565→            if speedRunRemaining>0 then
>    566→                speedRunRemaining-=1
>    567→                if speedRunRemaining==0 then
>    568→                    currentInput={x=0,y=0,kick=false}
>    569→                    currentInputs[1]=currentInput
>    570→                    logEvent("speedRunFinished",{ticks=120,playerX=p.x,playerVx=p.vx,playerSpeed=speed(p)},state.tick)
>    571→                end
>    572→            end
>    573→            metrics.lastCollisionSubsteps=stepInfo.substeps
>    574→            metrics.maxCollisionSubsteps=math.max(metrics.maxCollisionSubsteps,stepInfo.substeps)
>    575→            if stepInfo.ballWallBounces>0 then
>    576→                metrics.ballWallBounces+=stepInfo.ballWallBounces
>    577→                logEvent("ballBoundaryBounce",{count=stepInfo.ballWallBounces,x=b.x,y=b.y,vx=b.vx,vy=b.vy,substeps=stepInfo.substeps},state.tick)
>    578→            end
>    579→            if stepInfo.playerWallBounces>0 then
>    580→                metrics.playerWallBounces+=stepInfo.playerWallBounces
>    581→                logEvent("playerBoundaryBounce",{count=stepInfo.playerWallBounces,x=p.x,y=p.y,vx=p.vx,vy=p.vy,substeps=stepInfo.substeps},state.tick)
>    582→            end
>    583→            local separation=math.sqrt((p.x-b.x)^2+(p.y-b.y)^2)
>    584→            local nowTouching=separation<=p.radius+b.radius+0.02
>    585→            touchingBall=nowTouching
>    586→        else
>    587→            if currentInput.kick
>    588→ and not lastKick then
>    589→                metrics.kickAttempts+=1
>    590→                local dx,dy=b.x-p.x,b.y-p.y
>    591→                local separation=math.sqrt(dx*dx+dy*dy)
>    592→                local accepted=Physics2D.tryKick(state,facingX,facingY)
>    593→                if accepted then
>    594→                    metrics.successfulKicks+=1
>    595→                    metrics.lastKickSuccessTick=state.tick+1
>    596→                end
>    597→                logEvent("kickAttempt",{accepted=accepted,separation=separation,playerX=p.x,playerY=p.y,ballX=b.x,ballY=b.y})
>    598→            end
>    599→            lastKick=currentInput.kick
>    600→            local _,stepInfo=Physics2D.step(state,currentInput)
>    601→            physicsStepInfo=stepInfo
>    602→            if speedRunRemaining>0 then
>    603→                speedRunRemaining-=1
>    604→                if speedRunRemaining==0 then
>    605→                    currentInput={x=0,y=0,kick=false}
>    606→                    currentInputs[1]=currentInput
>    607→                    logEvent("speedRunFinished",{ticks=120,playerX=p.x,playerVx=p.vx,playerSpeed=speed(p)},state.tick)
>    608→                end
>    609→            end
>    610→            metrics.lastCollisionSubsteps=stepInfo.substeps
>    611→            metrics.maxCollisionSubsteps=math.max(metrics.maxCollisionSubsteps,stepInfo.substeps)
>    612→            if stepInfo.ballWallBounces>0 then
>    613→                metrics.ballWallBounces+=stepInfo.ballWallBounces
>    614→                logEvent("ballBoundaryBounce",{count=stepInfo.ballWallBounces,x=b.x,y=b.y,vx=b.vx,vy=b.vy,substeps=stepInfo.substeps},state.tick)
>    615→            end
>    616→            if stepInfo.playerWallBounces>0 then
>    617→                metrics.playerWallBounces+=stepInfo.playerWallBounces
>    618→                logEvent("playerBoundaryBounce",{count=stepInfo.playerWallBounces,x=p.x,y=p.y,vx=p.vx,vy=p.vy,substeps=stepInfo.substeps},state.tick)
>    619→            end
>    620→            local separation=math.sqrt((p.x-b.x)^2+(p.y-b.y)^2)
>    621→            local nowTouching=separation<=p.radius+b.radius+0.02
>    622→            if stepInfo.playerBallContacts>0 and not touchingBall then
>    623→                metrics.ballContacts+=1
>    624→                local contact=stepInfo.lastPlayerBallContact or {}
>    625→                logEvent("playerBallContact",{
>    626→                    separation=p.radius+b.radius-(contact.penetration or 0),postStepSeparation=separation,
>    627→                    contactsThisTick=stepInfo.playerBallContacts,substep=contact.substep,substeps=stepInfo.substeps,
>    628→                    normalX=contact.normalX,normalY=contact.normalY,normalSpeedBefore=contact.normalSpeedBefore,
>    629→                    impulse=contact.impulse,penetration=contact.penetration,playerX=p.x,playerY=p.y,ballX=b.x,ballY=b.y,
>    630→                },state.tick)
>    631→            end
>    632→            touchingBall=nowTouching
>    633→        end
>    634→
>    635→        accumulator-=stepDt
>    636→        iterations+=1
>    637→        local current=snapshot()
>    638→        if recording then
>    639→            historyBuffer[historyWrite]={
>    640→                tick=current.tick,gameTime=current.gameTime,pairMode=pairMode,crowdMode=crowdMode,
>    641→                inputX=current.input.x,inputY=current.input.y,kick=current.input.kick,
>    642→                playerX=p.x,playerY=p.y,playerVx=p.vx,playerVy=p.vy,playerSpeed=current.player.speed,
>    643→                player2X=p2.x,player2Y=p2.y,player2Vx=p2.vx,player2Vy=p2.vy,player2Speed=current.player2.speed,
>    644→                players=current.players,
>    645→                ballX=b.x,ballY=b.y,ballVx=b.vx,ballVy=b.vy,ballSpeed=current.ball.speed,
>    646→                separation=current.separation,playerSeparation=current.playerSeparation,player2BallSeparation=current.player2BallSeparation,
>    647→                pairPenetration=pairResolution and pairResolution.penetration or 0,
>    648→                crowdContacts=metrics.crowdContacts,crowdResidual=metrics.crowdLastResidualPenetration,solverIterations=metrics.crowdLastSolverIterations,
>    649→                physicsSubsteps=physicsStepInfo and physicsStepInfo.substeps or 0,
>    650→                residualP1P2=crowdResiduals and crowdResiduals["player1-player2"] or 0,
>    651→                residualP1Ball=crowdResiduals and crowdResiduals["player1-ball"] or 0,
>    652→                residualP2Ball=crowdResiduals and crowdResiduals["player2-ball"] or 0,
>    653→                pairNormalX=pairResolution and pairResolution.normalX or 0,
>    654→                pairNormalY=pairResolution and pairResolution.normalY or 0,
>    655→                pairImpulse=pairResolution and pairResolution.impulse or 0,
>    656→                touchingBall=current.touchingBall,touchingPlayers=current.touchingPlayers,
>    657→            }
>    658→            historyWrite=(historyWrite%historyCapacity)+1
>    659→            historyCount=math.min(historyCapacity,historyCount+1)
>    660→        end
>    661→        snapshotRemote:FireAllClients(current)
>    662→    end
>    663→end)
>    664→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.MatchRules2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local ReplicatedStorage = game:GetService("ReplicatedStorage")
>      2→local Profile = require(ReplicatedStorage:WaitForChild("HaxballLab"):WaitForChild("StadiumReference2D"))
>      3→local Rules = {}
>      4→
>      5→Rules.GoalLines = {
>      6→    { side = "left", x = Profile.Goals.leftX, team = Profile.Goals.scoringTeams.left },
>      7→    { side = "right", x = Profile.Goals.rightX, team = Profile.Goals.scoringTeams.right },
>      8→}
>      9→Rules.GoalHalfHeight = Profile.Goals.halfHeight
>     10→Rules.GoalPauseTicks = 90
>     11→Rules.KickoffTicks = 30
>     12→
>     13→function Rules.newMatch()
>     14→    return { phase = "playing", remainingTicks = 0, lastGoal = nil, kickoffTeam = nil }
>     15→end
>     16→
>     17→function Rules.findGoalCrossing(motionSegments, ballId)
>     18→    if type(motionSegments) ~= "table" then return nil end
>     19→    ballId = ballId or "ball"
>     20→    for _, path in ipairs(motionSegments) do
>     21→        if path.discId == ballId then
>     22→            for _, goal in ipairs(Rules.GoalLines) do
>     23→                local crossed = goal.side == "right"
>     24→                    and path.x0 < goal.x and path.x1 >= goal.x
>     25→                    or goal.side == "left" and path.x0 > goal.x and path.x1 <= goal.x
>     26→                if crossed then
>     27→                    local dx = path.x1 - path.x0
>     28→                    if math.abs(dx) > 1e-12 then
>     29→                        local alpha = (goal.x - path.x0) / dx
>     30→                        local y = path.y0 + (path.y1 - path.y0) * alpha
>     31→                        if math.abs(y) <= Rules.GoalHalfHeight then
>     32→                            return { side = goal.side, team = goal.team, x = goal.x, y = y, substep = path.substep, substeps = path.substeps, fraction = alpha }
>     33→                        end
>     34→                    end
>     35→                end
>     36→            end
>     37→        end
>     38→    end
>     39→    return nil
>     40→end
>     41→
>     42→function Rules.beginGoalPause(match, score, goal, ball, players, pauseTicks)
>     43→    assert(match.phase == "playing", "goal can only be recorded while playing")
>     44→    assert(goal and (goal.team == "red" or goal.team == "blue"), "goal team is invalid")
>     45→    score[goal.team] += 1
>     46→    match.phase = "goalPause"
>     47→    match.remainingTicks = pauseTicks or Rules.GoalPauseTicks
>     48→    match.lastGoal = { team = goal.team, side = goal.side, x = goal.x, y = goal.y, tick = goal.tick }
>     49→    ball.vx, ball.vy = 0, 0
>     50→    for _, player in ipairs(players) do
>     51→        player.vx, player.vy = 0, 0
>     52→        player.kickHeld = false
>     53→        player.kickArmed = false
>     54→        player.kickCooldown = 0
>     55→    end
>     56→    return match.lastGoal
>     57→end
>     58→
>     59→function Rules.advancePause(match)
>     60→    if match.phase ~= "goalPause" then return false end
>     61→    match.remainingTicks = math.max(0, match.remainingTicks - 1)
>     62→    return match.remainingTicks == 0
>     63→end
>     64→
>     65→function Rules.resetKickoff(ball, players, spawnPoints)
>     66→    ball.x, ball.y, ball.vx, ball.vy = 0, 0, 0, 0
>     67→    for index, player in ipairs(players) do
>     68→        local spawn = spawnPoints[index]
>     69→        assert(spawn and type(spawn.x) == "number" and type(spawn.y) == "number", "spawn point is missing")
>     70→        player.x, player.y, player.vx, player.vy = spawn.x, spawn.y, 0, 0
>     71→        player.kickHeld, player.kickArmed, player.kickCooldown = false, false, 0
>     72→    end
>     73→end
>     74→
>     75→function Rules.beginKickoff(match, team, ticks)
>     76→    assert(match.phase == "goalPause", "kickoff can only follow a goal pause")
>     77→    assert(team == "red" or team == "blue", "kickoff team is invalid")
>     78→    match.phase, match.remainingTicks, match.kickoffTeam = "kickoff", ticks or Rules.KickoffTicks, team
>     79→end
>     80→
>     81→function Rules.advanceKickoff(match)
>     82→    if match.phase ~= "kickoff" then return false end
>     83→    match.remainingTicks = math.max(0, match.remainingTicks - 1)
>     84→    return match.remainingTicks == 0
>     85→end
>     86→
>     87→function Rules.resume(match)
>     88→    match.phase, match.remainingTicks = "playing", 0
>     89→end
>     90→
>     91→function Rules.recordTouch(match, playerId, team, tick, kind)
>     92→    if type(playerId) ~= "number" or (team ~= "red" and team ~= "blue") then return false end
>     93→    match.lastTouch = { playerId = playerId, team = team, tick = tick, kind = kind }
>     94→    return true
>     95→end
>     96→
>     97→function Rules.kickoffCollisionMask(match, playerTeam, defaultMask, ballGroup)
>     98→    local mask = defaultMask
>     99→    if match.kickoffTeam then
>    100→        local kickoffFlag = match.kickoffTeam == "red" and Profile.CollisionGroups.redKO or Profile.CollisionGroups.blueKO
>    101→        -- Haxball adds the kickoff flag to the normal player mask; ball remains enabled.
>    102→        mask = bit32.bor(mask, kickoffFlag)
>    103→    end
>    104→    return mask
>    105→end
>    106→
>    107→function Rules.filterKickoffInput(match, playerTeam, input)
>    108→    if match.kickoffTeam and playerTeam ~= match.kickoffTeam and input.kick then
>    109→        return { x = input.x, y = input.y, kick = false }, true
>    110→    end
>    111→    return input, false
>    112→end
>    113→
>    114→function Rules.completeKickoff(match, playerTeam)
>    115→    if match.phase ~= "playing" or not match.kickoffTeam or playerTeam ~= match.kickoffTeam then return false end
>    116→    match.kickoffTeam = nil
>    117→    return true
>    118→end
>    119→
>    120→return Rules
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabRegression",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Suite={}
>      2→local ClassicStadium2D=require(script.Parent:WaitForChild("ClassicStadium2D"))
>      3→local MatchRules2D=require(script.Parent:WaitForChild("MatchRules2D"))
>      4→local PredictionLab2D=require(game:GetService("ReplicatedStorage").HaxballLab:WaitForChild("PredictionLab2D"))
>      5→local StadiumProfile2D=require(game:GetService("ReplicatedStorage").HaxballLab:WaitForChild("StadiumReference2D"))
>      6→local function near(a,b,tolerance)
>      7→    return math.abs(a-b)<=tolerance
>      8→end
>      9→local function finite(n)
>     10→    return type(n)=="number" and n==n and math.abs(n)<1e12
>     11→end
>     12→local function addResult(report,name,fn)
>     13→    local ok,value=pcall(fn)
>     14→    table.insert(report.tests,{
>     15→        name=name,passed=ok and value.passed==true,
>     16→        detail=ok and value.detail or tostring(value),
>     17→    })
>     18→end
>     19→
>     20→function Suite.Run(P)
>     21→    local report={tickRate=P.Config.tickRate,tests={}}
>     22→    addResult(report,"horizontal_free_acceleration_120_ticks",function()
>     23→        local s=P.newState();s.player.x=-200;s.player.y=100
>     24→        local vx,x=0,-200
>     25→        local maxX,maxV=0,0
>     26→        for i=1,120 do
>     27→            local before=vx+P.Config.playerAcceleration
>     28→            x+=before;vx=before*P.Config.playerDamping
>     29→            P.step(s,{x=1,y=0,kick=false})
>     30→            maxX=math.max(maxX,math.abs(s.player.x-x))
>     31→            maxV=math.max(maxV,math.abs(s.player.vx-vx))
>     32→        end
>     33→        return {passed=maxX<=1e-9 and maxV<=1e-9,detail=string.format("samples=120 maxPositionError=%.3g maxVelocityError=%.3g finalSpeed=%.9f",maxX,maxV,math.abs(vx))}
>     34→    end)
>     35→    addResult(report,"diagonal_normalization_120_ticks",function()
>     36→        local s=P.newState();s.player.x=-200;s.player.y=-150;s.ball.x=300
>     37→        local vx,vy,x,y=0,0,-200,-150
>     38→        local ux,uy=1/math.sqrt(2),1/math.sqrt(2)
>     39→        local maxError=0
>     40→        for i=1,120 do
>     41→            local nx,ny=vx+P.Config.playerAcceleration*ux,vy+P.Config.playerAcceleration*uy
>     42→            x+=nx;y+=ny;vx,vy=nx*P.Config.playerDamping,ny*P.Config.playerDamping
>     43→            P.step(s,{x=1,y=1,kick=false})
>     44→            maxError=math.max(maxError,math.abs(s.player.x-x),math.abs(s.player.y-y),math.abs(s.player.vx-vx),math.abs(s.player.vy-vy))
>     45→        end
>     46→        local speed=math.sqrt(s.player.vx*s.player.vx+s.player.vy*s.player.vy)
>     47→        return {passed=maxError<=1e-9 and near(speed,2.382103866679,1e-9),detail=string.format("samples=120 maxStateError=%.3g finalSpeed=%.9f",maxError,speed)}
>     48→    end)
>     49→    addResult(report,"release_damping_30_ticks",function()
>     50→        local s=P.newState();s.player.x=-200;s.player.y=100
>     51→        for i=1,120 do P.step(s,{x=1,y=0}) end
>     52→        local expectedV,expectedX=s.player.vx,s.player.x
>     53→        for i=1,30 do expectedX+=expectedV;expectedV*=P.Config.playerDamping;P.step(s,{x=0,y=0}) end
>     54→        local xError,vError=math.abs(s.player.x-expectedX),math.abs(s.player.vx-expectedV)
>     55→        return {passed=xError<=1e-9 and vError<=1e-9,detail=string.format("samples=30 positionError=%.3g velocityError=%.3g",xError,vError)}
>     56→    end)
>     57→    addResult(report,"ball_damping_120_ticks",function()
>     58→        local s=P.newState();s.player.x=-200;s.player.y=100;s.ball.vx=2
>     59→        local x,v=0,2
>     60→        for i=1,120 do x+=v;v*=P.Config.ballDamping;P.step(s,{x=0,y=0}) end
>     61→        local xError,vError=math.abs(s.ball.x-x),math.abs(s.ball.vx-v)
>     62→        return {passed=xError<=1e-9 and vError<=1e-9,detail=string.format("samples=120 positionError=%.3g velocityError=%.3g",xError,vError)}
>     63→    end)
>     64→    addResult(report,"kick_range_and_impulse",function()
>     65→        local s=P.newState();s.player.x=-27
>     66→        local accepted=P.tryKick(s,1,0)
>     67→        return {passed=accepted and near(s.ball.vx,5,1e-12) and near(s.player.vx,0,1e-12),detail=string.format("accepted=%s ballVx=%.9f playerVx=%.9f",tostring(accepted),s.ball.vx,s.player.vx)}
>     68→    end)
>     69→    addResult(report,"fast_player_ball_crossing",function()
>     70→        local s=P.newState();s.player.x=-40;s.player.vx=100
>     71→        local _,info=P.step(s,{x=0,y=0})
>     72→        local c=info.lastPlayerBallContact
>     73→        local ok=c~=nil and info.playerBallContacts>0 and near(c.normalSpeedBefore,-100,1e-8) and near(c.impulse,100,1e-8) and c.penetration<=2
>     74→        return {passed=ok,detail=string.format("substeps=%d contacts=%d contactSubstep=%s penetration=%.6f impulse=%.9f",info.substeps,info.playerBallContacts,tostring(c and c.substep),c and c.penetration or -1,c and c.impulse or -1)}
>     75→    end)
>     76→    addResult(report,"fast_diagonal_player_ball_contact",function()
>     77→        local s=P.newState();s.player.x=-40;s.player.y=-40;s.player.vx=100;s.player.vy=100
>     78→        local _,info=P.step(s,{x=0,y=0})
>     79→        local c=info.lastPlayerBallContact
>     80→        local expected=-1/math.sqrt(2)
>     81→        local ok=c~=nil and near(c.normalX,expected,1e-8) and near(c.normalY,expected,1e-8) and c.penetration<=0.5
>     82→        return {passed=ok,detail=string.format("substeps=%d normal=(%.6f,%.6f) penetration=%.6f impulse=%.6f",info.substeps,c and c.normalX or 0,c and c.normalY or 0,c and c.penetration or -1,c and c.impulse or -1)}
>     83→    end)
>     84→    addResult(report,"multiple_ball_wall_bounces_in_one_tick",function()
>     85→        local s=P.newState();s.player.y=100;s.ball.vx=3000
>     86→        local _,info=P.step(s,{x=0,y=0})
>     87→        local xError,vError=math.abs(s.ball.x+172.5),math.abs(s.ball.vx-742.5)
>     88→        local ok=info.ballWallBounces==2 and xError<=1e-8 and vError<=1e-8
>     89→        return {passed=ok,detail=string.format("bounces=%d substeps=%d x=%.9f vx=%.9f xError=%.3g vError=%.3g",info.ballWallBounces,info.substeps,s.ball.x,s.ball.vx,xError,vError)}
>     90→    end)
>     91→    addResult(report,"swept_player_pair_crossing",function()
>     92→        local s=P.newState();s.player.x=-40;s.player.vx=80;s.player2.x=40;s.player2.vx=-80
>     93→        local _,c=P.stepPlayerPair(s)
>     94→        local ok=c~=nil and c.swept==true and near(c.impactFraction,0.3125,1e-12) and near(c.impulse,240,1e-9)
>     95→        return {passed=ok,detail=string.format("swept=%s toi=%.9f impulse=%.9f",tostring(c and c.swept),c and c.impactFraction or -1,c and c.impulse or -1)}
>     96→    end)
>     97→    addResult(report,"symmetric_two_player_ball_collision",function()
>     98→        local s=P.newState();s.player.x=-32;s.player.vx=2;s.player2.x=32;s.player2.vx=-2
>     99→        local a,b
>    100→        local residual=math.huge
>    101→        for tick=1,12 do
>    102→            local _,impacts,_,stepResidual=P.stepThreeBody(s,24)
>    103→            residual=stepResidual
>    104→            a=impacts["player1-ball"] or a
>    105→            b=impacts["player2-ball"] or b
>    106→            if a and b then break end
>    107→        end
>    108→        if not a or not b then
>    109→            return {passed=false,detail="no paired contact within 12 ticks"}
>    110→        end
>    111→        local impulseError=math.abs(a.impulseTotal-b.impulseTotal)
>    112→        local velocityError=math.abs(s.player.vx+s.player2.vx)+math.abs(s.ball.vx)
>    113→        local ok=impulseError<=1e-3 and residual<=1e-3 and velocityError<=1e-3 and s.player.vx<0 and s.player2.vx>0
>    114→        return {passed=ok,detail=string.format("tick=%d impulses=(%.9f,%.9f) impulseError=%.3g residual=%.3g velocitySymmetryError=%.3g",s.tick,a.impulseTotal,b.impulseTotal,impulseError,residual,velocityError)}
>    115→    end)
>    116→    addResult(report,"three_disc_overlap_resolution",function()
>    117→        local s=P.newState();s.player.x=-14;s.player2.x=14
>    118→        local _,_,_,residual=P.stepThreeBody(s,24)
>    119→        local ok=finite(residual) and residual<=1e-3
>    120→        return {passed=ok,detail=string.format("firstTickResidual=%.9g",residual)}
>    121→    end)
>    122→    addResult(report,"coincident_player_centers",function()
>    123→        local s=P.newState();s.player.x=0;s.player2.x=0
>    124→        P.stepPlayerPair(s)
>    125→        local separation=math.abs(s.player.x-s.player2.x)
>    126→        local ok=near(separation,30,1e-9) and finite(s.player.x) and finite(s.player2.x)
>    127→        return {passed=ok,detail=string.format("positions=(%.9f,%.9f) separation=%.9f",s.player.x,s.player2.x,separation)}
>    128→    end)
>    129→
>    130→    local Core=P.MatchCore
>    131→    addResult(report,"core_fixed_tick_integration_order",function()
>    132→        local w=Core.newWorld()
>    133→        Core.addDisc(w,{id=1,kind="player",x=0,y=0,radius=15,invMass=1,damping=0.96,acceleration=0.1})
>    134→        Core.stepWorld(w,{[1]={x=1,y=0}})
>    135→        local d=w.discs[1]
>    136→        local expectedX=0.1
>    137→        local expectedV=0.096
>    138→        return {passed=near(d.x,expectedX,1e-12) and near(d.vx,expectedV,1e-12),detail=string.format("tick=%d x=%.12f vx=%.12f",w.tick,d.x,d.vx)}
>    139→    end)
>    140→    addResult(report,"core_diagonal_input_normalization",function()
>    141→        local w=Core.newWorld()
>    142→        Core.addDisc(w,{id=1,kind="player",radius=15,invMass=1,damping=1,acceleration=0.1})
>    143→        Core.stepWorld(w,{[1]={x=1,y=1}})
>    144→        local d=w.discs[1]
>    145→        local expected=0.1/math.sqrt(2)
>    146→        return {passed=near(d.vx,expected,1e-12) and near(d.vy,expected,1e-12),detail=string.format("vx=%.12f vy=%.12f",d.vx,d.vy)}
>    147→    end)
>    148→    addResult(report,"core_disc_collision_product_restitution",function()
>    149→        local w=Core.newWorld({fieldHalfWidth=1000,fieldHalfHeight=1000})
>    150→        Core.addDisc(w,{id=1,kind="player",x=-9,vx=1,radius=10,invMass=1,damping=1,bCoef=0.5})
>    151→        Core.addDisc(w,{id=2,kind="ball",x=9,vx=-1,radius=10,invMass=1,damping=1,bCoef=0.5})
>    152→        Core.stepWorld(w,{})
>    153→        local a,b=w.discs[1],w.discs[2]
>    154→        local expectedA,expectedB=-0.25,0.25
>    155→        return {passed=near(a.vx,expectedA,1e-12) and near(b.vx,expectedB,1e-12) and #w.events==1,detail=string.format("vx=(%.12f,%.12f) contactEvents=%d",a.vx,b.vx,#w.events)}
>    156→    end)
>    157→    addResult(report,"core_collision_masks_exclude_pair",function()
>    158→        local w=Core.newWorld({fieldHalfWidth=1000,fieldHalfHeight=1000})
>    159→        Core.addDisc(w,{id=1,x=-9,vx=1,radius=10,invMass=1,damping=1,collisionGroup=1,collisionMask=1})
>    160→        Core.addDisc(w,{id=2,x=9,vx=-1,radius=10,invMass=1,damping=1,collisionGroup=2,collisionMask=2})
>    161→        Core.stepWorld(w,{})
>    162→        return {passed=#w.events==0 and w.discs[1].x==-8 and w.discs[2].x==8,detail=string.format("contacts=%d positions=(%.3f,%.3f)",#w.events,w.discs[1].x,w.discs[2].x)}
>    163→    end)
>    164→    addResult(report,"core_kick_edge_only_once",function()
>    165→        local w=Core.newWorld()
>    166→        Core.addDisc(w,{id=1,kind="player",x=-20,radius=15,invMass=1,damping=1,kickStrength=5,kickback=0,kickRangeExtra=4})
>    167→        Core.addDisc(w,{id=2,kind="ball",x=0,radius=10,invMass=1,damping=1,kickable=true})
>    168→        Core.stepWorld(w,{[1]={x=0,y=0,kick=true}})
>    169→        local first=w.discs[2].vx
>    170→        local firstKickEvent=w.events[1] and w.events[1].kind=="kick"
>    171→        Core.stepWorld(w,{[1]={x=0,y=0,kick=true}})
>    172→        local second=w.discs[2].vx
>    173→        local repeatedKickEvent=false
>    174→        for _,event in ipairs(w.events) do if event.kind=="kick" then repeatedKickEvent=true end end
>    175→        return {passed=near(first,5,1e-12) and near(second,5,1e-12) and firstKickEvent and not repeatedKickEvent,detail=string.format("ballVx=%.3f->%.3f kickEventFirst=%s repeated=%s",first,second,tostring(firstKickEvent),tostring(repeatedKickEvent))}
>    176→    end)
>    177→    addResult(report,"core_ten_player_classic_world_600_ticks",function()
>    178→        local w=Core.newWorld({useBounds=false})
>    179→        Core.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=0.99,bCoef=0.5,kickable=true,collisionGroup=ClassicStadium2D.Groups.ball})
>    180→        local geometry=ClassicStadium2D.install(Core,w)
>    181→        local positions={{-80,0},{-150,-54},{-150,-18},{-150,18},{-150,54},{150,-72},{150,-36},{150,0},{150,36},{150,72}}
>    182→        local red,blue=0,0
>    183→        for i=1,10 do
>    184→            local team=i<=5 and "red" or "blue"
>    185→            if team=="red" then red+=1 else blue+=1 end
>    186→            local p=positions[i]
>    187→            Core.addDisc(w,{id=i,kind="player",team=team,x=p[1],y=p[2],radius=15,invMass=0.5,damping=0.96,bCoef=0.5,acceleration=0.1,kickAcceleration=0.07,kickStrength=5,kickback=0,collisionGroup=team=="red" and ClassicStadium2D.Groups.red or ClassicStadium2D.Groups.blue,collisionMask=require(game:GetService("ReplicatedStorage").HaxballLab.StadiumReference2D).CollisionMasks.player})
>    188→        end
>    189→        local totalEvents,maxSubsteps=0,0
>    190→        local valid=true
>    191→        for tick=1,600 do
>    192→            local inputs={}
>    193→            for i=1,10 do inputs[i]={x=math.sin(tick*0.013+i),y=math.cos(tick*0.017-i),kick=(tick%97==1)} end
>    194→            local _,tickEvents,substeps=Core.stepWorld(w,inputs)
>    195→            totalEvents+=#tickEvents
>    196→            maxSubsteps=math.max(maxSubsteps,substeps)
>    197→        end
>    198→        valid=w.tick==600 and #w.discs==15 and red==5 and blue==5 and geometry.planes==6 and geometry.segments==14 and geometry.posts==4 and totalEvents>0
>    199→        for _,d in ipairs(w.discs) do
>    200→            valid=valid and finite(d.x) and finite(d.y) and finite(d.vx) and finite(d.vy)
>    201→            if d.kind=="player" then valid=valid and math.abs(d.x)<=405 and math.abs(d.y)<=185 end
>    202→        end
>    203→        local ball=w.discById["string:ball"]
>    204→        valid=valid and math.abs(ball.x)<=410 and math.abs(ball.y)<=190
>    205→        return {passed=valid,detail=string.format("ticks=%d players=%d red=%d blue=%d discs=%d events=%d maxSubsteps=%d finite=%s",w.tick,red+blue,red,blue,#w.discs,totalEvents,maxSubsteps,tostring(valid))}
>    206→    end)
>    207→    addResult(report,"core_dense_ten_disc_overlap_relaxes",function()
>    208→        local w=Core.newWorld({useBounds=false})
>    209→        Core.addDisc(w,{id=0,kind="ball",radius=10,invMass=1,damping=0.99,kickable=true})
>    210→        for i=1,10 do
>    211→            Core.addDisc(w,{id=i,kind="player",x=((i-1)%5)*8-16,y=(i<=5 and -4 or 4),radius=15,invMass=0.5,damping=0.96})
>    212→        end
>    213→        local initialMax,finalMax=0,0
>    214→        local valid=true
>    215→        for tick=1,120 do
>    216→            Core.stepWorld(w,{})
>    217→            local maxOverlap=0
>    218→            for i=1,#w.discs-1 do
>    219→                for j=i+1,#w.discs do
>    220→                    local a,b=w.discs[i],w.discs[j]
>    221→                    local overlap=a.radius+b.radius-math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)
>    222→                    maxOverlap=math.max(maxOverlap,overlap)
>    223→                    valid=valid and finite(a.x) and finite(a.y) and finite(a.vx) and finite(a.vy)
>    224→                end
>    225→            end
>    226→            if tick==1 then initialMax=maxOverlap end
>    227→            if tick==120 then finalMax=maxOverlap end
>    228→        end
>    229→        local ok=valid and initialMax>20 and finalMax<=1e-3
>    230→        return {passed=ok,detail=string.format("ticks=120 initialMaxOverlap=%.6f finalMaxOverlap=%.3g finite=%s",initialMax,finalMax,tostring(valid))}
>    231→    end)
>    232→    addResult(report,"core_replay_deterministic",function()
>    233→        local function run()
>    234→            local w=Core.newWorld()
>    235→            Core.addDisc(w,{id=1,kind="player",x=-30,radius=15,invMass=0.5,damping=0.96,acceleration=0.1})
>    236→            Core.addDisc(w,{id=2,kind="ball",radius=10,invMass=1,damping=0.99,kickable=true})
>    237→            for tick=1,240 do Core.stepWorld(w,{[1]={x=tick%30<15 and 1 or -1,y=tick%40<20 and 0.5 or -0.5,kick=tick%61==1}}) end
>    238→            return Core.snapshot(w)
>    239→        end
>    240→        local a,b=run(),run()
>    241→        local exact=a.tick==b.tick and #a.discs==#b.discs
>    242→        for i=1,#a.discs do
>    243→            for _,key in ipairs({"x","y","vx","vy"}) do exact=exact and a.discs[i][key]==b.discs[i][key] end
>    244→        end
>    245→        return {passed=exact,detail=string.format("ticks=%d discs=%d exact=%s",a.tick,#a.discs,tostring(exact))}
>    246→    end)
>    247→    addResult(report,"core_boundary_clamp_and_bounce",function()
>    248→        local w=Core.newWorld({fieldHalfWidth=50,fieldHalfHeight=50})
>    249→        Core.addDisc(w,{id=1,kind="ball",x=35,vx=20,radius=10,invMass=1,damping=1,bCoef=0.5})
>    250→        Core.stepWorld(w,{})
>    251→        local d=w.discs[1]
>    252→        return {passed=near(d.x,35,1e-12) and near(d.vx,-10,1e-12),detail=string.format("x=%.3f vx=%.3f",d.x,d.vx)}
>    253→    end)
>    254→    addResult(report,"core_kick_windup_uses_kick_damping",function()
>    255→        local w=Core.newWorld({useBounds=false})
>    256→        Core.addDisc(w,{id=1,kind="player",radius=15,invMass=1,damping=0.9,kickDamping=0.5,acceleration=0.1,kickAcceleration=0.07})
>    257→        Core.addDisc(w,{id=2,kind="ball",x=200,radius=10,invMass=1,damping=1,kickable=true})
>    258→        Core.stepWorld(w,{[1]={x=1,y=0,kick=true}})
>    259→        local d=w.discById["number:1"]
>    260→        return {passed=near(d.x,0.07,1e-12) and near(d.vx,0.035,1e-12),detail=string.format("x=%.3f vx=%.3f",d.x,d.vx)}
>    261→    end)
>    262→    addResult(report,"core_successful_kick_restores_normal_acceleration",function()
>    263→        local w=Core.newWorld({useBounds=false})
>    264→        Core.addDisc(w,{id=1,kind="player",x=-20,radius=15,invMass=1,damping=0.9,kickDamping=0.5,acceleration=0.1,kickAcceleration=0.07,kickStrength=5})
>    265→        Core.addDisc(w,{id=2,kind="ball",radius=10,invMass=1,damping=1,kickable=true})
>    266→        Core.stepWorld(w,{[1]={x=1,y=0,kick=true}})
>    267→        local p,b=w.discById["number:1"],w.discById["number:2"]
>    268→        return {passed=near(p.x,-19.95,1e-12) and near(p.vx,0.09,1e-12) and near(b.vx,5,1e-12),detail=string.format("playerX=%.3f playerVx=%.3f ballVx=%.3f postKickOverlapCorrection=0.050",p.x,p.vx,b.vx)}
>    269→    end)
>    270→    addResult(report,"core_insertion_order_is_preserved",function()
>    271→        local w=Core.newWorld()
>    272→        Core.addDisc(w,{id=9,radius=10,invMass=1})
>    273→        Core.addDisc(w,{id=1,radius=10,invMass=1})
>    274→        Core.addDisc(w,{id=5,radius=10,invMass=1})
>    275→        return {passed=w.discs[1].id==9 and w.discs[2].id==1 and w.discs[3].id==5,detail=string.format("ids=%s,%s,%s",tostring(w.discs[1].id),tostring(w.discs[2].id),tostring(w.discs[3].id))}
>    276→    end)
>    277→    addResult(report,"core_segment_endpoint_cap",function()
>    278→        local w=Core.newWorld({useBounds=false})
>    279→        Core.addSegment(w,{id="post",x1=-10,y1=0,x2=10,y2=0})
>    280→        Core.addDisc(w,{id=1,kind="ball",x=13,radius=10,invMass=1,damping=1})
>    281→        Core.stepWorld(w,{})
>    282→        local d=w.discById["number:1"]
>    283→        local endpointDistance=math.sqrt((d.x-10)^2+d.y^2)
>    284→        local event=w.events[1]
>    285→        return {passed=near(endpointDistance,10,1e-9) and event and event.kind=="segmentContact",detail=string.format("endpointDistance=%.9f event=%s",endpointDistance,tostring(event and event.kind))}
>    286→    end)
>    287→    addResult(report,"core_static_plane_contact",function()
>    288→        local w=Core.newWorld({useBounds=false})
>    289→        Core.addPlane(w,{id="left",normalX=1,normalY=0,offset=-20,bCoef=0.5})
>    290→        Core.addDisc(w,{id=1,kind="ball",x=-15,vx=-5,radius=10,invMass=1,damping=1,bCoef=0.5})
>    291→        Core.stepWorld(w,{})
>    292→        local d=w.discs[1]
>    293→        local event=w.events[1]
>    294→        return {passed=near(d.x,-10,1e-12) and near(d.vx,1.25,1e-12) and event and event.kind=="planeContact",detail=string.format("x=%.3f vx=%.3f planeEvent=%s",d.x,d.vx,tostring(event and event.kind))}
>    295→    end)
>    296→    addResult(report,"core_static_segment_contact",function()
>    297→        local w=Core.newWorld({useBounds=false})
>    298→        Core.addSegment(w,{id="touchline",x1=-10,y1=0,x2=10,y2=0,bCoef=0.5})
>    299→        Core.addDisc(w,{id=1,kind="ball",x=0,y=8,vy=-2,radius=10,invMass=1,damping=1,bCoef=0.5})
>    300→        Core.stepWorld(w,{})
>    301→        local d=w.discs[1]
>    302→        local event=w.events[1]
>    303→        return {passed=near(d.y,10,1e-12) and near(d.vy,0.5,1e-12) and event and event.kind=="segmentContact",detail=string.format("y=%.3f vy=%.3f segmentEvent=%s",d.y,d.vy,tostring(event and event.kind))}
>    304→    end)
>    305→    addResult(report,"core_curved_segment_uses_arc_radius",function()
>    306→        local w=Core.newWorld({useBounds=false})
>    307→        Core.addSegment(w,{id="quarterArc",x1=0,y1=0,x2=10,y2=10,curveDegrees=90,bCoef=0.5})
>    308→        local cx,cy=0,10
>    309→        local ux,uy=math.sqrt(0.5),-math.sqrt(0.5)
>    310→        Core.addDisc(w,{id="testBall",kind="ball",x=cx+ux*11.3,y=cy+uy*11.3,vx=-ux,vy=-uy,radius=1,invMass=1,damping=1,bCoef=0.5})
>    311→        Core.stepWorld(w,{})
>    312→        local d=w.discById["string:testBall"]
>    313→        local radial=math.sqrt((d.x-cx)^2+(d.y-cy)^2)
>    314→        local event=w.events[1]
>    315→        return {passed=radial>=11-1e-9 and radial<=11.2 and event and event.kind=="segmentContact" and near(d.vx*ux+d.vy*uy,0.25,1e-9),detail=string.format("arcRadius=%.9f outwardSpeed=%.9f event=%s",radial,d.vx*ux+d.vy*uy,tostring(event and event.kind))}
>    316→    end)
>    317→    addResult(report,"classic_stadium_geometry_and_ball_only_boundary",function()
>    318→        local w=Core.newWorld({useBounds=false})
>    319→        Core.addDisc(w,{id="ball",kind="ball",y=165,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball})
>    320→        local counts=ClassicStadium2D.install(Core,w)
>    321→        Core.addDisc(w,{id="player",kind="player",y=195,radius=15,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.player})
>    322→        Core.stepWorld(w,{})
>    323→        local ball=w.discById["string:ball"]
>    324→        local player=w.discById["string:player"]
>    325→        local ballAreaHit,outerPlayerHit=false,false
>    326→        for _,event in ipairs(w.events) do
>    327→            if event.kind=="planeContact" and event.geometryId=="classic:ballArea:top" then ballAreaHit=true end
>    328→            if event.kind=="planeContact" and event.geometryId=="classic:outer:top" and event.discId=="player" then outerPlayerHit=true end
>    329→        end
>    330→        local ok=counts.planes==6 and counts.segments==14 and counts.posts==4 and #w.discs==6 and near(ball.y,160,1e-9) and near(player.y,185,1e-9) and ballAreaHit and outerPlayerHit
>    331→        return {passed=ok,detail=string.format("planes=%d segments=%d posts=%d ballY=%.3f playerY=%.3f ballArea=%s outerPlayer=%s",counts.planes,counts.segments,counts.posts,ball.y,player.y,tostring(ballAreaHit),tostring(outerPlayerHit))}
>    332→    end)
>    333→    addResult(report,"classic_goal_mouth_ball_hits_net_without_tunneling",function()
>    334→        local w=Core.newWorld({useBounds=false})
>    335→        local ball=Core.addDisc(w,{id="ball",kind="ball",x=350,y=0,vx=20,radius=10,invMass=1,damping=0.99,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball})
>    336→        ClassicStadium2D.install(Core,w)
>    337→        local contactTick,contactX,contactVx,contactSubsteps
>    338→        for tick=1,5 do
>    339→            local _,events=Core.stepWorld(w,{})
>    340→            for _,event in ipairs(events) do
>    341→                if event.kind=="segmentContact" and event.geometryId=="classic:goalNet:right:back" then
>    342→                    contactTick,contactX,contactVx,contactSubsteps=tick,ball.x,ball.vx,w.lastSubsteps
>    343→                end
>    344→            end
>    345→        end
>    346→        local ok=contactTick==3 and contactVx<0 and contactX<400 and contactX>370 and contactSubsteps>=4 and finite(ball.x) and finite(ball.vx)
>    347→        return {passed=ok,detail=string.format("contactTick=%s contactX=%.6f contactVx=%.6f finalX=%.6f finalVx=%.6f contactSubsteps=%s",tostring(contactTick),contactX or -1,contactVx or -1,ball.x,ball.vx,tostring(contactSubsteps))}
>    348→    end)
>    349→    addResult(report,"classic_field_trace_detects_goal_crossing",function()
>    350→        local w=Core.newWorld({useBounds=false})
>    351→        Core.addDisc(w,{id="ball",kind="ball",x=340,y=0,vx=12,radius=10,invMass=1,damping=0.99,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.ball,traceMotion=true})
>    352→        ClassicStadium2D.install(Core,w)
>    353→        local goal
>    354→        for tick=1,5 do
>    355→            Core.stepWorld(w,{})
>    356→            goal=MatchRules2D.findGoalCrossing(w.motionSegments,"ball")
>    357→            if goal then goal.tick=tick;break end
>    358→        end
>    359→        return {passed=goal~=nil and goal.tick==3 and goal.side=="right" and goal.team=="red" and math.abs(goal.y)<64,detail=string.format("goal=%s side=%s team=%s y=%.3f",tostring(goal~=nil),goal and goal.side or "-",goal and goal.team or "-",goal and goal.y or -999)}
>    360→    end)
>    361→    addResult(report,"classic_goalpost_collides_with_player",function()
>    362→        local w=Core.newWorld({useBounds=false})
>    363→        Core.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=1,collisionGroup=ClassicStadium2D.Groups.ball})
>    364→        ClassicStadium2D.install(Core,w)
>    365→        Core.addDisc(w,{id="player",kind="player",x=-356,y=64,vx=-1,radius=15,invMass=1,damping=1,bCoef=0.5,collisionGroup=ClassicStadium2D.Groups.player})
>    366→        Core.stepWorld(w,{})
>    367→        local player=w.discById["string:player"]
>    368→        local post=w.discById["string:classic:post:left:upper"]
>    369→        local distance=math.sqrt((player.x-post.x)^2+(player.y-post.y)^2)
>    370→        local found=false
>    371→        for _,event in ipairs(w.events) do if event.kind=="discContact" and (event.discA=="player" or event.discB=="player") then found=true end end
>    372→        return {passed=found and near(distance,23,1e-9) and player.vx>0,detail=string.format("playerPostDistance=%.9f bounced=%s",distance,tostring(player.vx>0))}
>    373→    end)
>    374→    addResult(report,"goal_crossing_awards_opposite_team_and_interpolates",function()
>    375→        local right=MatchRules2D.findGoalCrossing({{discId="ball",x0=368,y0=-10,x1=372,y1=10,substep=2,substeps=3}})
>    376→        local left=MatchRules2D.findGoalCrossing({{discId="ball",x0=-368,y0=0,x1=-372,y1=0,substep=1,substeps=2}})
>    377→        local outside=MatchRules2D.findGoalCrossing({{discId="ball",x0=368,y0=70,x1=372,y1=70,substep=1,substeps=1}})
>    378→        local ok=right and right.team=="red" and right.side=="right" and near(right.y,0,1e-12) and left and left.team=="blue" and left.side=="left" and outside==nil
>    379→        return {passed=ok,detail=string.format("right=%s/%s y=%.3f left=%s/%s outside=%s",right and right.side or "-",right and right.team or "-",right and right.y or -999,left and left.side or "-",left and left.team or "-",tostring(outside~=nil))}
>    380→    end)
>    381→    addResult(report,"goal_pause_resets_ball_and_ten_player_positions",function()
>    382→        local match=MatchRules2D.newMatch()
>    383→        local score={red=0,blue=0}
>    384→        local ball={x=371,y=3,vx=8,vy=2}
>    385→        local players={}
>    386→        local spawns={}
>    387→        for i=1,10 do
>    388→            players[i]={x=i*3,y=-i,vx=1,vy=2,kickHeld=true,kickArmed=true,kickCooldown=4}
>    389→            spawns[i]={x=(i<=5 and -100 or 100),y=(i-1)*4}
>    390→        end
>    391→        MatchRules2D.beginGoalPause(match,score,{team="red",side="right",x=370,y=3,tick=7},ball,players,2)
>    392→        local paused=match.phase=="goalPause" and score.red==1 and ball.vx==0 and players[1].vx==0
>    393→        local doneEarly=MatchRules2D.advancePause(match)
>    394→        local ready=MatchRules2D.advancePause(match)
>    395→        MatchRules2D.resetKickoff(ball,players,spawns)
>    396→        MatchRules2D.resume(match)
>    397→        local exact=ball.x==0 and ball.y==0 and players[10].x==100 and players[10].y==36 and players[10].kickArmed==false and players[10].kickCooldown==0
>    398→        return {passed=paused and not doneEarly and ready and exact and match.phase=="playing" and score.red==1,detail=string.format("phase=%s redScore=%d pauseComplete=%s resetAllTen=%s",match.phase,score.red,tostring(ready),tostring(exact))}
>    399→    end)
>    400→    addResult(report,"kickoff_countdown_locks_until_complete",function()
>    401→        local match=MatchRules2D.newMatch()
>    402→        match.phase="goalPause"
>    403→        MatchRules2D.beginKickoff(match,"blue",2)
>    404→        local firstDone=MatchRules2D.advanceKickoff(match)
>    405→        local stillLocked=match.phase=="kickoff" and match.remainingTicks==1 and match.kickoffTeam=="blue"
>    406→        local done=MatchRules2D.advanceKickoff(match)
>    407→        MatchRules2D.resume(match)
>    408→        local wrongTeam=MatchRules2D.completeKickoff(match,"red")
>    409→        local assignmentPreserved=match.kickoffTeam=="blue"
>    410→        local correctTeam=MatchRules2D.completeKickoff(match,"blue")
>    411→        local ok=not firstDone and stillLocked and done and match.phase=="playing" and assignmentPreserved and not wrongTeam and correctTeam and match.kickoffTeam==nil
>    412→        return {passed=ok,detail=string.format("phase=%s countdownComplete=%s wrongTeamRejected=%s correctTeamAccepted=%s",match.phase,tostring(done),tostring(not wrongTeam),tostring(correctTeam))}
>    413→    end)
>    414→    addResult(report,"micro_prediction_uses_fixed_tick_player_kinematics",function()
>    415→        local predicted=PredictionLab2D.predict({x=0,y=0,vx=0,vy=0},{x=1,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=0.96,kickDamping=0.96},2)
>    416→        return {passed=near(predicted.x,0.296,1e-12) and near(predicted.vx,0.18816,1e-12) and #predicted.path==2,detail=string.format("ticks=%d x=%.6f vx=%.6f",predicted.ticks,predicted.x,predicted.vx)}
>    417→    end)
>    418→    addResult(report,"micro_prediction_forecasts_ball_contact_without_applying_it",function()
>    419→        local predicted=PredictionLab2D.predict({x=-30,y=0,vx=4,vy=0},{x=0,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=1,kickDamping=1},2)
>    420→        local contact=PredictionLab2D.firstContact(predicted.path,15,{{id="ball",kind="ball",x=0,y=0,radius=10}})
>    421→        return {passed=contact~=nil and contact.kind=="ball" and contact.tick==2 and predicted.x==-22,detail=string.format("forecast=%s tick=%s predictedX=%.3f",tostring(contact and contact.kind),tostring(contact and contact.tick),predicted.x)}
>    422→    end)
>    423→    addResult(report,"last_touch_records_physical_actor_and_overwrites_in_event_order",function()
>    424→        local match=MatchRules2D.newMatch()
>    425→        local first=MatchRules2D.recordTouch(match,2,"red",10,"contact")
>    426→        local second=MatchRules2D.recordTouch(match,7,"blue",10,"kick")
>    427→        local invalid=MatchRules2D.recordTouch(match,11,"green",11,"contact")
>    428→        local ok=first and second and not invalid and match.lastTouch.playerId==7 and match.lastTouch.team=="blue" and match.lastTouch.tick==10 and match.lastTouch.kind=="kick"
>    429→        return {passed=ok,detail=string.format("actor=%s team=%s tick=%s kind=%s invalidRejected=%s",tostring(match.lastTouch and match.lastTouch.playerId),tostring(match.lastTouch and match.lastTouch.team),tostring(match.lastTouch and match.lastTouch.tick),tostring(match.lastTouch and match.lastTouch.kind),tostring(not invalid))}
>    430→    end)
>    431→    addResult(report,"kickoff_rejects_wrong_team_kick_only",function()
>    432→        local match=MatchRules2D.newMatch()
>    433→        match.phase="playing"
>    434→        match.kickoffTeam="blue"
>    435→        local redInput,redBlocked=MatchRules2D.filterKickoffInput(match,"red",{x=1,y=0,kick=true})
>    436→        local blueInput,blueBlocked=MatchRules2D.filterKickoffInput(match,"blue",{x=-1,y=0,kick=true})
>    437→        local redMask=MatchRules2D.kickoffCollisionMask(match,"red",0xFFFFFFFF,2)
>    438→        local blueMask=MatchRules2D.kickoffCollisionMask(match,"blue",0xFFFFFFFF,2)
>    439→        local redBallCollision=bit32.band(redMask,2)~=0
>    440→        local blueBallCollision=bit32.band(blueMask,2)~=0
>    441→        local ok=redBlocked and redInput.kick==false and redInput.x==1 and not blueBlocked and blueInput.kick==true and redBallCollision and blueBallCollision
>    442→        return {passed=ok,detail=string.format("opponentKickInputBlocked=%s assignedKickAllowed=%s movementPreserved=%s redBallCollision=%s blueBallCollision=%s",tostring(redBlocked and not redInput.kick),tostring(not blueBlocked and blueInput.kick),tostring(redInput.x==1),tostring(redBallCollision),tostring(blueBallCollision))}
>    443→    end)
>    444→    addResult(report,"core_rejects_nonfinite_specs",function()
>    445→        local ok=pcall(function() Core.newDisc({id=1,x=0/0,radius=10,invMass=1}) end)
>    446→        return {passed=not ok,detail="NaN spec rejected="..tostring(not ok)}
>    447→    end)
>    448→
>    449→    addResult(report,"classic_reference_profile_is_frozen_and_complete",function()
>    450→        local w=Core.newWorld({useBounds=false})
>    451→        local counts=ClassicStadium2D.install(Core,w)
>    452→        local ok=StadiumProfile2D.Metadata.sourceCommit=="4b9724f49fe0ff87ad3f111eb91b208020d96d73" and counts.planes==6 and counts.segments==14 and counts.posts==4 and StadiumProfile2D.Bounds.spanWidth==840 and StadiumProfile2D.Bounds.spanHeight==400 and StadiumProfile2D.PlayArea.width==740 and StadiumProfile2D.PlayArea.height==340
>    453→        return {passed=ok,detail=string.format("commit=%s geometry=%d/%d/%d bounds=%dx%d playable=%dx%d",StadiumProfile2D.Metadata.sourceCommit,counts.planes,counts.segments,counts.posts,StadiumProfile2D.Bounds.spanWidth,StadiumProfile2D.Bounds.spanHeight,StadiumProfile2D.PlayArea.width,StadiumProfile2D.PlayArea.height)}
>    454→    end)
>    455→    addResult(report,"classic_kickoff_collision_masks_select_reference_arc",function()
>    456→        local flags=StadiumProfile2D.CollisionGroups
>    457→        local base=StadiumProfile2D.CollisionMasks.player
>    458→        local match=MatchRules2D.newMatch();match.phase="kickoff";match.kickoffTeam="red"
>    459→        local redMask=MatchRules2D.kickoffCollisionMask(match,"red",base,flags.ball)
>    460→        local blueMask=MatchRules2D.kickoffCollisionMask(match,"blue",base,flags.ball)
>    461→        local redKickoff=bit32.band(redMask,flags.redKO)~=0 and bit32.band(redMask,flags.blueKO)==0
>    462→        local blueDuringRed=bit32.band(blueMask,flags.redKO)~=0 and bit32.band(blueMask,flags.blueKO)==0 and bit32.band(blueMask,flags.ball)~=0
>    463→        match.kickoffTeam="blue"
>    464→        local blueKickoffMask=MatchRules2D.kickoffCollisionMask(match,"blue",base,flags.ball)
>    465→        local blueKickoff=bit32.band(blueKickoffMask,flags.blueKO)~=0 and bit32.band(blueKickoffMask,flags.ball)~=0
>    466→        local redDuringBlueMask=MatchRules2D.kickoffCollisionMask(match,"red",base,flags.ball)
>    467→        local redDuringBlue=bit32.band(redDuringBlueMask,flags.blueKO)~=0 and bit32.band(redDuringBlueMask,flags.ball)~=0
>    468→        return {passed=redKickoff and blueDuringRed and blueKickoff and redDuringBlue,detail=string.format("redKOActive=%s blueDuringRedHasBall=%s blueKOActive=%s redDuringBlueHasBall=%s",tostring(redKickoff),tostring(blueDuringRed),tostring(blueKickoff),tostring(redDuringBlue))}
>    469→    end)
>    470→
>    471→    addResult(report,"classic_pinned_hbs_geometry_values",function()
>    472→        local p=StadiumProfile2D
>    473→        local plane=p.Geometry.planes
>    474→        local seg=p.Geometry.segments
>    475→        local redArc,blueArc
>    476→        for _,s in ipairs(seg) do
>    477→            if s.id=="classic:kickoff:circleRedKO" then redArc=s end
>    478→            if s.id=="classic:kickoff:circleBlueKO" then blueArc=s end
>    479→        end
>    480→        local ok=p.StadiumProperties.width==420 and p.StadiumProperties.height==200 and p.StadiumProperties.spawnDistance==170
>    481→            and p.StadiumProperties.bg.width==370 and p.StadiumProperties.bg.height==170 and p.StadiumProperties.bg.kickOffRadius==75
>    482→            and plane[1].id=="classic:ballArea:bottom" and plane[1].normalY==1 and plane[1].offset==-170 and plane[1].bCoef==1 and plane[1].collisionMask==p.CollisionGroups.ball
>    483→            and plane[3].id=="classic:outer:bottom" and plane[3].normalY==1 and plane[3].offset==-200 and plane[3].bCoef==0.1
>    484→            and plane[5].id=="classic:outer:left" and plane[5].normalX==1 and plane[5].offset==-420 and plane[5].bCoef==0.1
>    485→            and seg[1].x1==-370 and seg[1].y1==170 and seg[1].x2==-370 and seg[1].y2==64 and seg[1].collisionMask==p.CollisionGroups.ball
>    486→            and seg[5].x1==-380 and seg[5].y1==-64 and seg[5].x2==-400 and seg[5].y2==-44 and seg[5].curveDegrees==-90
>    487→            and seg[7].curveDegrees==-90 and seg[7].collisionMask==p.CollisionGroups.ball
>    488→            and seg[11].x1==0 and seg[11].y1==200 and seg[11].x2==0 and seg[11].y2==75 and seg[11].collisionGroup==p.CollisionGroups.kickoffBarrier
>    489→            and redArc and redArc.curveDegrees==-180 and redArc.collisionGroup==p.CollisionGroups.redKO and redArc.collisionMask==p.CollisionMasks.kickoffBarrier
>    490→            and blueArc and blueArc.curveDegrees==180 and blueArc.collisionGroup==p.CollisionGroups.blueKO and blueArc.collisionMask==p.CollisionMasks.kickoffBarrier
>    491→            and p.Geometry.posts[1].x==-370 and p.Geometry.posts[1].y==64 and p.Geometry.posts[1].radius==8 and p.Geometry.posts[1].bCoef==0.5
>    492→            and p.Goals.leftX==-370 and p.Goals.rightX==370 and p.Goals.halfHeight==64
>    493→        return {passed=ok,detail=string.format("frozen HBS values checked: properties, planes, net arcs, kickoff arcs, posts and goal lines; redArc=%s blueArc=%s",tostring(redArc and redArc.curveDegrees),tostring(blueArc and blueArc.curveDegrees))}
>    494→    end)
>    495→    addResult(report,"classic_collision_matrix_matches_hbs_flags",function()
>    496→        local f=StadiumProfile2D.CollisionGroups
>    497→        local masks=StadiumProfile2D.CollisionMasks
>    498→        local function can(aGroup,aMask,bGroup,bMask)
>    499→            return bit32.band(aGroup,bMask)~=0 and bit32.band(bGroup,aMask)~=0
>    500→        end
>    501→        local ballGroup,ballMask=f.ball,masks.all
>    502→        local playerMask=masks.player
>    503→        local wallGroup,wallMask=f.wall,masks.all
>    504→        local postGroup,postMask=f.post,masks.all
>    505→        local barrierGroup,barrierMask=f.kickoffBarrier,masks.kickoffBarrier
>    506→        local redKOmask=bit32.bor(playerMask,f.redKO)
>    507→        local blueKOmask=bit32.bor(playerMask,f.blueKO)
>    508→        local ok=can(f.red,playerMask,ballGroup,ballMask) and can(f.blue,playerMask,ballGroup,ballMask)
>    509→            and can(f.red,playerMask,f.blue,playerMask)
>    510→            and can(f.red,playerMask,wallGroup,wallMask) and can(f.blue,playerMask,postGroup,postMask)
>    511→            and can(ballGroup,ballMask,wallGroup,wallMask) and can(ballGroup,ballMask,postGroup,postMask)
>    512→            and not can(f.red,playerMask,barrierGroup,barrierMask)
>    513→            and can(f.red,redKOmask,barrierGroup,barrierMask) and can(f.blue,blueKOmask,barrierGroup,barrierMask)
>    514→            and not can(ballGroup,ballMask,barrierGroup,barrierMask)
>    515→        return {passed=ok,detail=string.format("red/blue-ball, red-blue, player-wall/post, ball-wall/post and kickoff off/on compatibility verified; postMask=%d",postMask)}
>    516→    end)
>    517→    addResult(report,"classic_wall_and_post_ball_response",function()
>    518→        local w=Core.newWorld({useBounds=false})
>    519→        local ball=Core.addDisc(w,{id="ball",kind="ball",x=-355,y=64,vx=-2,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=StadiumProfile2D.CollisionGroups.ball})
>    520→        ClassicStadium2D.install(Core,w)
>    521→        Core.stepWorld(w,{})
>    522→        local post=w.discById["string:classic:post:left:upper"]
>    523→        local postEvent=false
>    524→        for _,event in ipairs(w.events) do
>    525→            if event.kind=="discContact" and (event.discA=="ball" or event.discB=="ball") then postEvent=true end
>    526→        end
>    527→        local postDistance=math.sqrt((ball.x-post.x)^2+(ball.y-post.y)^2)
>    528→        local wallWorld=Core.newWorld({useBounds=false})
>    529→        local wallBall=Core.addDisc(wallWorld,{id="wallBall",kind="ball",y=165,vy=2,radius=10,invMass=1,damping=1,bCoef=0.5,collisionGroup=StadiumProfile2D.CollisionGroups.ball})
>    530→        ClassicStadium2D.install(Core,wallWorld)
>    531→        Core.stepWorld(wallWorld,{})
>    532→        local wallEvent=false
>    533→        for _,event in ipairs(wallWorld.events) do
>    534→            if event.kind=="planeContact" and event.geometryId=="classic:ballArea:top" then wallEvent=true end
>    535→        end
>    536→        local ok=post.invMass==0 and post.radius==8 and post.bCoef==0.5 and post.collisionMask==StadiumProfile2D.CollisionMasks.all
>    537→            and postEvent and postDistance>=18-1e-9 and ball.vx>0 and wallEvent and wallBall.y<=160+1e-9 and wallBall.vy<0
>    538→        return {passed=ok,detail=string.format("postDistance=%.6f ballVx=%.6f wallY=%.6f wallVy=%.6f postContact=%s wallContact=%s",postDistance,ball.vx,wallBall.y,wallBall.vy,tostring(postEvent),tostring(wallEvent))}
>    539→    end)
>    540→    addResult(report,"classic_kickoff_arc_contacts_both_teams_and_deactivates",function()
>    541→        local CoreLocal=Core
>    542→        local function run(team,kickoffActive)
>    543→            local w=CoreLocal.newWorld({useBounds=false,maxSubsteps=128})
>    544→            CoreLocal.addDisc(w,{id="ball",kind="ball",radius=10,invMass=1,damping=1,collisionGroup=StadiumProfile2D.CollisionGroups.ball,collisionMask=StadiumProfile2D.CollisionMasks.all})
>    545→            ClassicStadium2D.install(CoreLocal,w)
>    546→            local match=MatchRules2D.newMatch()
>    547→            match.phase=kickoffActive and "kickoff" or "playing"
>    548→            match.kickoffTeam=kickoffActive and team or nil
>    549→            local x,vx=team=="red" and 100 or -100,team=="red" and -20 or 20
>    550→            local mask=MatchRules2D.kickoffCollisionMask(match,team,StadiumProfile2D.CollisionMasks.player,StadiumProfile2D.CollisionGroups.ball)
>    551→            local group=team=="red" and StadiumProfile2D.CollisionGroups.red or StadiumProfile2D.CollisionGroups.blue
>    552→            local player=CoreLocal.addDisc(w,{id="player",kind="player",team=team,x=x,y=0,vx=vx,radius=15,invMass=0.5,damping=1,bCoef=0.5,collisionGroup=group,collisionMask=mask})
>    553→            local hit
>    554→            for _=1,5 do
>    555→                CoreLocal.stepWorld(w,{})
>    556→                for _,event in ipairs(w.events) do
>    557→                    if event.kind=="segmentContact" and string.find(event.geometryId,"kickoff:circle") then hit=event.geometryId end
>    558→                end
>    559→            end
>    560→            return {hit=hit,mask=mask,vx=player.vx}
>    561→        end
>    562→        local redOn=run("red",true)
>    563→        local blueOn=run("blue",true)
>    564→        local redOff=run("red",false)
>    565→        local blueOff=run("blue",false)
>    566→        local ok=redOn.hit=="classic:kickoff:circleRedKO" and blueOn.hit=="classic:kickoff:circleBlueKO"
>    567→            and redOn.mask==47 and blueOn.mask==55 and redOn.vx>0 and blueOn.vx<0
>    568→            and redOff.hit==nil and blueOff.hit==nil and redOff.mask==39 and blueOff.mask==39
>    569→        return {passed=ok,detail=string.format("redOn=%s redMask=%d blueOn=%s blueMask=%d offHits=%s/%s",tostring(redOn.hit),redOn.mask,tostring(blueOn.hit),blueOn.mask,tostring(redOff.hit),tostring(blueOff.hit))}
>    570→    end)
>    571→    addResult(report,"classic_goal_line_edge_and_duplicate_guard",function()
>    572→        local inside=MatchRules2D.findGoalCrossing({{discId="ball",x0=369,y0=63.9,x1=371,y1=63.9}})
>    573→        local outside=MatchRules2D.findGoalCrossing({{discId="ball",x0=369,y0=64.1,x1=371,y1=64.1}})
>    574→        local reverse=MatchRules2D.findGoalCrossing({{discId="ball",x0=371,y0=0,x1=369,y1=0}})
>    575→        local match=MatchRules2D.newMatch()
>    576→        local score={red=0,blue=0}
>    577→        MatchRules2D.beginGoalPause(match,score,{team=inside and inside.team,side=inside and inside.side,x=inside and inside.x,y=inside and inside.y}, {vx=0,vy=0}, {}, 2)
>    578→        local duplicateOk=not pcall(function()
>    579→            MatchRules2D.beginGoalPause(match,score,{team=inside.team,side=inside.side,x=inside.x,y=inside.y},{vx=0,vy=0},{},2)
>    580→        end)
>    581→        local ok=inside~=nil and inside.team=="red" and outside==nil and reverse==nil and duplicateOk and score.red==1 and score.blue==0
>    582→        return {passed=ok,detail=string.format("insideY=%.1f scores=%s outsideRejected=%s reverseRejected=%s duplicateRejected=%s",inside and inside.y or -999,tostring(inside~=nil),tostring(outside==nil),tostring(reverse==nil),tostring(duplicateOk))}
>    583→    end)
>    584→    report.passed=0
>    585→    report.failed=0
>    586→    for _,test in ipairs(report.tests) do
>    587→        if test.passed then report.passed+=1 else report.failed+=1 end
>    588→    end
>    589→    report.total=#report.tests
>    590→    report.allPassed=report.failed==0
>    591→    return report
>    592→end
>    593→
>    594→return Suite
>    595→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ReplicatedStorage.HaxballLab.StadiumReference2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→local Profile = {}
>      2→
>      3→Profile.Metadata = {
>      4→    id = "haxball-classic-reference",
>      5→    name = "Classic",
>      6→    sourceRepository = "haxball/haxball-issues",
>      7→    sourceFile = "stadiums/classic.hbs",
>      8→    sourceCommit = "4b9724f49fe0ff87ad3f111eb91b208020d96d73",
>      9→    sourcePermalink = "https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs",
>     10→    geometryStatus = "FROZEN_REFERENCE",
>     11→    logicalUnits = "Haxball stadium units",
>     12→    note = "HBS width/height are 420/200; physical geometry spans x=[-420,420], y=[-200,200].",
>     13→}
>     14→
>     15→Profile.StadiumProperties = {
>     16→    width = 420,
>     17→    height = 200,
>     18→    spawnDistance = 170,
>     19→    bg = { width = 370, height = 170, kickOffRadius = 75 },
>     20→}
>     21→
>     22→Profile.Bounds = {
>     23→    minX = -420, maxX = 420,
>     24→    minY = -200, maxY = 200,
>     25→    halfWidth = 420, halfHeight = 200,
>     26→    spanWidth = 840, spanHeight = 400,
>     27→}
>     28→
>     29→Profile.PlayArea = {
>     30→    minX = -370, maxX = 370,
>     31→    minY = -170, maxY = 170,
>     32→    width = 740, height = 340,
>     33→}
>     34→
>     35→Profile.Goals = {
>     36→    leftX = -370,
>     37→    rightX = 370,
>     38→    halfHeight = 64,
>     39→    openingWidth = 128,
>     40→    netBackX = 400,
>     41→    postRadius = 8,
>     42→    goalOwnerTeams = { left = "red", right = "blue" },
>     43→    scoringTeams = { left = "blue", right = "red" },
>     44→}
>     45→
>     46→Profile.CollisionGroups = {
>     47→    -- Haxball collision flag bit values.
>     48→    ball = 1,
>     49→    red = 2,
>     50→    blue = 4,
>     51→    player = 6,
>     52→    redKO = 8,
>     53→    blueKO = 16,
>     54→    kickoffBarrier = 24,
>     55→    wall = 32,
>     56→    outerWall = 32,
>     57→    post = 32,
>     58→    ballArea = 32,
>     59→    goalNet = 32,
>     60→    kick = 64,
>     61→    score = 128,
>     62→}
>     63→
>     64→Profile.CollisionMasks = {
>     65→    all = 63,
>     66→    player = 39,
>     67→    ball = 63,
>     68→    post = 63,
>     69→    kickoffBarrier = 6,
>     70→}
>     71→
>     72→Profile.Geometry = {
>     73→    planes = {
>     74→        { id = "classic:ballArea:bottom", normalX = 0, normalY = 1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     75→        { id = "classic:ballArea:top", normalX = 0, normalY = -1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     76→        { id = "classic:outer:bottom", normalX = 0, normalY = 1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     77→        { id = "classic:outer:top", normalX = 0, normalY = -1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     78→        { id = "classic:outer:left", normalX = 1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     79→        { id = "classic:outer:right", normalX = -1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
>     80→    },
>     81→    segments = {
>     82→        { id = "classic:ballArea:left:upper", x1 = -370, y1 = 170, x2 = -370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     83→        { id = "classic:ballArea:left:lower", x1 = -370, y1 = -64, x2 = -370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     84→        { id = "classic:ballArea:right:upper", x1 = 370, y1 = 170, x2 = 370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     85→        { id = "classic:ballArea:right:lower", x1 = 370, y1 = -64, x2 = 370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
>     86→        { id = "classic:goalNet:left:lowerCurve", x1 = -380, y1 = -64, x2 = -400, y2 = -44, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     87→        { id = "classic:goalNet:left:back", x1 = -400, y1 = -44, x2 = -400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     88→        { id = "classic:goalNet:left:upperCurve", x1 = -400, y1 = 44, x2 = -380, y2 = 64, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     89→        { id = "classic:goalNet:right:lowerCurve", x1 = 380, y1 = -64, x2 = 400, y2 = -44, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     90→        { id = "classic:goalNet:right:back", x1 = 400, y1 = -44, x2 = 400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     91→        { id = "classic:goalNet:right:upperCurve", x1 = 400, y1 = 44, x2 = 380, y2 = 64, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
>     92→        { id = "classic:kickoff:upperLine", x1 = 0, y1 = 200, x2 = 0, y2 = 75, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
>     93→        { id = "classic:kickoff:circleBlueKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = 180, bCoef = 0.1, collisionGroup = 16, collisionMask = 6, kickoffOnly = true },
>     94→        { id = "classic:kickoff:circleRedKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = -180, bCoef = 0.1, collisionGroup = 8, collisionMask = 6, kickoffOnly = true },
>     95→        { id = "classic:kickoff:lowerLine", x1 = 0, y1 = -75, x2 = 0, y2 = -200, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
>     96→    },
>     97→    posts = {
>     98→        { id = "classic:post:left:upper", x = -370, y = 64, radius = 8, bCoef = 0.5 },
>     99→        { id = "classic:post:left:lower", x = -370, y = -64, radius = 8, bCoef = 0.5 },
>    100→        { id = "classic:post:right:upper", x = 370, y = 64, radius = 8, bCoef = 0.5 },
>    101→        { id = "classic:post:right:lower", x = 370, y = -64, radius = 8, bCoef = 0.5 },
>    102→    },
>    103→}
>    104→
>    105→Profile.SpawnPoints = {
>    106→    -- Current 5v5 lab formation; a project choice, not a claim about HBS default spawns.
>    107→    { x = -80, y = 0 },
>    108→    { x = -150, y = -54 }, { x = -150, y = -18 }, { x = -150, y = 18 }, { x = -150, y = 54 },
>    109→    { x = 150, y = -72 }, { x = 150, y = -36 }, { x = 150, y = 0 }, { x = 150, y = 36 }, { x = 150, y = 72 },
>    110→}
>    111→
>    112→Profile.Simulation = {
>    113→    tickRate = { value = 60, evidence = "DOCUMENTED_LOGICAL_TICK", source = "Headless Host onGameTick documentation; does not prove internal substeps or render/network rates." },
>    114→}
>    115→
>    116→Profile.PhysicsBaseline = {
>    117→    evidenceReplay = {
>    118→        format = "HBR2",
>    119→        version = 3,
>    120→        frames = 12368,
>    121→        stadium = "Small",
>    122→        sha256 = "60a184ca3e33f763424960e407bc7d898cbf13a0a5e54eb85f811661e4d478d5",
>    123→        engine = "Node-Haxball",
>    124→        engineCommit = "4d4b88f1e5e25d484d27819ee6a4699720bda164",
>    125→        evidenceLevel = "RECONSTRUCTED_INDEPENDENT_IMPLEMENTATION",
>    126→        note = "Replay stadium is Small, not the frozen Classic geometry profile; values remain candidates until cross-validated.",
>    127→    },
>    128→    active = {
>    129→        status = "PROJECT_PROVISIONAL",
>    130→        note = "Existing lab runtime defaults retained; not certified against the official Haxball engine.",
>    131→        player = {
>    132→            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
>    133→            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
>    134→            kickStrength = 5, kickback = 0,
>    135→        },
>    136→        ball = { radius = 10, invMass = 1, damping = 0.99, bounce = 0.5 },
>    137→        kickRangeExtra = 4,
>    138→        evidence = {
>    139→            player = "Values match the independent replay reconstruction; official comparison pending.",
>    140→            ball = "radius and damping match the replay reconstruction; active invMass/bounce are retained project defaults and differ from that replay candidate.",
>    141→            kickRangeExtra = "UNKNOWN_PROJECT_PROVISIONAL",
>    142→        },
>    143→    },
>    144→    replayCandidate = {
>    145→        status = "RECONSTRUCTED_NOT_OFFICIAL_MEASUREMENT",
>    146→        source = "replay_metadata.json roomData physics metadata",
>    147→        player = {
>    148→            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
>    149→            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
>    150→            kickStrength = 5, kickback = 0,
>    151→        },
>    152→        ball = { radius = 10, invMass = 0.5, damping = 0.99, bounce = 1 },
>    153→    },
>    154→    labSolver = {
>    155→        collisionIterations = 24,
>    156→        maxSubsteps = 128,
>    157→        substepRadiusFraction = 0.2,
>    158→        evidence = "PROJECT_IMPLEMENTATION_TUNING_NOT_ORIGINAL_ENGINE_PARAMETERS",
>    159→    },
>    160→}
>    161→
>    162→Profile.Calibration = {
>    163→    status = "IN_PROGRESS",
>    164→    reference = {
>    165→        class = "VERIFIED_FROM_FROZEN_HBS",
>    166→        source = Profile.Metadata.sourcePermalink,
>    167→        confidence = "high for map data",
>    168→        geometryCounts = { planes = 6, segments = 14, kickoffSegments = 4, posts = 4 },
>    169→    },
>    170→    replayComparison = {
>    171→        class = "RECONSTRUCTED_AND_MEASURED_ON_NODE_HAXBALL",
>    172→        sourceSha256 = Profile.PhysicsBaseline.evidenceReplay.sha256,
>    173→        sourceStadium = "Small",
>    174→        frames = 12368,
>    175→        directOfficialComparison = false,
>    176→        playerFreeFlight = {
>    177→            eligiblePairs = 10002,
>    178→            noInputPairs = 762,
>    179→            medianPositionResidual = 6.8e-15,
>    180→            medianVelocityResidual = 0,
>    181→            dampingRatioMedian = 0.96,
>    182→        },
>    183→        ballFreeFlight = {
>    184→            eligiblePairs = 10998,
>    185→            medianPositionResidual = 2.6e-15,
>    186→            dampingRatioMedian = 0.99,
>    187→        },
>    188→        kicks = { callbacks = 28, medianCenterDistance = 27.64, medianDeltaVelocityMagnitude = 4.944 },
>    189→    },
>    190→    parameterDelta = {
>    191→        playerCandidateValuesMatchActive = true,
>    192→        ballRadius = { active = 10, replayCandidate = 10, status = "MATCH" },
>    193→        ballInvMass = { active = 1, replayCandidate = 0.5, status = "DISAGREEMENT" },
>    194→        ballDamping = { active = 0.99, replayCandidate = 0.99, status = "MATCH" },
>    195→        ballBounce = { active = 0.5, replayCandidate = 1, status = "DISAGREEMENT" },
>    196→        kickRangeExtra = { active = 4, replayCandidate = nil, status = "UNKNOWN" },
>    197→    },
>    198→    separateTelemetry = {
>    199→        stadium = "Big",
>    200→        records = 21912,
>    201→        events = 78,
>    202→        sameMatchAsReplay = false,
>    203→        usableForDirectParameterCalibration = false,
>    204→        reason = "Separate stadium/session, no per-tick inputs, repeated gameTime and resets prevent direct physical fitting.",
>    205→    },
>    206→    unresolved = {
>    207→        "Official-engine trajectory comparison on Classic",
>    208→        "Kick range and failed-kick boundary",
>    209→        "Solver order and internal substeps",
>    210→        "Player-to-player calibration on controlled original-engine data",
>    211→    },
>    212→}
>    213→
>    214→Profile.Presentation = {
>    215→    studsPerUnit = 0.5,
>    216→    logicalOrigin = { x = 0, y = 0 },
>    217→    worldOrigin = { x = 0, z = 0 },
>    218→    floorY = 11,
>    219→    invertLogicalY = true,
>    220→    evidence = "Presentation-only scale; physics coordinates remain in stadium units.",
>    221→}
>    222→
>    223→return Profile
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ReplicatedStorage.HaxballLab.PredictionLab2D",
>   "should_read_entire_file": true
> }
> ```
>
> ```text
>      1→-- Client-only free-motion micro-prediction for isolated latency experiments.
>      2→-- Predicted contacts are forecasts, never authoritative collision results.
>      3→local Prediction = {}
>      4→
>      5→local function clampInput(x,y)
>      6→    x=type(x)=="number" and x or 0
>      7→    y=type(y)=="number" and y or 0
>      8→    local magnitude=math.sqrt(x*x+y*y)
>      9→    if magnitude>1 then return x/magnitude,y/magnitude end
>     10→    return x,y
>     11→end
>     12→
>     13→function Prediction.predict(state,input,params,ticks)
>     14→    assert(type(state)=="table" and type(input)=="table" and type(params)=="table","state, input, and params are required")
>     15→    ticks=math.clamp(math.floor(tonumber(ticks) or 0),0,24)
>     16→    local x,y,vx,vy=state.x,state.y,state.vx,state.vy
>     17→    local ix,iy=clampInput(input.x,input.y)
>     18→    local path=table.create(ticks)
>     19→    for tick=1,ticks do
>     20→        local acceleration=input.kick and params.kickAcceleration or params.acceleration
>     21→        vx+=ix*acceleration
>     22→        vy+=iy*acceleration
>     23→        if params.maxSpeed then
>     24→            local speed=math.sqrt(vx*vx+vy*vy)
>     25→            if speed>params.maxSpeed then
>     26→                local scale=params.maxSpeed/speed
>     27→                vx*=scale
>     28→                vy*=scale
>     29→            end
>     30→        end
>     31→        x+=vx
>     32→        y+=vy
>     33→        local damping=input.kick and params.kickDamping or params.damping
>     34→        vx*=damping
>     35→        vy*=damping
>     36→        path[tick]={tick=tick,x=x,y=y,vx=vx,vy=vy}
>     37→    end
>     38→    return {x=x,y=y,vx=vx,vy=vy,path=path,ticks=ticks}
>     39→end
>     40→
>     41→function Prediction.firstContact(path,playerRadius,targets)
>     42→    for _,sample in ipairs(path or {}) do
>     43→        for _,target in ipairs(targets or {}) do
>     44→            local tx=target.x+(target.vx or 0)*sample.tick
>     45→            local ty=target.y+(target.vy or 0)*sample.tick
>     46→            local dx,dy=sample.x-tx,sample.y-ty
>     47→            local distance=math.sqrt(dx*dx+dy*dy)
>     48→            if distance<=playerRadius+(target.radius or 0) then
>     49→                return {tick=sample.tick,targetId=target.id,kind=target.kind,distance=distance}
>     50→            end
>     51→        end
>     52→    end
>     53→    return nil
>     54→end
>     55→
>     56→return Prediction
>     57→
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "coreMode"
> }
> ```
>
> ```text
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 229 |     if syntheticInputDelayMs>0 and latest.coreMode and latest.matchPhase=="playing" and latest.predictionParams then
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 293 |         latest.tick,latest.gameTime,latest.crowdMode and "THREE-DISC TEST" or (latest.pairMode and "PAIR TEST" or (latest.coreMode and ("CORE v1 | owner "..tostring(latest.ownerUserId or "-")) or (latest.legacyMode and "LEGACY CCD TEST" or ("owner "..tostring(latest.ownerUserId or "-"))))),
> Path: ServerScriptService.HaxballLab.LabServer | Line: 339 |         coreMode=state.coreWorld~=nil,
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "startCoreMatch"
> }
> ```
>
> ```text
> No matches found for the given query.
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "PhysicsCore2D.newWorld"
> }
> ```
>
> ```text
> Path: ServerScriptService.HaxballLab.LabServer | Line: 161 |     local world=PhysicsCore2D.newWorld({
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "recordTouch"
> }
> ```
>
> ```text
> Path: ServerScriptService.HaxballLab.LabServer | Line: 484 |                     if kicker then MatchRules2D.recordTouch(matchState,event.playerId,kicker.team,state.tick,"kick") end
> Path: ServerScriptService.HaxballLab.LabServer | Line: 508 |                         if toucher then MatchRules2D.recordTouch(matchState,playerId,toucher.team,state.tick,"contact") end
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 425 |         local first=MatchRules2D.recordTouch(match,2,"red",10,"contact")
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 426 |         local second=MatchRules2D.recordTouch(match,7,"blue",10,"kick")
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 427 |         local invalid=MatchRules2D.recordTouch(match,11,"green",11,"contact")
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 91 | function Rules.recordTouch(match, playerId, team, tick, kind)
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "OnServerEvent"
> }
> ```
>
> ```text
> Path: ServerScriptService.HaxballLab.LabServer | Line: 140 | inputRemote.OnServerEvent:Connect(function(player,x,y,kick)
> Path: ServerScriptService.HaxballLab.LabServer | Line: 222 | commandRemote.OnServerEvent:Connect(function(player,command)
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "runRegressionSuite"
> }
> ```
>
> ```text
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 162 | regressionButton.Activated:Connect(function() commandRemote:FireServer("runRegressionSuite") end)
> Path: ServerScriptService.HaxballLab.LabServer | Line: 294 |     elseif command=="runRegressionSuite" then
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "PredictionLab"
> }
> ```
>
> ```text
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 12 | local PredictionLab2D=require(lab:WaitForChild("PredictionLab2D"))
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 82 | local predictionLabel=Instance.new("TextLabel")
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 83 | predictionLabel.Name="NetworkPredictionDebug"
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 84 | predictionLabel.Size=UDim2.fromOffset(370,72)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 85 | predictionLabel.Position=UDim2.new(1,-384,0,14)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 86 | predictionLabel.BackgroundTransparency=0.18
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 87 | predictionLabel.BackgroundColor3=Color3.fromRGB(15,20,25)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 88 | predictionLabel.TextColor3=Color3.fromRGB(255,235,150)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 89 | predictionLabel.Font=Enum.Font.Code
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 90 | predictionLabel.TextSize=13
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 91 | predictionLabel.TextXAlignment=Enum.TextXAlignment.Left
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 92 | predictionLabel.TextYAlignment=Enum.TextYAlignment.Top
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 93 | predictionLabel.TextWrapped=true
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 94 | predictionLabel.Text="Predicción experimental | input delay 0 ms"
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 95 | predictionLabel.Parent=gui
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 230 |         predictedState=PredictionLab2D.predict(latest.player,{x=move.X,y=move.Y,kick=kick},latest.predictionParams,predictionTicks)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 236 |         predictedContact=PredictionLab2D.firstContact(predictedState.path,latest.player.radius or 15,targets)
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 241 |         predictionLabel.Text=string.format("SIMULATED INPUT DELAY %d ms | horizon %d ticks\nGhost lead %.2f units | ball gap %.2f\nForecast: %s | server touch now: %s",syntheticInputDelayMs,predictionTicks,lead,latest.separation,forecast,tostring(latest.touchingBall))
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 244 |         predictionLabel.Text=syntheticInputDelayMs>0 and string.format("Input delay %d ms | prediction active in 5v5 core only",syntheticInputDelayMs) or "Predicción experimental | input delay 0 ms"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 4 | local PredictionLab2D=require(game:GetService("ReplicatedStorage").HaxballLab:WaitForChild("PredictionLab2D"))
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 415 |         local predicted=PredictionLab2D.predict({x=0,y=0,vx=0,vy=0},{x=1,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=0.96,kickDamping=0.96},2)
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 419 |         local predicted=PredictionLab2D.predict({x=-30,y=0,vx=4,vy=0},{x=0,y=0,kick=false},{acceleration=0.1,kickAcceleration=0.07,damping=1,kickDamping=1},2)
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 420 |         local contact=PredictionLab2D.firstContact(predicted.path,15,{{id="ball",kind="ball",x=0,y=0,radius=10}})
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "RateLimit"
> }
> ```
>
> ```text
> No matches found for the given query.
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "kickoffTeam"
> }
> ```
>
> ```text
> Path: ReplicatedStorage.HaxballLab.LabClient | Line: 289 |     local matchStatus=latest.matchPhase=="goalPause" and string.format("GOAL PAUSE %d",latest.pauseTicksRemaining) or (latest.matchPhase=="kickoff" and string.format("KICKOFF %s %d",string.upper(latest.kickoffTeam or "-"),latest.pauseTicksRemaining) or (latest.kickoffTeam and ("WAIT KICK "..string.upper(latest.kickoffTeam)) or "PLAYING"))
> Path: ServerScriptService.HaxballLab.LabServer | Line: 322 |         matchPhase=matchState.phase,pauseTicksRemaining=matchState.remainingTicks,kickoffTeam=matchState.kickoffTeam,lastGoal=matchState.lastGoal,lastTouch=matchState.lastTouch,
> Path: ServerScriptService.HaxballLab.LabServer | Line: 546 |                     local teamToKick=matchState.kickoffTeam
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 405 |         local stillLocked=match.phase=="kickoff" and match.remainingTicks==1 and match.kickoffTeam=="blue"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 409 |         local assignmentPreserved=match.kickoffTeam=="blue"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 411 |         local ok=not firstDone and stillLocked and done and match.phase=="playing" and assignmentPreserved and not wrongTeam and correctTeam and match.kickoffTeam==nil
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 434 |         match.kickoffTeam="blue"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 458 |         local match=MatchRules2D.newMatch();match.phase="kickoff";match.kickoffTeam="red"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 463 |         match.kickoffTeam="blue"
> Path: ServerScriptService.HaxballLab.LabRegression | Line: 548 |             match.kickoffTeam=kickoffActive and team or nil
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 14 |     return { phase = "playing", remainingTicks = 0, lastGoal = nil, kickoffTeam = nil }
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 78 |     match.phase, match.remainingTicks, match.kickoffTeam = "kickoff", ticks or Rules.KickoffTicks, team
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 99 |     if match.kickoffTeam then
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 100 |         local kickoffFlag = match.kickoffTeam == "red" and Profile.CollisionGroups.redKO or Profile.CollisionGroups.blueKO
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 108 |     if match.kickoffTeam and playerTeam ~= match.kickoffTeam and input.kick then
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 115 |     if match.phase ~= "playing" or not match.kickoffTeam or playerTeam ~= match.kickoffTeam then return false end
> Path: ServerScriptService.HaxballLab.MatchRules2D | Line: 116 |     match.kickoffTeam = nil
> ```
>
> MCP tool call
>
> Roblox_Studio.script_grep
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "query": "Players:GetPlayers"
> }
> ```
>
> ```text
> Path: ServerScriptService.HaxballLab.LabServer | Line: 100 | for _,player in Players:GetPlayers() do setController(player) end
> Path: ServerScriptService.HaxballLab.LabServer | Line: 113 |         for _,candidate in Players:GetPlayers() do
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabServer",
>   "should_read_entire_file": false,
>   "start_line_one_indexed": 128,
>   "end_line_one_indexed_inclusive": 180
> }
> ```
>
> ```text
>    128→local function allocateInput(playerSlot,x,y,kick)
>    129→    if not finite(x) or not finite(y) then return nil end
>    130→    local magnitude=math.sqrt(x*x+y*y)
>    131→    if magnitude>1 then x,y=x/magnitude,y/magnitude end
>    132→    local value={x=x,y=y,kick=kick==true}
>    133→    local old=currentInputs[playerSlot] or {x=0,y=0,kick=false}
>    134→    if x~=old.x or y~=old.y or value.kick~=old.kick then
>    135→        logEvent("input",{playerId=playerSlot,x=x,y=y,kick=value.kick})
>    136→    end
>    137→    currentInputs[playerSlot]=value
>    138→    return value
>    139→end
>    140→inputRemote.OnServerEvent:Connect(function(player,x,y,kick)
>    141→    local slot=playerUserSlots[player.UserId]
>    142→    if not slot then return end
>    143→    if state.coreWorld and matchState.phase~="playing" then return end
>    144→    if pairMode or crowdMode or legacyMode then
>    145→        if player~=controlledPlayer then return end
>    146→        local value=allocateInput(1,x,y,kick)
>    147→        if value then currentInput=value end
>    148→        if value and x*x+y*y>0.01 then
>    149→            local magnitude=math.sqrt(x*x+y*y)
>    150→            facingX,facingY=x/magnitude,y/magnitude
>    151→        end
>    152→        return
>    153→    end
>    154→    local value=allocateInput(slot,x,y,kick)
>    155→    if value and slot==1 then currentInput=value end
>    156→end)
>    157→
>    158→local function speed(d) return math.sqrt(d.vx*d.vx+d.vy*d.vy) end
>    159→local function makeCoreState()
>    160→    local legacy=Physics2D.newState()
>    161→    local world=PhysicsCore2D.newWorld({
>    162→        tickRate=Physics2D.Config.tickRate,
>    163→        fieldHalfWidth=Physics2D.Config.fieldHalfWidth,
>    164→        fieldHalfHeight=Physics2D.Config.fieldHalfHeight,
>    165→        useBounds=false,
>    166→    })
>    167→    -- Preserve stadium order: ball, static posts, then ten player discs.
>    168→    local ball=PhysicsCore2D.addDisc(world,{
>    169→        id="ball",kind="ball",x=0,y=0,radius=Physics2D.Config.ballRadius,
>    170→        invMass=Physics2D.Config.ballInvMass,damping=Physics2D.Config.ballDamping,traceMotion=true,
>    171→        bCoef=Physics2D.Config.ballBounce,kickable=true,
>    172→        collisionGroup=ClassicStadium2D.Groups.ball,
>    173→    })
>    174→    local stadiumGeometry=ClassicStadium2D.install(PhysicsCore2D,world)
>    175→    local spawnPoints = table.clone(StadiumProfile2D.SpawnPoints)
>    176→    local players={}
>    177→    local playerCollisionMasks={}
>    178→    for slot=1,10 do
>    179→        local position=spawnPoints[slot]
>    180→        local disc=PhysicsCore2D.addDisc(world,{
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabServer",
>   "should_read_entire_file": false,
>   "start_line_one_indexed": 260,
>   "end_line_one_indexed_inclusive": 360
> }
> ```
>
> ```text
>    260→        new.player.y=100
>    261→        new.ball.x=0; new.ball.y=0; new.ball.vx=3000
>    262→        logEvent("scenarioReset",{scenario="multiWallBouncesInTick",ballX=0,ballVx=3000})
>    263→    elseif command=="setupPairHeadOn" then
>    264→        local new=newState(true)
>    265→        new.player.x=-40; new.player.vx=2
>    266→        new.player2.x=40; new.player2.vx=-2
>    267→        logEvent("scenarioReset",{scenario="playerHeadOn",p1x=-40,p1vx=2,p2x=40,p2vx=-2})
>    268→    elseif command=="setupPairFastCrossing" then
>    269→        local new=newState(true)
>    270→        new.player.x=-40; new.player.vx=80
>    271→        new.player2.x=40; new.player2.vx=-80
>    272→        logEvent("scenarioReset",{scenario="fastPairCrossing",p1x=-40,p1vx=80,p2x=40,p2vx=-80})
>    273→    elseif command=="setupPairOblique" then
>    274→        local new=newState(true)
>    275→        new.player.x=-40; new.player.y=-10; new.player.vx=2
>    276→        new.player2.x=0; new.player2.y=15; new.player2.vy=-0.8
>    277→        logEvent("scenarioReset",{scenario="playerOblique",p1x=-40,p1y=-10,p1vx=2,p2x=0,p2y=15,p2vy=-0.8})
>    278→    elseif command=="setupPairOverlap" then
>    279→        local new=newState(true)
>    280→        new.player.x=0; new.player.y=0
>    281→        new.player2.x=0; new.player2.y=0
>    282→        logEvent("scenarioReset",{scenario="playerCoincidentCenters"})
>    283→    elseif command=="setupCrowdOverlap" then
>    284→        local new=newState(false,true)
>    285→        new.player.x=-14; new.player2.x=14
>    286→        new.ball.x=0; new.ball.y=0
>    287→        logEvent("scenarioReset",{scenario="threeDiscOverlap",p1x=-14,p2x=14,ballX=0})
>    288→    elseif command=="setupCrowdApproach" then
>    289→        local new=newState(false,true)
>    290→        new.player.x=-32; new.player.vx=2
>    291→        new.player2.x=32; new.player2.vx=-2
>    292→        new.ball.x=0; new.ball.y=0
>    293→        logEvent("scenarioReset",{scenario="twoPlayersApproachBall",p1x=-32,p1vx=2,p2x=32,p2vx=-2,ballX=0})
>    294→    elseif command=="runRegressionSuite" then
>    295→        local report=LabRegression.Run(Physics2D)
>    296→        metrics.regressionRan=true
>    297→        metrics.regressionPassed=report.passed
>    298→        metrics.regressionFailed=report.failed
>    299→        metrics.regressionTotal=report.total
>    300→        logEvent("regressionSuiteCompleted",{passed=report.passed,failed=report.failed,total=report.total,allPassed=report.allPassed})
>    301→    elseif command=="toggleRecording" then
>    302→        recording=not recording
>    303→        logEvent("recordingChanged",{recording=recording})
>    304→    end
>    305→end)
>    306→
>    307→local function snapshot()
>    308→    local p,p2,b=state.player,state.player2,state.ball
>    309→    local dx,dy=p.x-b.x,p.y-b.y
>    310→    local p2dx,p2dy=p.x-p2.x,p.y-p2.y
>    311→    local p2bdx,p2bdy=p2.x-b.x,p2.y-b.y
>    312→    local playerSnapshots={}
>    313→    local redCount,blueCount=0,0
>    314→    if state.players then
>    315→        for slot,disc in ipairs(state.players) do
>    316→            if disc.team=="red" then redCount+=1 elseif disc.team=="blue" then blueCount+=1 end
>    317→            table.insert(playerSnapshots,{playerId=slot,team=disc.team,ownerUserId=disc.ownerUserId,x=disc.x,y=disc.y,vx=disc.vx,vy=disc.vy,speed=speed(disc),radius=disc.radius,collisionGroup=disc.collisionGroup,collisionMask=disc.collisionMask})
>    318→        end
>    319→    end
>    320→    return {
>    321→        tick=state.tick, gameTime=state.tick/Physics2D.Config.tickRate,
>    322→        matchPhase=matchState.phase,pauseTicksRemaining=matchState.remainingTicks,kickoffTeam=matchState.kickoffTeam,lastGoal=matchState.lastGoal,lastTouch=matchState.lastTouch,
>    323→        player={x=p.x,y=p.y,vx=p.vx,vy=p.vy,speed=speed(p),radius=p.radius},
>    324→        predictionParams={acceleration=p.acceleration or Physics2D.Config.playerAcceleration,kickAcceleration=p.kickAcceleration or Physics2D.Config.playerKickAcceleration,damping=p.damping or Physics2D.Config.playerDamping,kickDamping=p.kickDamping or Physics2D.Config.playerDamping,maxSpeed=p.maxSpeed},
>    325→        player2={x=p2.x,y=p2.y,vx=p2.vx,vy=p2.vy,speed=speed(p2)},
>    326→        players=playerSnapshots,playerCount=#playerSnapshots,redCount=redCount,blueCount=blueCount,
>    327→        ball={x=b.x,y=b.y,vx=b.vx,vy=b.vy,speed=speed(b),radius=b.radius,collisionGroup=b.collisionGroup,collisionMask=b.collisionMask},
>    328→        score={red=state.score.red,blue=state.score.blue},
>    329→        ownerUserId=p.ownerUserId,physicsDiscCount=state.coreWorld and #state.coreWorld.discs or 0,
>    330→        input={x=currentInput.x,y=currentInput.y,kick=currentInput.kick},
>    331→        separation=math.sqrt(dx*dx+dy*dy),
>    332→        playerSeparation=math.sqrt(p2dx*p2dx+p2dy*p2dy),
>    333→        player2BallSeparation=math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy),
>    334→        touchingBall=not pairMode and math.sqrt(dx*dx+dy*dy)<=p.radius+b.radius+0.02,
>    335→        touchingPlayer2Ball=crowdMode and math.sqrt(p2bdx*p2bdx+p2bdy*p2bdy)<=p2.radius+b.radius+0.02,
>    336→        touchingPlayers=math.sqrt(p2dx*p2dx+p2dy*p2dy)<=p.radius+p2.radius+0.02,
>    337→        pairMode=pairMode,
>    338→        crowdMode=crowdMode,
>    339→        coreMode=state.coreWorld~=nil,
>    340→        legacyMode=legacyMode,
>    341→        ballActive=not pairMode,
>    342→        metrics=table.clone(metrics),
>    343→        recording=recording,
>    344→        crowdMode=crowdMode,
>    345→        historySamples=historyCount,
>    346→    }
>    347→end
>    348→debugState.OnInvoke=function(request)
>    349→    local current=snapshot()
>    350→    if request=="regression" then
>    351→        return LabRegression.Run(Physics2D)
>    352→    end
>    353→    if request=="summary" then
>    354→        return {current=current,metrics=table.clone(metrics),eventCount=#events,historyCount=historyCount,recording=recording}
>    355→    end
>    356→    local chronological={}
>    357→    local limit=type(request)=="table" and math.clamp(request.limit or 600,1,1200) or 600
>    358→    local hasAfterTick=type(request)=="table" and type(request.afterTick)=="number"
>    359→    local afterTick=hasAfterTick and request.afterTick or -1
>    360→    local first=historyCount<historyCapacity and 1 or historyWrite
> ```
>
> MCP tool call
>
> Roblox_Studio.script_read
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0",
>   "target_file": "game.ServerScriptService.HaxballLab.LabServer",
>   "should_read_entire_file": false,
>   "start_line_one_indexed": 460,
>   "end_line_one_indexed_inclusive": 570
> }
> ```
>
> ```text
>    460→            local inputsLocked=pausedAtStart or kickoffAtStart
>    461→            for slot=1,10 do
>    462→                local input=inputsLocked and {x=0,y=0,kick=false} or (currentInputs[slot] or {x=0,y=0,kick=false})
>    463→                if not inputsLocked then
>    464→                    input=MatchRules2D.filterKickoffInput(matchState,state.players[slot].team,input)
>    465→                end
>    466→                coreInputs[slot]=input
>    467→                if not inputsLocked and input.kick and not lastCoreKickInputs[slot] then table.insert(kickAttempts,slot) end
>    468→                lastCoreKickInputs[slot]=inputsLocked and false or input.kick
>    469→            end
>    470→            for slot,actor in ipairs(state.players) do
>    471→                actor.collisionMask=MatchRules2D.kickoffCollisionMask(matchState,actor.team,state.playerCollisionMasks[slot],ClassicStadium2D.Groups.ball)
>    472→            end
>    473→            local _,coreEvents,coreSubsteps=PhysicsCore2D.stepWorld(state.coreWorld,coreInputs)
>    474→            state.tick=state.coreWorld.tick
>    475→            local stepInfo={substeps=coreSubsteps or 1,ballWallBounces=0,playerWallBounces=0,playerBallContacts=0,lastPlayerBallContact=nil}
>    476→            local acceptedKicks,currentTouches,contactsByPlayer={},{},{}
>    477→            for _,event in ipairs(coreEvents) do
>    478→                if event.kind=="kick" then
>    479→                    acceptedKicks[event.playerId]=true
>    480→                    metrics.successfulKicks+=1
>    481→                    metrics.lastKickSuccessTick=state.tick
>    482→                    logEvent("kickApplied",{playerId=event.playerId,targetId=event.targetId,normalX=event.normalX,normalY=event.normalY},state.tick)
>    483→                    local kicker=state.players[event.playerId]
>    484→                    if kicker then MatchRules2D.recordTouch(matchState,event.playerId,kicker.team,state.tick,"kick") end
>    485→                    if kicker and MatchRules2D.completeKickoff(matchState,kicker.team) then
>    486→                        logEvent("kickoffTaken",{playerId=event.playerId,team=kicker.team},state.tick)
>    487→                    end
>    488→                elseif event.kind=="boundaryContact" then
>    489→                    local count=event.count or 1
>    490→                    if event.discId=="ball" then stepInfo.ballWallBounces+=count
>    491→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=count end
>    492→                elseif event.kind=="planeContact" or event.kind=="segmentContact" then
>    493→                    if event.discId=="ball" then stepInfo.ballWallBounces+=1
>    494→                    elseif type(event.discId)=="number" then stepInfo.playerWallBounces+=1 end
>    495→                elseif event.kind=="discContact" then
>    496→                    local playerId
>    497→                    if event.discA=="ball" and type(event.discB)=="number" then playerId=event.discB
>    498→                    elseif event.discB=="ball" and type(event.discA)=="number" then playerId=event.discA end
>    499→                    if playerId then
>    500→                        stepInfo.playerBallContacts+=1
>    501→                        local nx,ny=event.normalX,event.normalY
>    502→                        if event.discA=="ball" then nx,ny=-nx,-ny end
>    503→                        local contact={playerId=playerId,normalX=nx,normalY=ny,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse}
>    504→                        stepInfo.lastPlayerBallContact=contact
>    505→                        contactsByPlayer[playerId]=contact
>    506→                        currentTouches[playerId]=true
>    507→                        local toucher=state.players[playerId]
>    508→                        if toucher then MatchRules2D.recordTouch(matchState,playerId,toucher.team,state.tick,"contact") end
>    509→                    elseif type(event.discA)=="number" and type(event.discB)=="number" then
>    510→                        metrics.playerContacts+=1
>    511→                        metrics.lastPlayerContactTick=state.tick
>    512→                        metrics.maxPlayerPenetration=math.max(metrics.maxPlayerPenetration,event.penetration or 0)
>    513→                        metrics.lastPlayerImpulse=event.impulse or 0
>    514→                        logEvent("playerPlayerContact",{playerA=event.discA,playerB=event.discB,normalX=event.normalX,normalY=event.normalY,penetration=event.penetration,normalSpeedBefore=event.normalSpeedBefore,impulse=event.impulse},state.tick)
>    515→                    end
>    516→                end
>    517→            end
>    518→            metrics.kickAttempts+=#kickAttempts
>    519→            for _,slot in ipairs(kickAttempts) do
>    520→                local accepted=acceptedKicks[slot]==true
>    521→                local actor=state.players[slot]
>    522→                local separation=math.sqrt((actor.x-b.x)^2+(actor.y-b.y)^2)
>    523→                logEvent("kickAttempt",{playerId=slot,accepted=accepted,separation=separation,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    524→            end
>    525→            for slot,actor in ipairs(state.players) do
>    526→                local dx,dy=actor.x-b.x,actor.y-b.y
>    527→                local touching=math.sqrt(dx*dx+dy*dy)<=actor.radius+b.radius+0.02
>    528→                if currentTouches[slot] and not touchingCoreBall[slot] then
>    529→                    metrics.ballContacts+=1
>    530→                    local contact=contactsByPlayer[slot] or {}
>    531→                    logEvent("playerBallContact",{playerId=slot,separation=actor.radius+b.radius-(contact.penetration or 0),normalX=contact.normalX,normalY=contact.normalY,normalSpeedBefore=contact.normalSpeedBefore,impulse=contact.impulse,playerX=actor.x,playerY=actor.y,ballX=b.x,ballY=b.y},state.tick)
>    532→                end
>    533→                touchingCoreBall[slot]=touching
>    534→            end
>    535→            if pausedAtStart then
>    536→                if MatchRules2D.advancePause(matchState) then
>    537→                    MatchRules2D.resetKickoff(b,state.players,state.spawnPoints)
>    538→                    local teamToKick=matchState.lastGoal and (matchState.lastGoal.team=="red" and "blue" or "red") or "red"
>    539→                    MatchRules2D.beginKickoff(matchState,teamToKick)
>    540→                    touchingCoreBall={}
>    541→                    touchingBall=false
>    542→                    logEvent("kickoffReset",{teamToKick=teamToKick,lockTicks=matchState.remainingTicks},state.tick)
>    543→                end
>    544→            elseif kickoffAtStart then
>    545→                if MatchRules2D.advanceKickoff(matchState) then
>    546→                    local teamToKick=matchState.kickoffTeam
>    547→                    MatchRules2D.resume(matchState)
>    548→                    logEvent("kickoffComplete",{teamToKick=teamToKick},state.tick)
>    549→                end
>    550→            else
>    551→                local goal=MatchRules2D.findGoalCrossing(state.coreWorld.motionSegments,"ball")
>    552→                if goal then
>    553→                    goal.tick=state.tick
>    554→                    MatchRules2D.beginGoalPause(matchState,state.score,goal,b,state.players)
>    555→                    currentInputs={}
>    556→                    for slot=1,10 do currentInputs[slot]={x=0,y=0,kick=false} end
>    557→                    currentInput=currentInputs[1]
>    558→                    lastCoreKickInputs={}
>    559→                    touchingCoreBall={}
>    560→                    touchingBall=false
>    561→                    logEvent("goalScored",{team=goal.team,side=goal.side,x=goal.x,y=goal.y,substep=goal.substep,substeps=goal.substeps,fraction=goal.fraction},state.tick)
>    562→                end
>    563→            end
>    564→            physicsStepInfo=stepInfo
>    565→            if speedRunRemaining>0 then
>    566→                speedRunRemaining-=1
>    567→                if speedRunRemaining==0 then
>    568→                    currentInput={x=0,y=0,kick=false}
>    569→                    currentInputs[1]=currentInput
>    570→                    logEvent("speedRunFinished",{ticks=120,playerX=p.x,playerVx=p.vx,playerSpeed=speed(p)},state.tick)
> ```
>
> </details>
</details>

Revisé la carpeta del 17 y contrasté sus informes con la instancia actual de Roblox Studio. **No hice cambios, no inicié Play y no guardé ni publiqué el lugar.**

## Lo que hay

- El proyecto es **Football, hexball**, PlaceId `85137916104328`, UniverseId `10777655598`. La instancia abierta coincide y está en **Edit**.
- La carpeta local contiene informes y datos de investigación, pero su `src` solo tiene tres scripts básicos. **El juego que Studio tiene abierto contiene el código desarrollado**; la carpeta no parece ser una copia sincronizada de ese código. El README propone Rojo, aunque la continuidad del proyecto registra la preferencia de trabajar directamente con Studio MCP.
- En Studio encontré el núcleo `PhysicsCore2D`, el perfil Classic, la lógica de partido, un servidor de laboratorio, regresiones y una herramienta de predicción experimental. El servidor arma diez discos y maneja equipos, inputs, goles, reinicios, kickoff y Last Touch. La presencia de esas funciones no demuestra por sí sola que estén validadas para producción.

## Estado técnico que se desprende de la evidencia

La decisión más reciente de Fase 3 es **PARTIAL GO**: la reproducción de los tres escenarios con Node-Haxball 2.3.0 está documentada, pero la calibración dinámica no está cerrada. En particular, queda por explicar la respuesta distinta del balón al primer contacto del escenario 3. Node-Haxball es una reconstrucción independiente; estos resultados **no certifican igualdad con el Haxball oficial**.

Los informes recomiendan aislar contactos de un solo plano antes de tocar el solver o sus coeficientes. Movimiento y patadas tampoco están calibrados contra una referencia externa. El resultado de regresión 47/47 es histórico; los documentos aclaran que no se volvió a ejecutar en la última auditoría.

También vi una discrepancia que conviene mantener presente: el perfil Classic activo asigna `bCoef=0.1` a los planos exteriores, mientras que la referencia HBS citada declara `bCoef=0`. Los informes indican que esa diferencia no explica por sí sola la divergencia principal y que no se modificó.

## Nota sobre los informes

Hay documentos con conclusiones distintas: `PHASE3_FINAL_GO_NO_GO.md` dice NO-GO y describe evidencia más limitada; el informe dinámico posterior, `PHASE3_DYNAMIC_CALIBRATION_DECISION.md`, incorpora la reproducción 2.3.0 y concluye PARTIAL GO. Para continuar, tomaría este último como estado más reciente, junto con `PHASE3_FIRST_DIVERGENCE_REPORT.md` y `PHASE3_CONTACT_SOLVER_ANALYSIS.md`.

Referencias principales: [contexto de continuidad](/C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/HAXBALL_PROJECT_CONTEXT.md), [decisión dinámica](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_DYNAMIC_CALIBRATION_DECISION.md>), [divergencias por tick](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_FIRST_DIVERGENCE_REPORT.md>) y [plan de validación de movimiento y patadas](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_PLAYER_KICK_VALIDATION_PLAN.md>).

> Con lo ultimo que te he mandado y contexto, eres capaz de trabajar? y

Sí, puedo continuar trabajando con lo que ya compartiste. Tengo el contexto del proyecto y confirmé que Roblox Studio tiene abierto el lugar correcto. También tengo presente que el código vivo está en Studio y que la calibración física sigue abierta.

Parece que tu pregunta quedó a medias después de «y». ¿Qué más querías preguntarme?

> \# HAXBALL LAB — FASE 3: AISLAMIENTO DEL ESCENARIO 3 Y AUDITORÍA DE PLANOS HBS\
> \
> \## OBJETIVO PRINCIPAL\
> \
> Investigar y localizar la causa exacta de la divergencia física del escenario 3 entre nuestro \`PhysicsCore2D\` y Node-HaxBall 2.3.0.\
> \
> La investigación debe concentrarse en:\
> \
> 1\. Identificar qué plano produce realmente el contacto divergente.\
> 2\. Auditar la geometría, normales y propiedades físicas de ese plano en HBS y en nuestro proyecto.\
> 3\. Reconstruir detalladamente la respuesta de contacto de ambos motores.\
> 4\. Aislar el contacto mediante micropruebas reproducibles.\
> 5\. Determinar si la diferencia procede de los parámetros del plano, la geometría, la detección de colisiones o el algoritmo de resolución.\
> \
> \*\*No se busca reducir el RMS artificialmente. Se busca identificar una causa demostrable.\*\*\
> \
> \---\
> \
> \# 1. CONTEXTO Y EVIDENCIA DISPONIBLE\
> \
> La investigación anterior produjo una comparación de 373 ticks:\
> \
> \- Escenario 1: 180 ticks.\
> \- Escenario 2: 13 ticks anteriores al gol.\
> \- Escenario 3: 180 ticks.\
> \
> La comparación incluye posiciones, velocidades, errores por tick de la pelota y jugadores, eventos y contactos.\
> \
> \## Escenarios 1 y 2\
> \
> La primera divergencia significativa aparece durante un contacto con un plano.\
> \
> Se observó que:\
> \
> \- Las velocidades poscontacto coinciden.\
> \- La posición al terminar el tick es diferente.\
> \- \`PhysicsCore2D\` resuelve durante los subpasos y continúa avanzando el resto del paso.\
> \- Node-HaxBall presenta una corrección de posición al final del paso.\
> \
> No modificar todavía este comportamiento. Es una línea de investigación separada.\
> \
> \## Escenario 3 — PRIORIDAD MÁXIMA\
> \
> En el tick 4:\
> \
> \*\*Node-HaxBall:\*\*\
> \- Posición: \`(157.616, 160)\`\
> \- Velocidad Y: \`0\`\
> \
> \*\*PhysicsCore2D:\*\*\
> \- Posición: \`(157.616, 143.206)\`\
> \- Velocidad Y: \`-24.015\`\
> \
> La respuesta normal es diferente.\
> \
> La investigación anterior identificó un \`planeId\`, pero no pudo atribuirlo de manera segura a una propiedad o plano interno concreto.\
> \
> También quedó documentada una discrepancia entre el \`bCoef\` de los planos exteriores del HBS y el perfil activo de nuestro proyecto.\
> \
> Esto es una pista, no una causa confirmada.\
> \
> \## Referencia\
> \
> Se utilizó Node-HaxBall 2.3.0, instalado y reproducido de manera aislada.\
> \
> La reproducción del fixture fue confirmada dos veces byte por byte.\
> \
> Repositorio de referencia fijado:\
> https\://github.com/wxyz-abcd/node-haxball/tree/4d4b88f1e5e25d484d27819ee6a4699720bda164\
> \
> Recuerda que Node-HaxBall es una implementación independiente. No equivale a una certificación de la física del cliente oficial de Haxball.\
> \
> \---\
> \
> \# 2. AUDITORÍA PREVIA OBLIGATORIA\
> \
> Antes de ejecutar pruebas:\
> \
> 1\. Lee los entregables de la investigación anterior:\
> &#x20;  \- \`PHASE3_FIRST_DIVERGENCE_REPORT.md\`\
> &#x20;  \- \`PHASE3_CONTACT_SOLVER_ANALYSIS.md\`\
> &#x20;  \- \`PHASE3_MICROBENCHMARK_RESULTS.json\`\
> &#x20;  \- \`PHASE3_PARAMETER_EVIDENCE_MATRIX.json\`\
> &#x20;  \- \`PHASE3_PLAYER_KICK_VALIDATION_PLAN.md\`\
> &#x20;  \- \`PHASE3_DYNAMIC_CALIBRATION_DECISION.md\`\
> \
> 2\. Inspecciona el código actual de:\
> &#x20;  \- \`PhysicsCore2D\`\
> &#x20;  \- \`Physics2D\`\
> &#x20;  \- \`ClassicStadium2D\`\
> &#x20;  \- \`StadiumReference2D\`\
> &#x20;  \- Los módulos o estructuras que contienen los planos y sus propiedades.\
> \
> 3\. Reutiliza la instalación aislada de Node-HaxBall 2.3.0 y las herramientas anteriores cuando sea posible. No reinstales ni cambies la versión sin una necesidad demostrable.\
> \
> 4\. Confirma que la reproducción del escenario 3 sigue siendo determinista.\
> \
> 5\. Identifica las condiciones iniciales exactas del tick 4 en ambos motores:\
> &#x20;  \- Posición.\
> &#x20;  \- Velocidad.\
> &#x20;  \- Radio de la pelota.\
> &#x20;  \- Propiedades físicas.\
> &#x20;  \- Tiempo de simulación.\
> &#x20;  \- Geometría.\
> &#x20;  \- Estado anterior al contacto.\
> \
> No compares dos estados que no sean equivalentes.\
> \
> Si algún dato no está disponible, documenta la limitación en lugar de inventarlo.\
> \
> \---\
> \
> \# 3. IDENTIFICAR EL PLANO REAL DEL CONTACTO\
> \
> Esta es una de las tareas más importantes.\
> \
> No aceptes que \`planeId\` sea suficiente para identificar un plano.\
> \
> Investiga cómo se asigna ese identificador en cada motor y establece una correspondencia verificable entre:\
> \
> \- El plano detectado por Node-HaxBall.\
> \- El plano detectado por PhysicsCore2D.\
> \- El plano correspondiente en el estadio HBS.\
> \- La definición y propiedades utilizadas durante la simulación.\
> \
> Registra para cada candidato:\
> \
> \- Identificador interno.\
> \- Identificador o posición dentro de la definición del estadio.\
> \- Vector normal.\
> \- Distancia o constante del plano.\
> \- Orientación.\
> \- Sentido de la normal.\
> \- Propiedad \`bCoef\`.\
> \- Cualquier otra propiedad que afecte al contacto.\
> \- Forma en que el motor convierte la definición HBS en una estructura física interna.\
> \
> Determina si ambos motores están utilizando exactamente el mismo plano geométrico.\
> \
> Comprueba especialmente:\
> \
> \- Si las normales apuntan en la misma dirección.\
> \- Si la distancia del plano coincide.\
> \- Si existe alguna transformación de coordenadas.\
> \- Si el plano se interpreta como límite interior o exterior.\
> \- Si hay planos superpuestos.\
> \- Si el contacto se asigna a un plano diferente del que aparenta producirlo.\
> \
> \*\*No atribuyas la discrepancia al \`bCoef\` hasta haber demostrado que ambos motores están resolviendo contra el mismo plano.\*\*\
> \
> \---\
> \
> \# 4. CAPTURA DETALLADA DEL CONTACTO\
> \
> Necesitamos observar qué sucede inmediatamente antes, durante y después del contacto.\
> \
> Instrumenta ambos entornos de manera que sea posible registrar:\
> \
> \### Antes del contacto\
> \
> \- Posición X/Y.\
> \- Velocidad X/Y.\
> \- Velocidad normal.\
> \- Velocidad tangencial.\
> \- Radio.\
> \- Distancia al plano.\
> \- Penetración.\
> \- Normal del plano.\
> \- Propiedades físicas utilizadas.\
> \
> \### Durante la detección y resolución\
> \
> \- Momento exacto de detección.\
> \- Plano seleccionado.\
> \- Normal utilizada por el solver.\
> \- Profundidad de penetración.\
> \- Corrección posicional aplicada.\
> \- Velocidad antes de resolver.\
> \- Velocidad después de resolver.\
> \- Aplicación de restitución o rebote.\
> \- Aplicación del damping.\
> \- Número de iteraciones.\
> \- Subpaso en el que sucede.\
> \- Orden de las operaciones.\
> \
> \### Después del contacto\
> \
> \- Posición inmediatamente después de resolver.\
> \- Velocidad inmediatamente después de resolver.\
> \- Posición al terminar el subpaso.\
> \- Posición al terminar el tick.\
> \- Velocidad al terminar el tick.\
> \
> Si el motor no expone alguno de estos datos, investiga su implementación y utiliza instrumentación temporal en un entorno aislado.\
> \
> No alteres el comportamiento de los motores por añadir instrumentación.\
> \
> \---\
> \
> \# 5. MICROPRUEBAS AISLADAS\
> \
> Reproduce el contacto de manera independiente, eliminando jugadores y otros elementos que puedan interferir.\
> \
> Necesitamos como mínimo las siguientes pruebas:\
> \
> \### Prueba A — Contacto perpendicular\
> \
> Una pelota y un solo plano.\
> \
> Reproducir el contacto con una velocidad normal conocida.\
> \
> Comparar la respuesta de ambos motores.\
> \
> \### Prueba B — Contacto oblicuo\
> \
> La pelota llega al mismo plano con componentes normal y tangencial.\
> \
> Determinar si ambos motores conservan la misma componente tangencial y responden igual a la normal.\
> \
> \### Prueba C — Variación de velocidad\
> \
> Repetir el mismo contacto utilizando varias velocidades iniciales.\
> \
> El objetivo es comprobar si la divergencia depende de la velocidad de impacto.\
> \
> \### Prueba D — Variación de distancia inicial\
> \
> Mantener la velocidad y modificar únicamente la distancia inicial respecto al plano.\
> \
> Comprobar si la diferencia depende del momento en que se detecta el contacto.\
> \
> \### Prueba E — Restitución y \`bCoef\`\
> \
> Realizar pruebas diagnósticas variando una sola propiedad cada vez en entornos desechables.\
> \
> Separar:\
> \- Geometría.\
> \- Normal.\
> \- \`bCoef\`.\
> \- Restitución.\
> \- Damping.\
> \- Corrección posicional.\
> \
> No aplicar estos cambios al perfil productivo.\
> \
> \### Prueba F — Contacto desde el lado opuesto\
> \
> Comprobar el comportamiento de las normales y la respuesta del plano desde ambas direcciones, siempre que la geometría y las reglas de HBS permitan ese contacto.\
> \
> Cada microprueba debe ejecutarse en Node-HaxBall y en PhysicsCore2D con condiciones iniciales idénticas.\
> \
> \---\
> \
> \# 6. INVESTIGACIÓN DEL ALGORITMO DE CONTACTO\
> \
> Analiza la implementación de ambos motores.\
> \
> No te limites a comparar los nombres de sus funciones.\
> \
> Reconstruye el orden efectivo de las operaciones.\
> \
> Investiga:\
> \
> 1\. Integración de posición.\
> 2\. Integración de velocidad.\
> 3\. Detección de contacto.\
> 4\. Cálculo de penetración.\
> 5\. Corrección posicional.\
> 6\. Cálculo de velocidad normal.\
> 7\. Aplicación de restitución.\
> 8\. Tratamiento de velocidad tangencial.\
> 9\. Damping.\
> 10\. Resolución de contactos persistentes.\
> 11\. Iteraciones del solver.\
> 12\. Fin del paso físico.\
> \
> Determina qué diferencias son realmente relevantes para el escenario 3.\
> \
> Si es posible, prepara una representación secuencial del orden de operaciones de ambos motores.\
> \
> Distingue claramente entre:\
> \- Comportamiento observado.\
> \- Código inspeccionado.\
> \- Inferencias.\
> \- Hipótesis pendientes de demostrar.\
> \
> No presentes una hipótesis como una conclusión.\
> \
> \---\
> \
> \# 7. PRUEBAS A/B PARA LOCALIZAR LA CAUSA\
> \
> Cuando las micropruebas permitan identificar candidatos, prepara pruebas A/B controladas.\
> \
> Ejemplos:\
> \
> \- Mismo contacto, distinta normal.\
> \- Mismo contacto, distinto \`bCoef\`.\
> \- Mismo contacto, diferente momento de corrección posicional.\
> \- Mismo contacto, distinto orden de integración y resolución.\
> \
> Cambia una sola variable por ejecución.\
> \
> El objetivo es determinar qué modificación aislada reproduce o elimina la diferencia observada.\
> \
> No busques una combinación de parámetros que simplemente produzca una trayectoria parecida.\
> \
> Si la causa parece estar en el algoritmo del solver, documenta exactamente qué operación debe cambiar y por qué.\
> \
> No implementes esa modificación en el código productivo todavía.\
> \
> \---\
> \
> \# 8. REVISIÓN DE LOS ESCENARIOS 1 Y 2\
> \
> No deben convertirse en el centro de esta tarea, pero conserva los resultados existentes.\
> \
> Prepara una sección breve que explique:\
> \
> \- Por qué sus divergencias parecen relacionadas con el orden temporal.\
> \- Qué evidencia respalda esa hipótesis.\
> \- Qué prueba falta para confirmarla.\
> \- Si la causa podría compartir alguna parte del comportamiento del escenario 3.\
> \
> No mezcles las dos investigaciones si no hay evidencia que las relacione.\
> \
> \---\
> \
> \# 9. RESTRICCIONES ABSOLUTAS\
> \
> \- No modificar parámetros físicos productivos.\
> \- No modificar el solver productivo.\
> \- No cambiar \`bCoef\` activo.\
> \- No cambiar radios, masas, damping, restitución ni velocidades.\
> \- No realizar calibraciones a ciegas.\
> \- No modificar el comportamiento de producción para que coincida artificialmente con un fixture.\
> \- No pasar a Fase 4.\
> \- No iniciar Fase 5.\
> \- No implementar el modo Fútbol avanzado.\
> \- No guardar ni publicar el place.\
> \- Mantener Roblox Studio en Edit.\
> \- No subir ni compartir telemetría o replays privados.\
> \- No reemplazar Node-HaxBall 2.3.0 por otra versión.\
> \- No afirmar que una prueba se ejecutó si solo se analizó su código.\
> \- No declarar resuelto un problema únicamente porque disminuyó el RMS.\
> \
> Puedes crear scripts, harnesses, copias temporales, instrumentación y escenarios aislados fuera del entorno productivo.\
> \
> Cualquier prueba que implique cambios experimentales debe dejar claro que esos cambios no afectan a \`PhysicsCore2D\` ni al perfil activo.\
> \
> \---\
> \
> \# 10. ENTREGABLES OBLIGATORIOS\
> \
> Genera estos archivos:\
> \
> \### 1. \`PHASE3_SCENARIO3_PLANE_AUDIT.md\`\
> \
> Auditoría de planos HBS, correspondencia con los planos internos de ambos motores, geometría, normales y propiedades.\
> \
> \### 2. \`PHASE3_SCENARIO3_CONTACT_TRACE.json\`\
> \
> Registro detallado por etapa del contacto, con estados anteriores, durante y posteriores a la resolución.\
> \
> \### 3. \`PHASE3_SCENARIO3_MICROBENCHMARKS.json\`\
> \
> Resultados de las pruebas A-F, condiciones iniciales, resultados de ambos motores y errores medidos.\
> \
> \### 4. \`PHASE3_SCENARIO3_SOLVER_FORENSICS.md\`\
> \
> Análisis del algoritmo de contacto, diferencias encontradas y reconstrucción del orden de operaciones.\
> \
> \### 5. \`PHASE3_CAUSE_ISOLATION_MATRIX.json\`\
> \
> Matriz con cada causa candidata y su estado:\
> \
> \- CONFIRMED.\
> \- STRONGLY_SUPPORTED.\
> \- POSSIBLE.\
> \- REJECTED.\
> \- UNKNOWN.\
> \
> Incluye evidencia, prueba realizada y justificación.\
> \
> \### 6. \`PHASE3_NEXT_IMPLEMENTATION_PLAN.md\`\
> \
> Propuesta concreta de corrección, pero sin implementarla.\
> \
> Debe indicar:\
> \- Qué archivo o función habría que modificar.\
> \- Qué comportamiento debe cambiar.\
> \- Por qué debería resolver la divergencia.\
> \- Qué riesgos introduce.\
> \- Qué pruebas de regresión deben ejecutarse.\
> \- Qué resultados permitirían aceptar la corrección.\
> \
> \### 7. \`PHASE3_SCENARIO3_DECISION.md\`\
> \
> Veredicto final GO, PARTIAL GO o NO-GO.\
> \
> Explica qué quedó demostrado y qué sigue pendiente.\
> \
> \---\
> \
> \# 11. CRITERIOS PARA EL VEREDICTO\
> \
> \*\*GO\*\*\
> \
> Solo si se identificó de manera reproducible la causa de la divergencia y existe una explicación técnica respaldada por evidencia.\
> \
> No significa que la corrección productiva ya esté aprobada.\
> \
> \*\*PARTIAL GO\*\*\
> \
> Si se redujo la lista de causas posibles, se identificó el plano o se consiguió aislar parte del problema, pero todavía no se conoce completamente el origen.\
> \
> \*\*NO-GO\*\*\
> \
> Si las pruebas son inconsistentes, las condiciones iniciales no coinciden, la identificación del contacto no es fiable o los resultados no permiten una conclusión.\
> \
> No fuerces un GO.\
> \
> \---\
> \
> \# 12. INFORME FINAL\
> \
> Al terminar, responde claramente:\
> \
> 1\. ¿Qué plano produjo el contacto?\
> 2\. ¿Ambos motores utilizaron exactamente la misma geometría?\
> 3\. ¿Qué diferencia hubo en la normal?\
> 4\. ¿Qué diferencia hubo en el cálculo de la respuesta normal?\
> 5\. ¿El \`bCoef\` explica la divergencia o no?\
> 6\. ¿El orden temporal explica la diferencia o no?\
> 7\. ¿Cuál es la causa más probable y qué evidencia la respalda?\
> 8\. ¿Qué falta para demostrarla?\
> 9\. ¿Cuál es la corrección recomendada?\
> 10\. ¿Se modificó algún archivo productivo?\
> 11\. ¿Se guardó o publicó el place?\
> 12\. ¿Qué pruebas se ejecutaron realmente y cuáles solo se analizaron?\
> \
> \*\*Prioridad absoluta: explicar correctamente el contacto del escenario 3 antes de tocar la física productiva.\*\*\
> \
> No avances a otras fases. No intentes cerrar la Fase 3 por calendario. La calibración dinámica permanece abierta hasta que exista evidencia suficiente.

<details><summary>4 previous messages</summary>

> Voy a hacer la auditoría en modo de solo lectura sobre Studio y las fuentes existentes, y prepararé harnesses temporales separados para las comparaciones. Mantendré Studio en Edit y no tocaré la física productiva; primero comprobaré las referencias y la disponibilidad real del entorno Node 2.3.0 antes de afirmar resultados de microprueba.
>
> <details><summary>Ran 5 commands</summary>
>
> - Ran `Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_FIRST_DIVERGENCE_REPORT.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_CONTACT_SOLVER_ANALYSIS.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_PLAYER_KICK_VALIDATION_PLAN.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_DYNAMIC_CALIBRATION_DECISION.md; Get-ChildItem referenced-chatgpt-conversation-this-is-an\work\node-haxball-source\node-haxball-4d4b88f1e5e25d484d27819ee6a4699720bda164 -Force | Select Mode,Length,Name`
> - Ran `rg --files referenced-chatgpt-conversation-this-is-an | rg 'classic\.hbs|node-haxball|SCENARIO|fixture|telemetry|install|oracle' | Select-Object -First 120; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\ORACLE_230_INSTALLATION.json; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\ORACLE_230_REPRODUCIBILITY.md; Get-Content referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_PARAMETER_EVIDENCE_MATRIX.json`
> - Ran `Get-ChildItem referenced-chatgpt-conversation-this-is-an\work -Force | Select Mode,Length,Name; Get-ChildItem referenced-chatgpt-conversation-this-is-an\outputs\hbr-extractor\results\analysis -Force | Select Mode,Length,Name; Get-Command node -ErrorAction SilentlyContinue | Select Source; Get-Command npm -ErrorAction SilentlyContinue | Select Source; Get-ChildItem referenced-chatgpt-conversation-this-is-an\outputs -Filter '*fixture*' -Recurse | Select FullName,Length`
> - Ran `$p='referenced-chatgpt-conversation-this-is-an/outputs/ORACLE_FULL_TICK_TELEMETRY.json'; $j=Get-Content $p -Raw | ConvertFrom-Json; $j.PSObject.Properties.Name; $j.scenarios[2] | ConvertTo-Json -Depth 6 | Select-Object -First 80; Get-Content referenced-chatgpt-conversation-this-is-an\work\node-haxball-source\node-haxball-4d4b88f1e5e25d484d27819ee6a4699720bda164\package.json | Select-Object -First 40; Get-Command node -ErrorAction SilentlyContinue`
> - Ran `$j=Get-Content referenced-chatgpt-conversation-this-is-an/outputs/ORACLE_FULL_TICK_TELEMETRY.json -Raw | ConvertFrom-Json; $s=$j.scenarios[2]; 'scenarioKeys=' + ($s.PSObject.Properties.Name -join ','); 'hbsKeys=' + ($s.stadiumHbs.PSObject.Properties.Name -join ','); 'planes=' + ($s.stadiumHbs.planes | ConvertTo-Json -Depth 4 -Compress); 'eventsTick4=' + (($s.events | Where-Object {$_.frameNumber -eq 4 -and $_.eventType -like '*Collision*'} | ConvertTo-Json -Depth 5 -Compress)); 'scenario3Tick4=' + ($s.ticks[3] | ConvertTo-Json -Depth 5 -Compress);`
>
> </details>
>
> Los datos sí permiten acotar la geometría: el contacto del tick 4 ocurre en `y=160`, justo donde una pelota de radio 10 toca el plano HBS de área superior situado en `y=170`. Pero el callback de Node informa `planeId=1`, que no coincide directamente con su índice aparente en el arreglo HBS; no lo voy a tratar como identidad probada. Además, aquí está la fuente fijada 2.3.1, no la instalación aislada 2.3.0 citada por los informes, y no encuentro el runtime/fixture ejecutable de esa instalación. Así que puedo cerrar una auditoría estática con evidencia existente, pero no presentar las pruebas A–F como ejecutadas.
>
> <details><summary>Ran 2 commands, called a tool</summary>
>
> - Ran ``$out='referenced-chatgpt-conversation-this-is-an/outputs'
> @'
> # Auditoría de planos Classic — escenario 3
>
> ## Estado y alcance
> Auditoría estática de las fuentes locales, los informes previos y la telemetría congelada. El fixture/oráculo Node-HaxBall 2.3.0 no está disponible como instalación ejecutable en esta sesión; la carpeta de fuente presente declara 2.3.1. Por ello no se repitieron A–F ni la reproducción 2.3.0. Studio fue leído en Edit; no se modificó.
>
> ## Contacto localizado geométricamente
> En el tick 4, el centro termina en (157.615960,160), radio 10. En `stadiumHbs.planes` del registro Classic aparecen seis planos: índices HBS cero-based 0..3 son perímetro exterior, y 4/5 el área de balón con normales (0,1)/(0,-1), dist=-170. El centro a y=160 satisface tangencia al plano superior (`n=(0,-1)`, distancia firmada `-160`, radio 10); la distancia al otro ball-area plane y=-170 es 330. **El candidato geométrico es inequívocamente el plano superior del área del balón.**
>
> El callback de Oracle reporta `onCollisionDiscVsPlane(..., planeId=1)` en frame 4. Otros eventos de la misma ejecución usan IDs distintos. No se localizó una tabla de mapeo que demuestre que `planeId` sea índice HBS, índice interno o ID del array. Por tanto el candidato geométrico no queda unido al `planeId` por identidad interna verificada.
>
> ## Definiciones contrastadas
> - HBS telemetría, planos: cuatro exteriores con bCoef=0; ball-area inferior `n=(0,1), dist=-170, cMask=ball`; superior `n=(0,-1), dist=-170, cMask=ball`. El bCoef de los dos planos ball-area está omitido, por tanto no debe inferirse como cero.
> - Perfil de Studio `ReplicatedStorage.HaxballLab.StadiumReference2D`: `classic:ballArea:top`, normal (0,-1), offset -170, bCoef 1, grupo 32, máscara 1. El ball-area bottom tiene el espejo geométrico. Los cuatro exteriores usan 0.1, distinto del HBS (0).
> - `ClassicStadium2D.install` crea geometría a partir del perfil; `LabServer.makeCoreState` instala postes y geometría y desactiva bounds simplificados.
> - Core resuelve plano por `signed=x*nX+y*nY-offset`, `penetration=radius-signed`, corrige `p += n*penetration`; si `v·n<0`, suma `n * (-(1+disc.bCoef*plane.bCoef)*(v·n))`.
>
> Geometría/orientación del candidato coincide en coordenadas lógicas, normal y constante. La igualdad de filtros/propiedades efectivas dentro del motor Node y la causa de su `planeId` siguen sin probarse.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_PLANE_AUDIT.md')
> @'
> {
>   "status":"PARTIAL_TRACE_FROM_EXISTING_CAPTURE",
>   "source":"ORACLE_FULL_TICK_TELEMETRY.json scenarioIndex=3 and PHASE3_MICROBENCHMARK_RESULTS.json",
>   "officialClientCertification":false,
>   "oracleReexecutionThisSession":false,
>   "tick":4,
>   "timeSeconds":0.06666666666666667,
>   "stateBeforeTick4":{
>     "ball":{"x":118.804,"y":148.505,"vx":38.81196,"vy":48.51495,"radius":10,"invMass":1,"damping":0.99,"bCoef":0.5},
>     "logicalTickStartSeconds":0.05,
>     "playersInterference":"None geometrically; all captured players are distant and stationary"
>   },
>   "geometryCandidate":{
>     "hbsPlaneIndexZeroBased":5,
>     "name":"ball-area top inferred from geometry; internal plane ID mapping unverified",
>     "normal":{"x":0,"y":-1},"dist":-170,"tangentCenterY":160,
>     "oracleCallbackPlaneId":1,"planeIdMapping":"UNKNOWN"
>   },
>   "oracleAfterTick4":{"x":157.61596,"y":160,"vx":38.4238404,"vy":0},
>   "physicsCoreAfterTick4":{"x":157.61596,"y":143.206363,"vx":38.4238404,"vy":-24.01490025},
>   "corePrecontactState":"not separately captured in the supplied per-tick diff; do not infer identical within-tick impact state beyond shared tick-3 end state",
>   "coreResolutionFormula":"v_n<0: v += n * (-(1 + disc.bCoef*plane.bCoef)*v_n); then later substeps continue; damping occurs after substeps",
>   "oracleResolutionInternals":"not exposed by public collision callback; reconstructed Node/Nago source pass described in PHASE3_CONTACT_SOLVER_ANALYSIS.md",
>   "missing":"oracle normal/penetration/impulse; exact selected internal plane; contact substep timing; isolated matched pre-contact state; independently captured post-resolution pre-tick-end state"
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_CONTACT_TRACE.json')
> @'
> {
>  "status":"NOT_RUN_IN_THIS_SESSION",
>  "reason":"Node-HaxBall 2.3.0 isolated executable installation and runnable fixture are not present in this workspace; the only checked-in source package is 2.3.1. No A-F outcomes are claimed.",
>  "cases":{
>   "A_perpendicular":{"status":"NOT_RUN","reason":"requires matched isolated harness in both engines"},
>   "B_oblique":{"status":"NOT_RUN"},
>   "C_velocity_sweep":{"status":"NOT_RUN"},
>   "D_initial_distance_sweep":{"status":"NOT_RUN"},
>   "E_bcoef_restitution_damping_ab":{"status":"NOT_RUN"},
>   "F_opposite_side":{"status":"NOT_RUN","reason":"HBS one-sided plane semantics need confirmation before interpreting reverse-side collision"}
>  },
>  "existing_scenario3_observation":{"tick":4,"oracle":{"x":157.61596,"y":160,"vx":38.4238404,"vy":0},"core":{"x":157.61596,"y":143.206363,"vx":38.4238404,"vy":-24.01490025},"priorDeterminismEvidence":"two byte-identical runs recorded in ORACLE_230_REPRODUCIBILITY.md; not repeated here"},
>  "controlledConditions":"No A-F result exists. Prior scenario is multi-player stadium fixture, but prior controls found the same ball path with 0/2/6 players.",
>  "units":"Haxball logical stadium units; logical tick 1/60 s"
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_MICROBENCHMARKS.json')
> @'
> # Forense del solver — escenario 3
>
> ## Secuencia de Core inspeccionada en Studio
> 1. `stepWorld` aplica input/kick.
> 2. Elige subpasos adaptativos por velocidad y radio.
> 3. Cada subpaso avanza posición por v/N; por disco y en orden, resuelve pares dinámicos, planos y segmentos inmediatamente. En el plano proyecta penetración y refleja la componente normal entrante con `1 + disc.bCoef*geometry.bCoef`.
> 4. Completa los subpasos restantes usando la velocidad ya cambiada.
> 5. Aplica gravedad/damping una vez al final del tick.
>
> ## Secuencia Node/Nago documentada anteriormente
> 1. Avanza posición una vez con velocidad previa; amortigua velocidad/gravedad.
> 2. Recorre discos secuencialmente y resuelve contactos de pares.
> 3. Por disco, recorre planos, corrige posición y actualiza inmediatamente componente normal si es entrante; sigue segmentos/vértices y dos pasadas de juntas.
> 4. Callback de plano es público pero no expone normal, penetración ni impulso.
>
> ## Evidencia versus interpretación
> **Observado en la telemetría congelada:** tick 4 empieza tras vuelo libre equivalente hasta tick 3; radio 10; contacto geométrico en y=160; Node acaba con vy=0; Core acaba con vy≈-24.0149 y y≈143.2064. El callback Node da planeId=1.
>
> **Código inspeccionado:** perfil Core del ball-area top: n=(0,-1), offset=-170, bCoef=1; pelota bCoef=0.5. Entrando con velocidad normal negativa en la convención de Core, la fórmula multiplica la inversión por 1+0.5*1=1.5; la salida reportada por Core es coherente con ese coeficiente y subpasos. La telemetría inicial Node declara pelota con los mismos radius, damping y bCoef. El HBS omite bCoef de los planos ball-area.
>
> **Inferencias:** por coordenadas y radio, el plano geométrico candidato es el ball-area top. La diferencia del tick puede involucrar selección/propiedad efectiva del plano o cronología del solver; con datos de final de tick no se separan.
>
> **No demostrado:** que callback planeId=1 sea índice HBS 5; que Node tenga bCoef efectivo 0 en dicho plano; que cambiar bCoef replique vy=0; que normal o filtro de colisión difieran; el estado justo antes de impacto dentro de cada paso.
>
> ## Prueba discriminante pendiente
> Instrumentar un solo balón y un solo plano en copias temporales de ambas implementaciones; registrar pre/post resolución. Primero igualar n, offset, radio, bCoef efectivo, damping, tick y estado de entrada. Luego variar solo bCoef, después solo calendario de integración/corrección. No tocar producción.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_SOLVER_FORENSICS.md')
> @'
> {
>  "schemaVersion":1,
>  "candidates":[
>   {"cause":"contact geometry is the Classic ball-area top at y=170, center tangent y=160","status":"STRONGLY_SUPPORTED","evidence":"HBS plane n=(0,-1), dist=-170; radius 10; Oracle tick4 center y=160; other top/bottom plane is far away","test":"static geometric correspondence from supplied telemetry","remaining":"internal Node planeId mapping not proven"},
>   {"cause":"Node callback planeId=1 directly identifies HBS plane array entry","status":"UNKNOWN","evidence":"callback ID is 1; no mapping table found; HBS candidate zero-based index 5","test":"none","remaining":"inspect version-specific ID allocator/callback arguments and instrument mapping"},
>   {"cause":"same geometric normal/offset used by both engines","status":"STRONGLY_SUPPORTED","evidence":"HBS and Studio profile candidate both n=(0,-1), offset/dist=-170 in logical coordinates","test":"source/telemetry comparison","remaining":"effective converted Node structure not captured at callback"},
>   {"cause":"different effective bCoef explains vy=0","status":"POSSIBLE","evidence":"Core uses ball 0.5 * plane 1 and outputs reflected normal velocity; HBS ball-area plane omits bCoef; Node public capture does not expose effective plane bCoef","test":"none isolated","remaining":"do not assign omitted HBS field a default without source proof"},
>   {"cause":"active-profile outer-plane bCoef mismatch explains first tick4 contact","status":"REJECTED","evidence":"first contact geometrically at y=160 on ball-area top, not outer y=200; outer mismatch 0.1 vs HBS 0 is real but not this first surface","test":"geometric bounds check"},
>   {"cause":"different solver chronology contributes to scenario3 difference","status":"POSSIBLE","evidence":"source audit shows one-pass Nago versus adaptive Core substeps; may affect within-tick contact state","test":"source comparison only","remaining":"isolated same-state benchmark"},
>   {"cause":"different normal orientation causes observed response","status":"REJECTED_FOR_CANDIDATE_GEOMETRY","evidence":"both candidate HBS and Core normals are (0,-1)","test":"definition comparison","remaining":"verify Node conversion/selected plane"},
>   {"cause":"player collision/interference","status":"REJECTED","evidence":"prior controls report same ball path with 0,2,6 players; tick4 players are distant" ,"test":"prior recorded controls"},
>   {"cause":"official Haxball client behavior established","status":"UNKNOWN","evidence":"oracle is independent Node-HaxBall reconstruction","test":"none"}
>  ]
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_CAUSE_ISOLATION_MATRIX.json')
> @'
> # Plan de implementación siguiente — no aplicar todavía
>
> 1. Recuperar la instalación aislada 2.3.0 previamente verificada y sus scripts/fixture (sin reinstalar ni cambiar versión). Confirmar hashes y dos ejecuciones deterministas.
> 2. Inspeccionar `N.prototype.E$` y la ruta de `onCollisionDiscVsPlane` de esa distribución para encontrar cómo se asigna `planeId`, y documentar conversión HBS→planos runtime. No adivinar por el entero del callback.
> 3. Crear harness desechable, sin place productivo: un disco balón, un único plano ball-area top, bounds apagados y estados equivalentes al estado inmediatamente anterior al contacto. Registrar normal/distancia/bCoef convertidos, tick/subpaso, velocidad normal antes/después y desplazamiento.
> 4. Ejecutar A perpendicular y B oblicua; C velocidad y D distancia; E barridos de un solo parámetro (primero bCoef efectivo y luego cronología); F lado opuesto solo tras verificar semántica unilateral. Repetir cada caso y guardar JSON crudo.
> 5. Solo si un A/B reproduce vy=0 al cambiar una variable aislada, proponer corrección en copia. No cambiar ahora `PhysicsCore2D`, `Physics2D.Config` ni `StadiumReference2D`.
>
> ## Posible ubicación de cambio futuro
> - Si se confirma propiedad/configuración del plano: `ReplicatedStorage.HaxballLab.StadiumReference2D` en el registro `classic:ballArea:top` o su conversor `ClassicStadium2D`; el valor debe provenir de la conversión verificada, no del ajuste de RMS.
> - Si se confirma cronología/solver: `ServerScriptService.HaxballLab.PhysicsCore2D` en `stepWorld`/`resolveStaticGeometryForDisc`; implementar únicamente la diferencia de orden respaldada por el microcaso.
>
> ## Riesgos y aceptación
> Riesgo de cambiar trayectoria global, goles, contactos persistentes y estabilidad 5v5. Requerir escenario 3 aislado, A–F deterministas, escenarios 1/2 conservados, regresiones existentes, y explicación de cada estado poscontacto. Aceptar solo si la variable causal es única, reproduce la salida en ambos motores y mantiene regresiones definidas; RMS por sí solo no es criterio.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_NEXT_IMPLEMENTATION_PLAN.md')
> @'
> # Decisión — aislamiento del escenario 3
>
> ## Veredicto: PARTIAL GO
>
> Se identifica con fuerte apoyo geométrico el plano candidato: el plano superior del área de balón Classic, n=(0,-1), dist=-170; una pelota de radio 10 toca con centro y=160. La definición visible de Studio coincide en normal y offset. El contacto no corresponde a los planos exteriores cuyo bCoef activo difiere del HBS.
>
> La causa exacta no está cerrada: el callback Node `planeId=1` no está mapeado a la entrada HBS; la respuesta normal interna de Node no es expuesta por el callback; el bCoef del plano ball-area está omitido en el HBS capturado. No se ejecutaron micropruebas A–F ni se repitió la instalación 2.3.0 en esta sesión. Los datos deterministas anteriores siguen siendo evidencia histórica, no una reproducción nueva.
>
> Escenarios 1/2 conservan la hipótesis documentada de cronología distinta: velocidades tras plano casi iguales, pero posiciones de fin de tick distintas, consistente con subpasos Core y corrección secuencial Node. Falta un contacto aislado para confirmar esa explicación; no se combina con la causa del escenario 3.
>
> No se modificó ningún archivo productivo ni propiedad de Studio. Studio sigue en Edit; place no guardado ni publicado. Los archivos de auditoría de esta entrega son diagnóstico y no alteran el juego.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_DECISION.md')
> Get-ChildItem $out -Filter 'PHASE3_SCENARIO3_*' | Select-Object Name,Length; Get-ChildItem $out -Filter 'PHASE3_CAUSE_ISOLATION_MATRIX.json'; Get-ChildItem $out -Filter 'PHASE3_NEXT_IMPLEMENTATION_PLAN.md'``
>
> - Ran `$files=@('PHASE3_SCENARIO3_CONTACT_TRACE.json','PHASE3_SCENARIO3_MICROBENCHMARKS.json','PHASE3_CAUSE_ISOLATION_MATRIX.json'); foreach($f in $files){Get-Content (Join-Path 'referenced-chatgpt-conversation-this-is-an/outputs' $f) -Raw | ConvertFrom-Json | Out-Null; "VALID $f"}; Get-FileHash referenced-chatgpt-conversation-this-is-an\outputs\PHASE3_SCENARIO3_CONTACT_TRACE.json -Algorithm SHA256 | Select-Object Hash,Path`
>
> MCP tool call
>
> Roblox_Studio.get_studio_state
>
> ```json
> {
>   "studio_id": "3e731d6a-4da2-40c5-a4e1-74d65208d2b0"
> }
> ```
>
> ```text
> - Current Studio Mode: Edit
> - Available DataModels: Edit
> - Focused DataModel in the viewport: Edit
> ```
>
> </details>
</details>

**Veredicto: PARTIAL GO.** Localicé con fuerte apoyo geométrico el plano candidato del escenario 3: el plano superior del área de balón Classic, con normal `(0, -1)` y posición `y=170`. Una pelota de radio 10 lo toca cuando su centro llega a `y=160`. La definición de Studio coincide en geometría y normal.

Aún no puedo afirmar que encontré la causa exacta. El `planeId=1` del callback Node no está mapeado de forma verificable a la entrada HBS, y el HBS capturado omite el `bCoef` de los planos del área de balón. Los planos exteriores sí tienen una diferencia de `bCoef` frente al perfil activo, pero no son la superficie del primer contacto del escenario 3.

Dejé los siete entregables en `outputs`:

- [Auditoría de planos](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_PLANE_AUDIT.md>)
- [Traza de contacto](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_CONTACT_TRACE.json>)
- [Microbenchmarks A–F](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_MICROBENCHMARKS.json>)
- [Análisis del solver](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_SOLVER_FORENSICS.md>)
- [Matriz de causas](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_CAUSE_ISOLATION_MATRIX.json>)
- [Plan de implementación futura](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NEXT_IMPLEMENTATION_PLAN.md>)
- [Decisión de Fase 3](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_DECISION.md>)

Las pruebas A–F **no se ejecutaron**: en el entorno disponible encontré la fuente Node-HaxBall 2.3.1, pero no la instalación ejecutable 2.3.0 ni su harness. El JSON de microbenchmarks deja esa limitación explícita; los resultados 2.3.0 anteriores se conservan como evidencia histórica, no como una repetición de esta sesión. Validé la estructura de los tres JSON nuevos.

No cambié archivos ni parámetros productivos. Roblox Studio sigue en Edit; el lugar no se guardó ni publicó.

> \# HAXBALL LAB — FASE 3: RECUPERACIÓN DEL ENTORNO NODE-HAXBALL 2.3.0 Y EJECUCIÓN EXPERIMENTAL\
> \
> \## OBJETIVO\
> \
> Continuar la investigación del escenario 3 sin repetir trabajos anteriores ni asumir que el contexto compartido está completo.\
> \
> La tarea inmediata es recuperar el entorno ejecutable de Node-HaxBall 2.3.0 que ya se instaló y verificó en una sesión anterior.\
> \
> Después, si se recupera correctamente, ejecutar las micropruebas A-F que quedaron pendientes.\
> \
> No modificar la física productiva.\
> \
> \---\
> \
> \## 1. CONTEXTO QUE DEBES RECUPERAR\
> \
> La investigación anterior consiguió:\
> \
> \- Instalar Node-HaxBall 2.3.0 de forma aislada.\
> \- Ejecutarlo y verificar su versión desde el propio proceso.\
> \- Reproducir el fixture dos veces byte por byte.\
> \- Confirmar el SHA-256 del fixture:\
> \
> \`7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37\`\
> \
> \- Capturar 540/540 ticks, 180 por escenario.\
> \- Registrar discos de jugadores, propiedades y eventos disponibles.\
> \
> La última investigación identificó geométricamente el plano candidato del escenario 3:\
> \
> \- Plano superior del área de balón Classic.\
> \- Normal \`(0, -1)\`.\
> \- Posición \`y=170\`.\
> \- Radio de pelota \`10\`.\
> \- Contacto esperado cuando el centro llega a \`y=160\`.\
> \
> La geometría de Studio coincide.\
> \
> Sin embargo:\
> \
> \- No se pudo mapear de forma verificable el \`planeId=1\` de Node al plano HBS.\
> \- El HBS capturado omite el \`bCoef\` de los planos del área de balón.\
> \- Las pruebas A-F no se ejecutaron.\
> \- En el entorno actual se encontró fuente Node-HaxBall 2.3.1, pero no el ejecutable 2.3.0 ni su harness.\
> \
> \## 2. AUDITORÍA DE RECUPERACIÓN\
> \
> Antes de instalar nada nuevo, busca el entorno que se utilizó anteriormente.\
> \
> Inspecciona:\
> \
> \- Archivos y carpetas del proyecto de diagnóstico.\
> \- Carpetas \`node_modules\`.\
> \- Instalaciones aisladas de Node-HaxBall.\
> \- Archivos \`package.json\`.\
> \- \`package-lock.json\`.\
> \- Caché local de npm.\
> \- Scripts de ejecución anteriores.\
> \- Harness de captura.\
> \- Directorios temporales y outputs previos.\
> \
> Busca específicamente los entregables:\
> \
> \- \`ORACLE_ENVIRONMENT_AUDIT.md\`\
> \- \`ORACLE_230_INSTALLATION.json\`\
> \- \`ORACLE_230_REPRODUCIBILITY.md\`\
> \- \`ORACLE_230_REPRODUCIBILITY.json\`\
> \- \`ORACLE_FULL_TICK_TELEMETRY.json\`\
> \- \`ORACLE_ANOMALY_ROOT_CAUSE.md\`\
> \- \`CLASSIC_ENTITY_COMPARISON.json\`\
> \
> Usa esos documentos para reconstruir la ruta de instalación, los comandos, la versión, las dependencias y el procedimiento de ejecución.\
> \
> No supongas que los archivos están en el directorio de trabajo actual.\
> \
> Si el contexto compartido no cargó información, reconstruye lo necesario inspeccionando los archivos reales.\
> \
> No afirmes que recuperaste una instalación hasta ejecutarla.\
> \
> \## 3. VERIFICACIÓN OBLIGATORIA DE VERSIÓN\
> \
> La única referencia permitida para estas pruebas es Node-HaxBall 2.3.0.\
> \
> Verifica:\
> \
> 1\. Versión declarada por el paquete.\
> 2\. Versión reportada desde el proceso ejecutable.\
> 3\. Ruta real del módulo cargado.\
> 4\. Dependencias utilizadas.\
> 5\. Integridad del paquete o evidencia de procedencia disponible.\
> \
> No uses Node-HaxBall 2.3.1 como sustituto.\
> \
> Si solo encuentras 2.3.1, no lo utilices para generar resultados equivalentes a 2.3.0.\
> \
> Si el entorno anterior no puede recuperarse, investiga si es posible instalar exactamente 2.3.0 mediante su versión fijada y dependencias reproducibles.\
> \
> No cambies de versión ni inventes equivalencias.\
> \
> \## 4. REPRODUCIBILIDAD\
> \
> Una vez recuperado el entorno:\
> \
> \- Ejecuta el harness anterior.\
> \- Reproduce el fixture dos veces.\
> \- Compara ambas salidas byte por byte.\
> \- Verifica nuevamente el SHA-256 esperado.\
> \- Confirma 540/540 ticks.\
> \- Verifica que no existan saltos ni duplicados.\
> \
> Si falla cualquiera de estas condiciones, detén las pruebas físicas.\
> \
> No utilices una ejecución no reproducible como base para calibrar.\
> \
> \## 5. EJECUCIÓN DE MICROPRUEBAS A-F\
> \
> Si la recuperación y la reproducibilidad son satisfactorias, ejecuta las pruebas aisladas que quedaron pendientes:\
> \
> A. Contacto perpendicular.\
> \
> B. Contacto oblicuo.\
> \
> C. Variación de velocidad inicial.\
> \
> D. Variación de distancia inicial al plano.\
> \
> E. Variación aislada de \`bCoef\` y restitución.\
> \
> F. Contacto desde el lado opuesto, cuando corresponda a la geometría y las reglas.\
> \
> Todas las pruebas deben comparar Node-HaxBall 2.3.0 y PhysicsCore2D usando condiciones iniciales idénticas.\
> \
> Registra:\
> \
> \- Posición inicial.\
> \- Velocidad inicial.\
> \- Radio.\
> \- Geometría.\
> \- Normal.\
> \- Distancia al plano.\
> \- Penetración.\
> \- \`bCoef\` utilizado, cuando esté disponible.\
> \- Velocidad antes del contacto.\
> \- Velocidad después del contacto.\
> \- Corrección posicional.\
> \- Posición final.\
> \- Diferencia entre motores.\
> \
> Cambia una sola variable por prueba.\
> \
> No mezcles cambios de geometría con cambios de restitución.\
> \
> Si alguna propiedad interna de Node-HaxBall no puede establecerse o inspeccionarse, documenta esa limitación. No inventes su valor.\
> \
> \## 6. CORRESPONDENCIA DEL PLANO\
> \
> Aprovecha el entorno recuperado para investigar el mapeo de \`planeId=1\`.\
> \
> Determina si es posible relacionar el identificador del callback con:\
> \
> \- La estructura interna del plano.\
> \- La entrada correspondiente del estadio.\
> \- El plano superior del área de balón Classic.\
> \
> No asumas que el índice del callback coincide con el índice HBS.\
> \
> Si el mapeo no puede demostrarse mediante código o instrumentación, continúa marcándolo como desconocido.\
> \
> \## 7. ENTREGABLES\
> \
> Genera:\
> \
> 1\. \`PHASE3_ORACLE_ENVIRONMENT_RECOVERY.md\`\
> &#x20;  \- Rutas encontradas.\
> &#x20;  \- Versión real.\
> &#x20;  \- Procedimiento de ejecución.\
> &#x20;  \- Estado de recuperación.\
> \
> 2\. \`PHASE3_ORACLE_230_REPRODUCIBILITY.json\`\
> &#x20;  \- Versiones.\
> &#x20;  \- Hashes.\
> &#x20;  \- Resultados de las dos ejecuciones.\
> &#x20;  \- Validación de ticks.\
> \
> 3\. \`PHASE3_PLANE_ID_MAPPING.md\`\
> &#x20;  \- Investigación de \`planeId=1\`.\
> &#x20;  \- Evidencia del mapeo o explicación de por qué sigue desconocido.\
> \
> 4\. \`PHASE3_SCENARIO3_MICROBENCHMARKS_EXECUTED.json\`\
> &#x20;  \- Resultados reales de A-F.\
> &#x20;  \- Condiciones iniciales.\
> &#x20;  \- Estados de ambos motores.\
> &#x20;  \- Errores medidos.\
> &#x20;  \- Pruebas que no se pudieron completar.\
> \
> 5\. \`PHASE3_SCENARIO3_CAUSE_UPDATE.md\`\
> &#x20;  \- Qué hipótesis se fortalecieron.\
> &#x20;  \- Qué hipótesis se descartaron.\
> &#x20;  \- Qué permanece desconocido.\
> &#x20;  \- Próxima prueba necesaria.\
> \
> \## 8. RESTRICCIONES\
> \
> \- No modificar \`PhysicsCore2D\` productivo.\
> \- No modificar parámetros físicos activos.\
> \- No modificar el solver productivo.\
> \- No cambiar la versión de referencia por 2.3.1.\
> \- No alterar el estadio productivo.\
> \- No guardar ni publicar el place.\
> \- Mantener Studio en Edit.\
> \- No avanzar a Fase 4 o Fase 5.\
> \- No implementar el modo Fútbol avanzado.\
> \- No subir ni compartir telemetría privada.\
> \- No afirmar que una prueba se ejecutó si solamente se analizó el código.\
> \- No presentar resultados históricos como si fueran ejecutados nuevamente.\
> \
> \## 9. INFORME FINAL\
> \
> Responde:\
> \
> 1\. ¿Se recuperó Node-HaxBall 2.3.0?\
> 2\. ¿Desde qué ruta se ejecutó?\
> 3\. ¿Se reprodujo el fixture dos veces?\
> 4\. ¿Los hashes coincidieron?\
> 5\. ¿Se ejecutaron realmente las pruebas A-F?\
> 6\. ¿Se pudo mapear \`planeId=1\`?\
> 7\. ¿Qué resultados experimentales se obtuvieron?\
> 8\. ¿Qué hipótesis tienen ahora más respaldo?\
> 9\. ¿Qué sigue sin demostrarse?\
> 10\. ¿Se modificó algún archivo productivo?\
> 11\. ¿Se guardó o publicó Studio?\
> \
> Veredicto: GO, PARTIAL GO o NO-GO.\
> \
> No fuerces un GO por haber recuperado el entorno. Recuperar el entorno es un requisito para investigar, no una solución física.

<details><summary>2 previous messages</summary>

> Voy a buscar primero la instalación y los scripts previos en las ubicaciones del proyecto, temporales y cachés, usando los manifiestos como guía. Solo si encuentro o reconstruyo una instalación verificable de 2.3.0 ejecutaré el replay; si no, dejaré A–F sin correr. Mantendré Studio en Edit y la física activa intacta.
>
> <details><summary>Ran 9 commands</summary>
>
> - Ran `$root='C:\Users\User\Documents\Codex\2026-11-17'; $candidates=@($root,'C:\Users\User\AppData\Local\Temp','C:\Users\User\AppData\Roaming\npm-cache','C:\Users\User\.npm','C:\Users\User\.cache'); foreach($p in $candidates){if(Test-Path -LiteralPath $p){"## $p"; rg --files $p -g package.json -g package-lock.json -g '*oracle*' -g '*harness*' -g '*replay*' -g 'node.exe' -g 'npm.cmd' 2>$null | Select-Object -First 120}}; Get-Content $root\referenced-chatgpt-conversation-this-is-an\outputs\ORACLE_ENVIRONMENT_AUDIT.md; Get-Content $root\referenced-chatgpt-conversation-this-is-an\outputs\ORACLE_230_INSTALLATION.json; Get-Content $root\referenced-chatgpt-conversation-this-is-an\outputs\ORACLE_230_REPRODUCIBILITY.json`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; Get-ChildItem $root -Force | Select Mode,Length,Name; rg --files $root | Select-Object -First 80;`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; Get-Content (Join-Path $root 'oracle-install\run-oracle-twice.mjs'); Get-ChildItem (Join-Path $root 'oracle-install') -Force | Select Mode,Length,Name; Get-ChildItem (Join-Path $root 'oracle-install') -Directory -Filter node_modules | Select FullName`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; & $node (Join-Path $root 'oracle-install\run-oracle-twice.mjs'); $pkg=Get-Content (Join-Path $root 'oracle-install\node_modules\node-haxball\package.json') -Raw | ConvertFrom-Json; "declaredPackageVersion=$($pkg.version)"; $script="console.log(JSON.stringify({node:process.version,package:require('node-haxball/package.json').version,module:require.resolve('node-haxball')}))"; & $node -e $script;`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const p=require.resolve('node-haxball');const nh=require('node-haxball');console.log(JSON.stringify({node:process.version,module:p,exportType:typeof nh,packageVersion:require('./node_modules/node-haxball/package.json').version}))"; Get-FileHash (Join-Path $root 'oracle-install\package-lock.json') -Algorithm SHA256 | Select-Object Hash; Get-Content (Join-Path $root 'oracle-install\inspect-state.cjs') | Select-Object -First 45`
> - Ran `rg -n 'planeId|onCollisionDiscVsPlane|E\$=' node_modules/node-haxball/src/api.js | Select-Object -First 25; Get-Content nh_oracle.js;`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\oracle-install'; $a=Get-Content (Join-Path $root 'oracle-run1.json') -Raw | ConvertFrom-Json; $b=Get-Content (Join-Path $root 'oracle-run2.json') -Raw | ConvertFrom-Json; $classic=@($a | Where-Object {$_.stadium -eq 'classic'}); $ticks=($classic | ForEach-Object {$_.ball_traj.Count} | Measure-Object -Sum).Sum; "classicScenarios=$($classic.Count) ticksPerScenario=$((($classic|ForEach-Object {$_.ball_traj.Count}) -join ',')) total=$ticks"; "fixtureFileHash="+(Get-FileHash (Join-Path $root 'oracle-run1.json') -Algorithm SHA256).Hash; "scenarioOutputArraysIdentical="(($a | ConvertTo-Json -Depth 8 -Compress) -ceq ($b | ConvertTo-Json -Depth 8 -Compress));`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\oracle-install'; $a=Get-Content (Join-Path $root 'oracle-run1.json') -Raw | ConvertFrom-Json; $b=Get-Content (Join-Path $root 'oracle-run2.json') -Raw | ConvertFrom-Json; $classic=@($a | Where-Object {$_.stadium -eq 'classic'}); $counts=@($classic | ForEach-Object {$_.ball_traj.Count}); $ticks=($counts | Measure-Object -Sum).Sum; "classicScenarios=$($classic.Count) counts=$($counts -join ',') total=$ticks"; "scenarioDataEqual=$([string]::Equals((ConvertTo-Json -InputObject $a -Depth 8 -Compress),(ConvertTo-Json -InputObject $b -Depth 8 -Compress)))"`
> - Ran ``$out='referenced-chatgpt-conversation-this-is-an/outputs'
> @'
> # Recuperación del entorno Oracle
>
> Estado: **RECUPERADO Y EJECUTADO** desde `C:\Users\User\AppData\Local\Temp\codex-haxball-oracle-230-20261118`.
>
> Ejecutable portable: `portable-node\node-v24.22.3-win-x64\node.exe` (Node v24.22.3; npm portable 11.19.1). Aislado: `oracle-install\node_modules\node-haxball`; `require.resolve` desde ese directorio resolvió `node_modules\node-haxball\src\index.js`. `package.json` declara 2.3.0; el proceso produjo salida con el harness `nh_oracle.js` en el cwd aislado. Lockfile SHA-256 `25a0592f990abf94340600078074f32b2ff6fd95b1794a7b3ec939f2a95288f3`. SRI y tarball previos: `sha512-fSxZFWuDSckKK1JBKVRATXcnXR5lZV4ae3Jf6yr+FxxKE86Yore/xidVR1Sq+ZgrERtHSe0rtcgWo3uauJKlgw==`; tarball SHA-256 `d37c62e81f3f3c932eb5bb3b760e7d1e39347c686a4d9212c2f30633fc3183d9` (registro previo). Dependencias se resolvieron desde el node_modules aislado con el lockfile referido en ORACLE_230_INSTALLATION.json.
>
> Se ejecutó `run-oracle-twice.mjs`, que lanza `nh_oracle.js` dos veces. Ambas terminaron exit code 0, generaron 38,693 bytes, igualaron byte por byte, SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`. Cada salida tiene 3 Classic × 180 ticks = 540. La telemetría histórica verificada aporta los callbacks por tick 1..180, 0 faltantes/duplicados; no se regeneró la telemetría instrumentada en esta recuperación. No sustituí por 2.3.1.
>
> La ejecución simple volvió a reproducir el fixture de trayectorias. Las pruebas A–F requieren el instrumentador extendido de ambos motores; el runner encontrado es el harness básico de trayectorias y no mide estado instantáneo del solver. Se detuvo la experimentación antes de producir datos físicos no comparables.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_ORACLE_ENVIRONMENT_RECOVERY.md')
> @'
> {
>  "status":"RECOVERED_AND_RERUN",
>  "node":{"version":"v24.22.3","path":"%TEMP%\\codex-haxball-oracle-230-20261118\\portable-node\\node-v24.22.3-win-x64\\node.exe"},
>  "npm":"11.19.1 portable",
>  "package":{"name":"node-haxball","declaredVersion":"2.3.0","moduleResolvedFrom":"%TEMP%\\codex-haxball-oracle-230-20261118\\oracle-install\\node_modules\\node-haxball\\src\\index.js","tarballSha256PreviouslyVerified":"d37c62e81f3f3c932eb5bb3b760e7d1e39347c686a4d9212c2f30633fc3183d9","integrity":"sha512-fSxZFWuDSckKK1JBKVRATXcnXR5lZV4ae3Jf6yr+FxxKE86Yore/xidVR1Sq+ZgrERtHSe0rtcgWo3uauJKlgw==","lockfileSha256":"25a0592f990abf94340600078074f32b2ff6fd95b1794a7b3ec939f2a95288f3"},
>  "harness":"oracle-install/run-oracle-twice.mjs -> nh_oracle.js",
>  "runs":[{"exitCode":0,"bytes":38693,"sha256":"7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37"},{"exitCode":0,"bytes":38693,"sha256":"7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37"}],
>  "byteIdentical":true,
>  "classicScenarioTicks":[180,180,180],"classicTicksTotal":540,
>  "telemetryContinuity":"Existing verified instrumented capture has frames 1..180 per scenario, 0 missing and 0 duplicate; full telemetry was not regenerated in this rerun.",
>  "testsAF":"NOT_RUN; basic runner does not expose matched instant solver states for PhysicsCore2D",
>  "officialClientCertification":false
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_ORACLE_230_REPRODUCIBILITY.json')
> @'
> # Mapeo de planeId=1
>
> ## Resultado: sigue UNKNOWN
>
> La captura reproducida usa Node-HaxBall 2.3.0 y registra frame 4 callback `onCollisionDiscVsPlane(..., planeId=1)`. La reconstrucción geométrica localiza el contacto en el plano superior ball-area: HBS `normal=(0,-1), dist=-170`, radio 10, centro y=160. Esa es evidencia del plano espacial que produjo la colisión, pero no demuestra qué representa el entero `planeId`.
>
> El código de API empaquetado está minificado en `node_modules/node-haxball/src/api.js`. El runner básico no expone el objeto plano ni normal/profundidad del callback. En esta sesión no quedó establecida una asignación verificable entre el entero y la estructura compilada del estadio. No equiparar planeId con el índice HBS (HBS cero-based candidato 5) ni con orden de geometría sin seguir el constructor y callback interno con una sonda.
>
> Siguiente paso: en una copia temporal, instrumentar el constructor HBS→runtime y wrapper del callback para registrar identidad/posición del plano entregado. Si la estructura no conserva identidad, asignar IDs observacionales al recorrer el array runtime y validar contra una prueba de un solo plano. No cambiar estadio productivo.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_PLANE_ID_MAPPING.md')
> @'
> {
>  "status":"A_F_NOT_EXECUTED",
>  "oracle230Recovery":"SUCCESS; 2 runs byte-identical and expected fixture hash verified",
>  "reason":"Recovered nh_oracle.js is a trajectory replay harness. It does not construct matched one-plane cases or capture resolution-stage states in both Node-HaxBall and live PhysicsCore2D. A valid cross-engine benchmark needs a temporary Node harness plus in-memory Studio Core harness and synchronized conditions; no such pair was available in this recovery pass.",
>  "cases":{
>   "A_perpendicular":{"status":"NOT_RUN"},"B_oblique":{"status":"NOT_RUN"},"C_velocity_sweep":{"status":"NOT_RUN"},"D_distance_sweep":{"status":"NOT_RUN"},"E_bcoef_restitution":{"status":"NOT_RUN"},"F_opposite_side":{"status":"NOT_RUN"}},
>  "recoveredReplay":{"ticks":[180,180,180],"total":540,"runsByteIdentical":true,"sha256":"7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37"},
>  "noPhysicalMeasurementsFabricated":true
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_MICROBENCHMARKS_EXECUTED.json')
> @'
> # Actualización causal del escenario 3
>
> ## Reforzado
> - La recuperación real del runtime 2.3.0 permitió repetir el harness básico. Dos salidas idénticas, SHA esperado correcto, 3 Classic ×180 ticks.
> - La localización geométrica en el ball-area top queda fuertemente respaldada: el centro y=160 corresponde a tangencia de radio 10 con la superficie y=170.
> - La diferencia de respuesta de velocidad registrada en tick 4 persiste como observación histórica; el rerun básico de trayectoria no añade estados internos del solver.
>
> ## Descartado o no relacionado
> - La discrepancia de bCoef de los planos exteriores no es el primer contacto, que ocurre en el límite interior de área de balón.
> - No hay indicio de que jugadores causen ese primer contacto; los controles anteriores no alteraron la trayectoria.
>
> ## Sigue desconocido
> - Significado del `planeId=1` runtime y su correspondencia con plano HBS.
> - bCoef efectivo de ese plano Node: el HBS exportado lo omite.
> - Normal/penetración/velocidad normal e instante interno Node: el callback no los expone.
> - Si la respuesta Node vy=0 deriva de propiedad efectiva, rama del solver o secuencia temporal.
>
> ## Próxima prueba
> Construir dos harnesses temporales de un solo plano y pelota: Node 2.3.0 y PhysicsCore2D en memoria Studio, estado de tick y plano idénticos. Medir antes/después de resolución. Después ejecutar A–F variando una dimensión por vez. Esta sesión no ejecutó esas pruebas y no justifica cambios productivos.
>
> Estado productivo: sin modificaciones; Studio Edit; place no guardado/no publicado.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_SCENARIO3_CAUSE_UPDATE.md')
> $files=@('PHASE3_ORACLE_230_REPRODUCIBILITY.json','PHASE3_SCENARIO3_MICROBENCHMARKS_EXECUTED.json'); foreach($f in $files){Get-Content (Join-Path $out $f) -Raw | ConvertFrom-Json | Out-Null; "VALID $f"}; Get-ChildItem $out -Filter 'PHASE3_ORACLE_*' | Select-Object Name,Length; Get-ChildItem $out -Filter 'PHASE3_PLANE_ID_MAPPING.md'; Get-ChildItem $out -Filter 'PHASE3_SCENARIO3_*' | Select-Object Name,Length``
>
> </details>
</details>

**Se recuperó y reejecutó Node-HaxBall 2.3.0** desde la instalación aislada en `%TEMP%\codex-haxball-oracle-230-20261118`. Verifiqué la versión declarada, la ruta del módulo cargado y la procedencia registrada.

El harness se ejecutó dos veces: ambas salidas fueron idénticas byte por byte y tuvieron el SHA-256 esperado `7d612957…d110e37`. Se confirmaron 540 ticks Classic, 180 por escenario. La telemetría instrumentada 1–180 sin saltos ni duplicados corresponde a la captura ya verificada anteriormente; no se regeneró en esta ejecución.

Las micropruebas A–F **no se ejecutaron**. El harness recuperado reproduce trayectorias, pero no proporciona los estados de resolución necesarios para comparar pruebas aisladas equivalentes en Node y `PhysicsCore2D`. El `planeId=1` sigue sin una correspondencia interna demostrada. Por eso el veredicto permanece **PARTIAL GO**: se recuperó la referencia y se confirmó su reproducibilidad, pero aún no se aisló la causa física.

Creé los cinco entregables solicitados; validé la sintaxis de los JSON:

- [Recuperación del entorno](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_ORACLE_ENVIRONMENT_RECOVERY.md>)
- [Reproducibilidad 2.3.0](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_ORACLE_230_REPRODUCIBILITY.json>)
- [Mapeo de `planeId`](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_PLANE_ID_MAPPING.md>)
- [Microbenchmarks ejecutados](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_MICROBENCHMARKS_EXECUTED.json>)
- [Actualización causal](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_SCENARIO3_CAUSE_UPDATE.md>)

No modifiqué la física productiva. Studio sigue en Edit; el lugar no se guardó ni publicó.

> \# HAXBALL LAB — FASE 3: INSTRUMENTACIÓN DEL ORÁCULO NODE-HAXBALL 2.3.0\
> \
> \## OBJETIVO\
> \
> Construir un entorno de diagnóstico capaz de observar internamente cómo Node-HaxBall 2.3.0 detecta y resuelve contactos físicos.\
> \
> La investigación del escenario 3 ya identificó un plano candidato, pero todavía no conocemos la causa exacta de la respuesta normal diferente entre Node-HaxBall y nuestro PhysicsCore2D.\
> \
> El principal obstáculo actual es que el harness recuperado reproduce trayectorias, pero no expone los estados internos necesarios para comparar la resolución de contactos.\
> \
> Esta tarea debe resolver ese obstáculo.\
> \
> \*\*No se busca calibrar ni modificar la física productiva. Se busca conseguir observabilidad interna fiable.\*\*\
> \
> \---\
> \
> \# 1. CONTEXTO Y ESTADO CONOCIDO\
> \
> La instalación aislada de Node-HaxBall 2.3.0 se recuperó desde:\
> \
> \`%TEMP%\codex-haxball-oracle-230-20261118\`\
> \
> Se verificaron:\
> \
> \- Versión declarada.\
> \- Ruta real del módulo cargado.\
> \- Procedencia registrada.\
> \- Dos ejecuciones idénticas byte por byte.\
> \- SHA-256 esperado: \`7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37\`.\
> \- 540 ticks Classic, 180 por escenario.\
> \
> IMPORTANTE: la captura instrumentada de 540 ticks mencionada anteriormente corresponde a una ejecución verificada previamente. No se regeneró en la última sesión.\
> \
> Las pruebas A–F no se ejecutaron porque el harness no proporciona los estados internos de resolución.\
> \
> \## Escenario 3\
> \
> El contacto divergente del tick 4 presenta:\
> \
> Node-HaxBall:\
> \- Posición: \`(157.616, 160)\`.\
> \- Velocidad Y: \`0\`.\
> \
> PhysicsCore2D:\
> \- Posición: \`(157.616, 143.206)\`.\
> \- Velocidad Y: \`-24.015\`.\
> \
> Plano candidato:\
> \- Superficie superior del área de balón Classic.\
> \- \`y=170\`.\
> \- Normal \`(0,-1)\`.\
> \- Radio de pelota: \`10\`.\
> \- Centro de la pelota en el contacto esperado: \`y=160\`.\
> \
> La geometría de Studio coincide con esta definición.\
> \
> No obstante, \`planeId=1\` del callback Node todavía no tiene correspondencia interna demostrada con una entrada del HBS.\
> \
> El HBS capturado tampoco proporciona el \`bCoef\` de los planos del área de balón.\
> \
> \---\
> \
> \# 2. AUDITORÍA DEL CÓDIGO EXACTO 2.3.0\
> \
> Inspecciona la instalación recuperada.\
> \
> Localiza:\
> \
> \- Punto de entrada del paquete.\
> \- Módulos responsables de la simulación.\
> \- Construcción de planos.\
> \- Detección de contactos.\
> \- Cálculo de normales.\
> \- Cálculo de penetración.\
> \- Resolución de velocidades.\
> \- Corrección posicional.\
> \- Aplicación de restitución.\
> \- Damping.\
> \- Iteraciones y subpasos.\
> \- Callback o sistema que genera \`planeId\`.\
> \
> No asumas que los nombres o estructuras de la versión 2.3.1 son iguales.\
> \
> La fuente 2.3.1 puede servir como referencia secundaria para comprender una implementación, pero no puede utilizarse para atribuir comportamientos a 2.3.0 sin verificarlos en la versión fijada.\
> \
> Documenta las rutas y funciones exactas del código 2.3.0.\
> \
> Si el paquete está compilado, minificado o distribuido sin fuentes completas, determina qué mecanismos reales existen para observarlo.\
> \
> No inventes funciones internas ni supongas que una propiedad es accesible desde la API pública.\
> \
> \---\
> \
> \# 3. DISEÑAR LA INSTRUMENTACIÓN\
> \
> Evalúa estas posibilidades:\
> \
> A. Instrumentación directa de la fuente exacta 2.3.0.\
> \
> B. Instrumentación de una copia del paquete compilado.\
> \
> C. Hooks sobre funciones realmente exportadas.\
> \
> D. Instrumentación mediante el depurador o trazado de ejecución.\
> \
> E. Reconstrucción del paquete desde una fuente exacta y verificable, siempre que pueda demostrarse que corresponde a 2.3.0.\
> \
> Elige el mecanismo que proporcione mayor fidelidad y menor riesgo de alterar el comportamiento.\
> \
> No modifiques la instalación original.\
> \
> La instrumentación debe residir en una copia aislada, con su propio directorio y procedimiento de ejecución.\
> \
> Antes de implementar, presenta una evaluación breve de viabilidad. Si hay una limitación técnica, explíquela y no la ocultes.\
> \
> \---\
> \
> \# 4. TRAZA INTERNA DE CONTACTOS\
> \
> El objetivo es poder registrar, cuando el motor lo permita:\
> \
> \### Estado previo\
> \
> \- Tick.\
> \- Subpaso.\
> \- Posición X/Y.\
> \- Velocidad X/Y.\
> \- Radio.\
> \- Geometría del plano.\
> \- Normal.\
> \- Distancia.\
> \- Penetración.\
> \- Identificador interno del plano.\
> \
> \### Detección\
> \
> \- Función responsable de detectar el contacto.\
> \- Plano seleccionado.\
> \- Momento de detección.\
> \- Normal calculada.\
> \- Distancia calculada.\
> \- Penetración detectada.\
> \
> \### Resolución\
> \
> \- Velocidad antes de resolver.\
> \- Componente normal.\
> \- Componente tangencial.\
> \- \`bCoef\` realmente utilizado.\
> \- Restitución realmente aplicada.\
> \- Damping aplicado.\
> \- Corrección posicional.\
> \- Cambios de velocidad.\
> \- Orden de las operaciones.\
> \
> \### Estado posterior\
> \
> \- Posición después de resolver.\
> \- Velocidad después de resolver.\
> \- Posición final del subpaso.\
> \- Posición final del tick.\
> \
> Cada campo debe distinguir entre:\
> \
> \- Valor observado directamente.\
> \- Valor obtenido mediante inspección de código.\
> \- Valor derivado matemáticamente.\
> \- Valor desconocido.\
> \
> Nunca inventes un valor interno solo porque la salida permite inferirlo.\
> \
> \---\
> \
> \# 5. PRUEBA DE QUE LA INSTRUMENTACIÓN NO ALTERA LA FÍSICA\
> \
> Esta fase es obligatoria.\
> \
> Antes y después de instrumentar, ejecuta el mismo fixture con la instalación original y con la copia instrumentada.\
> \
> Compara:\
> \
> \- Posiciones.\
> \- Velocidades.\
> \- Eventos.\
> \- Resultados por tick.\
> \- Hash de las salidas de trayectoria.\
> \
> La traza adicional puede almacenarse en un archivo separado, pero no debe cambiar los resultados físicos.\
> \
> Requisitos:\
> \
> 1\. La versión original debe seguir intacta.\
> 2\. La copia instrumentada debe identificarse claramente.\
> 3\. El fixture debe seguir produciendo 540 estados.\
> 4\. Las trayectorias originales e instrumentadas deben coincidir byte por byte cuando se comparen los mismos campos.\
> 5\. Debe poder ejecutarse la misma prueba varias veces de forma determinista.\
> \
> Si la instrumentación cambia los resultados, no la consideres válida hasta determinar por qué.\
> \
> No continúes a las micropruebas con una instrumentación que no haya superado esta comprobación.\
> \
> \---\
> \
> \# 6. RECUPERAR EL CONTACTO DEL ESCENARIO 3\
> \
> Una vez validada la instrumentación:\
> \
> 1\. Carga el escenario 3 original.\
> 2\. Reconstruye las condiciones iniciales reales.\
> 3\. Ejecuta la simulación.\
> 4\. Captura el contacto divergente.\
> 5\. Determina qué plano interno produce el contacto.\
> 6\. Registra las propiedades utilizadas por el solver.\
> 7\. Determina cuándo se modifica la velocidad normal.\
> 8\. Determina cuándo se modifica la posición.\
> \
> No construyas todavía un escenario artificial si no es necesario.\
> \
> Primero intenta obtener la traza del contacto real del fixture.\
> \
> Después, si el motor permite construir un escenario aislado con la API real de 2.3.0, prepara un único balón y el plano correspondiente.\
> \
> Si no permite aislar el plano sin alterar la semántica de la simulación, documenta la limitación.\
> \
> \---\
> \
> \# 7. CORRESPONDENCIA DE PLANEID\
> \
> Investiga específicamente el \`planeId=1\`.\
> \
> Determina:\
> \
> \- Dónde se genera.\
> \- Si representa un índice, identificador interno o referencia.\
> \- Si cambia según el orden de construcción.\
> \- Cómo se relaciona con la estructura interna.\
> \- Si se puede relacionar con la definición HBS.\
> \
> No supongas que el identificador coincide con el índice de la entrada HBS.\
> \
> Si no se puede demostrar, conserva su correspondencia como desconocida.\
> \
> \---\
> \
> \# 8. COMPARACIÓN CON PHYSICSCORE2D\
> \
> Cuando exista una traza fiable de Node-HaxBall:\
> \
> Prepara una instrumentación equivalente para el entorno de pruebas de PhysicsCore2D.\
> \
> No modifiques el solver productivo.\
> \
> Utiliza una copia diagnóstica o instrumentación temporal aislada.\
> \
> La comparación debe utilizar:\
> \
> \- Las mismas condiciones iniciales.\
> \- El mismo estado de pelota.\
> \- El mismo radio.\
> \- La misma geometría.\
> \- Las mismas propiedades que puedan demostrarse.\
> \- El mismo punto de referencia temporal.\
> \
> Registra las diferencias etapa por etapa.\
> \
> El objetivo es saber exactamente en qué operación comienza la divergencia.\
> \
> \---\
> \
> \# 9. MICROPRUEBAS A-F\
> \
> No ejecutes todavía las pruebas A-F completas si la instrumentación no está lista.\
> \
> Primero entrega una prueba mínima del escenario 3 con una traza interna verificable.\
> \
> Cuando esa prueba funcione y la instrumentación esté validada, podrás preparar A-F en una tarea posterior.\
> \
> No confundas tener un harness ejecutable con tener capacidad de observar la resolución interna.\
> \
> \---\
> \
> \# 10. RESTRICCIONES ABSOLUTAS\
> \
> \- No modificar la instalación original 2.3.0.\
> \- No sustituir 2.3.0 por 2.3.1.\
> \- No modificar los parámetros físicos productivos.\
> \- No modificar el solver productivo.\
> \- No alterar el estadio activo.\
> \- No guardar ni publicar el place.\
> \- Mantener Roblox Studio en Edit.\
> \- No avanzar a Fase 4 o Fase 5.\
> \- No implementar el modo Fútbol avanzado.\
> \- No compartir ni subir telemetría privada.\
> \- No declarar que una traza es interna si solo contiene estados finales.\
> \- No afirmar que la instrumentación es inocua sin comparar ambas ejecuciones.\
> \- No presentar inferencias como datos observados.\
> \
> \---\
> \
> \# 11. ENTREGABLES\
> \
> Genera:\
> \
> 1\. \`PHASE3_NODE230_SOURCE_AUDIT.md\`\
> &#x20;  \- Código y módulos inspeccionados.\
> &#x20;  \- Funciones reales del motor.\
> &#x20;  \- Posibilidades de instrumentación.\
> &#x20;  \- Limitaciones.\
> \
> 2\. \`PHASE3_NODE230_INSTRUMENTATION_DESIGN.md\`\
> &#x20;  \- Mecanismo elegido.\
> &#x20;  \- Motivo de selección.\
> &#x20;  \- Estructura de la copia aislada.\
> &#x20;  \- Campos que podrá registrar.\
> \
> 3\. \`PHASE3_NODE230_INSTRUMENTATION_VALIDATION.json\`\
> &#x20;  \- Identificación de instalaciones.\
> &#x20;  \- Versiones.\
> &#x20;  \- Hashes.\
> &#x20;  \- Resultados de comparación original/instrumentada.\
> &#x20;  \- Determinismo.\
> &#x20;  \- Confirmación de equivalencia de trayectorias.\
> \
> 4\. \`PHASE3_NODE230_CONTACT_TRACE.json\`\
> &#x20;  \- Traza interna del contacto del escenario 3, si se consigue.\
> \
> 5\. \`PHASE3_NODE230_PLANE_MAPPING.md\`\
> &#x20;  \- Investigación de \`planeId=1\`.\
> &#x20;  \- Correspondencia demostrada o limitación.\
> \
> 6\. \`PHASE3_INSTRUMENTATION_DECISION.md\`\
> &#x20;  \- Qué se logró.\
> &#x20;  \- Qué no se logró.\
> &#x20;  \- Qué datos son observados.\
> &#x20;  \- Qué datos son inferidos.\
> &#x20;  \- Qué debe hacerse después.\
> \
> \---\
> \
> \# 12. VEREDICTO\
> \
> \*\*GO\*\*\
> \
> Solo si:\
> \- Existe una instrumentación real.\
> \- Su versión está verificada.\
> \- No altera las trayectorias.\
> \- Produce información interna útil del contacto.\
> \
> \*\*PARTIAL GO\*\*\
> \
> Si se encontró una vía viable de instrumentación, pero todavía no se consiguió una traza completa o una equivalencia demostrada.\
> \
> \*\*NO-GO\*\*\
> \
> Si no existe una vía fiable para inspeccionar la resolución interna o la instrumentación altera la física y no puede corregirse.\
> \
> \---\
> \
> \# 13. INFORME FINAL\
> \
> Responde:\
> \
> 1\. ¿Qué código exacto de Node-HaxBall 2.3.0 inspeccionaste?\
> 2\. ¿Dónde se detectan y resuelven los contactos?\
> 3\. ¿Cómo se genera \`planeId\`?\
> 4\. ¿Se pudo instrumentar sin alterar los resultados?\
> 5\. ¿Qué campos internos se pueden observar?\
> 6\. ¿Se capturó el contacto del escenario 3?\
> 7\. ¿Se identificó el plano real?\
> 8\. ¿Qué información sigue faltando?\
> 9\. ¿Se modificó la instalación original?\
> 10\. ¿Se modificó algún archivo productivo?\
> 11\. ¿Se guardó o publicó Studio?\
> \
> No declares resuelta la divergencia.\
> \
> \*\*La prioridad es conseguir una traza interna fiable del contacto del escenario 3.\*\*

<details><summary>2 previous messages</summary>

> La auditoría de recuperación encontró el entorno temporal exacto, no solo sus informes: el paquete carga como 2.3.0 y el replay acaba de repetir el hash esperado dos veces. La viabilidad preliminar es buena para copiar e instrumentar el wrapper/callback y verificar que la copia conserva las trayectorias; es incierta para observar variables del solver, porque la API pública solo entrega argumentos de colisión y `api.js` está minificado. Revisaré ahora el código 2.3.0 y el harness de captura para elegir un hook real antes de construir una copia de diagnóstico.
>
> <details><summary>Ran 6 commands</summary>
>
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\oracle-install'; Get-Content package.json; Get-Content nh_oracle_instrumented.cjs -TotalCount 180; $node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const fs=require('fs'),p=require.resolve('node-haxball'),s=fs.readFileSync(p,'utf8'); console.log(JSON.stringify({entry:p,bytes:Buffer.byteLength(s),symbols:['onCollisionDiscVsPlane','E$','planeId','runSteps','prototype.E$'].map(x=>({x,index:s.indexOf(x),context:(i=>i<0?'':s.slice(Math.max(0,i-400),i+700))(s.indexOf(x))}))}))"`
> - Ran `Get-Content package.json; Get-Content nh_oracle_instrumented.cjs -TotalCount 180; $node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const fs=require('fs'),p=require.resolve('node-haxball'),s=fs.readFileSync(p,'utf8'); console.log(JSON.stringify({entry:p,bytes:Buffer.byteLength(s),symbols:['onCollisionDiscVsPlane','E$','planeId','runSteps','prototype.E$'].map(x=>({x,index:s.indexOf(x),context:(i=>i<0?'':s.slice(Math.max(0,i-400),i+700))(s.indexOf(x))}))}))"`
> - Ran `$node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const a=require('node-haxball')(); console.log(Object.keys(a));console.log('GPS',a.GamePlayState&&Object.keys(a.GamePlayState),a.GamePlayState&&Object.getOwnPropertyNames(a.GamePlayState.prototype))"; Get-Content node_modules\node-haxball\src\index.js; Get-Content node_modules\node-haxball\src\indexCommon.js -TotalCount 20;`
> - Ran `Get-Content node_modules\node-haxball\src\index.js; Get-Content node_modules\node-haxball\package.json | Select-String 'main|version'; Get-ChildItem node_modules\node-haxball\src -Force | Select Length,Name;`
> - Ran `$node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const fs=require('fs'),p=require.resolve('node-haxball'),d=require('path').dirname(p),s=fs.readFileSync(d+'/api.js','utf8');for(const q of ['planeId','E$','onCollisionDiscVsPlane','prototype.E$','dist']){let i=s.indexOf(q);console.log(q,i,i>=0?s.slice(Math.max(0,i-180),i+300):'')}"`
> - Ran `$node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const fs=require('fs'),p=require.resolve('node-haxball'),s=fs.readFileSync(require('path').dirname(p)+'/api.js','utf8'),i=s.indexOf('E$:function'); console.log(s.slice(i,i+7500))"`
>
> </details>
</details>

**Veredicto: PARTIAL GO.** Recuperé y ejecuté el paquete exacto Node-HaxBall 2.3.0. Sus dos ejecuciones reprodujeron el SHA esperado byte por byte y 540 ticks Classic. Inspeccioné su entrada (`src/index.js`) y el código minificado `src/api.js`: contiene el solver Nago `E$` y el wrapper del callback de planos, pero no encontré una API pública para observar los pasos internos de resolución.

La vía con mejor equilibrio entre observabilidad y riesgo es una **copia temporal del harness que envuelva el método `E$` del objeto de estado físico en ejecución**, llame al original y capture antes/después, dejando intacto el paquete original. Esa vía aún necesita una prueba de equivalencia de trayectorias y no ofrece por sí sola una traza antes y después de cada operación interna. Por eso no la presento como instrumentación validada ni afirmo haber capturado el contacto interno del escenario 3. El `planeId=1` sigue sin mapearse de forma demostrada.

Dejé los seis entregables en `outputs`:

- [Auditoría del código 2.3.0](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NODE230_SOURCE_AUDIT.md>)
- [Diseño de instrumentación](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NODE230_INSTRUMENTATION_DESIGN.md>)
- [Validación de instrumentación](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NODE230_INSTRUMENTATION_VALIDATION.json>)
- [Traza de contacto](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NODE230_CONTACT_TRACE.json>)
- [Mapeo de plano](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_NODE230_PLANE_MAPPING.md>)
- [Decisión de instrumentación](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_INSTRUMENTATION_DECISION.md>)

No modifiqué la instalación original ni el código productivo. Studio permanece en Edit; el place no se guardó ni publicó. Las pruebas A–F quedan para después de validar la instrumentación.

> HAXBALL LAB — FASE 3: VALIDACIÓN DEL WRAPPER E$ DE NODE-HAXBALL 2.3.0\
> \
> Objetivo:\
> Validar experimentalmente la instrumentación propuesta sobre E$,\
> sin modificar la instalación original ni la física productiva.\
> \
> 1\. Crear una copia aislada del harness y utilizar exclusivamente\
> &#x20;  Node-HaxBall 2.3.0.\
> \
> 2\. Identificar el objeto real que contiene E$:\
> &#x20;  \- Ruta de construcción.\
> &#x20;  \- Identidad de la función.\
> &#x20;  \- Propietario del método.\
> &#x20;  \- Descriptor de la propiedad.\
> &#x20;  \- Número de llamadas por tick.\
> &#x20;  \- Relación real con la simulación física.\
> \
> 3\. Implementar un wrapper temporal que:\
> &#x20;  \- Preserve this.\
> &#x20;  \- Preserve todos los argumentos.\
> &#x20;  \- Ejecute el método original exactamente una vez.\
> &#x20;  \- Preserve el valor de retorno.\
> &#x20;  \- Preserve las excepciones.\
> &#x20;  \- No modifique los argumentos ni el estado físico.\
> &#x20;  \- Registre snapshots antes y después.\
> \
> 4\. Registrar:\
> &#x20;  \- Tick y llamada.\
> &#x20;  \- Identificador del objeto.\
> &#x20;  \- Posiciones y velocidades disponibles.\
> &#x20;  \- Estado de la pelota.\
> &#x20;  \- Estado de los discos relevantes.\
> &#x20;  \- Contactos y eventos accesibles.\
> &#x20;  \- Datos que no puedan observarse explícitamente.\
> \
> 5\. No asumir que E$ proporciona acceso a las operaciones\
> &#x20;  internas del solver. Documentar exactamente qué permite observar.\
> \
> 6\. Ejecutar el fixture original y la copia instrumentada\
> &#x20;  en procesos separados.\
> \
> 7\. Comparar:\
> &#x20;  \- 540 estados Classic.\
> &#x20;  \- Posiciones.\
> &#x20;  \- Velocidades.\
> &#x20;  \- Eventos.\
> &#x20;  \- Orden de los eventos.\
> &#x20;  \- Hashes de las salidas físicas equivalentes.\
> \
> 8\. Repetir las ejecuciones para comprobar determinismo.\
> \
> 9\. Si existen diferencias, investigar y corregir el wrapper.\
> &#x20;  No declarar validada la instrumentación.\
> \
> 10\. Si las trayectorias coinciden, ejecutar el escenario 3\
> &#x20;   y comprobar si se puede capturar su transición física.\
> \
> IMPORTANTE:\
> No ejecutar A-F todavía.\
> No modificar el solver original.\
> No cambiar parámetros.\
> No utilizar Node-HaxBall 2.3.1.\
> No guardar ni publicar Roblox Studio.\
> No presentar estados finales como estados internos.\
> \
> Entregables:\
> \- PHASE3_E_WRAPPER_IMPLEMENTATION.md\
> \- PHASE3_E_WRAPPER_VALIDATION.json\
> \- PHASE3_E_WRAPPER_CALL_TRACE.json\
> \- PHASE3_E_SCENARIO3_CAPTURE.json\
> \- PHASE3_E_WRAPPER_DECISION.md\
> \
> Veredicto GO únicamente si la instrumentación conserva\
> los resultados originales y demuestra que captura información útil.

<details><summary>6 previous messages</summary>

> Voy a revisar primero los entregables y el entorno temporal recuperado, y después construiré una copia del harness fuera de la instalación original. Validaré el wrapper en procesos separados y compararé las trayectorias Classic, incluidos los eventos disponibles; no ejecutaré A–F ni tocaré Studio.
>
> <details><summary>Explored a file, ran 2 commands</summary>
>
> - Ran `$out='referenced-chatgpt-conversation-this-is-an/outputs'; Get-Content (Join-Path $out 'PHASE3_NODE230_SOURCE_AUDIT.md'); Get-Content (Join-Path $out 'PHASE3_NODE230_INSTRUMENTATION_DESIGN.md'); Get-Content (Join-Path $out 'PHASE3_NODE230_INSTRUMENTATION_VALIDATION.json'); $root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\oracle-install'; Get-ChildItem $root -Force | Select Mode,Length,Name; Get-Content (Join-Path $root 'nh_oracle_instrumented.cjs') -TotalCount 100`
>
> <details><summary>Explored a file</summary>
>
> - Read `./inspect-state.cjs`
>
> </details>
>
> - Ran `$node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node -e "const {Room,Utils}=require('node-haxball')();const r=Room.sandbox({},{});r.setCurrentStadium(Utils.getDefaultStadiums().find(x=>x.name==='Classic'),0);r.playerJoin(1,'a','tr','','','');r.setPlayerTeam(1,1,0);r.startGame(0);const g=r.gameState.copy(),p=g.physicsState;let x=p;for(let i=0;x&&i<5;i++,x=Object.getPrototypeOf(x)){console.log(i,Object.getOwnPropertyNames(x).filter(k=>k==='E$'||typeof x[k]==='function'),Object.keys(x))};console.log('gps proto',Object.getOwnPropertyNames(Object.getPrototypeOf(g)))"`
>
> </details>
>
> El objeto real aparece en tiempo de ejecución: `gameState.copy().physicsState` hereda `E$` del prototipo del motor Nago. Voy a envolver ese descriptor solo dentro del proceso diagnóstico, manteniendo una referencia al original y usando `Reflect.apply` con el mismo `this` y argumentos. La traza será de entrada/salida de `E$`; no la describiré como captura de operaciones internas del solver.
>
> <details><summary>Ran 7 commands</summary>
>
> - Ran ``$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $src=Join-Path $root 'oracle-install\nh_oracle_instrumented.cjs'; $dst=Join-Path $root 'e-wrapper-diagnostic'; New-Item -ItemType Directory -Force -Path $dst | Out-Null; $code=Get-Content $src -Raw; $inject=@'
>  const physics=gs.physicsState;
>  let proto=physics; while(proto && !Object.prototype.hasOwnProperty.call(proto,'E$')) proto=Object.getPrototypeOf(proto);
>  if(!proto) throw new Error('physicsState prototype chain has no E$');
>  const originalDescriptor=Object.getOwnPropertyDescriptor(proto,'E$');
>  const originalE=originalDescriptor.value; let eCalls=0;
>  const idMap=new WeakMap(); let nextObjectId=1;
>  const internalVector=v=>v&&typeof v.x==='number'&&typeof v.y==='number'?{x:v.x,y:v.y}:null;
>  const snapInternal=owner=>({ownerId:(()=>{if(!idMap.has(owner))idMap.set(owner,nextObjectId++);return idMap.get(owner)})(),
>   discs:(owner.F||[]).map((d,i)=>({index:i,objectId:(()=>{if(!idMap.has(d))idMap.set(d,nextObjectId++);return idMap.get(d)})(),position:internalVector(d.B),velocity:internalVector(d.I),radius:d.l,invMass:d.j,bCoef:d.a,fieldNames:Object.keys(d)})),
>   planes:(owner.m||[]).map((p,i)=>({index:i,objectId:(()=>{if(!idMap.has(p))idMap.set(p,nextObjectId++);return idMap.get(p)})(),normal:internalVector(p.z$),offset:p.c$,bCoef:p.a,fieldNames:Object.keys(p)})),
>   segmentCount:(owner.k||[]).length,vertexCount:(owner.O||[]).length,jointCount:(owner['L$']||[]).length});
>  const thisCalls=[];
>  const wrapper=function(...args){const call=++eCalls; const before=snapInternal(this); let result,thrown;
>   try{result=Reflect.apply(originalE,this,args)}catch(err){thrown=err;throw err}finally{thisCalls.push({frameNumber:captureFrame,call,objectId:before.ownerId,args:args.map(v=>typeof v==='number'||typeof v==='string'||typeof v==='boolean'?v:null),before,after:snapInternal(this),threw:!!thrown});}
>   return result;
>  };
>  Object.defineProperty(proto,'E$',{...originalDescriptor,value:wrapper});
> '@;
> $marker=' const gs=room.gameState.copy();'; if(!$code.Contains($marker)){throw 'harness insertion point missing'}; $code=$code.Replace($marker,$marker+"`n"+$inject); $code=$code.Replace("const output={schemaVersion:1,provenance:","const output={schemaVersion:1,provenance:");
> $code=$code.Replace(" const states= ticks.map(t=>t.postStep);"," Object.defineProperty(proto,'E$',originalDescriptor);`n const states= ticks.map(t=>t.postStep);");
> $code=$code.Replace(" const states= ticks.map(t=>t.postStep);"," fs.appendFileSync(process.argv[3],JSON.stringify({scenarioIndex:si+1,callCount:eCalls,calls:thisCalls})+'`n');`n const states= ticks.map(t=>t.postStep);");
> $code=$code.Replace("const outPath=process.argv[2];fs.writeFileSync(outPath,JSON.stringify(output));","const outPath=process.argv[2];fs.writeFileSync(outPath,JSON.stringify(output));");
> Set-Content -Encoding utf8 (Join-Path $dst 'nh_oracle_e_wrapper.cjs') $code; "Created $dst";``
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; $inst=Join-Path $root 'oracle-install'; $diag=Join-Path $root 'e-wrapper-diagnostic'; Copy-Item (Join-Path $inst 'nh_oracle_instrumented.cjs') (Join-Path $diag 'nh_oracle_baseline.cjs'); $env:NODE_PATH=Join-Path $inst 'node_modules'; Push-Location $diag; try { & $node (Join-Path $diag 'nh_oracle_baseline.cjs') (Join-Path $diag 'baseline.json'); "baselineExit=$LASTEXITCODE"; Remove-Item (Join-Path $diag 'trace.jsonl') -ErrorAction SilentlyContinue; & $node (Join-Path $diag 'nh_oracle_e_wrapper.cjs') (Join-Path $diag 'instrumented.json') (Join-Path $diag 'trace.jsonl'); "instrumentedExit=$LASTEXITCODE" } finally {Pop-Location};`
> - Ran `Get-ChildItem (Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\e-wrapper-diagnostic') | Select Length,Name;`
> - Ran `rg -n 'Object.defineProperty|appendFile|states=|for\(let frame|eCalls' nh_oracle_e_wrapper.cjs`
> - Ran `Get-Content nh_oracle_e_wrapper.cjs | Select-Object -Skip 72 -First 10`
> - Ran ``$p='nh_oracle_e_wrapper.cjs'; $s=Get-Content $p -Raw; $s=$s.Replace("})+'`n');", "})+'\n');"); Set-Content -Encoding utf8 $p $s; $node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node --check $p;``
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; $env:NODE_PATH=Join-Path $root 'oracle-install\node_modules'; & $node (Join-Path $root 'e-wrapper-diagnostic\nh_oracle_e_wrapper.cjs') (Join-Path $root 'e-wrapper-diagnostic\instrumented.json') (Join-Path $root 'e-wrapper-diagnostic\trace.jsonl');`
>
> </details>
>
> La primera ejecución instrumentada completó 540 ticks y produjo la misma salida de 3,007,628 bytes y el mismo hash que el harness de referencia. Ahora estoy comprobando igualdad byte por byte, repetición del wrapper y cuántas veces se invoca `E$`; la traza registra estados de entrada/salida, no pasos internos entre ellos.
>
> <details><summary>Ran 7 commands</summary>
>
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; $env:NODE_PATH=Join-Path $root 'oracle-install\node_modules'; & $node (Join-Path $root 'e-wrapper-diagnostic\nh_oracle_e_wrapper.cjs') (Join-Path $root 'e-wrapper-diagnostic\instrumented2.json') (Join-Path $root 'e-wrapper-diagnostic\trace2.jsonl') | Out-Null; $files='baseline.json','instrumented.json','instrumented2.json'; foreach($f in $files){$h=Get-FileHash (Join-Path $root ('e-wrapper-diagnostic\'+$f)) -Algorithm SHA256; "$f $($h.Hash)"}; $a=[IO.File]::ReadAllBytes((Join-Path $root 'e-wrapper-diagnostic\baseline.json')); $b=[IO.File]::ReadAllBytes((Join-Path $root 'e-wrapper-diagnostic\instrumented.json')); "equalBaselineInstrumented=$([Linq.Enumerable]::SequenceEqual[byte]($a,$b))"; $t1=Get-Content (Join-Path $root 'e-wrapper-diagnostic\trace.jsonl') -Raw; $t2=Get-Content (Join-Path $root 'e-wrapper-diagnostic\trace2.jsonl') -Raw; "traceDeterministic=$([string]::Equals($t1,$t2))"; $tr=@(Get-Content (Join-Path $root 'e-wrapper-diagnostic\trace.jsonl') | ForEach-Object {$_ | ConvertFrom-Json}); $tr | ForEach-Object {"scenario=$($_.scenarioIndex) calls=$($_.callCount) traceEntries=$($_.calls.Count)"}; $tr[2].calls | Where-Object {$_.frameNumber -le 5} | ForEach-Object {"frame=$($_.frameNumber) call=$($_.call) balls=$($_.after.discs.Count) ballAfter=$($_.after.discs[0].position.y),$($_.after.discs[0].velocity.y) planeCount=$($_.after.planes.Count)"}`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\e-wrapper-diagnostic'; Get-ChildItem $root | Select Length,Name; Get-FileHash (Join-Path $root 'baseline.json'),(Join-Path $root 'instrumented.json'),(Join-Path $root 'instrumented2.json'),(Join-Path $root 'trace.jsonl'),(Join-Path $root 'trace2.jsonl') -Algorithm SHA256 | Select Hash,Path`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\e-wrapper-diagnostic'; @'
> const fs=require('fs'),crypto=require('crypto'),path=require('path');
> const base=fs.readFileSync(path.join(__dirname,'baseline.json'));
> for(const n of ['baseline.json','instrumented.json','instrumented2.json']){const b=fs.readFileSync(path.join(__dirname,n));console.log(n,b.length,crypto.createHash('sha256').update(b).digest('hex'),'equalBase',base.equals(b));}
> const t1=fs.readFileSync(path.join(__dirname,'trace.jsonl')),t2=fs.readFileSync(path.join(__dirname,'trace2.jsonl'));console.log('traceBytes',t1.length,'traceDeterministic',t1.equals(t2));
> const rows=t1.toString().trim().split('\n').map(JSON.parse);for(const r of rows){console.log('scenario',r.scenarioIndex,'calls',r.callCount,'entries',r.calls.length,'frameRange',r.calls[0]?.frameNumber,r.calls.at(-1)?.frameNumber);}
> const r=rows[2];for(const c of r.calls.filter(x=>x.frameNumber<=5)){console.log('S3',c.frameNumber,c.call,'ballPre',c.before.discs[0]?.position,c.before.discs[0]?.velocity,'ballPost',c.after.discs[0]?.position,c.after.discs[0]?.velocity,'planes',c.before.planes.length);}
> '@ | Set-Content -Encoding utf8 (Join-Path $root 'summarize.cjs'); $node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; & $node (Join-Path $root 'summarize.cjs')`
> - Ran `$root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118'; $node=Join-Path $root 'portable-node\node-v24.22.3-win-x64\node.exe'; $env:NODE_PATH=Join-Path $root 'oracle-install\node_modules'; & $node -e "const {Room,Utils}=require('node-haxball')();const r=Room.sandbox({},{});r.setCurrentStadium(Utils.getDefaultStadiums().find(s=>s.name==='Classic'),0);r.playerJoin(1,'p','tr','','','');r.setPlayerTeam(1,1,0);r.startGame(0);const p=r.gameState.copy().physicsState;let q=p;while(q&&!Object.prototype.hasOwnProperty.call(q,'E$'))q=Object.getPrototypeOf(q);const d=Object.getOwnPropertyDescriptor(q,'E$');console.log(JSON.stringify({ownerConstructor:q.constructor.name,depth:(()=>{let x=p,n=0;while(x&&x!==q){x=Object.getPrototypeOf(x);n++}return n})(),ownProperty:!!Object.hasOwn(p,'E$'),sameFunction:p.E$===d.value,name:d.value.name,length:d.value.length,descriptor:{writable:d.writable,enumerable:d.enumerable,configurable:d.configurable},functionHead:d.value.toString().slice(0,100)}))"`
> - Ran ``$out='referenced-chatgpt-conversation-this-is-an/outputs'; $root=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\e-wrapper-diagnostic'; $node=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\portable-node\node-v24.22.3-win-x64\node.exe'; @'
> const fs=require('fs'),path=require('path');const lines=fs.readFileSync(path.join(__dirname,'trace.jsonl'),'utf8').trim().split('\n').map(JSON.parse);fs.writeFileSync(path.join(process.argv[2],'PHASE3_E_WRAPPER_CALL_TRACE.json'),JSON.stringify({schemaVersion:1,scenarioIndex:3,scope:'wrapper entry/exit snapshots around E$; not per-operation solver instrumentation',calls:lines[2].calls}));
> '@ | Set-Content -Encoding utf8 (Join-Path $root 'export-trace.cjs'); & $node (Join-Path $root 'export-trace.cjs') (Resolve-Path $out).Path
> @'
> # Implementación wrapper temporal de E$
>
> Se usó la instalación aislada Node 24.22.3 / `node-haxball` declarado 2.3.0 en `%TEMP%\codex-haxball-oracle-230-20261118\oracle-install`. No se editó `node_modules` ni la instalación original. Se copió el harness de telemetría `nh_oracle_instrumented.cjs` a `e-wrapper-diagnostic\nh_oracle_e_wrapper.cjs`; requiere el `node_modules` fijado por `NODE_PATH`.
>
> ## Objeto y método identificados en runtime
> Ruta de construcción: `Room.sandbox(callbacks,{})` → `room.startGame(0)` → `room.gameState.copy()` → `gs.physicsState`. E$ es heredado por `physicsState` desde el segundo prototipo arriba (depth 2); propietario: objeto prototipo anónimo (`constructor.name === "Object"`). No es propiedad propia del physicsState. Descriptor: writable/enumerable/configurable true. La función original tiene nombre `E$`, aridad 2 y comienza `function(C,h){...}`. `physicsState.E$ === descriptor.value` es true.
>
> ## Wrapper
> La copia conserva el descriptor original y lo reemplaza solo en el proceso. El wrapper captura `this` y argumentos; registra snapshot de entrada; invoca exactamente una vez mediante `Reflect.apply(originalE,this,args)`; registra retorno normal sin cambiarlo, o captura/re-lanza el mismo objeto de excepción; `finally` guarda snapshot de salida. Restaura descriptor después de cada escenario. No escribe propiedades en argumentos, discos o geometría.
>
> El snapshot lee discos dinámicos en `this.F`: identidad observacional local, `B` (posición), `I` (velocidad), radio `l`, invMass `j`, bCoef `a`, y el array de planos `this.m`: `z$` (normal), `c$` (offset), `a` (bCoef). Estos nombres internos se obtuvieron inspeccionando el método minificado exacto 2.3.0. Los eventos accesibles provienen de callbacks públicos capturados por el harness y su orden queda en la salida física. El wrapper no observa la instrucción exacta de detección/resolución, penetración, impulso, contactos seleccionados, ni estados intermedios dentro de E$.
>
> ## Conteo y relación física
> En escenarios Classic el wrapper observó 180 llamadas por escenario, llamadas 1..180 alineadas con frames 1..180 (una E$ por `gs.runSteps(1)` para esta configuración/harness). Entrada/salida de cada llamada delimita la transición física del tick. No demuestra qué operación interior cambió velocidad/posición.
>
> Copia y scripts diagnósticos: `%TEMP%\codex-haxball-oracle-230-20261118\e-wrapper-diagnostic`. Salidas comparables: baseline.json, instrumented.json, instrumented2.json. Traza completa escenario 3: `PHASE3_E_WRAPPER_CALL_TRACE.json`.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_E_WRAPPER_IMPLEMENTATION.md')
> @'
> {
>  "status":"VALIDATED_FOR_TICK_BOUNDARY_SNAPSHOTS",
>  "package":{"name":"node-haxball","declaredVersion":"2.3.0","node":"v24.22.3","module":"oracle-install/node_modules/node-haxball/src/index.js","packageUnmodified":true},
>  "method":{"path":"Room.sandbox -> startGame -> gameState.copy -> physicsState.E$","prototypeDepth":2,"ownerConstructor":"Object","ownOnPhysicsState":false,"sameFunctionAsDescriptor":true,"name":"E$","arity":2,"descriptor":{"writable":true,"enumerable":true,"configurable":true}},
>  "runs":{
>   "baseline":{"sha256":"74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8","bytes":3007628,"ticks":[180,180,180]},
>   "instrumented1":{"sha256":"74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8","bytes":3007628,"ticks":[180,180,180]},
>   "instrumented2":{"sha256":"74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8","bytes":3007628,"ticks":[180,180,180]},
>   "baselineEqualsInstrumentedBytewise":true,"instrumentedRunsEqualBytewise":true,
>   "traceSha256":"see local call trace artifact","traceDeterministic":true,"callsPerScenario":[180,180,180],"classicStateCount":540
>  },
>  "events":"Entire 3,007,628-byte JSON includes per-tick disc states and ordered callbacks; equality of complete serialized output establishes identical event content/order for these runs.",
>  "observable":"E$ entry/exit physical disc and plane snapshots; public callbacks captured by harness",
>  "notObservable":"internal collision candidate, exact contact order within method, penetration/impulse, operation-level pre/post velocity, internal subiterations",
>  "validationScope":"specific Classic fixture and Node 2.3.0 harness; not a universal proof of noninterference"
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_E_WRAPPER_VALIDATION.json')
> @'
> {
>  "schemaVersion":1,"scenarioIndex":3,"calls":180,"frames":"1..180","traceBoundary":"immediately before and after E$ per runSteps(1)",
>  "tick4":{
>   "before":{"ball":{"x":118.804,"y":148.505,"vx":38.81196,"vy":48.51495,"radius":10,"bCoef":0.5},"planeCandidate":{"index":5,"normal":{"x":0,"y":-1},"offset":-170,"bCoef":null}},
>   "after":{"ball":{"x":157.61596,"y":160,"vx":38.4238404,"vy":0,"radius":10,"bCoef":0.5}},
>   "callback":"onCollisionDiscVsPlane at frame 4; public callback reports planeId=1",
>   "limit":"These are E$ boundary snapshots. They do not expose the instant of collision or before/after individual solver operations. null bCoef means unavailable/undefined in runtime snapshot, not numeric zero."
>  },
>  "fullTraceFile":"PHASE3_E_WRAPPER_CALL_TRACE.json"
> }
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_E_SCENARIO3_CAPTURE.json')
> @'
> # Decisión del wrapper E$
>
> ## Veredicto: PARTIAL GO
>
> Se validó un wrapper temporal de la función `E$` realmente heredada por `gameState.copy().physicsState` en Node-HaxBall 2.3.0. Conserva `this`, argumentos, llamada única al original, retorno/excepción y descriptor restaurado. En el fixture Classic produjo 180 llamadas por escenario y capturó snapshots de discos/planos antes y después de cada transición física.
>
> La salida física serializada de baseline e instrumentación fue byte por byte idéntica en dos ejecuciones instrumentadas; los tres hashes fueron `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`. Los 540 estados y eventos ordenados coinciden para este fixture. La traza es útil para delimitar el tick en que cambia el estado; no revela las operaciones internas ni penetración/impulso. Por ello aún no es una traza interna completa del contacto ni resuelve la causa física.
>
> En escenario 3, la envoltura muestra entrada al tick 4 con (118.804,148.505), velocidad (38.81196,48.51495), y salida (157.61596,160), velocidad Y 0; el callback accesible reporta planeId 1. Geometría y candidate plane pueden inspeccionarse en el array de planos, pero correlacionar con el ID de callback requiere instrumentar el punto exacto de callback/solver dentro de E$.
>
> No se cambió el paquete original ni ningún archivo productivo; Studio no se usó y permanece en Edit según estado previo. No se ejecutaron A–F. Siguiente paso: instrumentación de fuente en otra copia, añadiendo solo observadores pasivos alrededor del bloque de planos y callback, y repetir prueba bytewise antes de usarla.
> '@ | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_E_WRAPPER_DECISION.md')
> foreach($f in @('PHASE3_E_WRAPPER_VALIDATION.json','PHASE3_E_SCENARIO3_CAPTURE.json','PHASE3_E_WRAPPER_CALL_TRACE.json')){Get-Content (Join-Path $out $f) -Raw | ConvertFrom-Json | Out-Null; "VALID $f"}; Get-ChildItem $out -Filter 'PHASE3_E_*' | Select Name,Length``
> - Ran `Test-Path 'C:\Users\User\Documents\Codex\2026-11-17\referenced-chatgpt-conversation-this-is-an\outputs'; Get-Location; Get-ChildItem referenced-chatgpt-conversation-this-is-an\outputs -Filter 'PHASE3_E*'`
> - Ran `$out='referenced-chatgpt-conversation-this-is-an/outputs'; $tempRoot=Join-Path $env:TEMP 'codex-haxball-oracle-230-20261118\e-wrapper-diagnostic'; $lines=Get-Content (Join-Path $tempRoot 'trace.jsonl'); $row=$lines[2] | ConvertFrom-Json; $doc=[ordered]@{schemaVersion=1;scenarioIndex=3;scope='E$ entry/exit snapshots only';calls=$row.calls}; $doc | ConvertTo-Json -Depth 20 -Compress | Set-Content -Encoding utf8 (Join-Path $out 'PHASE3_E_WRAPPER_CALL_TRACE.json'); Get-Content (Join-Path $out 'PHASE3_E_WRAPPER_CALL_TRACE.json') -Raw | ConvertFrom-Json | Out-Null; Get-Item (Join-Path $out 'PHASE3_E_WRAPPER_CALL_TRACE.json') | Select Length,Name`
>
> </details>
</details>

**Veredicto: PARTIAL GO.** El wrapper superó la comparación para este fixture: el harness de referencia y dos ejecuciones instrumentadas produjeron exactamente el mismo SHA-256 (`74e7e0f…d67765ca8`), con 540 estados Classic y contenido y orden de eventos idénticos.

Identifiqué `E$` en el prototipo de `gameState.copy().physicsState`. En este harness se llamó 180 veces por escenario, una por cada `runSteps(1)`. La traza captura discos y planos justo antes y después de cada llamada. En el escenario 3, el límite del tick 4 muestra la velocidad Y pasar de `48.51495` a `0` y la posición Y terminar en `160`.

Eso **no** revela la operación interna que produjo el cambio, ni la penetración o el impulso durante el contacto. Tampoco probé deliberadamente la ruta de excepción; el wrapper la conserva por construcción al volver a lanzar el mismo error, pero no afirmo que ese caso haya sido validado experimentalmente. Por estas limitaciones, la captura no resuelve la divergencia ni demuestra todavía una traza interna completa.

Entregables creados:

- [Implementación del wrapper](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_E_WRAPPER_IMPLEMENTATION.md>)
- [Validación](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_E_WRAPPER_VALIDATION.json>)
- [Traza de llamadas del escenario 3](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_E_WRAPPER_CALL_TRACE.json>)
- [Captura del escenario 3](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_E_SCENARIO3_CAPTURE.json>)
- [Decisión](</C:/Users/User/Documents/Codex/2026-11-17/referenced-chatgpt-conversation-this-is-an/outputs/PHASE3_E_WRAPPER_DECISION.md>)

La instalación original quedó intacta y el wrapper solo vive en la copia temporal. No ejecuté A–F ni modifiqué producción. Studio no se usó; el lugar sigue sin guardar ni publicar.
