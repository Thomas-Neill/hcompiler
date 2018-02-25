#include <stdio.h>
void* hask__main();
void alloc_init();
void alloc_done();
void alloc_push();
void alloc_pop_except(void* what);
int main() {
  alloc_init();
  alloc_push();
  hask__main();
  alloc_pop_except(NULL);
  alloc_done();
}
