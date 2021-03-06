MEmu = MUGEN
MEmuV = N/A
MURL = http://www.elecbyte.com/
MAuthor = brolly & djvj
MVersion = 2.0
MCRC = FA399B17
iCRC = DB922C06
MID = 635038268906726252
MSystem = "MUGEN"
;----------------------------------------------------------------------------
; Notes:
; Default location to launch the games will be in your romPath with a subfolder for each game (named after the rom in the xml).
; Each game's folder, should contain a MUGEN.exe

; If you don't want to use the above path/exe, create an ini in the folder of this module with the same name as this module.
; Place each game in it using the example below. gamePath should start from your romPath and end with the exe to the game.
; moduleName ini contains an entry for each game, pointing to the MUGEN.exe
; It can also contain an exitHack setting which can be 1 or 0, typically you only add these to mugen 1.0+ games and set it to 0
; This will override the whole exit hack code needed for older mugen versions
; example:
;
; [Bastard]
; gamePath = Bastard\WinBastard.exe
; [Street Fighter Legends]
; gamePath = Street Fighter Legends\mugen.exe
; exitHack = 0
;
; emuPath and exe need to point to a dummy exe, like PCLauncher.exe
; romPath needs to point to the dir with all the blank txt files and the settings.ini
; Escape will only close the game from the main menu, it is needed for in-game menu usage otherwise.
; Fullscreen and controls are done via in-game options for each game. To speed up configuring of games, configure one game then save its settings to a default.cfg and paste it into each game's Saves folder.
; Controls are done via in-game options for each game.
; Larger games are inherently slower to load, this is MUGEN, nothing you can do about it but get a faster HD.
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
remapWinKeys := IniReadCheck(settingsFile, "Settings", "remapWinKeys","true",,1) 	; This remaps windows Start keys to Return to prevent accidental leaving of game
gamePath := IniReadCheck(settingsFile, romName, "gamePath",A_Space,,1)
exitHack := IniReadCheck(settingsFile, romName, "exitHack","1",,1)

gamePath := romPath . "\" . (If (!gamePath or gamePath = "ERROR") ? (romName . "\MUGEN.exe") : (gamePath))
CheckFile(gamePath,"Could not find " . gamePath . "`nPlease place your game in it's own folder in your Rom_Path or define a custom gamePath in " . SettingsFile)
SplitPath, gamePath,gExe, gPath

7z(romPath, romName, romExtension, 7zExtractPath)

; This remaps windows Start keys to Return to prevent accidental leaving of game
If remapWinKeys = true
{	Hotkey, RWin, WinRemap
	Hotkey, LWin, WinRemap
}

Err := Run(gExe, gPath, "UseErrorLevel", game_PID)
If Err
	ScriptError("Failed to launch " . romName)

WinWait("ahk_pid " . game_PID)
WinWaitActive("ahk_pid " . game_PID)

WinGetTitle, gameTitle, ahk_pid %game_PID%

FadeInExit()

If ( exitHack = 1)	; Sometimes mugen crashes during exit and doesn't close, so we need to do a workaround to detect it, this doesn't seem to happen on MUGEN 1.0
{	If gameTitle != HyperSpin	; If the user exited mugen in under 1500ms then we don't need to do this otherwise the script would hang
		IfWinExist, %gameTitle%
			Loop {
				Sleep, 1000
				WinGet, gameState, MinMax, %gameTitle%
				If ( gameState != 1 )	; Mugen window minimized or closed
					Break
			}

	Sleep 2000
	If gameTitle != HyperSpin
		IfWinExist, %gameTitle%
		{	
			FadeOutExit()	; this needs to be on its own line so it does not error
			Process("Close", game_PID)
		}
	Process("Close", executable) ;on some machines/games, MUGEN doesn't close itself properly, this is the work around to make sure it does
} Else
	Process("WaitClose", game_PID)

7zCleanUp()
FadeOutExit()
ExitModule()


WinRemap:
Return

CloseProcess:
	FadeOutStart()
	WinClose(gameTitle  . " ahk_pid " . game_PID)
Return
