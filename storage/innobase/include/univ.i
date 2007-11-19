/***************************************************************************
Version control for database, common definitions, and include files

(c) 1994 - 2000 Innobase Oy

Created 1/20/1994 Heikki Tuuri
****************************************************************************/

#ifndef univ_i
#define univ_i

#if (defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)) && !defined(MYSQL_SERVER) && !defined(__WIN__)
# undef __WIN__
# define __WIN__

# include <windows.h>

# if !defined(WIN64) && !defined(_WIN64)
#  define UNIV_CAN_USE_X86_ASSEMBLER
# endif

# ifdef _NT_
#  define __NT__
# endif

#else
/* The defines used with MySQL */

/* Include two header files from MySQL to make the Unix flavor used
in compiling more Posix-compatible. These headers also define __WIN__
if we are compiling on Windows. */

# include <my_global.h>
# include <my_pthread.h>

/* Include <sys/stat.h> to get S_I... macros defined for os0file.c */
# include <sys/stat.h>

# undef PACKAGE
# undef VERSION

/* Include the header file generated by GNU autoconf */
# ifndef __WIN__
#  include "config.h"
# endif

# ifdef HAVE_SCHED_H
#  include <sched.h>
# endif

/* When compiling for Itanium IA64, undefine the flag below to prevent use
of the 32-bit x86 assembler in mutex operations. */

# if defined(__WIN__) && !defined(WIN64) && !defined(_WIN64)
#  define UNIV_CAN_USE_X86_ASSEMBLER
# endif

/* We only try to do explicit inlining of functions with gcc and
Microsoft Visual C++ */

# if !defined(__GNUC__)
#  undef  UNIV_MUST_NOT_INLINE			/* Remove compiler warning */
#  define UNIV_MUST_NOT_INLINE
# endif

# ifdef HAVE_PREAD
#  define HAVE_PWRITE
# endif

#endif /* #if (defined(WIN32) || ... */

/*			DEBUG VERSION CONTROL
			===================== */

/* The following flag will make InnoDB to initialize
all memory it allocates to zero. It hides Purify
warnings about reading unallocated memory unless
memory is read outside the allocated blocks. */
/*
#define UNIV_INIT_MEM_TO_ZERO
*/

/* Make a non-inline debug version */

#if 0
#define UNIV_DEBUG_VALGRIND			/* Enable extra
						Valgrind instrumentation */
#define UNIV_DEBUG				/* Enable ut_ad() assertions */
#define UNIV_LIST_DEBUG				/* debug UT_LIST_ macros */
#define UNIV_MEM_DEBUG				/* detect memory leaks etc */
#define UNIV_IBUF_DEBUG				/* debug the insert buffer;
this limits the database to IBUF_COUNT_N_SPACES and IBUF_COUNT_N_PAGES,
and the insert buffer must be empty when the database is started */
#define UNIV_SYNC_DEBUG				/* debug mutex and latch
operations (very slow); also UNIV_DEBUG must be defined */
#define UNIV_SEARCH_DEBUG			/* debug B-tree comparisons */
#define UNIV_SYNC_PERF_STAT			/* operation counts for
						rw-locks and mutexes */
#define UNIV_SEARCH_PERF_STAT			/* statistics for the
						adaptive hash index */
#define UNIV_SRV_PRINT_LATCH_WAITS		/* enable diagnostic output
						in sync0sync.c */
#define UNIV_BTR_PRINT				/* enable functions for
						printing B-trees */
#endif

#define UNIV_BTR_DEBUG				/* check B-tree links */
#define UNIV_LIGHT_MEM_DEBUG			/* light memory debugging */

#ifdef HAVE_purify
/* The following sets all new allocated memory to zero before use:
this can be used to eliminate unnecessary Purify warnings, but note that
it also masks many bugs Purify could detect. For detailed Purify analysis it
is best to remove the define below and look through the warnings one
by one. */
#define UNIV_SET_MEM_TO_ZERO
#endif

/*
#define UNIV_SQL_DEBUG
#define UNIV_LOG_DEBUG
*/
			/* the above option prevents forcing of log to disk
			at a buffer page write: it should be tested with this
			option off; also some ibuf tests are suppressed */
/*
#define UNIV_BASIC_LOG_DEBUG
*/
			/* the above option enables basic recovery debugging:
			new allocated file pages are reset */

