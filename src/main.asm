
include irvine32.inc

;include \masm32\lib\kernel32.lib


WriteConsoleW PROTO, hOut:DWORD, lpBuf:PTR WORD, nChars:DWORD, lpWritten:PTR DWORD, lpRes:DWORD


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Vars +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.data

waitingMsj BYTE "Waiting oponents response", 0
dotText BYTE ".", 0
ingresarPieza BYTE "Seleccione una casilla: ", 0
ingresarDestino BYTE "Seleccione el destino: ", 0
casillaEquivocada BYTE "No puedes moverte a esa casilla", 0
casillaVacia BYTE "No hay ninguna pieza en esa casilla", 0

selectColor1 BYTE "Color of the pieces: ", 0
selectColor2 BYTE "Color of the squares: ", 0

cantCapture BYTE "No puedes capturar tus propias piezas", 0

colorWhites db 16h
colorBlacks db 61h

typeColorOfPiece1 BYTE ?
typeColorOfPiece2 BYTE ?

kingRows db 1, 1, 0, -1, -1, -1, 0, 1
kingColumns db 0, 1, 1, 1, 0, -1, -1, -1

knightRows db 2, 2, -2, -2, 1, -1, 1, -1
knightColumns db 1, -1, -1, 1, -2, -2, 2, 2

bishopRows db 1, 1, -1, -1
bishopColumns db 1, -1, 1, -1

rookRows db 1, 0, -1, 0
rookColumns db 0, 1, 0, -1

addOrSub db 1, -1

counterStrike db ?

bufferSelection db 3 dup(?)
bufferSelection2 db 3 dup(?)
buffer db 3 dup(?) 
temporalColumn db ?
temporalRow db ?
typeTemporal db ?
temporalIndex DWORD ?
newColumn db ?
newRow db ?
temporalPawn db ?

queenMove db 0

numberToString BYTE "0"
bufsize = ($ - numberToString)


pieza STRUC
    color BYTE ?
    tipoPieza db ?
    coordenadaX db ?
    coordenadaY db ?
    columna BYTE ?
    fila db ?    
pieza ENDS

jugador1 pieza 64 DUP(<0>)

glyphChar    WORD ?, 20h
glyphWritten DWORD ?

; ------------------------------------------------------------------ First Screen -----------------------------------------------------------------


firstScreen BYTE 201, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205, 205, 205, 205, 205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205,  205, 205, 205, 205, 205
BYTE 177, 177, 177, 177, 177, 177, 205, 205, 205,  205, 205, 205, 205, 205, 187, 0DH, 0AH

BYTE 186, " By: Mario Andr", 130, "s Rojas Varela                                                                       ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "     ", 186, 0DH, 0AH

BYTE 186, " & Sebasti", 160, "n Josu", 130, " Sand", 161, " Blanco                                                                      ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "     ", 186, 0DH, 0AH

BYTE 186, "                                                                                                        ", 177, 177, 177, 177, 177, 177, "        ", 186, 0DH, 0AH

BYTE 186, "                                                                                                        ", 177, 177, 177, 177, 177, 177, "        ", 186, 0DH, 0AH

BYTE 186, "                                                                                               ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 0DH, 0AH

BYTE 186, "                                                                                                 ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, " ", 186, 0DH, 0AH

BYTE 186, "                                                                                                   ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "   ", 186, 0DH, 0AH

BYTE 186, "       ", 177, 177, 177, 177, 177, "                                                                                        ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "    ", 186, 0DH, 0AH

BYTE 186, "   ", 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                                          ", 186, 0DH, 0AH

BYTE 186, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                     ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "   ", 186, 0DH, 0AH

BYTE 186, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                                    ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "  ", 177, 177, 177, 177, 177, 177, 177, "                                                                                 ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                 ", 176, 178, 178, 176, 176, 178, 187, 176, 176, 187, "  ", 176, 178, 187, 176, 176, 178, 178
BYTE 176, 176, 178, 187, 176, 176, 178, 178, 176, 176, 178, 187, 176, 176, 178, 178, 176, 176, 178, 187, "                      ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "              ", 178, 178, 201, 205, 205, 205, 205, 188, 178, 178, 186, "  ", 178, 176, 186, 178
BYTE 178, 201, 205, 205, 205, 205, 188, 178, 178, 201, 205, 205, 205, 205, 188, 178, 178, 201, 205, 205, 205, 205, 188, "                      ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "    ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "              ", 176, 176, 186, "     ", 176, 176, 178, 178, 176, 176, 178, 186, 176, 176, 178, 178, 176, 187
BYTE "  ", 176, 176, 178, 178, 176, 176, 178, 187, 176, 176, 178, 178, 176, 176, 178, 187, "                      ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "       ", 177, 177, 177, 177, 177, 177, 177, 177, "               ",  178, 178, 186, "     ", 178, 178, 201, 205, 205, 178, 176, 186, 178, 178, 201, 205, 205, 188, "  ", 200, 205
BYTE 205, 205, 205, 178, 176, 186, 200, 205, 205, 205, 205, 178, 176, 186, "                      ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                             ", 200, 176, 178, 178, 176, 176, 178, 187, 176, 176, 186, "  ", 176, 178, 186, 176, 176, 178, 178, 176, 176, 178, 187, 176, 176, 178, 178, 176
BYTE 176, 178, 186, 176, 176, 178, 178, 176, 176, 178, 186, "                      ", 177, 177, 177, 177, 177, 177, 177, 177, "       ", 186, 0DH, 0AH

BYTE 186, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                            ", 200, 205, 205, 205, 205, 205, 188, 200, 205, 188, "  ", 200, 205, 188, 200, 205, 205, 205, 205, 205, 205, 188, 200, 205, 205, 205
BYTE 205, 205, 205, 188, 200, 205, 205, 205, 205, 205, 205, 188, "                     ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "      ", 186, 0DH, 0AH

BYTE 186, " ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                      ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "      ", 186, 0DH, 0AH

BYTE 186, "  ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                   ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "     ", 186, 0DH, 0AH

BYTE 186, "  ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                           Press any key to continue...                        ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "   ", 186, 0DH, 0AH

BYTE 186, "    ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                                ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "  ", 186, 0DH, 0AH

BYTE 186, "                                                                                                                      ", 186, 0DH, 0AH

BYTE 186, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "                                                                          ", 177, 177, 177, 177, 177, 177, 177, 177, 177
BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 186, 0DH, 0AH

BYTE 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 0DH, 0AH, 0

; -------------------------------------------------------------------------------------------------------------------------------------------------



; ---------------------------------------------------------------------- Menu ---------------------------------------------------------------------

; ********************* Menu title text *********************
menu BYTE "                              ", 177, 177, "  ", 177, 177, "  ", 177, 177, "                                         ", 177, 177, "  ", 177, 177, "  ", 177, 177, 0DH, 0AH
BYTE "                              ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "  ", 219, 219, 219, "    ", 219, 219, 219, " ", 219, 219, 219, 219, 219, 219, 219, " ", 219
BYTE 219, 219, "    ", 219, 219, " ", 219, 219, "    ", 219, 219, "  ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 0DH, 0AH

BYTE "                                ", 177, 177, 177, 177, 177, 177, "    ", 219, 219, 219, 219, "  ", 219, 219, 219, 219, " ", 219, 219, "      ", 219, 219, 219, 219, "   ", 219
BYTE 219, " ", 219, 219, "    ", 219, 219, "    ", 177, 177, 177, 177, 177, 177, 0DH, 0AH

BYTE "                                ", 177, 177, 177, 177, 177, 177, "    ", 219, 219, " ", 219, 219, 219, 219, " ", 219, 219, " ", 219, 219, 219, 219, 219, "   ", 219, 219, " ", 219
BYTE 219, "  ", 219, 219, " ", 219, 219, "    ", 219, 219, "    ", 177, 177, 177, 177, 177, 177, 0DH, 0AH

BYTE "                                ", 177, 177, 177, 177, 177, 177, "    ", 219, 219, "  ", 219, 219, "  ", 219, 219, " ", 219, 219, "      ", 219, 219, "  ", 219, 219, " ", 219
BYTE 219, " ", 219, 219, "    ", 219, 219, "    ", 177, 177, 177, 177, 177, 177, 0DH, 0AH

BYTE "                              ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, "  ", 219, 219, "      ", 219, 219, " ", 219, 219, 219, 219, 219, 219, 219, " ", 219, 219
BYTE "   ", 219, 219, 219, 219, "  ", 219, 219, 219, 219, 219, 219, "   ", 177, 177, 177, 177, 177, 177, 177, 177, 177, 177, 0DH, 0AH, 0

; ********************* Menu options *********************
newGameMessage BYTE "                       1. New Game                          ", 0

gameHistoryMessage BYTE "                       2. Game History                      ", 0

settingsMessage BYTE "                       3. Settings                          ", 0

exitMessage BYTE "                       4. Exit                              ", 0

; ********************* Other messages *********************
selectMessage BYTE "Please, select an option [1-4]: ", 0

invalidOptionMessage BYTE "*Enter a valid option of the menu!", 0

newLine  BYTE "                                  ", 0

menuOption BYTE 0

; ********************* Options box *********************
optionsBox BYTE "                             ", 201, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 187, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 186, "                                                              ", 186, 0DH, 0AH

BYTE "                             ", 200, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205
BYTE 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 188, 0DH, 0AH, 0

; -------------------------------------------------------------------------------------------------------------------------------------------------

                                           

; --------------------------------------------------------------------- Board ---------------------------------------------------------------------

chessBox BYTE "       ", 0
miniChessBox BYTE "  ", 0

chessBoardColumns BYTE "      A      B      C      D      E      F      G      H", 0DH, 0AH, 0
chessBoardColumns2 BYTE "      H      G      F      E      D      C      B      A", 0DH, 0AH, 0

