/*
 * Copyright (C) 1994, 1995, ..., 2013
 * Ulf Griesmann, Gaithersburg MD 20878, U.S.A.
 *
 * This program is in the Public Domain.
 *
 * $Id$
 */

/*
 * A list is a pointer to an anchor block which contains some global data
 * of the list and a pointer to the first mooring. The moorings consist
 * of pointers to the previous mooring, the next mooring and to the actual
 * data of the respective list entry. The anchor block contains a list pointer
 * which points to the 'current entry' of the list. Most operations which affect
 * a single entry of the list act on the current entry and afterwards increment
 * the list pointer.
 *
 *
 *                  +-------------------------+---------------------+
 *  List -------->  |      anchor block       | List pointer        |----+
 *                  +-------------------------+---------------------+    |
 *                               |                                       |
 *                               |  pointer to first mooring             |
 *                               V                                       V
 *                  +-------------------------+               +--------------------+
 *                  | pointer to previous     | <------------ | pointer to prev.   |
 *                  | mooring (here: NULL)    |               | mooring            |
 *                  +-------------------------+               +--------------------+
 *                  | pointer to next         | ------------> | pointer to next    |
 *                  | mooring                 |               | mooring            |
 *                  +-------------------------+               +--------------------+
 *                  | pointer to list data    |               | ptr to list data   |
 *                  +-------------------------+               +--------------------+
 *                              |                                        |
 *                              |                                        |
 *                              V                                        V
 *                       +--------------+                           +-----------+
 *                       | list data    |                           | list data |
 *                       +--------------+                           +-----------+
 *
 * The code in this module is based on a similar program published in 
 * Dal Cin, Lutz and Risse, Programmierung in Modula-2, Teubner Verlag, Germany
 */

/* modified for use in Octave & MATLAB mex files. Ulf Griesmann, August 2013 */

#include <stdlib.h>
#include <string.h>
#include "mxlist.h"
#include "mex.h"


/*
 * Moorings for data
 */
typedef struct {
   struct Mooring *prev;      /* pointer to previous mooring */
   struct Mooring *next;      /* pointer to next mooring */
   void *data;                /* pointer to the actual data */
} Mooring;

/*
 * Anchor block
 */
typedef struct {
   int entries;               /* current number of list entries */
   struct Mooring *first;     /* pointer to first entry; not necessary but useful */
   struct Mooring *last;      /* pointer to tail of list */
   struct Mooring *current;   /* pointer to current entry */
   struct Mooring *tmp;       /* to store a pointer */
} Anchor;


/*-----------------------------------------------------------------*/

int 
create_list( tList *list )
{
   Anchor *anchor_block;

   anchor_block = (Anchor *) mxMalloc( sizeof( Anchor ) );
   if ( anchor_block == NULL ) 
     {
	return -1;
     }
   else
     {
	anchor_block->entries = 0;
	anchor_block->first   = NULL;
	anchor_block->last    = NULL;
	anchor_block->current = NULL;
	*list = (tList)anchor_block;
	return 0;
     }
}

/*-----------------------------------------------------------------*/

tList 
new_list()
{
   Anchor *anchor_block;

   anchor_block = (Anchor *) mxMalloc( sizeof( Anchor ) );
   if ( anchor_block == NULL ) {
      return NULL;
   }

   anchor_block->entries = 0;
   anchor_block->first   = NULL;
   anchor_block->last    = NULL;
   anchor_block->current = NULL;
   return (tList)anchor_block;
}

/*-----------------------------------------------------------------*/

int
erase_list_entries( tList list )
{
   /* 
    * to make it speedier this function does not call remove_current_entry
    */
   Anchor  *anchor_block;
   Mooring *current_mooring;

   if ( list == NULL )
     return(-1);

   anchor_block = (Anchor *)list;
   if ( anchor_block->entries == 0 )
     return 0;
   
   list_tail( list );
   current_mooring = (Mooring *) anchor_block->current;
   while ( current_mooring->prev != NULL )
     {
	mxFree( current_mooring->data );
	current_mooring = (Mooring *)current_mooring->prev;  
	mxFree( current_mooring->next );
     }

   /* free the first entry */
   mxFree( current_mooring->data );
   mxFree( anchor_block->first );
   anchor_block->first   = NULL;
   anchor_block->last    = NULL;
   anchor_block->current = NULL;
   anchor_block->entries = 0;
   return 0;
}