#if (!defined(UNIV_DEBUG) && !defined(INSIDE_HA_INNOBASE_CC) && !defined(UNIV_MUST_NOT_INLINE))
/* Definition for inline version */

#ifdef __WIN__
#define UNIV_INLINE	__inline
#else
#define UNIV_INLINE static __inline__
#endif

#else
/* If we want to compile a noninlined version we use the following macro
definitions: */

#define UNIV_NONINL
#define UNIV_INLINE

#endif	/* UNIV_DEBUG */

#ifdef _WIN32
#define UNIV_WORD_SIZE		4
#elif defined(_WIN64)
#define UNIV_WORD_SIZE		8
#else
/* MySQL config.h generated by GNU autoconf will define SIZEOF_LONG in Posix */
#define UNIV_WORD_SIZE		SIZEOF_LONG
#endif

/* The following alignment is used in memory allocations in memory heap
management to ensure correct alignment for doubles etc. */
#define UNIV_MEM_ALIGNMENT      8

/* The following alignment is used in aligning lints etc. */
#define UNIV_WORD_ALIGNMENT	UNIV_WORD_SIZE

/*
			DATABASE VERSION CONTROL
			========================
*/

/* The universal page size of the database */
#define UNIV_PAGE_SIZE          (2 * 8192) /* NOTE! Currently, this has to be a
					power of 2 */
/* The 2-logarithm of UNIV_PAGE_SIZE: */
#define UNIV_PAGE_SIZE_SHIFT	14

/* Maximum number of parallel threads in a parallelized operation */
#define UNIV_MAX_PARALLELISM	32

/*
			UNIVERSAL TYPE DEFINITIONS
			==========================
*/

/* Note that inside MySQL 'byte' is defined as char on Linux! */
#define byte			unsigned char

/* Define an unsigned integer type that is exactly 32 bits. */

#if SIZEOF_INT == 4
typedef unsigned int		ib_uint32_t;
#elif SIZEOF_LONG == 4
typedef unsigned long		ib_uint32_t;
#else
#error "Neither int or long is 4 bytes"
#endif

/* Another basic type we use is unsigned long integer which should be equal to
the word size of the machine, that is on a 32-bit platform 32 bits, and on a
64-bit platform 64 bits. We also give the printf format for the type as a
macro ULINTPF. */

#ifdef _WIN64
typedef unsigned __int64	ulint;
#define ULINTPF			"%I64u"
typedef __int64			lint;
#else
typedef unsigned long int	ulint;
#define ULINTPF			"%lu"
typedef long int		lint;
#endif

#ifdef __WIN__
typedef __int64			ib_longlong;
#else
typedef longlong		ib_longlong;
#endif

typedef unsigned long long int	ullint;

#ifndef __WIN__
#if SIZEOF_LONG != SIZEOF_VOIDP
#error "Error: InnoDB's ulint must be of the same size as void*"
#endif
#endif

/* The 'undefined' value for a ulint */
#define ULINT_UNDEFINED		((ulint)(-1))

/* The undefined 32-bit unsigned integer */
#define	ULINT32_UNDEFINED	0xFFFFFFFF

/* Maximum value for a ulint */
#define ULINT_MAX		((ulint)(-2))

/* This 'ibool' type is used within Innobase. Remember that different included
headers may define 'bool' differently. Do not assume that 'bool' is a ulint! */
#define ibool			ulint

#ifndef TRUE

#define TRUE    1
#define FALSE   0

#endif

/* The following number as the length of a logical field means that the field
has the SQL NULL as its value. NOTE that because we assume that the length
of a field is a 32-bit integer when we store it, for example, to an undo log
on disk, we must have also this number fit in 32 bits, also in 64-bit
computers! */

#define UNIV_SQL_NULL ULINT32_UNDEFINED

/* Lengths which are not UNIV_SQL_NULL, but bigger than the following
number indicate that a field contains a reference to an externally
stored part of the field in the tablespace. The length field then
contains the sum of the following flag and the locally stored len. */

#define UNIV_EXTERN_STORAGE_FIELD (UNIV_SQL_NULL - UNIV_PAGE_SIZE)

