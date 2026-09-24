#include <regex.h>

regex_t *alloc_regex_t(void);
void free_regex_t(regex_t *ptr);
size_t re_nsub(regex_t *ptr);