/*-----------------------------------------------------------------*/

int 
delete_list( tList *list )
{
   Anchor *anchor_block;

   if ( list == NULL )
     return -1;
   anchor_block = (Anchor *) list;
   if ( anchor_block->entries > 0 )
     {
	return -1;
     }
   else
     {
	mxFree( anchor_block );
	*list = (tList)NULL;
	return 0;
     }
}

/*-----------------------------------------------------------------*/

int 
list_entries( tList list )
{
   Anchor *anchor_block;
   
   if ( list == NULL )
     return -1;
   anchor_block = (Anchor *) list;
   return( anchor_block->entries );
}

/*-----------------------------------------------------------------*/

void
list_next( tList list )
{
   Anchor *anchor_block;
   Mooring *current_mooring;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *)list;
   current_mooring = (Mooring *) anchor_block->current;
   if ( current_mooring->next == NULL )
     anchor_block->current = anchor_block->first;  /* wrap to beginning */
   else
     anchor_block->current = current_mooring->next;
}

/*-----------------------------------------------------------------*/

void
list_prev( tList list )
{
   Anchor  *anchor_block;
   Mooring *current_mooring;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *)list;
   current_mooring = (Mooring *) anchor_block->current;
   if ( current_mooring->prev == NULL )
     anchor_block->current = anchor_block->last;   /* wrap to end */
   else
     anchor_block->current = current_mooring->prev;
}

/*-----------------------------------------------------------------*/

void 
list_head( tList list )
{
   Anchor *anchor_block;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *) list;
   if ( anchor_block->entries > 0 )
     anchor_block->current = anchor_block->first;     
}

/*-----------------------------------------------------------------*/

void
list_tail( tList list)
{
   Anchor  *anchor_block;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *) list;
   if ( anchor_block->entries > 0 )
     anchor_block->current = anchor_block->last;     
}

/*-----------------------------------------------------------------*/

int
list_at_head( tList list )
{
   Anchor *anchor_block;

   if ( list == NULL )
     return -1;
   anchor_block = (Anchor *) list;
   if (anchor_block->entries == 0)
      return 1;
   if (anchor_block->current == anchor_block->first)
     return 1;
   return 0;
}

/*-----------------------------------------------------------------*/

int
list_at_tail( tList list )
{
   Anchor *anchor_block;

   if ( list == NULL )
     return -1;
   anchor_block = (Anchor *) list;
   if (anchor_block->entries == 0)
      return 1;
   if (anchor_block->current == anchor_block->last )
     return 1;
   return 0;
}

/*-----------------------------------------------------------------*/

void
list_store_current(tList list)
{
   Anchor *anchor_block;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *) list;
   anchor_block->tmp = anchor_block->current;
}

/*-----------------------------------------------------------------*/

void
list_recall_current(tList list)
{
   Anchor *anchor_block;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *) list;
   anchor_block->current = anchor_block->tmp;
}

/*-----------------------------------------------------------------*/

