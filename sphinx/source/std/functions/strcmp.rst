strcmp
------
String comparison
^^^^^^^^^^^^^^^^^

Synopsys
""""""""

strcmp compare two (potentially NULL) strings and return a negative, null or positive value depending on the comparison.

The comparison algorithm is the following:

   * If both string are NULL, strcmp returns 0
   * If the first string is NULL, strcmp returns -1
   * If the second string is NULL, strcmp returns 1
   * If both string are non-NULL, the result depends on the first differenciated character:

       * If the first string char ASCII value is smaller than the second string one, strcmp return -1
       * If the second string char ASCII value is smaller than the first string one, strcmp return 1
       * If strings are equal (no difference found upto the leading \0), strcmp return 0


Caution
"""""""

strcmp compare C (null-terminated) strings. strcmp arguments can be NULL but if not must finish with '\0'.

