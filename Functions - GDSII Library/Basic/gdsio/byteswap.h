/*
 * Utilities for byte swapping when data 
 * are not in host byte order on little endian machines.
 * These functions are provided because there is no standard for
 * byte reordering functions in C.
 *
 * Ulf Griesmann, August 2013
 */

#ifndef _BYTESWAP
#define _BYTESWAP

#include <stdint.h>

/* GNU C has inline */
#if defined __GNUC__
   #define INLINE __inline__
#else
   #define INLINE
#endif


/*-----------------------------------------------------------------*/

static INLINE void 
byte_reverse(uint16_t *s) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   *s =  ( ( *s & 0x00ffU ) <<  8 ) | 
         ( ( *s & 0xff00U ) >>  8 );
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. Nuthin' */
#endif
}


/*-----------------------------------------------------------------*/

static INLINE void 
byte_reverse_n(uint16_t *s, int n) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   register int k;
   for (k=0; k<n; k++) {
      s[k] =  ( ( s[k] & 0x00ffU ) <<  8 ) | 
              ( ( s[k] & 0xff00U ) >>  8 );
   }
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. НИЧЕГО */
#endif
}


/*-----------------------------------------------------------------*/

static INLINE void 
byte_reverse32(int32_t *i) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   register int32_t x;

   x = *i;
   x = ( ( x & 0x000000ffU ) << 24 ) | 
       ( ( x & 0x0000ff00U ) <<  8 ) | 
       ( ( x & 0x00ff0000U ) >>  8 ) | 
       ( ( x & 0xff000000U ) >> 24 );
   *i = x;
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. Nix */
#endif
}


/*-----------------------------------------------------------------*/

static INLINE void 
byte_reverse32_n(int32_t *i, int n) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   register int k;
   register int32_t x;

   for (k=0; k<n; k++) {
      x = i[k];
      x = ( ( x & 0x000000ffU ) << 24 ) | 
	  ( ( x & 0x0000ff00U ) <<  8 ) | 
	  ( ( x & 0x00ff0000U ) >>  8 ) | 
	  ( ( x & 0xff000000U ) >> 24 );
      i[k] = x;
   }
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. 而已 */
#endif
}


/*-----------------------------------------------------------------*/

static INLINE uint64_t 
be64_to_host(uint64_t u) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   return  (u>>56) |
          ((u<<40) & 0x00ff000000000000) |
          ((u<<24) & 0x0000ff0000000000) |
          ((u<<8)  & 0x000000ff00000000) |
          ((u>>8)  & 0x00000000ff000000) |
          ((u>>24) & 0x0000000000ff0000) |
          ((u>>40) & 0x000000000000ff00) |
           (u<<56);
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. Rien */
#endif
}

/*-----------------------------------------------------------------*/

static INLINE uint64_t 
host_to_be64(uint64_t u) {
#if __BYTE_ORDER == __LITTLE_ENDIAN
   return  (u>>56) |
          ((u<<40) & 0x00ff000000000000) |
          ((u<<24) & 0x0000ff0000000000) |
          ((u<<8)  & 0x000000ff00000000) |
          ((u>>8)  & 0x00000000ff000000) |
          ((u>>24) & 0x0000000000ff0000) |
          ((u>>40) & 0x000000000000ff00) |
           (u<<56);
#elif __BYTE_ORDER == __BIG_ENDIAN
   /*  .. Nihil */
#endif
}

/*-----------------------------------------------------------------*/

#endif /* _BYTESWAP */
