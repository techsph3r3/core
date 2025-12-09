#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f data.sh 
#endif

static  char data [] = 
#define      tst2_z	19
#define      tst2	((&data[3]))
	"\331\261\270\164\106\202\271\317\176\012\271\234\201\240\165\346"
	"\064\120\321\223\377\067\247\157\125\361"
#define      rlax_z	1
#define      rlax	((&data[26]))
	"\112"
#define      chk2_z	19
#define      chk2	((&data[30]))
	"\377\033\262\327\125\307\141\101\205\226\311\066\201\353\226\146"
	"\314\337\163\371\245\177\371\276\206\343"
#define      pswd_z	256
#define      pswd	((&data[73]))
	"\271\063\016\123\312\362\010\235\313\271\125\162\051\253\143\343"
	"\120\324\320\362\114\341\271\342\222\245\057\106\035\154\074\062"
	"\347\365\113\334\237\112\050\173\025\375\034\107\336\003\274\237"
	"\307\212\042\024\154\333\367\377\200\046\105\236\223\201\321\172"
	"\167\034\126\026\147\177\221\175\174\256\304\133\262\200\372\171"
	"\013\035\216\167\370\206\166\171\255\274\030\100\076\351\272\265"
	"\006\021\314\156\220\136\353\015\014\260\150\276\061\143\070\075"
	"\200\307\264\171\115\053\362\372\350\012\073\046\364\366\333\372"
	"\007\250\151\227\006\124\244\022\005\015\321\066\160\012\164\361"
	"\322\051\152\037\124\135\032\075\150\125\143\134\113\077\127\123"
	"\347\300\353\355\025\220\000\032\235\322\121\016\335\305\377\257"
	"\357\152\317\103\307\352\201\057\100\345\214\214\045\343\337\014"
	"\244\312\372\271\133\373\324\370\316\046\007\253\353\007\133\333"
	"\161\053\036\070\025\240\150\125\205\364\342\252\330\301\267\174"
	"\214\262\065\347\255\011\340\174\057\347\050\033\356\203\366\140"
	"\257\025\230\304\266\001\032\073\365\374\345\315\276\235\111\112"
	"\117\177\062\375\211\022\171\270\372\242\324\351\046\313\111\325"
	"\341\342\232\227\315\320\016\177\312\314\006\255\260\130\331"
#define      lsto_z	1
#define      lsto	((&data[340]))
	"\370"
#define      opts_z	1
#define      opts	((&data[341]))
	"\207"
#define      text_z	96
#define      text	((&data[365]))
	"\177\111\031\250\364\175\214\104\121\135\067\036\055\105\236\367"
	"\021\244\245\302\375\176\054\120\206\220\142\163\204\133\241\365"
	"\311\036\257\037\201\033\035\265\044\175\347\256\000\127\025\122"
	"\264\172\353\326\005\134\034\066\154\066\035\136\374\260\115\074"
	"\012\221\235\120\041\265\213\033\260\014\040\101\234\043\025\130"
	"\364\310\361\347\342\012\027\056\204\342\043\063\046\167\376\275"
	"\154\014\126\371\240\361\270\317\262\242\025\135\011\242\303\205"
	"\034\317\173\310\357\201\105\211\147\352\337\102\260\322\350\057"
	"\033\001\330\020\177\145\125"
#define      msg1_z	42
#define      msg1	((&data[485]))
	"\357\360\321\215\350\343\062\215\376\131\215\270\265\215\010\111"
	"\151\325\154\311\341\133\074\314\155\241\027\334\065\143\133\337"
	"\063\123\177\366\264\026\251\217\267\327\241\312\256\247\124\043"
	"\317\034\245\057\014\322\270\163"
#define      date_z	1
#define      date	((&data[533]))
	"\346"
#define      tst1_z	22
#define      tst1	((&data[536]))
	"\235\206\321\146\021\047\371\306\151\346\047\051\212\063\362\216"
	"\330\356\241\007\350\232\226\235\240\166\227"
#define      shll_z	10
#define      shll	((&data[563]))
	"\360\236\334\112\363\121\320\316\272\303\336\232\170\337"
#define      chk1_z	22
#define      chk1	((&data[576]))
	"\167\012\054\100\320\050\316\221\356\314\220\063\317\370\071\072"
	"\317\315\244\245\063\316\356\055\237"
#define      inlo_z	3
#define      inlo	((&data[600]))
	"\363\247\127"
#define      xecc_z	15
#define      xecc	((&data[605]))
	"\204\142\216\142\342\100\314\364\176\064\127\224\060\164\212\127"
	"\135\037\072"
#define      msg2_z	19
#define      msg2	((&data[624]))
	"\154\021\061\141\053\325\160\026\171\142\372\056\334\066\370\373"
	"\336\213\165\150\133\172\342\250\231"/* End of data[] */;
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