int 
list_insert( tList list, void *new_entry, int location )
{
   Anchor  *anchor_block;
   Mooring *mooring_block,
           *current_mooring,
           *tmp_mooring;

   if ( list == NULL )
     return -1;

   /* 
    * create a new mooring 
    */
   anchor_block  = (Anchor *) list;
   mooring_block = (Mooring *) mxMalloc( sizeof( Mooring ) );
   if ( mooring_block == NULL )
     return -1;

   if ( anchor_block->first == NULL )  
     {
	/* 
	 * list is still empty 
	 */
	anchor_block->first   = (void *) mooring_block;
	anchor_block->last    = (void *) mooring_block;
	mooring_block->prev   = NULL;
	mooring_block->next   = NULL;
     }
   else  
     {
	current_mooring = (Mooring *) anchor_block->current;

	if ( location == BEFORE )        /* link in before current mooring */
	  {
	     if ( current_mooring->prev == NULL )   /* already at beginning */
	       {
		  anchor_block->first = (void *)mooring_block;
		  mooring_block->prev = NULL;
		  mooring_block->next = (void *)current_mooring;
		  current_mooring->prev = (void *)mooring_block;
	       }
	     else
	       {
		  tmp_mooring = (Mooring *)current_mooring->prev;
		  tmp_mooring->next = (void *) mooring_block;
		  mooring_block->prev = (void *) tmp_mooring;
		  mooring_block->next = (void *) current_mooring;
		  current_mooring->prev = (void *) mooring_block;
	       }
	  }
	else                             /* link in after current mooring */
	  {
	     if ( current_mooring->next == NULL )  /* already at end */
	       {
		  anchor_block->last = (void *) mooring_block;
		  mooring_block->prev = (void *) current_mooring;
		  mooring_block->next = NULL;
		  current_mooring->next = (void *)mooring_block;
	       }
	     else
	       {
		  tmp_mooring = (Mooring *)current_mooring->next;
		  tmp_mooring->prev = (void *) mooring_block;
		  mooring_block->prev = (void *) current_mooring;
		  mooring_block->next = (void *) tmp_mooring;
		  current_mooring->next = (void *) mooring_block;
	       }
	  }
     }	
   mooring_block->data   = new_entry;
   anchor_block->current = (void *)mooring_block;
   anchor_block->entries++;
   return 0;
}

/*-----------------------------------------------------------------*/

int
list_insert_object( tList list, void *new_object, int obj_size, int location )
{
   void   *new_entry;

   if ( list == NULL )
     return -1;
   new_entry = (void *)mxMalloc( obj_size );
   if ( new_entry == NULL )
     return -1;
   memcpy( new_entry, new_object, obj_size );
   return list_insert( list, new_entry, location );
}

/*-----------------------------------------------------------------*/

int 
sorted_list_insert( tList list, void *new_entry, int (*comp_proc)(void *, void *) )
{
   Anchor  *anchor_block;
   Mooring *mooring_block,
           *current_mooring,
           *tmp_mooring;

   int comp_res;

   if ( list == NULL )
     return -1;
   
   /* 
    * create a new mooring 
    */
   anchor_block  = (Anchor *) list;
   mooring_block = (Mooring *) mxMalloc( sizeof( Mooring ) );
   if ( mooring_block == NULL )
     return -1;

   if ( anchor_block->first == NULL )  
     {
	/* 
	 * list is still empty 
	 */
	anchor_block->first = (void *) mooring_block;
	anchor_block->last  = (void *) mooring_block;
	mooring_block->prev = NULL;
	mooring_block->next = NULL;
     }
   else  
     {
	/* 
	 * find right place for new mooring and link it in 
	 */
	list_tail( list );
	current_mooring = (Mooring *)anchor_block->current;
	while ( (comp_res = (*comp_proc)(new_entry,current_mooring->data) ) < 0 
                && current_mooring->prev != NULL )
	  {
	     current_mooring = (Mooring *)current_mooring->prev;
	  }
	if ( current_mooring->prev == NULL && comp_res < 0 ) /* make it first entry */
	  {
	     anchor_block->first = (void *)mooring_block;
	     mooring_block->prev = (void *)NULL;
	     mooring_block->next = (void *)current_mooring;
	     current_mooring->prev = (void *)mooring_block;
	  }
	else
	  {
	     if ( current_mooring->next != NULL )
	       {
		  tmp_mooring = (Mooring *)current_mooring->next;
	          tmp_mooring->prev = (void *)mooring_block;
	       }
	     else
	       {
		  anchor_block->last = (void *)mooring_block;
	       }
	     mooring_block->prev = (void *)current_mooring;
	     mooring_block->next = current_mooring->next;
	     current_mooring->next = (void *)mooring_block;
	  }
     }
   mooring_block->data = new_entry;
   anchor_block->current = (void *)mooring_block;
   anchor_block->entries++;
   return 0;
}

/*-----------------------------------------------------------------*/

int 
sorted_list_insert_object(tList list, void *new_object, int obj_size, int (*comp_proc)(void *, void *))
{
   void   *new_entry;

   if ( list == NULL )
     return -1;
   new_entry = (void *)mxMalloc( obj_size );
   if ( new_entry == NULL )
     return -1;
   memcpy( new_entry, new_object, obj_size );
   return sorted_list_insert(list, new_entry, comp_proc );
}

