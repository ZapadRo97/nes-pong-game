.include "nes.inc"
.include "global.inc"

.macro NEGA
	EOR #$FF
	SEC
	ADC #0
.endmacro

.macro POSA
	CLC
	SBC #0
	EOR #$FF
.endmacro

.segment "VECTOR"
    .addr nmi
    .addr reset
    .addr irq

.segment "CHR0"
    .incbin "pong.chr"

.segment "BSS"
buttons1: .res 1
buttons2: .res 1
directionX: .res 1
directionY: .res 1
counter: .res 1
;the low byte represent subpixel
ballXSpeedLow: .res 1
ballYSpeedLow: .res 1
;the high byte represent pixel
ballSpeedHigh: .res 1 ;just for x
ballXSubpixel: .res 1
ballYSubpixel: .res 1
currBallPos: .res 1
angle: .res 1
player1Score: .res 1
player2Score: .res 1
playerWon: .res 1
gameState: .res 1
oldGameState: .res 1

.segment "CODE"

.proc main
	JSR load_main_palette
    JSR draw_bg


    LDA #%10010000 ;enable NMI
    STA PPUCTRL
    LDA #%00011110   ;enable sprites, enable background
    STA PPUMASK


    LDA #$00
    STA directionX
    STA player1Score
    STA player2Score

    LDA #$01
    STA gameState

    LDA #$00
    STA oldGameState
    STA playerWon

	JSR ResetVariables


forever:
    JMP forever

.endproc


.proc load_main_palette
	;;init palette data
    ;background pallete starts at $3F00
    ;sprite palette starts at $3F10
    LDA PPUSTATUS ;reset high/low latch
    LDA #$3F
    STA PPUADDR ;write high byte
    LDA #$00
    STA PPUADDR ;write low byte


    LDX #$00
LoadPalette:
    LDA PaletteData, x ;load data from address (PaletteData + val in x)
    STA PPUDATA ;write to PPU
    INX ; x = x+1
    CPX #$20 ;compare x to 32
    BNE LoadPalette

    RTS


PaletteData:
    .byt $0F,$30,$26,$25,  $0F,$30,$26,$25,  $0F,$30,$26,$25,  $0F,$30,$26,$25 ;bg
    .byt $0F,$2C,$15,$20,  $0F,$2C,$15,$20,  $0F,$2C,$15,$20,  $0F,$2C,$15,$20 ;sprites


.endproc


.proc nmi

	LDA #$00
   	STA OAMADDR ;low byte
   	LDA #$02
   	STA OAMDMA ;high byte, start the transfer


   	;;io
   	JSR ReadController1
   	JSR ReadController2

   	JSR GameEngine


	LDA #$00
    STA PPUSCROLL
    STA PPUSCROLL
    rti
.endproc

.proc irq
    rti
.endproc

;Buttons: A,B,Select, Start, up, down, left, right
topBorder = $1F
botBorder = $D7
leftBorder = $08
rightBorder = $F1

directionRight = $00
directionLeft = $01
directionUp = $00
directionDown = $01

;game states
running = $00
pressStart = $01
paused = $02
p1Wins = $03
p2Wins = $04



GameEngine:

	LDA oldGameState
	CMP gameState
	BEQ DontDrawText

	JSR DrawText
	

DontDrawText:
	LDA gameState
	CMP #running
	BEQ GameRunning
	CMP #paused
	BEQ PressStartScreen

	CMP #pressStart
	BEQ PressStartScreen

	CMP #p1Wins
	BEQ Player1Wins

	CMP #p2Wins
	BEQ Player2Wins


GameRunning:
	LDA buttons1
	AND #%00010000
	BNE PauseGame

	JSR MoveBall
	JSR PaddleCollision

	JSR MoveLeftPaddle
	JSR MoveRightPaddle
	JMP DontPauseGame

PauseGame:
	JSR KillTime
	LDA #paused
	STA gameState
	

DontPauseGame:
	RTS


PressStartScreen:
	LDA buttons1
	AND #%00010000
	BEQ DontStart

	JSR KillTime
	LDA #running
	STA gameState
	

DontStart:
	RTS

;maybe use a single subr here
Player1Wins:
	;todo
	RTS

Player2Wins:
	;todo
	RTS

;############################

MoveLeftPaddle:
	;check if up is pressed
	LDA buttons1
	AND #%00001000
	BNE LeftCheckTopCollision

	LDA buttons1
	AND #%00000100
	BNE LeftCheckDownCollision

	RTS

LeftCheckTopCollision:
	LDA LPADTOP_Y
	CMP #topBorder
	BEQ LeftDoneChecking

