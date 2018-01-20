#include <stdlib.h>
#include <stdio.h>

/*
Part of the H runtime.
Provides a stack-based allocation routine.

Declares a few functions:

void alloc_push()
Pushes a stack frame

void* alloc(int size)
Allocates size bytes, errors out if the stack is empty

void alloc_depends(void* depender,void* dependee)
Adds a dependency between depender and dependee

void alloc_pop_except(void* return)
If return == NULL, kill everything
Else, kill all except dependees, recursively found.

void alloc_init()
void alloc_done()
*/

#define DIE(err) printf(err);exit(1);

/* DATA */
const int STACK_MAX = 1000; //to be safe
struct List;
typedef struct List {
  struct List* next;
  void* value;
  struct List* dependencies;
} List;

typedef List* list;

static list* stack; // list of lists
static int stack_size = 0;

/* LIST HELPERS */
void append(list* list_,void* value) {
  list lst = *list_;
  if(lst == NULL) {
    (*list_) = malloc(sizeof(List));
    lst = *list_;
    lst->next = NULL;
    lst->value = value;
    lst->dependencies = NULL;
  } else {
    append(&lst->next,value);
  }
}

void appendNode(list* list_,list value) {
  if(*list_ == NULL) {
    (*list_) = value;
  } else {
    appendNode(&(*list_)->next,value);
  }
}

void freeAll(list lst) {
  if(lst == NULL) return;
  freeAll(lst->next);
  freeAll(lst->dependencies);
  free(lst);
}

/* IMPLEMENTATIONS */
void alloc_init() {stack = malloc(STACK_MAX);}
void alloc_done() {free(stack);}
void alloc_push() {
  if(stack_size == STACK_MAX){
    DIE("Error: stack overflow.\n")
  }
  stack[stack_size++] = NULL;
}

void* alloc(int size) {
  void* ret = malloc(size);
  append(&stack[stack_size - 1],ret);
  return ret;
}

void alloc_depends(void* depender,void* dependency) {
  if(stack_size == 0) {
    DIE("Stack underflow.\n");
  }
  for(list it = stack[stack_size-1];it!=NULL;it=it->next) {
      if(it->value == depender) {
        append(&it->dependencies,dependency);
        return;
      }
  }
  DIE("Depender not in stack frame\n");
}

void compile_dependencies(void* exception, list* exceptions) {
  append(exceptions,exception);
  for(list it1=stack[stack_size-1];it1!=NULL;it1=it1->next) {
    if(it1->value==exception) {
      for(list it=it1->dependencies;it!=NULL;it=it->next) {
        compile_dependencies(it->value,exceptions); //recurse to flatten dependency graph
      }
    }
  }
}

void alloc_pop_except(void* exception) {
  if(stack_size == 0) {
    DIE("Error: stack underflow.\n");
  }
  if(stack_size == 1) {
    for(list it = stack[stack_size-1];it!=NULL;it=it->next) {
      free(it->value);
    }
    freeAll(stack[--stack_size]);
    stack[stack_size] = NULL;
    return;
  }
  list exceptions = NULL;
  if(exception != NULL) {
    compile_dependencies(exception,&exceptions);
  }
  for(list it=stack[stack_size-1],last = NULL;it!=NULL;last=it,it=it->next) {
    int inex = 0;
    for(list it1 = exceptions; it1 != NULL; it1 = it1->next) {
      if(it1->value == it->value) {
        inex = 1;
        break;
      }
    }
    if(inex) {
      list new = malloc(sizeof(List));
      new->value = it->value;
      new->next = NULL;
      new->dependencies = it->dependencies;
      it->dependencies = NULL;
      appendNode(&stack[stack_size-2],new);
    } else {
      free(it->value);
    }
  }
  freeAll(exceptions);
  freeAll(stack[--stack_size]);
  stack[stack_size] = NULL;
}

/* TESTING */
/*
int* make(int a) {
  alloc_push();
  int* ret = alloc(sizeof(int));
  (*ret) = a;
  alloc_pop_except(ret);
  return ret;
}

int** join(int a,int b) {
  alloc_push();
  int** ret = alloc(sizeof(int*) * 2);
  int* a_ = alloc(sizeof(int));
  int* b_ = alloc(sizeof(int));
  int* unused = alloc(sizeof(int));
  (*a_) = a;
  (*b_) = b;
  ret[0] = a_;
  ret[1] = b_;
  alloc_depends(ret,a_);
  alloc_depends(ret,b_);
  alloc_pop_except(ret);
  return ret;
}

int** addboth(int** x,int*y) {
  (*x[0]) += *y;
  (*x[1]) += *y;
  return x;
}

int sum(int** x) {
  return (*x[0]) + (*x[1]);
}

int stuff() {
  alloc_push();
  int** a = join(10,20);
  int* b = make(10);
  addboth(a,b);
  int result = sum(a);
  alloc_pop_except(NULL);
  return result;
}

int main() {
  alloc_init();
  printf("The result is: %d\n",stuff());
  alloc_done();
}
*/
