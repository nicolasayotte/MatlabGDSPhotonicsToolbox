/*
 * Part of the GDS II toolbox for Octave & MATLAB
 * Copyright (c) 2013, Ulf Griesmann
 *
 * Description:
 * type declarations
 */

#ifndef _GDSTYPES_H
#define _GDSTYPES_H

#include <stdint.h>


/*--- GDS II record IDs ------------------------------*/
/*                                                    */
/*    record id -------+ +---------- data type        */
/*                     | |                            */
/*                     v v                            */
#define HEADER       0x0002
#define BGNLIB       0x0102
#define LIBNAME      0x0206
#define UNITS        0x0305
#define ENDLIB       0x0400
#define BGNSTR       0x0502
#define STRNAME      0x0606
#define ENDSTR       0x0700
#define BOUNDARY     0x0800
#define PATH         0x0900
#define SREF         0x0a00
#define AREF         0x0b00
#define TEXT         0x0c00
#define LAYER        0x0d02
#define DATATYPE     0x0e02
#define WIDTH        0x0f03
#define XY           0x1003
#define ENDEL        0x1100
#define SNAME        0x1206
#define COLROW       0x1302
#define TEXTNODE     0x1400
#define NODE         0x1500
#define TEXTTYPE     0x1602
#define PRESENTATION 0x1701
#define STRING       0x1906
#define STRANS       0x1a01
#define MAG          0x1b05
#define ANGLE        0x1c05
#define REFLIBS      0x1f06
#define FONTS        0x2006
#define PATHTYPE     0x2102
#define GENERATIONS  0x2202
#define ATTRTABLE    0x2306
#define STYPTABLE    0x2406
#define STRTYPE      0x2502
#define ELFLAGS      0x2601
#define ELKEY        0x2703
#define NODETYPE     0x2a02
#define PROPATTR     0x2b02
#define PROPVALUE    0x2c06
#define BOX          0x2d00
#define BOXTYPE      0x2e02
#define PLEX         0x2f03
#define BGNEXTN      0x3003
#define ENDEXTN      0x3103
#define TAPENUM      0x3202
#define TAPECODE     0x3302
#define STRCLASS     0x3401
#define RESERVED     0x3503
#define FORMAT       0x3602
#define MASK         0x3706
#define ENDMASKS     0x3800
#define LIBDIRSIZE   0x3902
#define SRFNAME      0x3a06


/*
 * element property flags for optional properties
 */
#define HAS_ELFLAGS    1
#define HAS_PLEX      (1<<1)
#define HAS_PTYPE     (1<<2)
#define HAS_WIDTH     (1<<3)
#define HAS_BGNEXTN   (1<<4)
#define HAS_ENDEXTN   (1<<5)
#define HAS_PRESTN    (1<<6)
#define HAS_STRANS    (1<<16)
#define HAS_ANGLE     (1<<17)
#define HAS_MAG       (1<<18)

/* 
 * dates 
 */
typedef uint16_t date_t[6];


/*
 * element kinds
 */
typedef enum {GDS_BOUNDARY=1, GDS_PATH, GDS_BOX, GDS_NODE, GDS_TEXT, 
              GDS_SREF, GDS_AREF} element_kind;

/*
 * properties stored in the internal structure
 */
typedef enum {PROP_ELFLAGS=1, PROP_PLEX, PROP_LAYER, 
	      PROP_DTYPE, PROP_PTYPE, PROP_TTYPE, PROP_BTYPE, PROP_NTYPE, 
              PROP_WIDTH, PROP_EXT, PROP_FONT, PROP_VERJ, PROP_HORJ,
	      PROP_STRANS, PROP_SNAME, PROP_ADIM} property_kind;
 

/* 
 * strans structure 
 */
typedef struct {
   uint16_t flags;
   double mag;
   double angle;
} strans_t;


typedef struct {
   element_kind kind;
   unsigned int has;  /* element property flags */
   uint16_t elflags;
   uint16_t layer;
   uint16_t dtype;    /* [data|text|node|box] type */
   uint16_t ptype;    /* path type */
   uint16_t present;  /* presentation */
   uint16_t nrow;
   uint16_t ncol;
   int32_t plex;
   char sname[34];    /* 32 chars max for structure names */
   strans_t strans;
   float width;
   float bgnextn;
   float endextn;
} element_t;

#endif /* _GDSTYPES_H */