chessBoardRows DWORD " 8 ", " 7 ", " 6 ", " 5 ", " 4 ", " 3 ", " 2 ", " 1 ", "   "
chessBoardRows2 DWORD " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", "   "
temporalBoardRows DWORD ?
temporalBoardColumns DWORD ?

; -------------------------------------------------------------------------------------------------------------------------------------------------





; --------------------------------------------------------------- You Win Screen ----------------------------------------------------------------

youWinMessage BYTE "____    ____  ______    __    __     ____    __    ____  __  .__   __.  __ ", 0DH, 0AH
BYTE "\   \  /   / /  __  \  |  |  |  |    \   \  /  \  /   / |  | |  \ |  | |  |", 0DH, 0AH
BYTE " \   \/   / |  |  |  | |  |  |  |     \   \/    \/   /  |  | |   \|  | |  |", 0DH, 0AH
BYTE "  \_    _/  |  |  |  | |  |  |  |      \            /   |  | |  .    | |  |", 0DH, 0AH
BYTE "    |  |    |  '--'  | |  '--'  |       \    /\    /    |  | |  |\   | |__|", 0DH, 0AH
BYTE "    |__|     \______/   \______/         \__/  \__/     |__| |__| \__| (__)", 0

; -------------------------------------------------------------------------------------------------------------------------------------------------





; --------------------------------------------------------------- Game Over Screen ----------------------------------------------------------------

gameOverMessage BYTE "  _______      ___      .___  ___.  _______      ______   ____    ____  _______ .______       __ ", 0DH, 0AH
BYTE " /  _____|    /   \     |   \/   | |   ____|    /  __  \  \   \  /   / |   ____||   _  \     |  |", 0DH, 0AH
BYTE "|  |  __     /  ^  \    |  \  /  | |  |__      |  |  |  |  \   \/   /  |  |__   |  |_)  |    |  |", 0DH, 0AH
BYTE "|  | |_ |   /  /_\  \   |  |\/|  | |   __|     |  |  |  |   \      /   |   __|  |      /     |  |", 0DH, 0AH
BYTE "|  |__| |  /  _____  \  |  |  |  | |  |____    |  '--'  |    \    /    |  |____ |  |\  \----.|__|", 0DH, 0AH
BYTE " \______| /__/     \__\ |__|  |__| |_______|    \______/      \__/     |_______|| _| '._____|(__)", 0

; -------------------------------------------------------------------------------------------------------------------------------------------------





; --------------------------------------------------------------- Draw Screen ----------------------------------------------------------------

drawMessage BYTE " _______  .______          ___   ____    __    ____  __ ", 0DH, 0AH
BYTE "|       \ |   _  \        /   \  \   \  /  \  /   / |  |", 0DH, 0AH
BYTE "|  .--.  ||  |_)  |      /  ^  \  \   \/    \/   /  |  |", 0DH, 0AH
BYTE "|  |  |  ||      /      /  /_\  \  \            /   |  |", 0DH, 0AH
BYTE "|  '--'  ||  |\  \----./  _____  \  \    /\    /    |__|", 0DH, 0AH
BYTE "|_______/ | _| '._____/__/     \__\  \__/  \__/     (__)", 0

; -------------------------------------------------------------------------------------------------------------------------------------------------





; --------------------------------------------------------------- Customize Screen ----------------------------------------------------------------
 
customizeScreen1 BYTE "                        ___  _  _  ____  ____  __   _  _  __  ____  ____", 0DH, 0AH
BYTE "                       / __)/ )( \/ ___)(_  _)/  \ ( \/ )(  )(__  )(  __)", 0DH, 0AH
BYTE "                      ( (__ ) \/ (\___ \  )( (  O )/ \/ \ )(  / _/  ) _)", 0DH, 0AH
BYTE "                       \___)\____/(____/ (__) \__/ \_)(_/(__)(____)(____)", 0

customizeScreen2 BYTE "                                                                            _  _  __   _  _  ____ ", 0DH, 0AH
BYTE "                                                                           ( \/ )/  \ / )( \(  _ \", 0DH, 0AH
BYTE "                                                                            )  /(  O )) \/ ( )   /", 0DH, 0AH
BYTE "                                                                           (__/  \__/ \____/(__\_)", 0

customizeScreen3 BYTE "                                              ____   __    __   ____  ____ ", 0DH, 0AH
BYTE "                                             (  _ \ /  \  / _\ (  _ \(    \", 0DH, 0AH
BYTE "                                              ) _ ((  O )/    \ )   / ) D |", 0DH, 0AH
BYTE "                                             (____/ \__/ \_/\_/(__\_)(____/", 0



optionSquare1 BYTE "                          _________                    _________                    _________  ", 0DH, 0AH
optionSquare2 BYTE "                         /         \                  /         \                  /         \ ", 0DH, 0AH
optionSquare3 BYTE "                        |           |                |           |                |           |", 0DH, 0AH
optionSquare4 BYTE "                        |           |                |           |                |           |", 0DH, 0AH
optionSquare5 BYTE "                        |           |                |           |                |           |", 0DH, 0AH
optionSquare7 BYTE "                         \_________/                  \_________/                  \_________/ ", 0DH, 0AH, 0

optionCustomize1P1 BYTE "(1)", 0
optionCustomize1P2 BYTE "Back", 0
optionCustomize1P3 BYTE 174, 0

optionCustomize2P1 BYTE "(2)", 0
optionCustomize2P2 BYTE "Set color", 0
optionCustomize2P3 BYTE "manually", 0

optionCustomize3P1 BYTE "(3)", 0
optionCustomize3P2 BYTE "Boards", 0
optionCustomize3P3 BYTE "catalog", 0

bufferCustomizeMenu BYTE 1 DUP(?)

customizeSelectMessage BYTE "Please, select an option [1-3]: ", 0


; ------ Setting game colors screen

setColorsTitle BYTE "                     ____  ____  ____    _  _  __   _  _  ____     ___  __   __     __  ____  ____ ", 0DH, 0AH
BYTE "                    / ___)(  __)(_  _)  ( \/ )/  \ / )( \(  _ \   / __)/  \ (  )   /  \(  _ \/ ___)", 0DH, 0AH
BYTE "                    \___ \ ) _)   )(     )  /(  O )) \/ ( )   /  ( (__(  O )/ (_/\(  O ))   /\___ \", 0DH, 0AH
BYTE "                    (____/(____) (__)   (__/  \__/ \____/(__\_)   \___)\__/ \____/ \__/(__\_)(____/", 0DH, 0AH, 0

color0 BYTE "0. Black", 0
color1 BYTE "1. Blue", 0
color2 BYTE "2. Green", 0
color3 BYTE "3. Cyan", 0
color4 BYTE "4. Red", 0
color5 BYTE "5. Magenta", 0
color6 BYTE "6. Yellow", 0
color7 BYTE "7. Light gray", 0
color8 BYTE "8. Dark gray", 0
color9 BYTE "9. Light blue", 0
colorA BYTE "A. Light green", 0
colorB BYTE "B. Light cyan", 0
colorC BYTE "C. Light red", 0
colorD BYTE "D. Light magenta", 0
colorE BYTE "E. Light yellow", 0
colorF BYTE "F. White", 0

boardColor1Message BYTE "(Board color 1) ", 0
boardColor2Message BYTE "(Board color 2) ", 0
whitePiecesColorMessage BYTE "(White pieces color) ", 0
blackPiecesColorMessage BYTE "(Black pieces color) ", 0
setColorManuallySelectMessage BYTE "Select a color [0-9 & A-F]:", 0
boardCatalogSelectMessage BYTE "Select board color combination [0-9 & A-F]: ", 0


repeatedColorMessage BYTE "*Second color must be different from first one!", 0

boarsCatalogColor1 BYTE "1. Modern minimalist", 0
boarsCatalogColor2 BYTE "2. Saprissa", 0
boarsCatalogColor3 BYTE "3. La Liga", 0
boarsCatalogColor4 BYTE "4. Herediano", 0
boarsCatalogColor5 BYTE "5. Zombie", 0
boarsCatalogColor6 BYTE "6. Lemon pie", 0
boarsCatalogColor7 BYTE "7. Bubble gum", 0
boarsCatalogColor8 BYTE "8. Cherry", 0
boarsCatalogColor9 BYTE "9. Blueberry", 0
boarsCatalogColorA BYTE "A. Classic", 0
boarsCatalogColorB BYTE "B. Cherry zombie", 0
boarsCatalogColorC BYTE "C. Boca", 0
boarsCatalogColorD BYTE "D. Eclipse", 0
boarsCatalogColorE BYTE "E. Cyberpunk", 0
boarsCatalogColorF BYTE "F. Gothic Cool On As", 0



; -------------------------------------------------------------------------------------------------------------------------------------------------





; ---------------------------------------------------------------- File Variables -----------------------------------------------------------------

fileBuffer BYTE 1000 DUP(?)
fileName BYTE "GameFile.txt", 0
fileHandle HANDLE ? ; Works as a token or identifier for the opened file
fileCreatingErrorMessage BYTE "Fatal error. Please quit the program and run it again.", 0
fileErrorMessage BYTE "Ooops! Something went wrong. Press any key to go back to the menu.", 0
fileBufferStorageError BYTE "This game has exceeded data limit... Please, create a new game!", 0
bytesRead DWORD ?
bytesWritten DWORD ?

fileBufferCopy BYTE 1000 DUP (?)

; -------------------------------------------------------------------------------------------------------------------------------------------------





; --------------------------------------------------------------- Global Variables ----------------------------------------------------------------

gameColors DWORD 70H, 0H

gameStatus db 0
playerTurn db 0

