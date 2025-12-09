#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f client_master_dnp3.sh 
#endif

static  char data [] = 
#define      tst2_z	19
#define      tst2	((&data[4]))
	"\357\253\220\317\112\314\056\132\146\310\167\053\334\230\274\015"
	"\123\143\311\354\372\215\313\026\321\327\017"
#define      msg2_z	19
#define      msg2	((&data[31]))
	"\035\273\231\337\337\340\247\361\361\114\041\102\212\316\230\144"
	"\106\127\335\235\223\101\234\130\223\153"
#define      xecc_z	15
#define      xecc	((&data[54]))
	"\041\011\037\203\307\213\065\340\033\135\265\036\206\350\110\117"
	"\123\064"
#define      opts_z	1
#define      opts	((&data[71]))
	"\247"
#define      lsto_z	1
#define      lsto	((&data[72]))
	"\056"
#define      inlo_z	3
#define      inlo	((&data[73]))
	"\053\160\352"
#define      chk2_z	19
#define      chk2	((&data[79]))
	"\262\230\017\351\305\027\111\011\137\136\376\061\317\322\265\321"
	"\052\123\206\126\067\321"
#define      tst1_z	22
#define      tst1	((&data[100]))
	"\167\063\234\160\363\047\312\044\127\337\373\063\327\262\324\273"
	"\141\163\264\311\304\034\060\075\162\126\213\006\301"
#define      pswd_z	256
#define      pswd	((&data[147]))
	"\006\243\166\316\300\314\051\302\011\171\263\363\132\165\363\014"
	"\015\003\146\205\157\302\077\367\214\125\136\003\267\117\000\321"
	"\041\020\207\103\335\153\222\252\152\061\306\216\052\064\056\071"
	"\160\136\061\337\040\161\327\254\306\065\260\176\205\261\117\247"
	"\301\326\352\236\102\175\111\254\256\020\073\331\104\151\023\264"
	"\307\105\224\350\266\153\225\174\241\105\372\047\366\112\316\267"
	"\040\270\126\143\065\237\017\344\257\113\276\364\264\322\250\174"
	"\027\075\144\315\251\371\112\112\077\104\161\065\216\077\355\257"
	"\370\103\022\056\343\042\022\223\155\321\207\042\243\060\236\272"
	"\155\003\207\027\374\321\141\074\026\323\162\245\023\137\125\014"
	"\243\147\072\206\212\115\032\367\036\241\032\302\322\270\174\100"
	"\273\004\127\270\326\270\364\355\214\146\223\240\306\350\254\151"
	"\120\346\360\332\064\012\322\122\254\354\025\176\245\222\276\140"
	"\226\025\031\155\316\015\133\133\164\356\373\072\326\247\244\046"
	"\216\225\001\302\237\323\025\114\300\052\312\145\274\210\305\122"
	"\236\337\300\154\354\033\307\141\011\303\234\340\152\100\007\370"
	"\325\010\272\165\334\317\301\234\371\214\001\266\025\307\011\263"
	"\246\311\040\223\334\335\270\117\064\104\125\365\051\246\070\060"
	"\112\257\376\012"
#define      chk1_z	22
#define      chk1	((&data[419]))
	"\223\000\144\357\320\346\314\036\212\374\152\011\341\236\042\200"
	"\213\251\321\157\222\050\205\241\200\171"
#define      msg1_z	42
#define      msg1	((&data[455]))
	"\007\003\157\156\210\114\114\101\233\200\161\336\101\103\350\274"
	"\337\356\300\276\060\023\143\044\021\247\072\254\065\017\062\342"
	"\170\157\044\232\074\335\200\040\335\260\355\011\306\153\275\150"
	"\334\215\230\246\206\361\166\260"
#define      rlax_z	1
#define      rlax	((&data[501]))
	"\303"
#define      date_z	1
#define      date	((&data[502]))
	"\233"
#define      shll_z	10
#define      shll	((&data[505]))
	"\270\137\112\011\214\071\355\016\206\275\136\135"
#define      text_z	114
#define      text	((&data[521]))
	"\243\057\105\252\063\264\016\133\336\260\175\331\030\102\270\017"
	"\231\147\110\305\166\013\131\046\065\037\277\207\104\066\001\073"
	"\372\217\113\045\052\324\245\353\322\037\033\214\152\175\362\157"
	"\310\341\055\354\014\025\166\341\017\261\014\325\057\061\115\017"
	"\054\242\120\010\114\172\160\227\323\143\131\126\272\114\004\260"
	"\245\211\105\120\157\207\136\034\177\122\004\074\126\121\167\222"
	"\115\103\212\362\263\340\075\046\074\214\343\107\045\132\245\044"
	"\254\136\233\107\044\010\370\067\031\274\001\145\375\234\346\204"
	"\215\134\064\045\013\024\006\151\363\362\102\372\253\242\242\345"/* End of data[] */;
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
