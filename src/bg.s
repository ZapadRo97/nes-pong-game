.include "nes.inc"
.include "global.inc"

.segment "ZEROPAGE"
rowTile: .res 1

.segment "CODE"

.proc draw_bg

;background starts at $2000
LoadBackground:
    LDA PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDA #$24
    STA rowTile
    .repeat 2
    JSR LoadScreenRow
    .endrepeat

    LDX #$00
ScoreLineLoop:
    LDA scoreRow, x
    STA PPUDATA
    INX
    CPX #$20
    BNE ScoreLineLoop


    LDA #$26
    STA rowTile
    JSR LoadRow


    LDY #$00
LinesLoop:
    JSR LoadScreenRow
    INY
    CPY #$18
    BNE LinesLoop

    LDA #$26
    STA rowTile
    .repeat 2
    JSR LoadRow
    .endrepeat

   JSR LoadAttribute

    ;the score
    LDA PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #P1_ADDR
    STA PPUADDR
    LDA #$00
    STA PPUDATA

    LDA PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #P2_ADDR
    STA PPUADDR
    LDA #$00
    STA PPUDATA




   ;the ball
    LDA #$80
    STA BALL_Y        ;put sprite 0 in center ($80) of screen vertically
    STA BALL_X        ;put sprite 0 in center ($80) of screen horizontally
    LDA #$00
    STA $0201        ;tile number
    lda #$00
    STA $0202        ;color palette = 0, no flipping

    ;left paddle

    LDA #$0C
    STA LPADTOP_X
    STA LPADMID_X
    STA LPADBOT_X

    LDA #$EC
    STA RPADTOP_X
    STA RPADMID_X
    STA RPADBOT_X

    LDA #$78
    STA LPADTOP_Y
    STA RPADTOP_Y

    LDA #$80
    STA LPADMID_Y
    STA RPADMID_Y

    LDA #$88
    STA LPADBOT_Y
    STA RPADBOT_Y


    LDX #$00
SpriteAttrLoop:
    TXA
    ASL A
    ASL A ;*4 for address
    TAY

    LDA #$10
    STA $0205, Y ;sprite num

    LDA #$00    
    STA $0206, Y ; color pallete, no flipping
    INX
    CPX #$06
    BNE SpriteAttrLoop


    RTS


LoadRow:
    LDX #$00
LoadFullLoop:
    LDA rowTile
    STA PPUDATA
    INX
    CPX #$20 ; copy 32
    BNE LoadFullLoop

    RTS

LoadScreenRow:
    LDA #$26
    STA PPUDATA
    LDX #$00
LoadScreenLoop:
    LDA #$24 ;sky
    STA PPUDATA
    INX
    CPX #$1E ; copy 30
    BNE LoadScreenLoop

    LDA #$26
    STA PPUDATA

    RTS

;attributes start at $23C0
LoadAttribute:
    LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$C0
    STA PPUADDR
    LDX #$00
LoadAttributeLoop:
    LDA #$FF
    STA PPUDATA
    INX
    CPX #$40 ;copy all 128
    BNE LoadAttributeLoop

    RTS


scoreRow:
        
    ;the 0 will be removed
    .byt $26,$24,$24,$24, $19,$15,$0A,$22,$0E,$1B,$01,$28,$24, $24,$24,$24  ;score row
    .byt $24,$24,$24, $19,$15,$0A,$22,$0E,$1B,$02,$28,$24, $24,$24,$24,$26

.endproc