MoveLeftPaddleUp:
	LDA LPADTOP_Y
    SEC
    SBC #$01
    STA LPADTOP_Y

	LDA LPADMID_Y
    SEC
    SBC #$01
    STA LPADMID_Y

    LDA LPADBOT_Y
    SEC
    SBC #$01
    STA LPADBOT_Y


	RTS

LeftCheckDownCollision:
	LDA LPADBOT_Y
	CMP #botBorder
	BEQ LeftDoneChecking

MoveLeftPaddleDown:
	LDA LPADTOP_Y
    CLC
    ADC #$01
    STA LPADTOP_Y

	LDA LPADMID_Y
    CLC
    ADC #$01
    STA LPADMID_Y

    LDA LPADBOT_Y
    CLC
    ADC #$01
    STA LPADBOT_Y
	
	RTS

LeftDoneChecking:
	RTS

;#################################

MoveRightPaddle:

	;check if up is pressed
	LDA buttons2
	AND #%00001000
	BNE RightCheckTopCollision

	LDA buttons2
	AND #%00000100
	BNE RightCheckDownCollision

	RTS


RightCheckTopCollision:
	LDA RPADTOP_Y
	CMP #topBorder
	BEQ RightDoneChecking

MoveRightPaddleUp:
	LDA RPADTOP_Y
    SEC
    SBC #$01
    STA RPADTOP_Y

	LDA RPADMID_Y
    SEC
    SBC #$01
    STA RPADMID_Y

    LDA RPADBOT_Y
    SEC
    SBC #$01
    STA RPADBOT_Y


	RTS

RightCheckDownCollision:
	LDA RPADBOT_Y
	CMP #botBorder
	BEQ RightDoneChecking

MoveRightPaddleDown:
	LDA RPADTOP_Y
    CLC
    ADC #$01
    STA RPADTOP_Y

	LDA RPADMID_Y
    CLC
    ADC #$01
    STA RPADMID_Y

    LDA RPADBOT_Y
    CLC
    ADC #$01
    STA RPADBOT_Y
	
	RTS

RightDoneChecking:
	RTS


;#################################

PaddleCollision:
	
	LDA directionX
	CMP #directionRight
	BEQ RightPaddleCollision

	LDA directionX
	CMP #directionLeft
	BEQ LeftPaddleCollision

LeftPaddleCollision:
	JSR LeftPaddleCollisionCheck
	RTS

RightPaddleCollision:
	JSR RightPaddleCollisionCheck
	RTS

;############################
LeftPaddleCollisionCheck:
	LDA LPADMID_X
	CLC
	ADC #$05
	CMP BALL_X
	BEQ LeftXCollision
	RTS

LeftXCollision:
	LDA LPADTOP_Y
	SEC
	SBC #$05
	SEC
	SBC BALL_Y
	BMI UnderLeftPaddle
	RTS

UnderLeftPaddle:
	LDA LPADBOT_Y
	CLC
	ADC #$05
	SEC
	SBC BALL_Y
	BPL InLeftPaddle
	RTS

InLeftPaddle:

	LDA #$00
	STA directionX

	JSR GetBallPosition
	RTS


;############################

RightPaddleCollisionCheck:
	LDA RPADMID_X
	SEC
	SBC #$05
	CMP BALL_X
	BEQ RightXCollision
	RTS

RightXCollision:
	LDA RPADTOP_Y
	SEC
	SBC #$05
	SEC
	SBC BALL_Y
	BMI UnderRightPaddle
	RTS

UnderRightPaddle:
	LDA RPADBOT_Y
	CLC
	ADC #$05
	SEC
	SBC BALL_Y
	BPL InRightPaddle
	RTS

InRightPaddle:

	LDA #$01
	STA directionX

	JSR GetBallPosition
	RTS


;###########################

GetBallPosition:

	;the direction is changed before this is called
	;that is why this is reversed
	;here we'll calculate directionY too
	CMP #directionLeft
	BEQ CalculateBallRight
	CMP #directionRight
	BEQ CalculateBallLeft
	

CalculateBallLeft:

	LDA BALL_Y
	CLC
	ADC #$04 ;middle of the ball
	SEC
	SBC LPADTOP_Y
	STA currBallPos

	LDA LPADMID_Y
	SEC
	SBC #$80
	BPL DirectionUp
	BMI DirectionDown





CalculateBallRight:

	LDA BALL_Y
	CLC
	ADC #$4 ;middle of the ball
	SEC
	SBC RPADTOP_Y
	STA currBallPos

	LDA RPADMID_Y
	SEC
	SBC #$80
	BPL DirectionUp
	BMI DirectionDown


