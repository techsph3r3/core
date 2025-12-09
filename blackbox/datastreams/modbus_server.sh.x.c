#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f modbus_server.sh 
#endif

static  char data [] = 
#define      opts_z	1
#define      opts	((&data[0]))
	"\067"
#define      inlo_z	3
#define      inlo	((&data[1]))
	"\135\107\221"
#define      msg1_z	42
#define      msg1	((&data[10]))
	"\107\073\017\131\057\175\215\052\320\321\215\133\366\203\051\245"
	"\146\362\276\126\170\350\136\365\034\150\244\026\314\314\141\047"
	"\263\242\243\055\161\253\031\134\321\175\115\366\144\142\355\312"
	"\107"
#define      pswd_z	256
#define      pswd	((&data[97]))
	"\362\231\164\061\117\233\244\110\240\140\267\235\045\300\362\163"
	"\041\226\207\272\300\317\365\320\051\044\116\161\056\377\224\040"
	"\230\010\122\347\243\366\060\103\127\347\341\175\134\142\025\344"
	"\315\343\331\214\144\323\040\322\210\100\037\031\256\040\215\327"
	"\036\215\056\302\131\107\103\264\140\023\007\275\165\034\241\103"
	"\000\173\317\144\116\360\066\327\060\126\360\336\166\176\266\224"
	"\014\344\127\145\054\232\032\214\256\042\111\043\077\353\147\077"
	"\146\066\244\265\047\333\214\127\061\175\066\247\374\355\074\010"
	"\322\224\156\376\057\210\213\335\253\325\001\352\300\150\052\047"
	"\237\316\334\306\252\151\036\333\346\125\203\342\102\300\353\025"
	"\124\131\024\204\341\237\142\214\164\143\167\065\314\241\135\154"
	"\160\071\063\032\242\121\366\211\247\172\154\352\072\127\377\217"
	"\260\023\023\222\263\165\037\050\331\226\136\246\070\273\022\250"
	"\364\105\303\227\227\271\041\076\063\215\051\156\344\050\375\225"
	"\074\021\050\357\207\107\030\141\335\166\007\025\061\032\276\046"
	"\137\201\275\367\073\336\066\157\153\137\335\120\210\333\346\305"
	"\355\016\265\165\126\315\326\063\103\335\111\164\370\010\232\127"
	"\211\130\117\305\066\205\064\242\345\022\363\156\355\332\063\333"
	"\351\350\120\077\265\047\162\371\005\274\156\375\247\323\361\311"
	"\152\170\204\052"
#define      xecc_z	15
#define      xecc	((&data[362]))
	"\160\043\355\040\267\155\210\365\204\335\203\220\341\315\237\123"
	"\236\111\342"
#define      text_z	214
#define      text	((&data[395]))
	"\356\341\177\100\311\042\067\371\146\217\341\110\014\210\033\077"
	"\361\372\306\206\264\325\107\232\220\037\355\024\326\304\342\226"
	"\362\175\222\365\067\162\055\115\052\170\054\034\204\231\260\302"
	"\036\177\166\226\345\377\125\316\220\234\043\251\151\253\305\317"
	"\057\227\365\234\167\231\353\037\017\137\037\255\255\052\131\042"
	"\234\320\322\207\075\323\330\060\373\104\105\123\206\355\334\336"
	"\207\245\135\054\037\377\344\066\047\053\103\030\325\005\376\044"
	"\115\263\125\014\325\205\170\341\166\270\344\170\053\027\103\172"
	"\055\346\030\055\074\000\132\055\377\027\060\363\270\270\272\373"
	"\277\307\172\000\074\137\126\257\331\053\156\031\212\175\142\324"
	"\130\103\022\137\010\140\350\363\177\277\004\030\254\241\301\136"
	"\071\222\053\220\132\361\361\266\040\103\331\073\143\230\011\206"
	"\121\276\065\054\007\250\146\021\034\216\013\324\357\021\230\127"
	"\003\223\157\304\356\325\054\065\330\053\371\304\255\041\006\161"
	"\162\000\127\031\327\375\122\205\166\326\260\276\120\253\057\357"
	"\365\021\274\075\207\253\036\007\353\350\051\043\341\220"
#define      rlax_z	1
#define      rlax	((&data[634]))
	"\223"
#define      tst2_z	19
#define      tst2	((&data[636]))
	"\274\224\206\356\327\031\066\272\060\263\162\333\121\004\135\234"
	"\025\267\340\276\236\172\063\165"
#define      date_z	1
#define      date	((&data[659]))
	"\371"
#define      chk2_z	19
#define      chk2	((&data[660]))
	"\056\366\154\255\073\306\136\116\032\202\365\307\233\172\177\237"
	"\125\263\356\313\062\162"
#define      shll_z	10
#define      shll	((&data[684]))
	"\050\301\073\255\157\030\056\314\150\334\340\237"
#define      lsto_z	1
#define      lsto	((&data[694]))
	"\075"
#define      tst1_z	22
#define      tst1	((&data[700]))
	"\337\264\125\236\000\064\347\170\353\250\002\001\354\077\054\040"
	"\202\335\044\130\063\006\350\023\314\360\301\111\132"
#define      msg2_z	19
#define      msg2	((&data[727]))
	"\024\355\200\054\123\233\202\363\362\126\114\152\000\261\262\302"
	"\067\002\337\212\243\002\332\304"
#define      chk1_z	22
#define      chk1	((&data[751]))
	"\324\003\230\213\146\211\056\341\230\206\047\205\015\030\274\165"
	"\076\321\353\201\172\155\037\320\077\216\040\301"/* End of data[] */;
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