playerName db 10 dup(?)

typePlayerNameMessage BYTE "Enter your nickname (Max. 10): ", 0

; -------------------------------------------------------------------------------------------------------------------------------------------------





; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Beginning +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.code


;------------------------------------------------------ Loading Screen --------------------------------------------------------------



waitFileChanges PROC
    call loadData
    clc


    mov edi, offset fileBuffer
    mov esi, offset fileBufferCopy


    cmp bytesRead, 0
        je endComparingFileBuffers

    comparingFileBuffers:

        xor eax, eax
        mov bl, [edi]
        
        cmp [esi], bl
            jne notEquals
        cmp bl, 37
            je endComparingFileBuffers
        inc edi
        inc esi
            jmp comparingFileBuffers
    notEquals:
        call copyBufferContent
        stc
    endComparingFileBuffers:
    ret
waitFileChanges ENDP



waitingPlayer2 PROC
    dotCicle:
        mov  eax,1000 ;delay 1 sec
        mov  dl, 73  ;column
        mov  dh, 13  ;row
        call Gotoxy

        mov  edx, OFFSET waitingMsj
        call WriteString

        mov  dl, 98  ;column
        mov  dh, 13  ;row
        call Gotoxy

        call Delay
        mov  edx, OFFSET dotText
        call WriteString
        call Delay
        call WriteString
        call Delay
        call WriteString
        call Delay

        mov  dl, 98  ;column
        mov  dh, 13  ;row
        call Gotoxy

        mov edx, offset chessBox
        call WriteString

        call waitFileChanges
    jnc dotCicle
ret
waitingPlayer2 endp







;------------------------------------------------------ Movement --------------------------------------------------------------


;-----------------------------------> Asignar índice

asignarIndice PROC
    
    mov al, playerTurn
    cmp al, 1
    jne indiceJugador2

    indiceJugador1:
        mov bl, 1; --> Player 1
        mov dh, 8; --> Player 2
        mov ecx, 65
        push ecx
        mov temporalIndex, 0
        mov al, "w"
        mov ah, "b"

        jmp startIndexSelection

    indiceJugador2:
        mov bl, 8; --> Player 1
        mov dh, 1; --> Player 2
        mov ecx, 72
        push ecx
        mov temporalIndex, 1
        mov al, "b"
        mov ah, "w"

    startIndexSelection:
        
        mov typeColorOfPiece1, al
        mov typeColorOfPiece2, ah

        mov esi, 0 ; --> Player 1
        mov edi, 16 ; --> Player 2 ;eax
        mov dl, 2
        mov counterStrike, dl

    filas:
        pop ecx
        mov bh, cl
        push ecx
        mov ch, 8 ; --> contador
        columnas:
            ;player 1
            mov jugador1[esi*8].fila, bl 
            mov jugador1[esi*8].columna, bh
            mov dl, typeColorOfPiece1
            mov jugador1[esi*8].color, dl

            ;player 2
            mov jugador1[edi*8].fila, dh ;eax
            mov jugador1[edi*8].columna, bh ;eax
            mov dl, typeColorOfPiece2
            mov jugador1[edi*8].color, dl ;eax

            mov eax, temporalIndex
            add bh, addOrSub[eax] ;--> Incrementar columna
            inc esi
            inc edi
        dec ch
        cmp ch, 0
        jne columnas

        dec counterStrike
        mov eax, temporalIndex
        add bl, addOrSub[eax] ;--> Row increment (player 1)
        ;inc bl 
        sub dh, addOrSub[eax] ; --> Row decrement (player 2)
        mov dl, counterStrike
        cmp dl, 0
        jne filas

        pop ecx
ret
asignarIndice ENDP

;-----------------------------------> Asignar coordenadas

asignarCoordenadas PROC

    xor edx, edx
    mov esi, 0
    mov dh, 3
    mov dl, 7
    mov ecx, 16 ; --> contador
    mov bl, playerTurn

    repasoTablero:
        cmp bl, 1
        jne blackCoordinates

        whiteCoordinates:
            mov al, 9
            sub al, jugador1[esi*8].fila
            mul dh
            mov jugador1[esi*8].coordenadaY, al

            mov al, jugador1[esi*8].columna
            sub al, 65
            mul dl
            mov jugador1[esi*8].coordenadaX, al
            jmp continueLoop

        blackCoordinates:
            mov al, jugador1[esi*8].fila
            mul dh
            mov jugador1[esi*8].coordenadaY, al

            mov al, 137
            sub al, jugador1[esi*8].columna
            sub al, 65
            mul dl
            mov jugador1[esi*8].coordenadaX, al

        continueLoop:

            inc esi

    loop repasoTablero

    mov esi, 16
    mov dh, 3
    mov dl, 7
    mov ecx, 16 ; --> contador

    repasoTableroEnemigo:
        cmp bl, 1
        jne blackCoordinates2

        whiteCoordinates2:
            mov al, 9
            sub al, jugador1[esi*8].fila
            mul dh
            mov jugador1[esi*8].coordenadaY, al

            mov al, jugador1[esi*8].columna
            sub al, 65
            mul dl
            mov jugador1[esi*8].coordenadaX, al
            jmp continueLoopEnemie

        blackCoordinates2:
            mov al, jugador1[esi*8].fila
            mul dh
            mov jugador1[esi*8].coordenadaY, al

            mov al, 137 
            sub al, jugador1[esi*8].columna
            sub al, 65
            mul dl
            mov jugador1[esi*8].coordenadaX, al

        continueLoopEnemie:
        inc esi

    loop repasoTableroEnemigo

    ret
    asignarCoordenadas ENDP


    ;-----------------------------------> Definir tipo de pieza

    definirPieza PROC
    mov esi, 0
    mov eax, 16
    mov ecx, 16

    cicloPiezas:
        mov bl, playerTurn
        cmp bl, 1
        jne definePlayer2Pieces

        cmp jugador1[esi*8].fila, 2
        je pawn

    defineColumnsType:

        cmp jugador1[esi*8].columna, 69
        je king

        cmp jugador1[esi*8].columna, 66
        je knight
        cmp jugador1[esi*8].columna, 71
        je knight

        cmp jugador1[esi*8].columna, 67
        je bishop
        cmp jugador1[esi*8].columna, 70
        je bishop

        cmp jugador1[esi*8].columna, 68
        je queen

        mov jugador1[esi*8].tipoPieza, 82
        mov jugador1[eax*8].tipoPieza, 82
        jmp continuePiecesType
    
    definePlayer2Pieces:

        cmp jugador1[esi*8].fila, 7
        je pawn
        jmp defineColumnsType
        

        king:
            mov jugador1[esi*8].tipoPieza, 75
            mov jugador1[eax*8].tipoPieza, 75
            jmp continuePiecesType

        knight:
            mov jugador1[esi*8].tipoPieza, 78
            mov jugador1[eax*8].tipoPieza, 78
            jmp continuePiecesType

        bishop:
            mov jugador1[esi*8].tipoPieza, 66
            mov jugador1[eax*8].tipoPieza, 66
            jmp continuePiecesType

        queen:
            mov jugador1[esi*8].tipoPieza, 81
            mov jugador1[eax*8].tipoPieza, 81
            jmp continuePiecesType

        pawn:
            mov jugador1[esi*8].tipoPieza, 80
            mov jugador1[eax*8].tipoPieza, 80

        continuePiecesType:
            inc esi
            inc eax
            dec ecx
            cmp ecx, 0
            jne cicloPiezas

ret
definirPieza endp


;-----------------------------------> Set theme of the pieces

setThemeColor PROC

    mov  dl, 38  ;column
    mov  dh, 15  ;row
    call Gotoxy

    mov  edx, OFFSET selectColor1
    call WriteString

    call ReadHex

    ;---- get color of white pieces ----
    mov colorWhites, al

    ;---- get color of black pieces ----
    mov bl, 10h ;process to revert the number
    div bl
    mov bh, al ;--> save the result of the division
    mov al, ah
    mov ah, 0
    mul bl
    add al, bh
    mov colorBlacks, al
    mov al, colorBlacks

ret
setThemeColor endp




;-----------------------------------> Print Pieces


printGlyph PROC
    pushad                      ; protege ecx, esi, edi, etc. del bucle de imprimirPiezas

    mov bx, 265Ah               ; K -> ♚
    cmp al, 75
        je glyphReady
    mov bx, 265Bh               ; Q -> ♛
    cmp al, 81
        je glyphReady
    mov bx, 265Ch               ; R -> ♜
    cmp al, 82
        je glyphReady
    mov bx, 265Dh               ; B -> ♝
    cmp al, 66
        je glyphReady
    mov bx, 265Eh               ; N -> ♞
    cmp al, 78
        je glyphReady
    mov bx, 2659h               ; cualquier otra (P) -> ♙

glyphReady:
    mov glyphChar, bx
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    INVOKE WriteConsoleW, eax, ADDR glyphChar, 2, ADDR glyphWritten, 0

    popad
    ret
printGlyph ENDP


imprimirPiezas PROC

; - Define player atributes -

cmp playerTurn, 1
    jne setColorBlack

    setColorWhite:

        mov bl, colorWhites ;--> black pieces
        ;push ebx
        mov bh, colorBlacks ;--> white pieces
        push ebx
            jmp continueSetColor

    setColorBlack:
        mov bl, colorBlacks ;--> black pieces
        
        mov bh, colorWhites ;--> white pieces
        push ebx
    continueSetColor:

    mov esi, 0
    mov edi, 16
    mov ecx, 16