DirectionUp:

	LDA #directionUp
	STA directionY

	;get a number in 1..24
	JSR CalculateAngle
	RTS

DirectionDown:

	LDA #directionDown
	STA directionY

	;get a number in 1..24
	JSR CalculateAngle
	RTS

CalculateAngle:

;paddle is divided in 5 sections
;               --- 24 (18)
;                |
;           INT1 | -> +3
;                |
;               --- 18 (12)
;                |
;           INT2 | -> -5 => -2
;                |
;               --- 13 (0D)
;                |
;           INT3 | -> +2 => +0
;                |
;               --- 11 (0B)
;                |
;           INT4 | -> -2 => -2
;                |
;               --- 6 (06)
;                |
;           INT5 | -> +5 => +3
;                |
;               --- 1 (01)

	
	LDA #$00
	CLC
	ADC #$03
	STA counter

	LDA currBallPos
	SEC
	SBC #$12
	BPL DoneChecking
	;in interval 2
	LDA counter
	SEC
	SBC #$05
	STA counter

	LDA currBallPos
	SEC
	SBC #$0D
	BPL DoneChecking
	;in interval 3
	LDA counter
	CLC
	ADC #$02
	STA counter

	LDA currBallPos
	SEC
	SBC #$0B
	BPL DoneChecking
	;in interval 4
	LDA counter
	SEC
	SBC #$02
	STA counter

	LDA currBallPos
	SEC
	SBC #$06
	BPL DoneChecking
	;in interval 5
	LDA counter
	CLC
	ADC #$05
	STA counter

DoneChecking:
	;here we use counter to calculate new angle

	LDA angle
	CLC
	ADC counter
	BPL AnglePositive
	POSA
	STA counter

AnglePositive:
	SEC
	SBC #$07
	BMI AngleValid
	LDA #$07
	JMP FinishAngleCalculus


AngleValid:
	LDA angle
	CLC
	ADC counter

FinishAngleCalculus:
	STA angle
	JSR CalculateSpeed
	RTS


CalculateSpeed:
	
	LDX angle

	;set low byte
	LDA CosTable, x
	STA ballXSpeedLow

	LDA SinTable, x
	STA ballYSpeedLow

	CPX #$00
	BNE BallSpeedHighZero
	LDA #$01
	STA ballSpeedHigh
	JMP FinishCalculateSpeed

BallSpeedHighZero:
	LDA #$00
	STA ballSpeedHigh

FinishCalculateSpeed:
	RTS

MoveBall:

	LDA BALL_Y
	SEC
	SBC #topBorder
	BPL CheckWallCollision

	LDA BALL_Y
	SEC
	SBC #botBorder
	BMI CheckWallCollision

	;change vertical direction
	LDA directionY
	EOR #$01
	STA directionY

CheckWallCollision:
	;check wall collision
	LDA BALL_X
	CMP #leftBorder
	BEQ ResetBall
	CMP #rightBorder
	BEQ ResetBall

	JSR MoveBallHorizontally
	JSR MoveBallVertically
	
	RTS

MoveBallHorizontally:
	LDA directionX
    CMP #directionLeft
    BEQ MoveBallLeft
    CMP #directionRight
    BEQ MoveBallRight

    RTS


MoveBallLeft:
	LDA ballXSubpixel
	SEC
	SBC ballXSpeedLow
	STA ballXSubpixel

	LDA BALL_X
	SBC ballSpeedHigh
	STA BALL_X

	RTS

MoveBallRight:
	;16-bit arithmetic
	LDA ballXSubpixel
	CLC
	ADC ballXSpeedLow
	STA ballXSubpixel

	LDA BALL_X
	ADC ballSpeedHigh
	STA BALL_X

	RTS

MoveBallVertically:
	LDA directionY
    CMP #directionUp
    BEQ MoveBallUp
    CMP #directionDown
    BEQ MoveBallDown

    RTS

MoveBallUp:
	LDA ballYSubpixel
	SEC
	SBC ballYSpeedLow
	STA ballYSubpixel

	LDA BALL_Y
	SBC #$00 ;can't go straight up
	STA BALL_Y

	RTS

MoveBallDown:
	LDA ballYSubpixel
	CLC
	ADC ballYSpeedLow
	STA ballYSubpixel

	LDA BALL_Y
	ADC #$00 ;can't go straight up
	STA BALL_Y

	RTS

ResetBall:
	LDA #$80
	STA BALL_X
	STA BALL_Y

	JSR ResetVariables

	;this should not work but it does
	;it doesnt
	LDX directionX
	CPX #directionRight
	BNE Player2Do
	JSR Player1Scored
	JMP ChangeDirection

