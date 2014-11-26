/*
 * Bit-level functions for GCC that convert between Excess64 and IEEE 754
 * floating point format.
 * -----------------------------------------------------------------------------
 *
 * Originally by Peter Scholtens, January 29th, 2012
 * modified by Ulf Griesmann, August 2013.
 *
 * This software is released under GPL version 3.
 * http://www.gnu.org/copyleft/gpl.html
 * 
 * NOTE: This file does not work correctly with Microsoft's C compiler. 
 * The generic version must be used instead.
 */


#ifndef _CONVERT_FLOAT
#define _CONVERT_FLOAT

#include "mex.h"
#include "byteswap.h"


/*-----------------------------------------------------------------*/

static INLINE double 
excess64_to_ieee754(uint64_t *b)
{ 
   int count = 0;
   uint64_t fraction;
   uint16_t exp_ieee;
   int8_t exp_ex64;


   /* Fraction takes binary content of last seven bytes */
   fraction = be64_to_host(*b) & 0xffffffffffffff;

   /* Exponent is last seven bits of first byte decremented with 64 */
   exp_ex64 = (*((int8_t *)b) & 0x7f) - 64;

   /* Convert exponent from Calma's GDSII (base16) to IEEE754 (base2) */
   exp_ieee = 1023+(((uint16_t) exp_ex64) << 2);

   /* Find leading '1' of significand,... but stop after 56 times,
      as left shift inserts zeros (prevent loop lock). */
   while (((fraction & 0x100000000000000) == 0) && count <= 56) {
      fraction <<= 1;
      exp_ieee-=1;
      count++;
   }
   /* When 57 times left shifted, fraction was filled
      with zero's, so to represent absolute zero in IEEE754
      set exponent also to lowest value */
   if (count >= 57)
      exp_ieee = 0;
 
   /* and suppress leading '1' (implicitly present in IEEE754) */
   fraction &= 0xFFFFFFFFFFFFFF;

   /* Shift 4-bits to the right, as IEEE754 has
      only 52 instead of 56 bits significand */
   fraction >>= 4;

   /* do binary OR operation with fraction and move
      exponent to correct position for IEEE754 */
   fraction |= (( (uint64_t) exp_ieee) << 52);

   /* Don't forget to logically OR sign bit too */
   if( *((int8_t *)b) & 0x80 ) fraction |= 0x8000000000000000;

   /* Re-interpret created bit pattern as double */
   return *( (double *)(&fraction) );
}


/*-----------------------------------------------------------------*/

static INLINE void 
ieee754_to_excess64(double d, uint64_t *b)
{
   uint16_t exp_ex64;
   uint16_t exp_ieee;
   uint64_t fraction;
   uint64_t d_bits;
   int i;


   /* Interpret double as an 64 bit unsigned integer */
   d_bits = *( (uint64_t *)&d );

   /* Fraction takes binary content of last 52 bits, while
      adding implicitly removed leading '1' (IEEE754) */
   fraction = (d_bits & 0xfffffffffffff) | 0x10000000000000;

   /* Take 2nd till 12th bit, and right shift them 52 positions,
      as representation of the exponent */
   exp_ieee = (uint16_t)((d_bits & 0x7ff0000000000000) >> 52);

   /* Verify if IEEE754 exponent exceeds Calma format range, return error */
   if ( (exp_ieee > 1275) || (exp_ieee < 767) ) {
     mexErrMsgTxt("ieee754_to_excess64 :  floating point number cannot be represented in excess-64 format.");
   } 
   else {
      /* Convert power of 2 to power of 16, remainder absorbed by fraction
         as ieee-1023 is default, add 4 (changing from 52 to 56 bit size of
         the fraction) and adding 4 times 64, the new offset of base 16.*/
      exp_ex64 = exp_ieee - 1023 + 4 + 4*64;
      for(i=1; i<3;i++) {
	 /* As factors 2^1, 2^2 and 2^3 do not fit in 2^4, shift fraction
	    accordingly, if needed. */
	 if(exp_ex64 & 0x1)
	    fraction <<= i;
	 exp_ex64 >>= 1; /* Looped twice, exp is divided by four */
      }
   }

   /* Write result to memory: binary OR function of sign, exponent and fraction */
   *b = host_to_be64( (d_bits & 0x8000000000000000) | 
                      ((uint64_t)exp_ex64 << 56) | fraction );
}

/*-----------------------------------------------------------------*/

#endif /* _CONVERT_FLOAT */