printProcess:
    xor eax, eax

    ;player 1
    cmp jugador1[esi*8].fila, 0
    je printPlayer2
    mov dl, jugador1[esi*8].coordenadaX
    add dl, 6
    mov dh, jugador1[esi*8].coordenadaY
    dec dh

    call Gotoxy

    pop ebx
    push ebx
    mov al, bl
    call SetTextColor

    mov al, jugador1[esi*8].tipoPieza
    call printGlyph

    printPlayer2:
        cmp jugador1[edi*8].fila, 0
        je passPrint
        mov dl, jugador1[edi*8].coordenadaX
        add dl, 6
        mov dh, jugador1[edi*8].coordenadaY
        dec dh

    call Gotoxy
    
    pop ebx
    push ebx
    mov al, bh
    call SetTextColor
    mov al, jugador1[edi*8].tipoPieza
    call printGlyph

    passPrint:
        inc esi
        inc edi

dec ecx
jnz printProcess

pop ebx
mov eax, 07H ; Choose a color
call SetTextColor
ret 
imprimirPiezas endp

;-----------------------------------> Mover pieza

moverPieza PROC

    mov  dh,1  ;row
    mov  dl,65  ;column
    call Gotoxy

    mov eax, cyan ; Choose a color
    call SetTextColor

    mov  edx,OFFSET playerName
    call WriteString

    mov eax, 07h ; Choose a color
    call SetTextColor

      mov  dh,3  ;row
      mov  dl,65  ;column
      call Gotoxy

    mov  edx,OFFSET ingresarPieza
    call WriteString

    mov edx, OFFSET bufferSelection
    mov ecx, 3
    call ReadString


    cmp bufferSelection [0], 48
    jne continueMoving

    cmp bufferSelection [1], 54
    je drawChoose
    cmp bufferSelection [1], 55
    je denyDraw
    cmp bufferSelection [1], 52
    jne notChange

    mov ah, 4
    mov gameStatus, ah
    stc
    jmp endMove

    drawChoose:
    mov ah, 6
    mov gameStatus, ah
    stc
    jmp endMove

    denyDraw:
    mov ah, 7
    mov gameStatus, ah
    stc
    jmp endMove

    continueMoving:
    mov al, bufferSelection[0]        ; read first symbol
    mov temporalColumn, al
    cmp al, 65
    jl notChange
    cmp al, 72
    jg notChange
    mov al, bufferSelection[1]        ; read second symbol
    mov numberToString, al
    cmp al, 49
    jl notChange
    cmp al, 56
    jg notChange

    mov edx,OFFSET numberToString
    mov ecx,bufsize
    call ParseDecimal32
    mov temporalRow, al 

    mov esi, 0
    mov ecx, 16

    cicloMover:
        mov al, temporalColumn
        cmp al, jugador1[esi*8].columna
        jne pasar
        mov al, temporalRow
        cmp al, jugador1[esi*8].fila
        je newPosition

        pasar:
            inc esi
    loop cicloMover

    jmp notChange

    newPosition:
            mov  dh,4  ;row
            mov  dl,65  ;column
            call Gotoxy
            mov temporalIndex, esi
            mov edx,OFFSET ingresarDestino
            call WriteString
               
            mov edx, OFFSET bufferSelection2
            mov ecx, 3
            call ReadString

            mov al, bufferSelection2[0]
            mov newColumn, al
            cmp al, 65
            jl notChange
            cmp al, 72
            jg notChange

            mov al, bufferSelection2[1]
            mov numberToString, al
            cmp al, 49
            jl notChange
            cmp al, 56
            jg notChange

            mov edx,OFFSET numberToString
            mov ecx,bufsize
            call ParseDecimal32
            mov newRow, al

            mov al, jugador1[esi*8].tipoPieza
            mov typeTemporal, al
            call movementSet
            cmp dh, 0
            jne changeSquare
            clc
            jmp endMove

        changeSquare:
            mov esi, temporalIndex
            mov al, newColumn
            mov jugador1[esi*8].columna, al
            mov al, newRow
            mov jugador1[esi*8].fila, al
            stc
            jmp endMove

        notChange:
            mov  dh,6  ;row
            mov  dl,65  ;column
            call Gotoxy
            mov  eax, red
            call SetTextColor
            mov  edx,OFFSET casillaVacia
            call WriteString
            mov  eax, white
            call SetTextColor
            call readChar
            clc

        endMove:
   
ret
moverPieza endp




;----------------------------- Movement Set ------------------------------->


movementSet PROC
    
    mov al, playerTurn ; --> necessary for the pawn's move
    cmp al, 1
    jne movesBlackPieces

    movesWhitePieces:
        mov cl, 2
        mov edi, 0
    jmp startMovementSet
        
    movesBlackPieces:
        mov cl, 7
        mov edi, 1
    startMovementSet:
        mov al, jugador1[esi*8].tipoPieza
        mov bl, temporalColumn ;values of the select square
        mov bh, temporalRow

        cmp al, 80
        je pawnSet

        cmp al, 82
        je rookSet

        cmp al, 78
        je knightSet

        cmp al, 66
        je bishopSet

        cmp al, 81
        je queenSet

        mov eax, 0 ; --> index of king combinations
        mov ecx, 8

    kingSet:

        add bl, kingColumns[eax]
        add bh, kingRows[eax]

        cmp bl, newColumn
        jne endKingSet
        cmp bh, newRow
        je accepted

        endKingSet:
            mov bl, temporalColumn ;values of the select square
            mov bh, temporalRow
            inc eax
    loop kingSet
    jmp denied


    pawnSet:
           cmp bh, cl
           jne oneMovePawn
           mov ecx, 2
           mov temporalPawn, 1
           jmp doubleMove

           oneMovePawn:
               add bh, addOrSub[edi]
               ;inc bh
               cmp bh, newRow
               jne denied
               mov temporalPawn, 1
               cmp bl, newColumn
               je accepted
               mov temporalPawn, 2
               inc bl
               cmp bl, newColumn
               je accepted
               sub bl, 2
               cmp bl, newColumn
               je accepted
               jmp denied

           doubleMove:
               add bh, addOrSub[edi]
               cmp bh, newRow
               jne pawnRejected
               cmp bl, newColumn
               je accepted
               jmp denied
           pawnRejected:
           loop doubleMove 
           jmp denied
        
    rookSet:
        cmp bl, newColumn
        jne horizontalMove
        cmp bh, newRow
        je denied
        jmp accepted

       horizontalMove:
            cmp bh, newRow
            jne denied

            cmp bl, newColumn
            je denied
            jmp accepted
    knightSet:
            mov eax, 0
            mov ecx, 8

        knightMoves:
            add bh, knightRows[eax]
            add bl, knightColumns[eax]
            cmp bh, newRow
            jne nextMoveK
            cmp bl, newColumn
            je accepted
            nextMoveK:
            mov bl, temporalColumn
            mov bh, temporalRow
            inc eax
        loop knightMoves
        jmp denied

    bishopSet:
        mov dl, 0
        bishopPP:
            add bl, bishopColumns[0]
            add bh, bishopRows[0]

            cmp bl, newColumn
            jne endPP
            cmp bh, newRow
            je accepted
                endPP:
                    cmp bl,72 ; compare with the last column H
                    je endPP2
                    cmp bh, 8 ; compare with the last row 8
                    jne bishopPP
                endPP2:
                    mov bl, temporalColumn
                    mov bh, temporalRow
                    inc dl
        bishopPN:
            add bl, bishopColumns[1]
            add bh, bishopRows[1]

            cmp bl, newColumn
            jne endPN
            cmp bh, newRow
            je accepted
                endPN:
                    cmp bl,65 ; compare with the first column A
                    je endPN2 
                    cmp bh, 8 ; compare with the last row 8
                    jne bishopPN
                endPN2:
                    mov bl, temporalColumn
                    mov bh, temporalRow
                    inc dl
        bishopNP:
            add bl, bishopColumns[2]
            add bh, bishopRows[2]

            cmp bl, newColumn
            jne endNP
            cmp bh, newRow
            je accepted
                endNP:
                    cmp bl,72 ; compare with the last column H
                    je endNP2
                    cmp bh, 1 ; compare with the first row 1
                    jne bishopNP
                endNP2:
                    mov bl, temporalColumn
                    mov bh, temporalRow
                    inc dl
        bishopNN:
            add bl, bishopColumns[3]
            add bh, bishopRows[3]

            cmp bl, newColumn
            jne endNN
            cmp bh, newRow
            je accepted
                endNN:
                    cmp bl,65 ; compare with the first column A
                    je endNN2
                    cmp bh, 1 ; compare with the first row 1
                    jne bishopNN
                endNN2:
                    mov bl, temporalColumn
                    mov bh, temporalRow
                    jmp denied

    queenSet:
        mov al, 0
        mov queenMove, al
        cmp bl, newColumn
        jne queenColumns
        cmp bh, newRow
        je denied ;in this case it doesn't move
        mov al, 1
        mov queenMove, al
        jmp accepted

        queenColumns:
            cmp bh, newRow
            jne bishopSet
            cmp bl, newColumn
            je bishopSet
            mov al, 1
            mov queenMove, al
            jmp accepted

denied:
    mov  dh,6  ;row
    mov  dl,65  ;column
    call Gotoxy
    ;change color to red
    mov  eax, red
    call SetTextColor
    mov  edx,OFFSET casillaEquivocada
    call WriteString
    mov  eax, white
    call SetTextColor
    call readChar
deniedCapture:
    mov dh, 0 ;--> Indicator on movePiece proc
    jmp exitSet

accepted:
    call capturePieces
    cmp dh, 0
    je deniedCapture
    call dontJump
    cmp al, 0
    je denied
    mov dh, 1 ;--> Indicator on movePiece proc

exitSet:
ret
movementSet endp


;------------------------- Don't Jump Process --------------------------------

