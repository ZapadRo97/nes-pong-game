.ifndef NES_INC
.define NES_INC 1

;;PPU Registers
PPUCTRL    = $2000
PPUMASK    = $2001
PPUSTATUS  = $2002
OAMADDR    = $2003
OAMDATA    = $2004
PPUSCROLL  = $2005
PPUADDR    = $2006
PPUDATA    = $2007

;; IOreg
OAMDMA     = $4014
APUSTATUS  = $4015
JOYPAD1    = $4016
JOYPAD2    = $4017


;;SPRITE POSITIONS
BALL_Y = $0200
BALL_X = $0203


LPADTOP_Y = $0204
LPADMID_Y = $0208
LPADBOT_Y = $020C

LPADTOP_X = $0207
LPADMID_X = $020B
LPADBOT_X = $020F

RPADTOP_Y = $0210
RPADMID_Y = $0214
RPADBOT_Y = $0218

RPADTOP_X = $0213
RPADMID_X = $0217
RPADBOT_X = $021B

;P1SCORE_Y = $021C
;P1SCORE_X = $021F
;P1SCORE_TILE = $021D
;P1SCORE_ATTR = $021E

;P2SCORE_Y = $0220
;P2SCORE_X = $0223
;P2SCORE_TILE = $0221
;P2SCORE_ATTR = $0222

P1_ADDR = $4C
P2_ADDR = $5B

.endif
