.include "nes.inc"
.include "global.inc"

.segment "CODE"

.proc reset

    sei
    cld
    ldx #$ff
    txs       ;initialize SP = $ff
    inx
    stx PPUCTRL
    stx PPUMASK
    stx PPUSTATUS

:   bit PPUSTATUS
    bpl :-
:   bit PPUSTATUS
    bpl :-

    ;zero ram
    txa
:   sta $000, x ;??
    sta $100, x
    sta $200, x
    sta $300, x
    sta $400, x
    sta $500, x
    sta $600, x
    sta $700, x
    inx
    bne :-

    ;final wait
:   bit PPUSTATUS
    bpl :-

JMP main

.endproc