/*-----------------------------------------------------------------*/

void *
get_current_entry( tList list, void **ptr_to_entry )
{
   Anchor  *anchor_block;
   Mooring *current_mooring;
   void *data_block;

   if ( list == NULL )
     return NULL;
   anchor_block = (Anchor *) list;
   current_mooring = (Mooring *) anchor_block->current;
   data_block = current_mooring->data;
   if ( current_mooring->next != NULL )
     anchor_block->current = current_mooring->next;
   else
     anchor_block->current = anchor_block->first;  /* wrap to beginning */
   if (ptr_to_entry != NULL)
      *ptr_to_entry = data_block;
   return data_block;
}

/*-----------------------------------------------------------------*/

void *
get_current_object( tList list, void *object, int obj_size )
{
   void *not_used;
   void *data;

   if ( list == NULL )
     return NULL;
   data = get_current_entry( list, &not_used );
   if ( data != NULL )
     memcpy( object, data, obj_size );
   return data;
}

/*-----------------------------------------------------------------*/

void
remove_current_entry( tList list )
{
   Anchor  *anchor_block;
   Mooring *current_mooring,
           *doomed_mooring,
           *tmp_mooring;

   if ( list == NULL )
     return;
   anchor_block = (Anchor *) list;
   if ( anchor_block->entries == 0 )             /* list is empty */
     return;
   doomed_mooring = (Mooring *) anchor_block->current;
   mxFree( doomed_mooring->data );
   
   if ( anchor_block->entries == 1 )             /* remove last remaining entry */
     {
	mxFree( anchor_block->first );
	anchor_block->first   = NULL;
	anchor_block->last    = NULL;
	anchor_block->current = NULL;
     }
   else
     {
	if ( doomed_mooring->next == NULL )     /* tail */
	  {
	     current_mooring = (Mooring *) doomed_mooring->prev;   
	     current_mooring->next = NULL;
	     anchor_block->last = (void *) current_mooring;	     
	  }
	else if ( doomed_mooring->prev == NULL )  /* head */
	  {
	     current_mooring = (Mooring *)doomed_mooring->next;
	     current_mooring->prev = NULL;
	     anchor_block->first = (void *) current_mooring;	     
	  }
	else
	  {
	     current_mooring = (Mooring *) doomed_mooring->prev;   /* forward */
	     current_mooring->next = doomed_mooring->next;
	     tmp_mooring = (Mooring *)doomed_mooring->next;        /* backward */
	     tmp_mooring->prev = (void *) current_mooring;     
	  }
	mxFree( doomed_mooring );
	anchor_block->current = (void *) current_mooring;
     }
   anchor_block->entries--;
}

/*-----------------------------------------------------------------*/

void
chop_list_tail( tList list )
{
   list_tail( list );   /* make last entry the current entry */
   remove_current_entry( list );
}

/*-----------------------------------------------------------------*/

void 
scan_list( tList list, void (*scan_proc)(void *) )
{
   void *data;
   int i;

   list_head( list );
   for (i=0; i<list_entries(list); i++)
     {
	get_current_entry( list, &data );
	(*scan_proc)( data );
     }
}

/*-----------------------------------------------------------------*/

void *
search_list( tList list, int (*search_proc)(void *) )
{
   void *data = NULL;
   int i;
   int flag = 0;

   list_head( list );
   for (i=0; i<list_entries(list); i++)
     {
	get_current_entry( list, &data );
	flag = (*search_proc)( data );
	if ( flag == 1 )
	  break;
     }
   if ( flag == 0 )
     return( NULL );
   else
     return( data );
}

/*-----------------------------------------------------------------*/

void *
search_list_object(tList list, void *object, int obj_size, int (*search_proc)(void *) )
{
   void *data = NULL;

   data = search_list( list, search_proc );
   if ( data != NULL )
     memcpy( object, data, obj_size );
   return data;
}

/*-----------------------------------------------------------------*/

/* Revision history:
 * -----------------
 * $Log$
 */
