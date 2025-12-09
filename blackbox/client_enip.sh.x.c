#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f client_enip.sh 
#endif

static  char data [] = 
#define      tst1_z	22
#define      tst1	((&data[1]))
	"\236\020\162\175\351\304\013\372\004\350\050\250\326\105\271\226"
	"\305\167\362\235\342\320\325\034\176\047\145\022"
#define      date_z	1
#define      date	((&data[28]))
	"\262"
#define      shll_z	10
#define      shll	((&data[29]))
	"\000\232\001\055\156\116\250\267\132\343"
#define      inlo_z	3
#define      inlo	((&data[39]))
	"\034\102\142"
#define      lsto_z	1
#define      lsto	((&data[42]))
	"\136"
#define      rlax_z	1
#define      rlax	((&data[43]))
	"\156"
#define      chk1_z	22
#define      chk1	((&data[45]))
	"\365\232\155\130\054\205\026\101\063\234\063\007\322\206\011\015"
	"\326\110\134\030\267\162\136"
#define      text_z	110
#define      text	((&data[73]))
	"\140\211\134\377\246\332\203\034\043\343\262\174\171\335\046\345"
	"\022\150\224\332\155\054\025\375\271\240\217\351\325\050\030\302"
	"\315\050\273\256\010\326\043\346\247\050\011\227\104\125\051\050"
	"\036\341\314\374\145\263\140\002\252\262\101\146\254\173\351\204"
	"\006\041\131\077\216\043\153\027\271\006\271\141\262\133\310\061"
	"\234\112\226\266\130\313\117\216\034\243\211\212\127\266\320\000"
	"\334\106\055\243\026\237\053\074\111\065\142\250\237\240\051\215"
	"\227\074\121\025\046\014\355\126\251\306\175\315\321\312\023\200"
	"\067"
#define      xecc_z	15
#define      xecc	((&data[198]))
	"\201\232\306\115\046\343\203\203\332\137\061\241\056\227\235\114"
	"\140\137\267\300"
#define      msg2_z	19
#define      msg2	((&data[218]))
	"\323\360\320\354\150\075\306\236\013\077\205\022\116\243\121\063"
	"\016\311\220\320\064\204\057\357\052"
#define      pswd_z	256
#define      pswd	((&data[246]))
	"\367\154\340\275\352\037\347\375\341\313\241\201\346\147\262\120"
	"\272\377\021\054\005\346\141\343\023\005\146\347\172\311\223\252"
	"\174\250\136\365\307\106\363\250\021\224\052\367\373\334\107\266"
	"\333\131\343\341\077\105\304\123\112\052\073\305\363\316\157\160"
	"\166\316\146\075\024\131\346\045\356\020\035\352\354\145\240\310"
	"\276\204\251\376\311\156\121\023\231\214\330\215\133\110\375\321"
	"\026\143\016\052\275\365\120\253\005\156\225\361\323\065\271\221"
	"\272\143\220\203\321\341\226\153\156\157\370\311\270\366\233\316"
	"\132\252\371\027\237\112\302\244\270\127\226\213\215\120\035\107"
	"\263\255\313\205\217\142\360\376\321\351\310\212\340\143\130\072"
	"\015\122\121\254\234\024\121\125\154\347\341\371\067\376\101\353"
	"\254\014\160\074\156\141\073\100\113\003\312\053\147\043\145\164"
	"\166\267\041\022\313\162\147\067\132\110\061\221\107\162\175\364"
	"\177\355\061\356\117\154\057\232\160\372\305\327\035\053\114\223"
	"\342\155\246\255\340\016\345\072\127\026\314\237\211\111\224\010"
	"\067\305\366\206\062\046\041\243\040\347\172\076\022\307\322\365"
	"\064\170\243\024\207\255\217\264\301\017\354\002\271\316\204\124"
	"\056\073"
#define      msg1_z	42
#define      msg1	((&data[520]))
	"\017\127\273\223\207\262\203\254\336\047\362\274\115\156\127\213"
	"\107\302\320\347\222\300\002\031\067\274\304\336\377\156\211\254"
	"\105\214\142\117\160\150\250\132\315\116\161\300\305\274\337\252"
	"\276\221\301\364\210\056\324"
#define      opts_z	1
#define      opts	((&data[570]))
	"\105"
#define      tst2_z	19
#define      tst2	((&data[575]))
	"\345\271\106\237\163\354\123\150\363\037\044\032\010\171\002\013"
	"\317\337\043\227\125\320\112\210"
#define      chk2_z	19
#define      chk2	((&data[599]))
	"\005\010\073\320\327\316\134\025\127\133\374\363\005\273\362\022"
	"\317\375\263\315\175\211\132\027\223\213"/* End of data[] */;
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
