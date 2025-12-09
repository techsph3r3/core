#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f modbus.sh 
#endif

static  char data [] = 
#define      rlax_z	1
#define      rlax	((&data[0]))
	"\372"
#define      shll_z	10
#define      shll	((&data[2]))
	"\000\253\217\347\171\173\170\316\322\223\034"
#define      text_z	130
#define      text	((&data[27]))
	"\332\156\310\124\215\226\026\214\340\047\024\001\262\056\170\015"
	"\341\253\017\133\210\031\102\177\232\046\313\004\112\011\076\175"
	"\046\207\305\245\062\266\102\333\010\225\305\260\134\057\170\015"
	"\130\236\326\352\330\323\124\176\062\271\272\257\300\225\174\240"
	"\134\071\307\160\123\376\161\310\077\377\022\271\357\124\001\355"
	"\177\214\064\023\277\303\072\327\016\165\154\145\302\372\371\052"
	"\045\106\074\037\376\236\233\104\031\302\321\156\371\361\037\137"
	"\002\253\311\114\060\210\220\360\330\322\243\022\136\112\324\063"
	"\302\307\251\151\255\231\033\157\103\024\201\212\315\144\144\375"
	"\024\226\061\006\334\263\123\227\114\235\321\345\302\322\301\075"
	"\226\233\254\137\357\071\366\006\306\326"
#define      date_z	1
#define      date	((&data[182]))
	"\227"
#define      tst2_z	19
#define      tst2	((&data[183]))
	"\003\010\062\061\372\231\076\304\211\045\204\331\236\242\377\000"
	"\227\132\224\166"
#define      inlo_z	3
#define      inlo	((&data[203]))
	"\327\362\003"
#define      chk2_z	19
#define      chk2	((&data[209]))
	"\072\107\274\170\161\136\237\327\257\361\106\054\215\310\325\366"
	"\020\071\031\054\054\306\037\012\217\340"
#define      xecc_z	15
#define      xecc	((&data[232]))
	"\315\066\307\023\305\265\363\124\067\046\132\274\116\006\272\364"
#define      tst1_z	22
#define      tst1	((&data[250]))
	"\173\162\041\056\350\131\142\124\133\217\277\357\304\047\012\351"
	"\301\051\050\021\013\200\135\137\364"
#define      lsto_z	1
#define      lsto	((&data[273]))
	"\372"
#define      chk1_z	22
#define      chk1	((&data[276]))
	"\171\366\074\032\043\062\035\111\207\301\120\244\322\335\232\330"
	"\177\004\155\047\077\372\217\052\022\320\112\000\172"
#define      msg2_z	19
#define      msg2	((&data[304]))
	"\361\360\014\055\252\210\152\357\105\026\151\141\356\003\367\147"
	"\255\032\116\044\132\315\201"
#define      opts_z	1
#define      opts	((&data[326]))
	"\353"
#define      pswd_z	256
#define      pswd	((&data[329]))
	"\044\070\360\223\025\344\304\316\071\234\304\340\221\033\113\056"
	"\076\367\123\066\077\367\043\365\162\013\213\013\201\141\177\043"
	"\177\160\267\224\124\173\143\215\030\047\156\252\103\271\330\201"
	"\260\054\270\360\044\334\345\227\347\161\243\151\323\043\214\122"
	"\223\103\347\347\277\112\165\327\162\343\201\265\235\132\067\116"
	"\207\360\077\254\314\045\104\264\226\347\035\151\012\251\273\236"
	"\355\243\205\254\355\373\204\140\336\006\026\173\141\116\312\351"
	"\076\011\225\012\056\331\277\304\301\334\055\314\206\351\152\164"
	"\215\360\041\172\353\245\333\312\254\361\106\015\100\020\366\176"
	"\031\214\211\110\146\110\014\050\045\072\364\254\044\137\041\261"
	"\117\102\054\073\350\010\006\224\371\114\242\071\135\231\270\167"
	"\045\101\277\214\212\314\264\260\007\251\135\053\010\176\335\130"
	"\300\012\223\250\022\232\075\013\346\337\105\104\170\376\273\236"
	"\077\173\053\312\107\337\172\117\211\327\172\221\126\130\352\026"
	"\142\175\277\164\030\374\200\376\334\305\103\125\303\376\363\003"
	"\172\037\316\301\376\111\020\207\041\213\031\167\343\003\215\106"
	"\201\115\250\226\055\372\066\375\043\266\325\234\254"