dontJump PROC
    mov bl, temporalColumn ;values of the select square
    mov bh, temporalRow


    mov al, typeTemporal
    cmp al, 82
    je rookNotJump
    cmp al, 66
    je bishopNotJump
    cmp al, 81
    jne notJumpDtcd

    queenNotJump:
        mov al, queenMove
        cmp al, 1
        jne bishopNotJump

        mov al, 0
        mov queenMove, al

    rookNotJump:
        ;-- detect the direction of the move --
        mov al, newColumn
        cmp al, temporalColumn
        jg rockRight
        cmp al, temporalColumn
        jl rockLeft
        mov al, newRow
        cmp al, temporalRow
        jl rockDown

            rockUp: 
                    add bl, rookColumns[0]
                    add bh, rookRows[0]
                    mov eax, 0 ; --> index of the players pieces
                    mov ecx, 16
                    upJump:
                        cmp jugador1[eax*8].fila, bh
                        jne endUp
                        cmp jugador1[eax*8].columna, bl
                        je rejected
                        endUp:
                        inc eax
                    loop upJump
                    cmp bh, newRow
                    je notJumpDtcd
                    jmp rockUp
            rockRight:
                    add bl, rookColumns[1]
                    add bh, rookRows[1]
                    mov eax, 0 ; --> index of the players pieces
                    mov ecx, 160
                    rightJump:
                        cmp jugador1[eax*8].fila, bh
                        jne endRight
                        cmp jugador1[eax*8].columna, bl
                        je rejected
                        endRight:
                        inc eax
                    loop rightJump
                    cmp bl, newColumn
                    je notJumpDtcd
                    jmp rockRight
            rockDown:
                    add bl, rookColumns[2]
                    add bh, rookRows[2]
                    mov eax, 0 ; --> index of the players pieces
                    mov ecx, 16
                    downJump:
                        cmp jugador1[eax*8].fila, bh
                        jne endDown
                        cmp jugador1[eax*8].columna, bl
                        je rejected
                        endDown:
                        inc eax
                    loop downJump
                    cmp bh, newRow
                    je notJumpDtcd
                    jmp rockDown

            rockLeft:    
                    add bl, rookColumns[3]
                    add bh, rookRows[3]
                    mov eax, 0 ; --> index of the players pieces
                    mov ecx, 16
                    leftJump:
                        cmp jugador1[eax*8].fila, bh
                        jne endLeft
                        cmp jugador1[eax*8].columna, bl
                        je rejected
                        endLeft:
                        inc eax
                    loop leftJump
                    cmp bl, newColumn
                    je notJumpDtcd
                    jmp rockLeft

    bishopNotJump:
        mov bl, temporalColumn
        mov bh, temporalRow
        cmp dl, 1
        je bishopPNJump
        cmp dl, 2
        je bishopNPJump
        cmp dl, 3
        je bishopNNJump

            bishopPPJump:
                add bl, bishopColumns[0]
                add bh, bishopRows[0]
                mov eax, 0 ; --> index of the players pieces
                mov ecx, 16
                jumpBishopPP:
                    cmp jugador1[eax*8].fila, bh
                    jne eJBPP
                    cmp jugador1[eax*8].columna, bl
                    je rejected
                    eJBPP:
                    inc eax
                loop jumpBishopPP
                cmp bl, newColumn
                je notJumpDtcd
                jmp bishopPPJump

                    endPP2:
                        mov bl, temporalColumn
                        mov bh, temporalRow
            bishopPNJump:
                add bl, bishopColumns[1]
                add bh, bishopRows[1]

                mov eax, 0 ; --> index of the players pieces
                mov ecx, 16
                jumpBishopPN:
                    cmp jugador1[eax*8].fila, bh
                    jne eJBPN
                    cmp jugador1[eax*8].columna, bl
                    je rejected
                    eJBPN:
                        inc eax
                loop jumpBishopPN
                cmp bl, newColumn
                je notJumpDtcd
                jmp bishopPNJump

            bishopNPJump:
                add bl, bishopColumns[2]
                add bh, bishopRows[2]

                mov eax, 0 ; --> index of the players pieces
                mov ecx, 16
                jumpBishopNP:
                    cmp jugador1[eax*8].fila, bh
                    jne eJBNP
                    cmp jugador1[eax*8].columna, bl
                    je rejected
                    eJBNP:
                    inc eax
                loop jumpBishopNP
                cmp bl, newColumn
                je notJumpDtcd
                jmp bishopNPJump

            bishopNNJump:
                add bl, bishopColumns[3]
                add bh, bishopRows[3]

                mov eax, 0 ; --> index of the players pieces
                mov ecx, 16
                jumpBishopNN:
                    cmp jugador1[eax*8].fila, bh
                    jne eJBNN
                    cmp jugador1[eax*8].columna, bl
                    je rejected
                    eJBNN:
                    inc eax
                loop jumpBishopNN
                cmp bl, newColumn
                je notJumpDtcd
                jmp bishopNNJump
    
rejected:
    mov al, 0
    jmp notJumpFinal
notJumpDtcd:
    mov al, 1
notJumpFinal:
ret
dontJump endp

;------------------------- Capture of the pieces -----------------------------

capturePieces PROC

    mov esi, 0
    mov ecx, 32
    mov bl, newColumn
    mov bh, newRow
    mov al, playerTurn
    cmp al, 1
    jne player2CaptureColor
    mov al, "w"

    jmp captureLoop
    player2CaptureColor:
    mov al, "b"

    captureLoop:
        cmp bl, jugador1[esi*8].columna
        jne nextCapture
        cmp bh, jugador1[esi*8].fila
        jne nextCapture
        cmp jugador1[esi*8].color, al
        jne captureYes
        jmp captureNo
        nextCapture:

        inc esi
    loop captureLoop

    mov al, typeTemporal
    cmp al, 80
    jne captureYes
    mov al, temporalPawn
    cmp al, 1
    je captureYes

    captureNo:
        mov  dh,6  ;row
        mov  dl,65  ;column
        call Gotoxy
        ;change color to red
        mov  eax, red
        call SetTextColor
        mov  edx,OFFSET cantCapture
        call WriteString
        mov  eax, white
        call SetTextColor
        call readChar

        mov dh, 0
        jmp endCapture
    captureYes:
        mov jugador1[esi*8].fila, 0
        mov dh, 1
    endCapture:
ret
capturePieces endp




createFileConnection PROC
    mov edx, offset fileName
    call OpenInputFile
    mov fileHandle, eax


    cmp eax, -1 ; Checks if there are any error while opening the file
    jne fileOpeningOK
    call ClrScr
    mov edx, offset fileErrorMessage
    call WriteString
    call ReadChar
    clc ; Indicates that something went wrong with the file (result is saved in CF as 0)
    ret

    fileOpeningOK:
        mov eax, fileHandle
        mov edx, offset fileBuffer
        mov ecx, 1000
        call ReadFromFile
        mov bytesRead, eax
        jnc validateBufferStorage

        mov  eax, fileHandle
        call CloseFile
        mov edx, offset fileErrorMessage
        call WriteString
        call ReadChar
        clc ; Indicates that something went wrong with the file (result is saved in CF as 0)
        ret


        validateBufferStorage:
            cmp eax, 1000 ; Validates if data size in the file (characters read, saved in eax) is lower than fileBuffer value
                jl bufferValidated
        
            mov edx, offset fileBufferStorageError
            call WriteString
            mov eax, fileHandle
            call CloseFile
            call ReadChar
            clc ; Indicates that something went wrong with the file (result is saved in CF as 0)
            ret

            bufferValidated:
            
                ; Closes the file
                mov eax, fileHandle
                call CloseFile
                stc
                ret
createFileConnection ENDP






loadData PROC

    call createFileConnection
    jc loadDataIntoPlayer

    clc ; Indicates that something went wrong with the file (result is saved in CF as 0)
    ret
    
    loadDataIntoPlayer:
                mov edi, offset fileBuffer
                cmp edi, 0
                    je endLoadData

                    mov al, [edi]
                    sub al, 48
                    mov gameStatus, al
                    inc edi
                    inc edi
                    inc edi
                    mov esi, 0
                    loopReadingPieces:
                        mov al, [edi]
                        mov jugador1[esi*8].tipoPieza, al
                        inc edi
                        ;mov al, [edi]
                        ;mov jugador1[esi*8].color, al
                        inc edi
                        mov al, [edi]
                        mov jugador1[esi*8].columna, al
                        inc edi
                        mov al, [edi]
                        sub al, 48
                        mov jugador1[esi*8].fila, al
                        add edi, 2
                        inc esi
                        mov al, [edi]
                        cmp al, "%"
                            jne loopReadingPieces

                endLoadData:

        ;stc ; Indicates that everything went well with the file (result is saved in CF as 1)
        ret
loadData ENDP


