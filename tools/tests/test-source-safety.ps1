Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Assert-FileExists {
    param(
        [string] $Path,
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Description`: $Path"
    }
}

function Assert-TextContains {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -notmatch $Pattern) {
        throw "Missing $Description"
    }
}

function Assert-TextDoesNotContain {
    param(
        [string] $Text,
        [string] $Pattern,
        [string] $Description
    )

    if ($Text -match $Pattern) {
        throw "Unexpected $Description"
    }
}

function Read-JsonFile {
    param([string] $Path)

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

function Assert-SetupPresetRoles {
    param(
        [string] $PresetName,
        [string] $FunctionPath,
        [string[]] $Roles
    )

    Assert-FileExists $FunctionPath "$PresetName setup preset function"
    $text = Get-Content -LiteralPath $FunctionPath -Raw

    Assert-TextContains $text 'function botc_patch:setup/clear_known_roles' "$PresetName clears previous setup roles"
    Assert-TextDoesNotContain $text 'function botc_patch:setup/preset\s' "$PresetName calls command-heavy script import wrapper"
    Assert-TextContains $text 'function ct:admin/setup/set_from_menu' "$PresetName syncs Sybillian role storage"
    $scriptId = [System.IO.Path]::GetFileNameWithoutExtension($FunctionPath)
    Assert-TextContains $text "function botc_patch:setup/script/$scriptId" "$PresetName rebuilds complete Sybillian script state"
    Assert-TextDoesNotContain $text 'data modify storage ct:script in_characters set value' "$PresetName bypasses the shared script-state transaction"
    Assert-TextDoesNotContain $text 'item modify entity' "$PresetName patches only the visible Script item"

    foreach ($role in $Roles) {
        Assert-TextContains $text "scoreboard players set $role role_list 1" "$PresetName enables $role in role_list"
    }
}

$dataRootTest = Join-Path $PSScriptRoot "test-data-root.ps1"
$startupTest = Join-Path $PSScriptRoot "test-startup-scripts.ps1"
$commandTest = Join-Path $PSScriptRoot "test-command-overlays.ps1"
$playerFacingMessageStyleTest = Join-Path $PSScriptRoot "test-player-facing-message-style.ps1"
$upstreamCallerPolicyTest = Join-Path $PSScriptRoot "test-upstream-caller-policy.ps1"
$customScriptImportTest = Join-Path $PSScriptRoot "test-custom-script-import-json.ps1"
$grimCharacterEditorTest = Join-Path $PSScriptRoot "test-grim-character-editor.ps1"
$storytellerPlayerDialogTest = Join-Path $PSScriptRoot "test-storyteller-player-dialogs.ps1"
$storytellerActionDialogTest = Join-Path $PSScriptRoot "test-storyteller-action-dialogs.ps1"
$teleportToolsTest = Join-Path $PSScriptRoot "test-teleport-tools.ps1"
$seatLayoutTest = Join-Path $PSScriptRoot "test-seat-layouts.ps1"
$dialogActionLifecycleTest = Join-Path $PSScriptRoot "test-dialog-action-lifecycle.ps1"
$passageTest = Join-Path $PSScriptRoot "test-storyteller-passage.ps1"
$gameStateInvariantTest = Join-Path $PSScriptRoot "test-game-state-invariants.ps1"
$bansheeTest = Join-Path $PSScriptRoot "test-banshee.ps1"
$alhadikhiaAnnouncementTest = Join-Path $PSScriptRoot "test-alhadikhia-announcement.ps1"
$grimRescindTest = Join-Path $PSScriptRoot "test-grim-rescind.ps1"
$winnerFireworkInventoryTest = Join-Path $PSScriptRoot "test-winner-fireworks-and-start-inventory.ps1"
$upstreamContractTest = Join-Path $PSScriptRoot "test-upstream-contract.ps1"
$yawpStartupCompatibilityTest = Join-Path $PSScriptRoot "test-yawp-startup-compatibility.ps1"
$nightChatTest = Join-Path $PSScriptRoot "test-night-chat.ps1"
$wraithTest = Join-Path $PSScriptRoot "test-wraith.ps1"
$spyWidowGrimoireTest = Join-Path $PSScriptRoot "test-spy-widow-grimoire.ps1"
$madnessExecutionTest = Join-Path $PSScriptRoot "test-madness-execution.ps1"
$storytellerRoleNotificationTest = Join-Path $PSScriptRoot "test-storyteller-role-notifications.ps1"
$boomdandyAndNominationKillsTest = Join-Path $PSScriptRoot "test-boomdandy-and-nomination-kills.ps1"
$storytellerRpsTest = Join-Path $PSScriptRoot "test-storyteller-rps.ps1"
$buffetGamemodeTest = Join-Path $PSScriptRoot "test-buffet-gamemodes.ps1"
$draftRandomizationModelTest = Join-Path $PSScriptRoot "test-draft-randomization-model.ps1"
$funDrunkTest = Join-Path $PSScriptRoot "test-fun-drunk.ps1"
$funSlayerTest = Join-Path $PSScriptRoot "test-fun-slayer.ps1"
$funToyboxTest = Join-Path $PSScriptRoot "test-fun-toybox.ps1"
$commandBudgetTest = Join-Path $PSScriptRoot "test-command-budget.ps1"
$resourcepackTest = Join-Path $PSScriptRoot "test-resourcepack-mappings.ps1"
$dialogUiMusicTest = Join-Path $PSScriptRoot "test-dialog-ui-and-music.ps1"
$publicPackageResourcepackTest = Join-Path $PSScriptRoot "test-public-package-resourcepack.ps1"
$toolItemRegistryTest = Join-Path $PSScriptRoot "test-tool-item-registry.ps1"
$worldTemplateManifestTest = Join-Path $PSScriptRoot "test-world-template-manifest.ps1"
$publicConfigHygieneTest = Join-Path $PSScriptRoot "test-public-config-hygiene.ps1"
$publicRepositoryHygieneTest = Join-Path $PSScriptRoot "test-public-repository-hygiene.ps1"
$toolItemGenerator = Join-Path $RepoRoot "tools/generate-tool-items.ps1"
$codeLibraryGenerator = Join-Path $RepoRoot "tools/update-code-library.ps1"
$sourceBaseline = Join-Path $RepoRoot "tools/update-source-baseline.ps1"
$ownershipTest = Join-Path $PSScriptRoot "test-source-ownership.ps1"
$todoFile = Join-Path $RepoRoot "docs/project-notes/plugin-todo.md"
$featureMap = Join-Path $RepoRoot "docs/code-library/feature-map.md"
$launcherSource = Join-Path $RepoRoot "launcher/exe/BotcLauncher.cs"
$composeFile = Join-Path $RepoRoot "launcher/compose.yml"
$commandsRoot = Join-Path $RepoRoot "Jays-Patch/melius-commands/commands"
$resourceItemsRoot = Join-Path $RepoRoot "Jays-Patch/resourcepack/assets/minecraft/items"
$roleIconsFile = Join-Path $RepoRoot "Jays-Patch/role-icons.json"
$generatedRoot = Join-Path $RepoRoot "docs/code-library/generated"
$hasPrivateDocs = Test-Path -LiteralPath (Join-Path $RepoRoot "docs") -PathType Container
$datapackFunctionRoot = Join-Path $RepoRoot "Jays-Patch/datapack/data/botc_patch/function"
$tickFunction = Join-Path $datapackFunctionRoot "tick.mcfunction"
$loadFunction = Join-Path $datapackFunctionRoot "load.mcfunction"
$setupSignFunctionRoot = Join-Path $datapackFunctionRoot "setup_sign"
$grimDialogFunction = Join-Path $datapackFunctionRoot "grim/dialog.mcfunction"
$grimDialogRoot = Join-Path $datapackFunctionRoot "grim/dialog"
$grimSweepFinishFunction = Join-Path $datapackFunctionRoot "grim/sweep/finish.mcfunction"
$grimDevProofPattern = 'disabled_(button|state)_test|dev_disabled_(button|state)_test'

Assert-FileExists $dataRootTest "live data-root safety test"
Assert-FileExists $startupTest "startup smoke test"
Assert-FileExists $commandTest "command overlay safety test"
Assert-FileExists $playerFacingMessageStyleTest "player-facing message style test"
Assert-FileExists $upstreamCallerPolicyTest "upstream caller capability policy test"
Assert-FileExists $customScriptImportTest "custom script import JSON test"
Assert-FileExists $grimCharacterEditorTest "Reveal Grimoire character editor test"
Assert-FileExists $storytellerPlayerDialogTest "Storyteller teleport player dialog test"
Assert-FileExists $storytellerActionDialogTest "Storyteller action player-dialog test"
Assert-FileExists $teleportToolsTest "Storyteller teleport tool test"
Assert-FileExists $seatLayoutTest "symmetric physical seat-layout test"
Assert-FileExists $dialogActionLifecycleTest "dialog action lifecycle test"
Assert-FileExists $passageTest "Storyteller's Passage state-machine test"
Assert-FileExists $gameStateInvariantTest "critical game-state invariant test"
Assert-FileExists $bansheeTest "Banshee adapter test"
Assert-FileExists $alhadikhiaAnnouncementTest "Al-Hadikhia announcement test"
Assert-FileExists $grimRescindTest "Storyteller Tools rename and grimoire rescind test"
Assert-FileExists $winnerFireworkInventoryTest "winner fireworks and new-game inventory safety test"
Assert-FileExists $upstreamContractTest "Sybillian upstream compatibility contract test"
Assert-FileExists $yawpStartupCompatibilityTest "parse-safe YAWP startup compatibility test"
Assert-FileExists $nightChatTest "active Night Chat compatibility test"
Assert-FileExists $wraithTest "Wraith adapter and state-machine test"
Assert-FileExists $spyWidowGrimoireTest "Spy and Widow personal-Grimoire test"
Assert-FileExists $madnessExecutionTest "guarded Cerenovus madness execution test"
Assert-FileExists $storytellerRoleNotificationTest "one-time Storyteller role notification test"
Assert-FileExists $boomdandyAndNominationKillsTest "Boomdandy final-three and nomination role-kill test"
Assert-FileExists $storytellerRpsTest "Storyteller RPS broker test"
Assert-FileExists $buffetGamemodeTest "Greedy and Draft Buffet gamemode test"
Assert-FileExists $draftRandomizationModelTest "Draft randomization deterministic model test"
Assert-FileExists $funDrunkTest "Drunk fun command and consumable test"
Assert-FileExists $funToyboxTest "fun toybox and entrance test"
Assert-FileExists $commandBudgetTest "command-budget safety test"
Assert-FileExists $resourcepackTest "resource-pack mapping test"
Assert-FileExists $dialogUiMusicTest "dialog UI and music catalog test"
Assert-FileExists $publicPackageResourcepackTest "public package resource-pack safety test"
Assert-FileExists $toolItemRegistryTest "tool item registry test"
Assert-FileExists $worldTemplateManifestTest "world-template release manifest test"
Assert-FileExists $publicConfigHygieneTest "public configuration hygiene test"
Assert-FileExists $publicRepositoryHygieneTest "public repository hygiene test"
Assert-FileExists $toolItemGenerator "tool item generator"
Assert-FileExists $codeLibraryGenerator "generated code-library updater"
Assert-FileExists $sourceBaseline "known-good source baseline tool"
Assert-FileExists $ownershipTest "source ownership test"
if ($hasPrivateDocs) {
    Assert-FileExists $todoFile "Jay's Patch TODO"
    Assert-FileExists $featureMap "code-library feature map"
}
Assert-FileExists $launcherSource "standalone launcher source"
Assert-FileExists $composeFile "Docker compose file"
Assert-FileExists $roleIconsFile "role icon source table"
Assert-FileExists $tickFunction "Jay's Patch tick function"
Assert-FileExists $loadFunction "Jay's Patch load function"
Assert-FileExists $grimDialogFunction "stable grimoire reveal dialog function"
Assert-FileExists $grimSweepFinishFunction "grimoire sweep finish function"

$invalidExecuteChains = @(
    Get-ChildItem -LiteralPath $datapackFunctionRoot -Filter "*.mcfunction" -File -Recurse |
        Select-String -Pattern '\brun\s+(if|unless)\s+(data|score|entity|block|blocks|predicate)\b'
)
if ($invalidExecuteChains.Count -gt 0) {
    $details = $invalidExecuteChains |
        ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    throw "Invalid Minecraft execute chain detected. Use 'execute if ... if ... run ...', not 'execute if ... run if ...'.`n$($details -join "`n")"
}

$invalidMacroCommands = [System.Collections.Generic.List[string]]::new()
foreach ($file in Get-ChildItem -LiteralPath $datapackFunctionRoot -Filter "*.mcfunction" -File -Recurse) {
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        if ($line.StartsWith('$') -and $line -notmatch '\$\([^)]+\)') {
            $relative = $file.FullName.Substring($datapackFunctionRoot.Length).TrimStart('\', '/')
            $invalidMacroCommands.Add("$relative`:$lineNumber`: $line")
        }
    }
}
if ($invalidMacroCommands.Count -gt 0) {
    throw "Datapack macro command(s) contain no macro variables. Remove the leading `$ or add a valid `$()` substitution:`n$($invalidMacroCommands -join "`n")"
}

$adjacentDuplicateCommands = [System.Collections.Generic.List[string]]::new()
foreach ($file in Get-ChildItem -LiteralPath $datapackFunctionRoot -Filter "*.mcfunction" -File -Recurse) {
    $lines = @(Get-Content -LiteralPath $file.FullName)
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $previous = $lines[$index - 1].Trim()
        $current = $lines[$index].Trim()
        if ($current.Length -gt 0 -and -not $current.StartsWith("#") -and $current -ceq $previous) {
            $relative = $file.FullName.Substring($datapackFunctionRoot.Length).TrimStart('\', '/')
            $adjacentDuplicateCommands.Add("$relative`:$($index + 1): $current")
        }
    }
}
if ($adjacentDuplicateCommands.Count -gt 0) {
    throw "Adjacent duplicate datapack command(s) detected:`n$($adjacentDuplicateCommands -join "`n")"
}

& $dataRootTest
& $startupTest
& $commandTest
& $playerFacingMessageStyleTest
& $upstreamCallerPolicyTest
& $customScriptImportTest
& $grimCharacterEditorTest
& $storytellerPlayerDialogTest
& $storytellerActionDialogTest
& $teleportToolsTest
& $seatLayoutTest
& $dialogActionLifecycleTest
& $passageTest
& $gameStateInvariantTest
& $bansheeTest
& $alhadikhiaAnnouncementTest
& $grimRescindTest
& $winnerFireworkInventoryTest
& $upstreamContractTest
& $yawpStartupCompatibilityTest
& $nightChatTest
& $wraithTest
& $spyWidowGrimoireTest
& $madnessExecutionTest
& $storytellerRoleNotificationTest
& $boomdandyAndNominationKillsTest
& $storytellerRpsTest
& $buffetGamemodeTest
& $draftRandomizationModelTest
& $funDrunkTest
& $funSlayerTest
& $funToyboxTest
& $commandBudgetTest
& $dialogUiMusicTest
& $resourcepackTest
if ($env:BOTC_SKIP_PUBLIC_PACKAGE -ne "1") {
    & $publicPackageResourcepackTest
}
& $toolItemRegistryTest
& $toolItemGenerator -Check
if ($hasPrivateDocs) {
    & $codeLibraryGenerator -Check
}
& $worldTemplateManifestTest
& $publicConfigHygieneTest
& $publicRepositoryHygieneTest
if ($env:BOTC_SKIP_SOURCE_BASELINE -ne "1") {
    & $sourceBaseline -Check
}
& $ownershipTest

$launcherText = Get-Content -LiteralPath $launcherSource -Raw
Assert-TextContains $launcherText 'values\["function-permission-level"\]\s*=\s*"3"' "function-permission-level ownership"
Assert-TextContains $launcherText 'values\["spawn-protection"\]\s*=\s*"0"' "spawn-protection ownership"
Assert-TextContains $launcherText "function botc_patch:startup/yawp_init" "YAWP final-sync wrapper command"
Assert-TextContains $launcherText "scoreboard players set yawp_startup_done botc_patch 1" "launcher marks datapack YAWP fallback complete"

$composeText = Get-Content -LiteralPath $composeFile -Raw
Assert-TextContains $composeText 'image:\s*itzg/minecraft-server@sha256:[0-9a-f]{64}' "pinned Minecraft Docker image digest"
Assert-TextDoesNotContain $composeText 'image:\s*itzg/minecraft-server:latest' "floating Minecraft Docker image tag"
if ($composeText -match "RCON_CMDS_STARTUP|ct:admin/init/yawp_") {
    throw "Docker compose should not run duplicate YAWP startup commands; BOTC.exe Final Sync owns them"
}

foreach ($file in Get-ChildItem -LiteralPath $commandsRoot -Filter "*.json" -File) {
    [void] (Read-JsonFile $file.FullName)
}

if (Test-Path -LiteralPath $resourceItemsRoot -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $resourceItemsRoot -Filter "*.json" -File) {
        [void] (Read-JsonFile $file.FullName)
    }
}

[void] (Read-JsonFile $roleIconsFile)

$tickText = Get-Content -LiteralPath $tickFunction -Raw
if ($tickText -match 'setup_sign') {
    throw "Retired setup-sign system is still wired into botc_patch:tick"
}

$loadText = Get-Content -LiteralPath $loadFunction -Raw
if ($loadText -match 'scoreboard objectives add setup_sign') {
    throw "Retired setup_sign trigger objective is still created by botc_patch:load"
}
Assert-TextContains $loadText 'scoreboard objectives add botc_setup_bridge_cd dummy' "setup bridge cooldown scoreboard objective"
Assert-TextContains $tickText 'botc_setup_bridge_cd=1\.\.' "setup bridge cooldown countdown in tick"

$retiredDeadFunctions = @(
    "music/play_to_self.mcfunction",
    "owner/add.mcfunction",
    "owner/remove.mcfunction",
    "setup/role_0.mcfunction",
    "setup/role_1.mcfunction",
    "storyteller/add.mcfunction",
    "storyteller/remove.mcfunction",
    "storyteller_tools/kill_menu/dialog/count_0.mcfunction",
    "storyteller_tools/nomination_menu/dialog/count_0.mcfunction",
    "storyteller_tools/revive_menu/dialog/count_0.mcfunction"
)
foreach ($relativePath in $retiredDeadFunctions) {
    $retiredPath = Join-Path $datapackFunctionRoot $relativePath
    if (Test-Path -LiteralPath $retiredPath) {
        throw "Retired dead function returned: $relativePath"
    }
}

$botcCommandText = Get-Content -LiteralPath (Join-Path $commandsRoot "botc.json") -Raw
Assert-TextDoesNotContain $botcCommandText $grimDevProofPattern "dev-only grimoire proof command in production overlay"
Assert-TextDoesNotContain $botcCommandText 'botc_patch:grim/dialog/group_' "grouped grimoire submenu bridge command"

$devProofFiles = @(
    Get-ChildItem -LiteralPath $datapackFunctionRoot -File -Recurse |
        Where-Object { $_.FullName -match $grimDevProofPattern }
)
if ($devProofFiles.Count -gt 0) {
    throw "Dev-only grimoire proof function(s) must not ship in production source: $($devProofFiles.FullName -join ', ')"
}

$grimDialogText = Get-Content -LiteralPath $grimDialogFunction -Raw
Assert-TextContains $grimDialogText 'function botc_patch:grim/dialog/count_1' "stable grimoire dialog dispatches through generated count functions"
Assert-TextDoesNotContain $grimDialogText $grimDevProofPattern "dev-only grimoire disabled proof wired into stable grimoire dialog"

$grimSweepFinishText = Get-Content -LiteralPath $grimSweepFinishFunction -Raw
Assert-TextContains $grimSweepFinishText 'function botc_patch:grim/dialog' "grimoire sweep returns to stable dialog after the intro"
Assert-TextDoesNotContain $grimSweepFinishText $grimDevProofPattern "dev-only grimoire disabled proof wired into sweep finish"

$oldCountFiles = @(Get-ChildItem -LiteralPath $grimDialogRoot -Filter "count_*.mcfunction" -File -ErrorAction SilentlyContinue)
if ($oldCountFiles.Count -ne 16) {
    throw "Expected 16 count-based grimoire dialog variants, found $($oldCountFiles.Count)"
}

$oldGroupedPaths = @(
    (Join-Path $grimDialogRoot "build_group_masks.mcfunction"),
    (Join-Path $grimDialogRoot "build_mask.mcfunction"),
    (Join-Path $grimDialogRoot "show_mask.mcfunction"),
    (Join-Path $grimDialogRoot "main"),
    (Join-Path $grimDialogRoot "mask"),
    (Join-Path $grimDialogRoot "group_1.mcfunction"),
    (Join-Path $grimDialogRoot "group_2.mcfunction"),
    (Join-Path $grimDialogRoot "group_3.mcfunction"),
    (Join-Path $grimDialogRoot "group_1"),
    (Join-Path $grimDialogRoot "group_2"),
    (Join-Path $grimDialogRoot "group_3")
)
foreach ($path in $oldGroupedPaths) {
    if (Test-Path -LiteralPath $path) {
        throw "Stale experimental grimoire dialog path still exists after stable generation: $path"
    }
}

foreach ($dialogFile in $oldCountFiles) {
    $dialogCountText = Get-Content -LiteralPath $dialogFile.FullName -Raw
    if ($dialogFile.BaseName -ne "count_0") {
        Assert-TextContains $dialogCountText '/botc grimoire reveal_seat_' "stable generated grimoire dialog reveal command in $($dialogFile.Name)"
    }
    Assert-TextDoesNotContain $dialogCountText $grimDevProofPattern "dev-only grimoire disabled proof wired into $($dialogFile.Name)"
}

$presetRoot = Join-Path $datapackFunctionRoot "setup/preset"
$presetWrapper = Join-Path $datapackFunctionRoot "setup/preset_compat.mcfunction"
Assert-FileExists $presetWrapper "legacy setup preset compatibility shim"
$presetWrapperText = Get-Content -LiteralPath $presetWrapper -Raw
Assert-TextContains $presetWrapperText 'setup_preset_match' "legacy setup preset shim dispatches through known built-in presets"
Assert-TextContains $presetWrapperText 'botc_patch:setup/bridge/import_full' "legacy setup preset shim falls back to the throttled safe custom import bridge"
Assert-TextContains $presetWrapperText 'botc_patch:setup/bridge/preset/trouble_brewing' "legacy setup preset shim uses throttled Trouble Brewing preset bridge"
Assert-TextDoesNotContain $presetWrapperText 'ct:admin/setup/(initial_load|convert_to_ids)' "legacy setup preset shim avoids Sybillian recursive import helpers"

$setupBridgeRoot = Join-Path $datapackFunctionRoot "setup/bridge"
$requiredSetupBridgeFiles = @(
    "apply.mcfunction",
    "clear.mcfunction",
    "import_full.mcfunction",
    "preset/trouble_brewing.mcfunction",
    "preset/sects_and_violets.mcfunction",
    "preset/bad_moon_rising.mcfunction"
)

foreach ($bridgeFile in $requiredSetupBridgeFiles) {
    $bridgePath = Join-Path $setupBridgeRoot $bridgeFile
    Assert-FileExists $bridgePath "throttled setup bridge $bridgeFile"
    $bridgeText = Get-Content -LiteralPath $bridgePath -Raw
    Assert-TextContains $bridgeText 'botc_setup_bridge_cd' "throttled setup bridge cooldown in $bridgeFile"
}
Assert-SetupPresetRoles "Trouble Brewing" (Join-Path $presetRoot "trouble_brewing.mcfunction") @(
    "washerwoman", "librarian", "investigator", "chef", "empath", "fortune_teller",
    "undertaker", "monk", "ravenkeeper", "virgin", "slayer", "soldier", "mayor",
    "butler", "drunk", "recluse", "saint", "poisoner", "spy", "scarlet_woman",
    "baron", "imp"
)
Assert-SetupPresetRoles "Sects and Violets" (Join-Path $presetRoot "sects_and_violets.mcfunction") @(
    "clockmaker", "dreamer", "snake_charmer", "mathematician", "flowergirl",
    "town_crier", "oracle", "savant", "seamstress", "philosopher", "artist",
    "juggler", "sage", "mutant", "sweetheart", "barber", "klutz", "evil_twin",
    "witch", "cerenovus", "pit_hag", "fang_gu", "vigormortis", "no_dashii",
    "vortox"
)
Assert-SetupPresetRoles "Bad Moon Rising" (Join-Path $presetRoot "bad_moon_rising.mcfunction") @(
    "grandmother", "sailor", "chambermaid", "exorcist", "innkeeper", "gambler",
    "gossip", "courtier", "professor", "minstrel", "tea_lady", "pacifist",
    "fool", "tinker", "moonchild", "goon", "lunatic", "godfather",
    "devils_advocate", "assassin", "mastermind", "zombuul", "pukka",
    "shabaloth", "po"
)

if (Test-Path -LiteralPath $setupSignFunctionRoot) {
    $setupSignFiles = @(Get-ChildItem -LiteralPath $setupSignFunctionRoot -File -Recurse -ErrorAction SilentlyContinue)
    if ($setupSignFiles.Count -gt 0) {
        throw "Retired setup-sign function files still exist under $setupSignFunctionRoot"
    }
}

$requiredGeneratedFiles = @(
    "function-index.md",
    "command-index.md",
    "resourcepack-index.md"
)

if ($hasPrivateDocs) {
    foreach ($fileName in $requiredGeneratedFiles) {
        $path = Join-Path $generatedRoot $fileName
        Assert-FileExists $path "generated code-library index"
    }
}

Write-Host "Source-only safety checks passed." -ForegroundColor Green
