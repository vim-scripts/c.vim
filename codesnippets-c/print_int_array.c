
/*----------------------------------------------------------------------
 *  print_int_array
 *  Print an int-array with one dimension 
 *----------------------------------------------------------------------*/
static void
print_int_array ( int array[],    /* array to print                */
                  int n,          /* number of elements to print   */
                  int columns,    /* number of elements per column */
                  char* arrayname /* array name                    */
                  )
{
  int i;
  printf ("\n  array \"%s\", length %d\n", arrayname, n );
  for ( i=0; i<n; i+=1 )
  {
    if(i%columns==0)
      printf ("\n%6d : ", i );
    printf (" %6d", array[i] );
  }
  return ;
}       /* ----------  end of function print_int_array  ---------- */