writeData PROC
    ; Empties jugador1
    ;mov edi, offset jugador1
    ;mov ecx, sizeof jugador1
    ;xor eax, eax
    ;rep stosb



    ;mov jugador1[8].columna, 66
    ;mov jugador1[8].fila, 8
    ;mov jugador1[8].tipoPieza, 78
    ;mov jugador1[8].color, 98

    ; Empties fileBuffer content
    ;mov edi, offset fileBuffer ; So edi is pointing to fileBuffer refference
    ;mov ecx, 1000
    ;xor al, al ; The value to set to fileBuffer
    ;rep stosb ; Fills memory direction set in edi with al value


    mov edi, offset fileBuffer

    ; Sets the game status
    mov al, gameStatus
    add al, 48
    mov [edi], al
    inc edi

    ; Sets player turn
    mov bl, playerTurn
    mov al, 51 ; ASCII code of 3, so if playerTurn is 2, 51 - 2 is 49 ('1' ASCII code), and if playerTurn is 1, 51 - 1 is 50 ('2' ASCII code)
    sub al, playerTurn
    mov [edi], al
    inc edi

    ; Adds the *
    mov al, 42
    mov [edi], al
    inc edi

    ;mov dl, jugador1[0].tipoPieza
    ;call WriteString
    mov esi, 16
    mov ecx, 32 ; Counter, based on the 32 maximum pieces jugador1 might have
    mov bytesWritten, 3
    loopWritingPieces:
        mov al, jugador1[esi*8].tipoPieza
        mov [edi], al
        inc edi
        mov al, jugador1[esi*8].color
        mov [edi], al
        inc edi
        mov al, jugador1[esi*8].columna
        mov [edi], al
        inc edi
        mov al, jugador1[esi*8].fila
        add al, 48
        mov [edi], al
        inc edi
        mov al, 47
        mov [edi], al
        inc edi
        inc esi
        add bytesWritten, 5

        cmp esi, 32
        jne endLoopWritingPieces

        mov esi, 0
    endLoopWritingPieces:

        loop loopWritingPieces

    mov al, 37
    mov [edi], al
    inc edi
    inc bytesWritten


    ; ------- Creating the file

    mov edx, offset fileName
    call CreateOutputFile
    mov fileHandle, eax

    mov eax, fileHandle
    mov edx, offset fileBuffer
    mov ecx, bytesWritten

    call WriteToFile
    mov bytesWritten, eax

    mov  eax, fileHandle
    call CloseFile

    call copyBufferContent

    ;call ReadChar
    stc ; Indicates that everything went well with the file (result is saved in CF as 1)
    ret
writeData ENDP


writePlayerTurn PROC
    ; ------- Creating the file

    mov edi, offset fileBuffer
    mov al, 48
    mov [edi], al
    inc edi
    mov al, 51
    sub al, playerTurn
    mov [edi], al
    inc edi
    mov al, 37
    mov [edi], al

    mov edx, offset fileName
    call CreateOutputFile
    mov fileHandle, eax
    mov edx, offset fileBuffer
    mov ecx, 3

    call WriteToFile
    mov bytesWritten, eax

    mov  eax, fileHandle
    call CloseFile

    ret
writePlayerTurn ENDP



validatePlayerTurn PROC
    mov edx, offset fileName
    call OpenInputFile
    mov fileHandle, eax

    cmp eax, -1 ; Checks if there are any error while opening the file
        jne fileOpeningOK2
    call ClrScr
    mov edx, offset fileErrorMessage
    call WriteString
    call ReadChar
    ret

    fileOpeningOK2:
        mov eax, fileHandle
        mov edx, offset fileBuffer
        mov ecx, 1000
        call ReadFromFile
        mov bytesRead, eax

        mov edx, offset fileBuffer
        mov al, 2
        mov ebx, [edx+1]

        cmp bl, 50
            je endValidatePlayerTurn

        mov al, 1

        endValidatePlayerTurn:
            mov playerTurn, al
            mov eax, fileHandle
            call CloseFile
            stc ; Indicates that everything went well with the file (result is saved in CF as 1)
            ret
validatePlayerTurn ENDP



copyBufferContent PROC
    mov edi, offset fileBuffer
    mov esi, offset fileBufferCopy
    mov ecx, bytesWritten
    
    cmp bytesWritten, 0
        je endLoopCopyingPieces

    loopCopyingPieces:
        mov eax, [edi]
        mov [esi], eax
        inc edi
        inc esi
        loop loopCopyingPieces
    endLoopCopyingPieces:
    ret
copyBufferContent ENDP



youWinScreen PROC

    ret
youWinScreen ENDP



newGame PROC

    call validatePlayerTurn
    call writePlayerTurn
    call copyBufferContent
    call ClrScr
    call waitingPlayer2
    jnc continueCreatingGame
    ;call loadData
    


    continueCreatingGame:
    call ClrScr
    call asignarIndice
    call definirPieza
    mov ecx, 3
    cmp playerTurn, 1
        je ciclo
    call loadData
    mov ecx, 3
    

    
    ciclo:
        call ClrScr
        call buildBoard
        call asignarCoordenadas
        call imprimirPiezas
        call moverPieza
            jnc ciclo
        call Clrscr
        call buildBoard
        call asignarCoordenadas
        call imprimirPiezas
        ;call enemieKingSquares

        cmp gameStatus, 4
            je gameOver
        cmp gameStatus, 6
            je gameOver

        call writeData
        call waitingPlayer2
        call loadData

        cmp jugador1 [16].fila, 0
            je gameOver

        cmp gameStatus, 3
            je youWin
    loop ciclo

    youWin:
    call ClrScr
    mov edx, offset youWinMessage
    call WriteString
    call ReadChar
    jmp endNewGame

    gameOver:
    call ClrScr
    mov gameStatus, 3
    call writeData
    mov edx, offset gameOverMessage
    call WriteString
    call ReadChar
    jmp endNewGame

    draw: ; Six for draw, and 7 to deny it
    call writeData
    call waitingPlayer2
    call loadData
    cmp gameStatus, 7
        je ciclo
    call ClrScr
    mov edx, offset drawMessage
    call WriteString
    call ReadChar
    jmp endNewGame

    endNewGame:
    ret
newGame ENDP


printOptions PROC
    ; _____ Print New Game option _____

    mov dl, 31 ; Column
    mov dh, 15 ; Row
    call Gotoxy ; Set cursor position

    mov eax, 01H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset newGameMessage
    call WriteString


    ; _____ Print Game History option _____

    mov dl, 31 ; Column
    mov dh, 17 ; Row
    call Gotoxy

    mov eax, 0EH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset gameHistoryMessage
    call WriteString


    ; _____ Print Settings option _____

    mov dl, 31 ; Column
    mov dh, 19 ; Row
    call Gotoxy

    mov eax, 08H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset settingsMessage
    call WriteString


    ; _____ Print Exit option _____

    mov dl, 31 ; Column
    mov dh, 21 ; Row
    call Gotoxy

    mov eax, 04H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset exitMessage
    call WriteString

    ; _____ Print Select an option _____

    mov dl, 45 ; Column
    mov dh, 23 ; Row
    call Gotoxy

    mov eax, 06H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset selectMessage
    call WriteString

    ret
printOptions ENDP

highlightOption PROC
    call printOptions

    
    mov dl, 44 ; Column
    mov dh, 26 ; Row
    call Gotoxy
    mov edx, offset newLine
    call WriteString


    call Crlf
    call Crlf
    call Crlf

    cmp EBX, 31H
        je option1Selected
    cmp EBX, 32H
        je option2Selected
    cmp EBX, 33H
        je option3Selected
    cmp EBX, 34H
        je option4Selected
    cmp EBX, 0DH
        je enterTyped1
    jne invalidOption


    option1Selected:
        mov dl, 31 ; Column
        mov dh, 15 ; Row
        call Gotoxy ; Set cursor position

        mov eax, 0A1H ; Choose a color
        call SetTextColor ; Set the chosen color on text

        mov edx, offset newGameMessage
        call WriteString
        mov menuOption, 1
        jmp endHighlightOption


    option2Selected:
        mov dl, 31 ; Column
        mov dh, 17 ; Row
        call Gotoxy ; Set cursor position

        mov eax, 0AEH ; Choose a color
        call SetTextColor ; Set the chosen color on text

        mov edx, offset gameHistoryMessage
        call WriteString
        mov menuOption, 2
        jmp endHighlightOption


    option3Selected:
        mov dl, 31 ; Column
        mov dh, 19 ; Row
        call Gotoxy ; Set cursor position

        mov eax, 0A0H ; Choose a color
        call SetTextColor ; Set the chosen color on text

        mov edx, offset settingsMessage
        call WriteString
        mov menuOption, 3
        jmp endHighlightOption


    option4Selected:
        mov dl, 31 ; Column
        mov dh, 21 ; Row
        call Gotoxy ; Set cursor position

        mov eax, 0A4H ; Choose a color
        call SetTextColor ; Set the chosen color on text

        mov edx, offset exitMessage
        call WriteString
        mov menuOption, 4
        jmp endHighlightOption


    enterTyped1:
        cmp menuOption, 1
            jl invalidOption
        cmp menuOption, 4
            jg invalidOption

        mov esi, 1

        jmp endHighlightOption


    invalidOption:
        mov dl, 44 ; Column
        mov dh, 26 ; Row
        call Gotoxy ; Set cursor position

        mov eax, 0CH ; Choose a color
        call SetTextColor ; Set the chosen color on text

        mov edx, offset invalidOptionMessage
        call WriteString

        mov menuOption, 0

    endHighlightOption:
    mov eax, 06H ; Choose a color
    call SetTextColor ; Set the chosen color on text
    ret
highlightOption ENDP



writeGameOver PROC
    ; ------- Creating the file

    mov edi, offset fileBuffer
    mov al, 53
    mov [edi], al

    mov edx, offset fileName
    call CreateOutputFile
    mov fileHandle, eax

    mov edx, offset fileBuffer
    mov ecx, 1

    call WriteToFile
    mov bytesWritten, eax

    mov  eax, fileHandle
    call CloseFile

    ret
writeGameOver ENDP