Player2Do:
	JSR Player2Scored

ChangeDirection:
	LDA directionX
	EOR #$01
	STA directionX


	RTS

Player1Scored:
	LDY player1Score
	INY
	STY player1Score

    LDA #$20
    STA PPUADDR
    LDA #P1_ADDR
    STA PPUADDR
    STY PPUDATA

    JSR CheckWinCondition
	RTS

Player2Scored:
	LDY player2Score
	INY
	STY player2Score

    LDA #$20
    STA PPUADDR
    LDA #P2_ADDR
    STA PPUADDR
    STY PPUDATA

    JSR CheckWinCondition
	RTS

CheckWinCondition:
	
	LDA player1Score
	CMP #$09
	BNE :+
	;player 1 wins
	LDA #p1Wins
	STA gameState
	LDA #01
	STA playerWon

:	LDA player2Score
	CMP #$09
	BNE ReturnFromCheck
	;player 2 wins
	LDA #p2Wins
	STA gameState
	LDA #02
	STA playerWon

ReturnFromCheck:
	RTS

;;;CONTROLLER AREA
ReadController1:
  	LDA #$01
  	STA JOYPAD1
  	LDA #$00
  	STA JOYPAD1
  	LDX #$08
ReadControllerLoop1:
  	LDA JOYPAD1
  	LSR A            ;bit0 -> Carry
  	ROL buttons1     ;bit0 <- Carry
  	DEX
  	BNE ReadControllerLoop1
  	RTS

ReadController2:
  	LDA #$01
  	STA JOYPAD2
  	LDA #$00
  	STA JOYPAD2
  	LDX #$08
ReadControllerLoop2:
  	LDA JOYPAD2
  	LSR A            ;bit0 -> Carry
  	ROL buttons2     ;bit0 <- Carry
  	DEX
  	BNE ReadControllerLoop2
  	RTS


;from 0 to 45 degress in 5 increment
SinTable: ;to be used in low byte; fractional part discretized in 0..255
	.byt $00, $17, $2C, $43, $57, $6C, $80, $92, $A4, $B6
CosTable: ;idem cos(0) = 1 ;high byte 
	.byt $00, $FD, $FA, $F8, $F0, $E9, $DF, $D2, $C5, $B6

ResetVariables:

    LDA #$00
    STA directionY

    LDA #$00
    STA counter

    LDA #$00
    STA angle

    LDA #$00
    STA ballXSpeedLow
    STA ballYSpeedLow
    LDA #$00
    STA ballXSubpixel
    STA ballYSubpixel
    LDA #$01
    STA ballSpeedHigh
    RTS

DrawText:

	LDA gameState
	STA oldGameState

	LDA gameState
	CMP #running
	BEQ ClearScreenLetters

	CMP #paused
	BEQ ShowPauseScreen

	CMP #pressStart
	BEQ ShowPlayScreen

	CMP #p1Wins
	BEQ ShowWinScreen

	CMP #p2Wins
	BEQ ShowWinScreen

ClearScreenLetters:
	LDA #$21
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDX #$00

:   
	LDA #$24
	STA PPUDATA
	INX
	CPX #$1E
	BNE :-
	
	RTS

ShowPauseScreen:
	LDA #$21
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDX #$00

:   
	LDA PauseRow, X
	STA PPUDATA
	INX
	CPX #$1E
	BNE :-

	RTS

ShowPlayScreen:
	LDA #$21
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDX #$00

:   
	LDA PlayRow, X
	STA PPUDATA
	INX
	CPX #$1E
	BNE :-

	RTS

ShowWinScreen: ;
	LDA #$21
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDX #$00

:   CPX #$10
	BNE :+
	LDA playerWon
	STA PPUDATA
	JMP :++	
:	LDA WinRow, X
	STA PPUDATA

:	INX
	CPX #$1E
	BNE :---

	RTS

KillTime:

	LDY #$10
	LDX #$10
:   JSR :+
	DEX
	BNE :-
	DEY
	BNE :-
:	RTS

;PRESS START
PlayRow:
	.byt $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $19, $1B, $0E, $1C, $1C
	.byt $24, $1C, $1D, $0A, $1B, $1D, $24, $24, $24, $24, $24, $24, $24, $24, $24

;PAUSE
PauseRow:
	.byt $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $19, $0A
	.byt $1E, $1C, $0E, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24

;PLAYER X WINS
WinRow:
	.byt $24, $24, $24, $24, $24, $24, $24, $24, $24, $19, $15, $0A, $22, $0E, $1B
	.byt $24, $00, $24, $20, $12, $17, $1C, $24, $24, $24, $24, $24, $24, $24, $24
