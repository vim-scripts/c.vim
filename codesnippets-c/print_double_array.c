
/*----------------------------------------------------------------------
 *  print_double_array
 *  Print a double-array with one dimension 
 *----------------------------------------------------------------------*/
static void
print_double_array (  double array[], /* array to print                */
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
    printf (" %8.2f", array[i] );
  }
  return ;
}       /* ----------  end of function print_double_array  ---------- */