setTextColorManually PROC
    setTextColorManuallyBeginning:
    call ClrScr

    call Crlf
    call Crlf


    mov edx, offset setColorsTitle
    call WriteString

    ; ---------- Black
    mov dl, 22 ; Column
    mov dh, 10 ; Row
    call Gotoxy

    mov eax, 70H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color0
    call WriteString

    ; ---------- Blue
    mov dl, 41 ; Column
    mov dh, 10 ; Row
    call Gotoxy

    mov eax, 1H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color1
    call WriteString

    ; ---------- Green
    mov dl, 61 ; Column
    mov dh, 10 ; Row
    call Gotoxy

    mov eax, 2H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color2
    call WriteString

    ; ---------- Cyan
    mov dl, 81 ; Column
    mov dh, 10 ; Row
    call Gotoxy

    mov eax, 3H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color3
    call WriteString

    ; ---------- Red
    mov dl, 22 ; Column
    mov dh, 13 ; Row
    call Gotoxy

    mov eax, 4H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color4
    call WriteString

    ; ---------- Magenta
    mov dl, 41 ; Column
    mov dh, 13 ; Row
    call Gotoxy

    mov eax, 5H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color5
    call WriteString

    ; ---------- Yellow
    mov dl, 61 ; Column
    mov dh, 13 ; Row
    call Gotoxy

    mov eax, 6H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color6
    call WriteString

    ; ---------- Light gray
    mov dl, 81 ; Column
    mov dh, 13 ; Row
    call Gotoxy

    mov eax, 7H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color7
    call WriteString

    ; ---------- Dark gray
    mov dl, 22 ; Column
    mov dh, 16 ; Row
    call Gotoxy

    mov eax, 8H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color8
    call WriteString

    ; ---------- Light blue
    mov dl, 41 ; Column
    mov dh, 16 ; Row
    call Gotoxy

    mov eax, 9H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset color9
    call WriteString

    ; ---------- Light green
    mov dl, 61 ; Column
    mov dh, 16 ; Row
    call Gotoxy

    mov eax, 0AH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorA
    call WriteString

    ; ---------- Light cyan
    mov dl, 81 ; Column
    mov dh, 16 ; Row
    call Gotoxy

    mov eax, 0BH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorB
    call WriteString

    ; ---------- Light red
    mov dl, 22 ; Column
    mov dh, 19 ; Row
    call Gotoxy

    mov eax, 0CH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorC
    call WriteString

    ; ---------- Light magenta
    mov dl, 41 ; Column
    mov dh, 19 ; Row
    call Gotoxy

    mov eax, 0DH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorD
    call WriteString

    ; ---------- Light yellow
    mov dl, 61 ; Column
    mov dh, 19 ; Row
    call Gotoxy

    mov eax, 0EH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorE
    call WriteString

    ; ---------- White
    mov dl, 81 ; Column
    mov dh, 19 ; Row
    call Gotoxy

    mov eax, 0FH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset colorF
    call WriteString




    ; ------- Prompt
    mov eax, 07H ; Choose a color
    call SetTextColor

    mov dl, 46 ; Column
    mov dh, 25 ; Row
    call Gotoxy
    mov edx, offset setColorManuallySelectMessage
    call WriteString


    ; -----------------
    firstBoardColor:

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    mov eax, 32
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov dl, 53 ; Column
    mov dh, 24 ; Row
    call Gotoxy
    mov edx, offset boardColor1Message
    call WriteString

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    call ReadHex

    cmp eax, 10h
        jl colorContinue1

    mov dl, 44 ; Column
    mov dh, 26 ; Row
    call Gotoxy

    mov edx, offset invalidOptionMessage
    call WriteString
    jmp firstBoardColor


    colorContinue1:
    mov edi, eax
    push eax

    ; -----------------
    secondBoardColor:

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    mov eax, 32
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov dl, 53 ; Column
    mov dh, 24 ; Row
    call Gotoxy
    mov edx, offset boardColor2Message
    call WriteString

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    call ReadHex
    
    cmp eax, edi
        jne colorContinue2

    mov dl, 37 ; Column
    mov dh, 26 ; Row
    call Gotoxy
    mov edx, offset repeatedColorMessage
    call WriteString
    jmp secondBoardColor

    colorContinue2:
    mov edi, eax
    push eax

    ; -----------------
    whitePiecesColor:

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    mov eax, 32
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov dl, 50 ; Column
    mov dh, 24 ; Row
    call Gotoxy
    mov edx, offset whitePiecesColorMessage
    call WriteString

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    call ReadHex

    cmp eax, 10h
        jl colorContinue3

    mov dl, 44 ; Column
    mov dh, 26 ; Row
    call Gotoxy
    jmp whitePiecesColor

    mov edx, offset invalidOptionMessage
    call WriteString

    colorContinue3:
    mov edi, eax
    push eax


    ; -----------------
    blackPiecesColor:

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    mov eax, 32
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    mov dl, 50 ; Column
    mov dh, 24 ; Row
    call Gotoxy
    mov edx, offset blackPiecesColorMessage
    call WriteString

    mov dl, 74 ; Column
    mov dh, 25 ; Row
    call Gotoxy

    call ReadHex

    cmp eax, edi
        jne colorContinue4

    mov dl, 37 ; Column
    mov dh, 26 ; Row
    call Gotoxy

    mov edx, offset repeatedColorMessage
    call WriteString
    jmp blackPiecesColor

    colorContinue4:
    mov edi, eax
    push eax

    ; -------


    ; ********** Saving other the two remaining color
    mov edx, 10h ; To multiply by 10
    pop ebx
    pop eax
    
    mul edx
    add eax, ebx

    mov colorWhites, al

    ; ********** Saving second color
    mov edx, 10h ; To multiply by 10
    pop eax
    mul edx
    mov [gameColors + 4], eax

    mov eax, [gameColors]

    mov edx, 10h ; To multiply by 10


    ; ********** Saving first color
    mov dl, 10h ; To multiply by 10
    pop eax
    mul dl
    mov [gameColors], eax


    
    


    ;---- get color of white pieces ----
    mov al, colorWhites

    ;---- get color of black pieces ----
    mov bl, 10h ;process to revert the number
    div bl
    mov bh, al ;--> save the result of the division
    mov al, ah
    mov ah, 0
    mul bl
    add al, bh
    mov colorBlacks, al

    ret
setTextColorManually ENDP


miniBoards PROC
    mov ecx, 8
    loopMiniBoardRows: ; Will contain the counter of the first loop (rows)
        push ecx

            mov edx, 8
            loopMiniBoardColumns:
                push edx

                mov eax, [gameColors + esi * 4]
                call SetTextColor
                mov edx, offset miniChessBox
                call WriteString

                xor esi, 1 ; Allows alternating between 0 and 1
                pop edx
                dec edx
                jnz loopMiniBoardColumns
                mov eax, 07h
                call SetTextColor
            call Crlf
        xor esi, 1
        pop ecx
        dec ecx
        jnz loopMiniBoardRows

    mov eax, 07H ; Choose a color
    call SetTextColor
    ret
miniBoards ENDP


boardsCatalog PROC
    boardsCatalogBeginning:
    mov edi, 0
    call ClrScr
    boardCatalogOption1:
    mov edx, offset boarsCatalogColor1
    call WriteString
    mov gameColors [0], 70h
    mov gameColors [4], 0H
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption2
    ret


    boardCatalogOption2:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor2
    call WriteString
    mov gameColors [0], 70h
    mov gameColors [4], 50H
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption3
    ret

    boardCatalogOption3:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor3
    call WriteString
    mov gameColors [0], 40h
    mov gameColors [4], 0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption4
    ret

    boardCatalogOption4:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor4
    call WriteString
    mov gameColors [0], 40h
    mov gameColors [4], 60h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption5
    ret

    boardCatalogOption5:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor5
    call WriteString
    mov gameColors [0], 20h
    mov gameColors [4], 0B0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption6
    ret

    boardCatalogOption6:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor6
    call WriteString
    mov gameColors [0], 0A0h
    mov gameColors [4], 0E0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption7
    ret

    boardCatalogOption7:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor8
    call WriteString
    mov gameColors [0], 10h
    mov gameColors [4], 0B0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption8
    ret

    boardCatalogOption8:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor8
    call WriteString
    mov gameColors [0], 0E0h
    mov gameColors [4], 40h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOption9
    ret

    boardCatalogOption9:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColor9
    call WriteString
    mov gameColors [0], 0E0h
    mov gameColors [4], 10h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionA
    ret

    boardCatalogOptionA:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorA
    call WriteString
    mov gameColors [0], 60h
    mov gameColors [4], 0E0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionB
    ret

    boardCatalogOptionB:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorB
    call WriteString
    mov gameColors [0], 40h
    mov gameColors [4], 0B0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionC
    ret

    boardCatalogOptionC:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorC
    call WriteString
    mov gameColors [0], 60h
    mov gameColors [4], 10h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionD
    ret

    boardCatalogOptionD:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorD
    call WriteString
    mov gameColors [0], 0h
    mov gameColors [4], 60h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionE
    ret

    boardCatalogOptionE:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorE
    call WriteString
    mov gameColors [0], 60h
    mov gameColors [4], 50h
    call Crlf
    call miniBoards

    cmp edi, 0
        je boardCatalogOptionF
    ret

    boardCatalogOptionF:
    call Crlf
    call Crlf
    call Crlf
    mov edx, offset boarsCatalogColorF
    call WriteString
    mov gameColors [0], 0D0h
    mov gameColors [4], 0h
    call Crlf
    call miniBoards

    cmp edi, 0
        je continueBoardCatalog
    ret


    continueBoardCatalog:
    call Crlf
    call Crlf

    mov edx, offset boardCatalogSelectMessage
    call WriteString

    call ReadHex

    mov edi, 1
    cmp eax, 1h
        je boardCatalogOption1
    cmp eax, 2h
        je boardCatalogOption2
    cmp eax, 3h
        je boardCatalogOption3
    cmp eax, 4h
        je boardCatalogOption4
    cmp eax, 5h
        je boardCatalogOption5
    cmp eax, 6h
        je boardCatalogOption6
    cmp eax, 7h
        je boardCatalogOption7
    cmp eax, 8h
        je boardCatalogOption8
    cmp eax, 9h
        je boardCatalogOption9
    cmp eax, 0Ah
        je boardCatalogOptionA
    cmp eax, 0Bh
        je boardCatalogOptionB
    cmp eax, 0Ch
        je boardCatalogOptionC
    cmp eax, 0Dh
        je boardCatalogOptionD
    cmp eax, 0Eh
        je boardCatalogOptionE
    cmp eax, 0Fh
        je boardCatalogOptionF

    mov edi, 0
    jmp boardsCatalogBeginning

    endBoardsCatalog:
    ret
