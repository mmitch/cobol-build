#include <libcob.h>
#include <stdio.h>

cob_s64_t addition(cob_s64_t value1, cob_s64_t value2) {
   printf("%lld %lld\n", value1, value2);
   return value1 + value2;
}