#define      msg1_z	42
#define      msg1	((&data[600]))
	"\350\347\054\043\044\313\210\223\021\040\322\126\013\021\342\104"
	"\010\363\164\336\300\321\023\151\223\054\356\243\125\350\364\145"
	"\150\064\004\253\171\023\230\116\355\334\251\041\230\154\252\036"
	"\175\167\237\270\215\106\160\227"/* End of data[] */;
#define      hide_z	4096
#define DEBUGEXEC	0	/* Define as 1 to debug execvp calls */
#define TRACEABLE	0	/* Define as 1 to enable ptrace the executable */

/* rtc.c */

#include <sys/stat.h>
#include <sys/types.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/* 'Alleged RC4' */

static unsigned char stte[256], indx, jndx, kndx;

/*
 * Reset arc4 stte. 
 */
void stte_0(void)
{
	indx = jndx = kndx = 0;
	do {
		stte[indx] = indx;
	} while (++indx);
}

/*
 * Set key. Can be used more than once. 
 */
void key(void * str, int len)
{
	unsigned char tmp, * ptr = (unsigned char *)str;
	while (len > 0) {
		do {
			tmp = stte[indx];
			kndx += tmp;
			kndx += ptr[(int)indx % len];
			stte[indx] = stte[kndx];
			stte[kndx] = tmp;
		} while (++indx);
		ptr += 256;
		len -= 256;
	}
}

/*
 * Crypt data. 
 */
void arc4(void * str, int len)
{
	unsigned char tmp, * ptr = (unsigned char *)str;
	while (len > 0) {
		indx++;
		tmp = stte[indx];
		jndx += tmp;
		stte[indx] = stte[jndx];
		stte[jndx] = tmp;
		tmp += stte[indx];
		*ptr ^= stte[tmp];
		ptr++;
		len--;
	}
}

/* End of ARC4 */

/*
 * Key with file invariants. 
 */
int key_with_file(char * file)
{
	struct stat statf[1];
	struct stat control[1];

	if (stat(file, statf) < 0)
		return -1;

	/* Turn on stable fields */
	memset(control, 0, sizeof(control));
	control->st_ino = statf->st_ino;
	control->st_dev = statf->st_dev;
	control->st_rdev = statf->st_rdev;
	control->st_uid = statf->st_uid;
	control->st_gid = statf->st_gid;
	control->st_size = statf->st_size;
	control->st_mtime = statf->st_mtime;
	control->st_ctime = statf->st_ctime;
	key(control, sizeof(control));
	return 0;
}

#if DEBUGEXEC
void debugexec(char * sh11, int argc, char ** argv)
{
	int i;
	fprintf(stderr, "shll=%s\n", sh11 ? sh11 : "<null>");
	fprintf(stderr, "argc=%d\n", argc);
	if (!argv) {
		fprintf(stderr, "argv=<null>\n");
	} else { 
		for (i = 0; i <= argc ; i++)
			fprintf(stderr, "argv[%d]=%.60s\n", i, argv[i] ? argv[i] : "<null>");
	}
}
#endif /* DEBUGEXEC */

void rmarg(char ** argv, char * arg)
{
	for (; argv && *argv && *argv != arg; argv++);
	for (; argv && *argv; argv++)
		*argv = argv[1];
}

int chkenv(int argc)
{
	char buff[512];
	unsigned long mask, m;
	int l, a, c;
	char * string;
	extern char ** environ;

	mask  = (unsigned long)&chkenv;
	mask ^= (unsigned long)getpid() * ~mask;
	sprintf(buff, "x%lx", mask);
	string = getenv(buff);
#if DEBUGEXEC
	fprintf(stderr, "getenv(%s)=%s\n", buff, string ? string : "<null>");
#endif
	l = strlen(buff);
	if (!string) {
		/* 1st */
		sprintf(&buff[l], "=%lu %d", mask, argc);
		putenv(strdup(buff));
		return 0;
	}
	c = sscanf(string, "%lu %d%c", &m, &a, buff);
	if (c == 2 && m == mask) {
		/* 3rd */
		rmarg(environ, &string[-l - 1]);
		return 1 + (argc - a);
	}
	return -1;
}