boardsCatalog ENDP





customizeBoard PROC
    customizeBeginning:
    call ClrScr
    call Crlf
    call Crlf
    mov eax, 01H ; Choose a color
    call SetTextColor ; Set the chosen color on text
    mov edx, offset customizeScreen2
    call WriteString

    mov dl, 0 ; Column
    mov dh, 2 ; Row
    call Gotoxy
    mov eax, 0DH ; Choose a color
    call SetTextColor ; Set the chosen color on text
    mov edx, offset customizeScreen1
    call WriteString

    mov dl, 0 ; Column
    mov dh, 6 ; Row
    call Gotoxy
    mov eax, 02H ; Choose a color
    call SetTextColor ; Set the chosen color on text
    mov edx, offset customizeScreen3
    call WriteString

    mov eax, 06H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov dl, 0 ; Column
    mov dh, 14 ; Row
    call Gotoxy
    mov edx, offset optionSquare1
    call WriteString

    ; ----- Option 1

    mov eax, 04H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov dl, 29 ; Column
    mov dh, 16 ; Row
    call Gotoxy
    mov edx, offset optionCustomize1P1
    call WriteString

    mov dl, 29 ; Column
    mov dh, 17 ; Row
    call Gotoxy
    mov edx, offset optionCustomize1P2
    call WriteString

    mov dl, 30 ; Column
    mov dh, 18 ; Row
    call Gotoxy
    mov edx, offset optionCustomize1P3
    call WriteString


    ; ----- Option 2

    mov eax, 03H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov dl, 58 ; Column
    mov dh, 16 ; Row
    call Gotoxy
    mov edx, offset optionCustomize2P1
    call WriteString

    mov dl, 55 ; Column
    mov dh, 17 ; Row
    call Gotoxy
    mov edx, offset optionCustomize2P2
    call WriteString

    mov dl, 56 ; Column
    mov dh, 18 ; Row
    call Gotoxy
    mov edx, offset optionCustomize2P3
    call WriteString


    ; ----- Option 3

    mov eax, 0AH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov dl, 87 ; Column
    mov dh, 16 ; Row
    call Gotoxy
    mov edx, offset optionCustomize3P1
    call WriteString

    mov dl, 86 ; Column
    mov dh, 17 ; Row
    call Gotoxy
    mov edx, offset optionCustomize3P2
    call WriteString

    mov dl, 85 ; Column
    mov dh, 18 ; Row
    call Gotoxy
    mov edx, offset optionCustomize3P3
    call WriteString


    ; ----- Select an option

    mov eax, 0EH ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov dl, 45 ; Column
    mov dh, 23 ; Row
    call Gotoxy

    mov edx, offset customizeSelectMessage
    call WriteString


    mov edx, offset bufferCustomizeMenu
    mov eax, 1
    call ReadString

    mov esi, offset bufferCustomizeMenu
    mov eax, [esi]

    loopCustomizeMenu:
        mov dl, 77 ; Column
        mov dh, 23 ; Row
        call Gotoxy
        
        mov esi, 0
        xor ebx, ebx
        call ReadChar
        movzx ebx, al
        mov eax, ebx
        call WriteChar
        call ReadChar

        cmp al, 0DH
            jne loopCustomizeMenu


        cmp ebx, 49
            je endCustomizeMenu
        cmp ebx, 50
            je optionCustomize2
        cmp ebx, 51
            je optionCustomize3

        ; ------- In case user entered an invalid option
        mov dl, 44 ; Column
        mov dh, 24 ; Row
        call Gotoxy

        mov edx, offset invalidOptionMessage
        call WriteString
        call ReadChar
        jmp customizeBeginning


        optionCustomize2:
            call setTextColorManually
            jmp endCustomizeMenu
        optionCustomize3:
            call boardsCatalog
            jmp endCustomizeMenu


    endCustomizeMenu:
    ret
customizeBoard ENDP



createPlayers PROC
    call ClrScr
    mov edx, offset typePlayerNameMessage
    call WriteString

    mov edx, offset playerName
    mov ecx, 10
    call ReadString

    call newGame
    ret
createPlayers ENDP



showMenu PROC
    menuStart:
    call ClrScr ; To clear the console / screen

    call Crlf
    call Crlf
    call Crlf
    call Crlf
    call Crlf
    call Crlf

    mov eax, 09H ; Choose a color
    call SetTextColor ; Set the chosen color on text

    mov edx, offset menu
    call WriteString


    mov dl, 0 ; Column
    mov dh, 13 ; Row
    call Gotoxy

    mov edx, offset optionsBox
    call WriteString

    call printOptions

    loopMenu:
        mov esi, 0
        mov dl, 77 ; Column
        mov dh, 23 ; Row
        call Gotoxy
        xor AL, AL
        xor EBX, EBX
        call ReadChar
        movzx EBX, AL
        call WriteChar
        call highlightOption

        cmp esi, 1 ;Validate if the user entered a valid option and pressed enter
            je endMenuLoop

        jmp loopMenu

    endMenuLoop:
    mov eax, 07H ; Choose a color
    call SetTextColor
    cmp menuOption, 1
        je menuOption1
    cmp menuOption, 2
        je menuOption2
    cmp menuOption, 3
        je menuOption3

    ; ----- In case selected option is 4
    mov edx, offset fileName
    call CreateOutputFile
    mov fileHandle, eax

    mov edi, offset fileBuffer
    mov al, 53
    mov [edi], al

    mov eax, fileHandle
    mov edx, offset fileBuffer
    mov ecx, 1


    call WriteToFile
    mov bytesWritten, eax

    mov  eax, fileHandle
    call CloseFile
    exit

    menuOption1:
        mov menuOption, 0
        call createPlayers
        jmp menuStart
    menuOption2:
        mov menuOption, 0
        call ReadChar
        jmp menuStart
    menuOption3:
        mov menuOption, 0
        call customizeBoard
        jmp menuStart
    continue:


    ret ; Return to the main process (must be in every process)
showMenu ENDP




buildBoard PROC

    mov al, playerTurn
    cmp al, 2
    je player2Board

    player1Board:
        mov esi, offset chessBoardRows
        mov [temporalBoardRows], esi
        mov esi, offset chessBoardColumns
        mov [temporalBoardColumns], esi
        mov esi, 0 ; Will contain gameColor array index

        jmp mainPrintBoard
    player2Board:
        mov esi, offset chessBoardRows2
        mov [temporalBoardRows], esi
        mov esi, offset chessBoardColumns2
        mov [temporalBoardColumns], esi
        mov esi, 1 ; Will contain gameColor array index

    mainPrintBoard:
    mov edx, [temporalBoardColumns]
    call WriteString

    mov edi, 0 ; Will contain chessBoardRows array index
    

    mov eax, 74H ; Choose a color
    call SetTextColor
    mov ecx, 8
    loopBoardRows: ; Will contain the counter of the first loop (rows)
        push ecx

        mov ebx, 3 ; Will contain the counter of the second loop (row lines)
        loopBoardRowLine:
            push ebx
            mov edx, 8 ; Will contain the counter of the third loop (columns)
            push edx

            mov eax, 07H ; Choose a color
            call SetTextColor

            cmp ebx, 2
                jne blankSpaceBoardRow1

            mov eax, [temporalBoardRows] 
            lea edx, [eax + edi * 4]
            call WriteString
            pop edx
            jmp loopBoardColumns

            blankSpaceBoardRow1:
                mov eax, [temporalBoardRows] 
                lea edx, [eax + 32]
                call WriteString
                pop edx
            
            loopBoardColumns:
                push edx

                mov eax, [gameColors + esi * 4]
                call SetTextColor
                mov edx, offset chessBox
                call WriteString

                xor esi, 1 ; Allows alternating between 0 and 1
                pop edx
                dec edx
                jnz loopBoardColumns


            pop ebx
            push ebx
            mov eax, 07H ; Choose a color
            call SetTextColor
            push edx
            cmp ebx, 2
                jne blankSpaceBoardRow2
            
            mov eax, [temporalBoardRows] 
            lea edx, [eax + edi * 4]
            call WriteString
            pop edx
            inc edi
            jmp continueBoardLineLoop

            blankSpaceBoardRow2:
                mov eax, [temporalBoardRows] 
                lea edx, [eax + 32]
                call WriteString
                pop edx

            continueBoardLineLoop:

            call Crlf

            pop ebx
            dec ebx
            jnz loopBoardRowLine




        xor esi, 1
        pop ecx
        dec ecx
        jnz loopBoardRows

    mov eax, 07H ; Choose a color
    call SetTextColor
    mov edx, [temporalBoardColumns]
    call WriteString
    ret
buildBoard ENDP








main PROC
    ; ---------------------------------------------------------------- First Screen ---------------------------------------------------------------

    mov edx, offset firstScreen
    call WriteString
    
    call Crlf ; Line break
    call ReadChar ; Only one character is read to create the "Press any key to continue..." message
    call showMenu        


    exit
main ENDP
end main


egewfgfkhgweklgwejlgwijore