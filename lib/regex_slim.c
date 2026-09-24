#include <regex.h>
#include <stdlib.h>

regex_t *alloc_regex_t(void) { return malloc(sizeof(regex_t)); }

void free_regex_t(regex_t *ptr) {
  regfree(ptr);
  free(ptr);
}

size_t re_nsub(regex_t *ptr) { return ptr->re_nsub; }