/* Some macros to improve branch prediction and reduce cache misses */
#if defined(__GNUC__) && (__GNUC__ > 2) && ! defined(__INTEL_COMPILER)
/* Tell the compiler that 'expr' probably evaluates to 'constant'. */
# define UNIV_EXPECT(expr,constant) __builtin_expect(expr, constant)
/* Tell the compiler that a pointer is likely to be NULL */
# define UNIV_LIKELY_NULL(ptr) __builtin_expect((ulint) ptr, 0)
/* Minimize cache-miss latency by moving data at addr into a cache before
it is read. */
# define UNIV_PREFETCH_R(addr) __builtin_prefetch(addr, 0, 3)
/* Minimize cache-miss latency by moving data at addr into a cache before
it is read or written. */
# define UNIV_PREFETCH_RW(addr) __builtin_prefetch(addr, 1, 3)
#else
/* Dummy versions of the macros */
# define UNIV_EXPECT(expr,value) (expr)
# define UNIV_LIKELY_NULL(expr) (expr)
# define UNIV_PREFETCH_R(addr) ((void) 0)
# define UNIV_PREFETCH_RW(addr) ((void) 0)
#endif
/* Tell the compiler that cond is likely to hold */
#define UNIV_LIKELY(cond) UNIV_EXPECT(cond, TRUE)
/* Tell the compiler that cond is unlikely to hold */
#define UNIV_UNLIKELY(cond) UNIV_EXPECT(cond, FALSE)

/* Compile-time constant of the given array's size. */
#define UT_ARR_SIZE(a) (sizeof(a) / sizeof((a)[0]))

/* The return type from a thread's start function differs between Unix and
Windows, so define a typedef for it and a macro to use at the end of such
functions. */

#ifdef __WIN__
typedef ulint os_thread_ret_t;
#define OS_THREAD_DUMMY_RETURN return(0)
#else
typedef void* os_thread_ret_t;
#define OS_THREAD_DUMMY_RETURN return(NULL)
#endif

#include <stdio.h>
#include "ut0dbg.h"
#include "ut0ut.h"
#include "db0err.h"
#ifdef UNIV_DEBUG_VALGRIND
# include <valgrind/memcheck.h>
# define UNIV_MEM_VALID(addr, size) VALGRIND_MAKE_MEM_DEFINED(addr, size)
# define UNIV_MEM_INVALID(addr, size) VALGRIND_MAKE_MEM_UNDEFINED(addr, size)
# define UNIV_MEM_FREE(addr, size) VALGRIND_MAKE_MEM_NOACCESS(addr, size)
# define UNIV_MEM_ALLOC(addr, size) VALGRIND_MAKE_MEM_UNDEFINED(addr, size)
# define UNIV_MEM_ASSERT_RW(addr, size) do {				\
	const void* _p = (const void*) (ulint)				\
		VALGRIND_CHECK_MEM_IS_DEFINED(addr, size);		\
	if (UNIV_LIKELY_NULL(_p))					\
		fprintf(stderr, "%s:%d: %p[%u] undefined at %ld\n",	\
			__FILE__, __LINE__,				\
			(const void*) (addr), (unsigned) (size), (long)	\
			(((const char*) _p) - ((const char*) (addr))));	\
	} while (0)
# define UNIV_MEM_ASSERT_W(addr, size) do {				\
	const void* _p = (const void*) (ulint)				\
		VALGRIND_CHECK_MEM_IS_ADDRESSABLE(addr, size);		\
	if (UNIV_LIKELY_NULL(_p))					\
		fprintf(stderr, "%s:%d: %p[%u] unwritable at %ld\n",	\
			__FILE__, __LINE__,				\
			(const void*) (addr), (unsigned) (size), (long)	\
			(((const char*) _p) - ((const char*) (addr))));	\
	} while (0)
#else
# define UNIV_MEM_VALID(addr, size) do {} while(0)
# define UNIV_MEM_INVALID(addr, size) do {} while(0)
# define UNIV_MEM_FREE(addr, size) do {} while(0)
# define UNIV_MEM_ALLOC(addr, size) do {} while(0)
# define UNIV_MEM_ASSERT_RW(addr, size) do {} while(0)
# define UNIV_MEM_ASSERT_W(addr, size) do {} while(0)
#endif
#define UNIV_MEM_ASSERT_AND_FREE(addr, size) do {	\
	UNIV_MEM_ASSERT_W(addr, size);			\
	UNIV_MEM_FREE(addr, size);			\
} while (0)
#define UNIV_MEM_ASSERT_AND_ALLOC(addr, size) do {	\
	UNIV_MEM_ASSERT_W(addr, size);			\
	UNIV_MEM_ALLOC(addr, size);			\
} while (0)

#endif
