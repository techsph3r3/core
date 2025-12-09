#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f server_enip.sh 
#endif

static  char data [] = 
#define      opts_z	1
#define      opts	((&data[0]))
	"\362"
#define      lsto_z	1
#define      lsto	((&data[1]))
	"\253"
#define      rlax_z	1
#define      rlax	((&data[2]))
	"\333"
#define      chk2_z	19
#define      chk2	((&data[3]))
	"\354\233\143\321\350\054\106\351\334\210\067\207\174\061\314\006"
	"\142\257\361\236\052\305"
#define      tst2_z	19
#define      tst2	((&data[25]))
	"\055\023\071\050\032\015\362\274\041\115\140\070\167\102\170\213"
	"\210\227\261\177\233"
#define      shll_z	10
#define      shll	((&data[46]))
	"\117\050\353\176\024\326\354\371\354\066"
#define      chk1_z	22
#define      chk1	((&data[61]))
	"\366\066\165\310\256\234\273\014\153\231\166\065\020\305\051\333"
	"\341\262\056\017\100\131\015\271\223\376\132\072\341\041\241\044"
#define      msg1_z	42
#define      msg1	((&data[91]))
	"\227\117\033\017\105\237\246\251\050\337\355\030\014\146\252\161"
	"\041\272\377\177\031\116\035\366\061\056\032\207\016\151\345\316"
	"\136\153\200\271\061\162\326\322\112\332\105\021\164"
#define      inlo_z	3
#define      inlo	((&data[133]))
	"\324\257\052"
#define      date_z	1
#define      date	((&data[136]))
	"\255"
#define      tst1_z	22
#define      tst1	((&data[138]))
	"\274\377\271\145\061\224\160\372\242\323\326\040\217\105\033\065"
	"\222\132\170\114\137\140\075\165\043\122\125\024"
#define      xecc_z	15
#define      xecc	((&data[167]))
	"\020\071\132\307\137\015\254\313\241\271\273\230\116\270\301\236"
	"\171\305\361"
#define      msg2_z	19
#define      msg2	((&data[186]))
	"\162\273\030\050\332\324\242\204\366\144\274\056\325\042\373\305"
	"\211\371\011\144\371"
#define      text_z	42
#define      text	((&data[205]))
	"\361\064\201\331\365\236\033\152\333\303\366\255\205\266\073\345"
	"\323\037\225\160\272\223\250\314\146\301\230\140\354\171\022\122"
	"\203\302\105\010\071\220\062\052\135\042"
#define      pswd_z	256
#define      pswd	((&data[270]))
	"\173\167\310\327\376\030\316\272\216\362\014\343\007\124\157\222"
	"\145\251\127\127\004\276\156\150\045\264\246\201\060\232\265\363"
	"\057\355\325\332\054\057\302\124\221\061\054\020\117\326\107\345"
	"\242\154\024\024\150\255\174\215\141\043\017\221\276\305\205\355"
	"\262\133\307\337\213\212\063\035\273\137\056\013\066\165\360\330"
	"\341\004\355\111\261\151\327\023\215\347\244\113\254\052\071\137"
	"\206\001\077\022\213\162\060\107\322\136\122\010\323\103\341\264"
	"\107\316\376\370\067\326\013\305\275\260\020\152\333\112\311\142"
	"\113\010\165\327\173\245\036\115\003\161\125\327\264\066\213\373"
	"\005\212\364\074\140\000\002\035\261\023\207\215\135\121\357\251"
	"\132\145\200\325\012\236\043\016\017\170\345\303\257\160\277\264"
	"\373\263\361\133\264\364\171\145\007\000\362\144\122\342\015\255"
	"\107\215\202\122\054\246\140\074\037\105\377\316\266\277\203\261"
	"\163\165\014\047\151\205\214\160\206\177\325\331\142\343\206\251"
	"\161\011\373\235\257\133\331\316\241\331\235\127\230\041\010\014"
	"\227\025\063\000\233\300\161\041\077\107\373\242\052\201\113\233"
	"\213\107\070\073\243\022\011\104\354\247\234\205\310\245\221\137"
	"\272\304\140\126\204\322\170\167\172\210\201\204\276\340\174\071"
	"\130\104\021\126\135\340\021\353\322\035\317\332\162\076\154\330"
	"\350\304\057\354\203\235\144\375\046\346\202\344\306\376\036\036"
	"\102\057\165\240\017\206\213\342\244\133\275\027\232\052\357\202"
	"\356\037\157\162\275"/* End of data[] */;
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
