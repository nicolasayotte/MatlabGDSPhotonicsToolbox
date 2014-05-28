/*
 * Generic functions for converting between Excess64 and IEEE 754
 * floating point format.
 *
 * These functions are in the Public Domain.
 */

/*-----------------------------------------------------------------*/

/* find mantissa and exponent of a real number
 * in a normalized base 16 representation: M * 16 ^ E
 * 
 * Ulf Griesmann, NIST, January 2008
 */
static INLINE int 
float_parts(double anum, double *M) 
{  
   int E;
   int ex;
   int sgn;
   double mn;
   double ex16;

   /* handle special case of 0 input */
   if (anum == 0.0) {
      *M = 0.0;
      return 0;
   }

   /* separate out the sign; */
   if (anum < 0.0) {
      sgn = -1;
      anum *= -1;
   }
   else {
      sgn = 1;
   }

   /* find a base 16 representation of the number */
   mn = frexp(anum, &ex);         /* anum = mn * 2^ex, normalized */
   ex16 = 0.25 * ex;              /* scale to base 16 */
   E = ceil(ex16);                /* integer fraction is exponent */
   *M = mn * pow(16.0, ex16 - E); /* base 16 mantissa */

   /* normalize the representation such that 1/16 <= M < 1 */
   while (*M >= 1) {
      *M *= 0.0625;
      E++;
   }
   while (*M < 0.0625) {
      *M *= 16.0;
      E--;
   }

   *M *= sgn;

   return E;
}


/*-----------------------------------------------------------------*/

static INLINE double 
excess64_to_ieee754(uint64_t *b)
{ 
   unsigned char *bytes;
   int k, sign, exponent;
   uint64_t imantissa;
   double rnum, mantissa;

   
   bytes = (unsigned char *)b;

   /* convert to IEEE-754 double */
   sign = bytes[0] & 0x80;
   exponent = (bytes[0] & 0x7f) - 64;
   imantissa = 0;
   for(k=1; k<8; k++) {
      imantissa <<= 8;
      imantissa += bytes[k];
   }
   mantissa = (double)imantissa / 72057594037927936.0;  /* divide by 2^56 */

   rnum = mantissa * pow(16, (float)exponent);
   if(sign)
      rnum *= -1;

   return rnum;
}


/*-----------------------------------------------------------------*/

static INLINE void 
ieee754_to_excess64(double d, uint64_t *b)
{
   double mantissa;        /* mantissa of rnum */
   int exponent;           /* and its exponent */
   int k;
   unsigned char help;
   char *snum;

   snum = (char *)b;

   /* find exponent and mantissa */
   exponent = float_parts(d, &mantissa);

   /* convert to excess-64 representation */
   /* originally used on IBM mainframes */
   exponent += 64;  
   if (mantissa < 0.0) {
      exponent |= 0x80;   /* set the sign bit */
      mantissa *= -1;     /* and make mantissa positive */
   }
   snum[0] = exponent;

   for (k=1; k<8; k++) {
      mantissa *= 256;    /* shift 8 bits to the right */
      help = (unsigned char)mantissa;
      snum[k] = help;
      mantissa -= help;
   }
}

/*-----------------------------------------------------------------*/