#if !TRACEABLE

#define _LINUX_SOURCE_COMPAT
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#if !defined(PTRACE_ATTACH) && defined(PT_ATTACH)
#	define PTRACE_ATTACH	PT_ATTACH
#endif
void untraceable(char * argv0)
{
	char proc[80];
	int pid, mine;

	switch(pid = fork()) {
	case  0:
		pid = getppid();
		/* For problematic SunOS ptrace */
#if defined(__FreeBSD__)
		sprintf(proc, "/proc/%d/mem", (int)pid);
#else
		sprintf(proc, "/proc/%d/as",  (int)pid);
#endif
		close(0);
		mine = !open(proc, O_RDWR|O_EXCL);
		if (!mine && errno != EBUSY)
			mine = !ptrace(PTRACE_ATTACH, pid, 0, 0);
		if (mine) {
			kill(pid, SIGCONT);
		} else {
			perror(argv0);
			kill(pid, SIGKILL);
		}
		_exit(mine);
	case -1:
		break;
	default:
		if (pid == waitpid(pid, 0, 0))
			return;
	}
	perror(argv0);
	_exit(1);
}
#endif /* !TRACEABLE */

char * xsh(int argc, char ** argv)
{
	char * scrpt;
	int ret, i, j;
	char ** varg;
	char * me = argv[0];

	stte_0();
	 key(pswd, pswd_z);
	arc4(msg1, msg1_z);
	arc4(date, date_z);
	if (date[0] && (atoll(date)<time(NULL)))
		return msg1;
	arc4(shll, shll_z);
	arc4(inlo, inlo_z);
	arc4(xecc, xecc_z);
	arc4(lsto, lsto_z);
	arc4(tst1, tst1_z);
	 key(tst1, tst1_z);
	arc4(chk1, chk1_z);
	if ((chk1_z != tst1_z) || memcmp(tst1, chk1, tst1_z))
		return tst1;
	ret = chkenv(argc);
	arc4(msg2, msg2_z);
	if (ret < 0)
		return msg2;
	varg = (char **)calloc(argc + 10, sizeof(char *));
	if (!varg)
		return 0;
	if (ret) {
		arc4(rlax, rlax_z);
		if (!rlax[0] && key_with_file(shll))
			return shll;
		arc4(opts, opts_z);
		arc4(text, text_z);
		arc4(tst2, tst2_z);
		 key(tst2, tst2_z);
		arc4(chk2, chk2_z);
		if ((chk2_z != tst2_z) || memcmp(tst2, chk2, tst2_z))
			return tst2;
		/* Prepend hide_z spaces to script text to hide it. */
		scrpt = malloc(hide_z + text_z);
		if (!scrpt)
			return 0;
		memset(scrpt, (int) ' ', hide_z);
		memcpy(&scrpt[hide_z], text, text_z);
	} else {			/* Reexecute */
		if (*xecc) {
			scrpt = malloc(512);
			if (!scrpt)
				return 0;
			sprintf(scrpt, xecc, me);
		} else {
			scrpt = me;
		}
	}
	j = 0;
	varg[j++] = argv[0];		/* My own name at execution */
	if (ret && *opts)
		varg[j++] = opts;	/* Options on 1st line of code */
	if (*inlo)
		varg[j++] = inlo;	/* Option introducing inline code */
	varg[j++] = scrpt;		/* The script itself */
	if (*lsto)
		varg[j++] = lsto;	/* Option meaning last option */
	i = (ret > 1) ? ret : 0;	/* Args numbering correction */
	while (i < argc)
		varg[j++] = argv[i++];	/* Main run-time arguments */
	varg[j] = 0;			/* NULL terminated array */
#if DEBUGEXEC
	debugexec(shll, j, varg);
#endif
	execvp(shll, varg);
	return shll;
}

int main(int argc, char ** argv)
{
#if DEBUGEXEC
	debugexec("main", argc, argv);
#endif
#if !TRACEABLE
	untraceable(argv[0]);
#endif
	argv[1] = xsh(argc, argv);
	fprintf(stderr, "%s%s%s: %s\n", argv[0],
		errno ? ": " : "",
		errno ? strerror(errno) : "",
		argv[1] ? argv[1] : "<null>"
	);
	return 1;
}
