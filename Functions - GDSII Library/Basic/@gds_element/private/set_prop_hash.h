/* ANSI-C code produced by gperf version 3.0.3 */
/* Command-line: gperf set_prop_hash.gperf  */
/* Computed positions: -k'1' */

#if !((' ' == 32) && ('!' == 33) && ('"' == 34) && ('#' == 35) \
      && ('%' == 37) && ('&' == 38) && ('\'' == 39) && ('(' == 40) \
      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \
      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \
      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \
      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \
      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \
      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \
      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \
      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \
      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \
      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \
      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \
      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \
      && ('Z' == 90) && ('[' == 91) && ('\\' == 92) && (']' == 93) \
      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \
      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \
      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \
      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \
      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \
      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \
      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \
      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))
/* The character set is not based on ISO-646.  */
#error "gperf generated tables don't work with this execution character set. Please report a bug to <bug-gnu-gperf@gnu.org>."
#endif

#line 1 "set_prop_hash.gperf"

/* hash function for element property access
 *
 * process with:
 *    gperf set_prop_hash.gperf > set_prop_hash.h
 *
 * NOTE: this software is in the Public Domain
 * Ulf Griesmann, July 2013
*/
#line 14 "set_prop_hash.gperf"
struct keyword {
   char *name;
   void (*set_prop_func)(element_t *, mxArray *);
};

#define TOTAL_KEYWORDS 16
#define MIN_WORD_LENGTH 3
#define MAX_WORD_LENGTH 7
#define MIN_HASH_VALUE 3
#define MAX_HASH_VALUE 35
/* maximum key range = 33, duplicates = 0 */

#ifdef __GNUC__
__inline
#else
#ifdef __cplusplus
inline
#endif
#endif
static unsigned int
hash (register const char *str, register unsigned int len)
{
  static unsigned char asso_values[] =
    {
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 20,  3, 36,
      30,  0, 15, 36, 10, 36, 36, 36, 25, 36,
      20, 36,  5, 36, 36,  0, 15, 36,  0, 10,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36, 36, 36, 36, 36,
      36, 36, 36, 36, 36, 36
    };
  return len + asso_values[(unsigned char)str[0]];
}

#ifdef __GNUC__
__inline
#ifdef __GNUC_STDC_INLINE__
__attribute__ ((__gnu_inline__))
#endif
#endif
struct keyword *
in_word_set (register const char *str, register unsigned int len)
{
  static struct keyword wordlist[] =
    {
      {""}, {""}, {""},
#line 29 "set_prop_hash.gperf"
      {"ext",     &set_ext},
#line 31 "set_prop_hash.gperf"
      {"verj",    &set_verj},
#line 34 "set_prop_hash.gperf"
      {"sname",   &set_sname},
#line 33 "set_prop_hash.gperf"
      {"strans",  &set_strans},
#line 20 "set_prop_hash.gperf"
      {"elflags", &set_elflags},
#line 26 "set_prop_hash.gperf"
      {"btype",   &set_btype},
#line 21 "set_prop_hash.gperf"
      {"plex",    &set_plex},
#line 24 "set_prop_hash.gperf"
      {"ptype",   &set_ptype},
      {""}, {""}, {""},
#line 32 "set_prop_hash.gperf"
      {"horj",    &set_horj},
#line 28 "set_prop_hash.gperf"
      {"width",   &set_width},
      {""}, {""}, {""},
#line 30 "set_prop_hash.gperf"
      {"font",    &set_font},
#line 25 "set_prop_hash.gperf"
      {"ttype",   &set_ttype},
      {""}, {""}, {""},
#line 35 "set_prop_hash.gperf"
      {"adim",    &set_adim},
#line 27 "set_prop_hash.gperf"
      {"ntype",   &set_ntype},
      {""}, {""}, {""}, {""},
#line 22 "set_prop_hash.gperf"
      {"layer",   &set_layer},
      {""}, {""}, {""}, {""},
#line 23 "set_prop_hash.gperf"
      {"dtype",   &set_dtype}
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = hash (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}
