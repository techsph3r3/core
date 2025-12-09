#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f http.sh 
#endif

static  char data [] = 
#define      tst2_z	19
#define      tst2	((&data[3]))
	"\172\121\301\360\365\035\243\376\262\142\373\060\153\100\220\222"
	"\220\254\344\354\165\213"
#define      rlax_z	1
#define      rlax	((&data[22]))
	"\251"
#define      xecc_z	15
#define      xecc	((&data[25]))
	"\161\137\261\226\210\355\025\106\256\052\123\132\046\262\105\062"
	"\200\341"
#define      pswd_z	256
#define      pswd	((&data[72]))
	"\024\271\157\162\314\116\240\361\325\235\263\074\001\224\360\061"
	"\017\102\362\276\006\111\027\214\225\211\354\167\226\150\160\145"
	"\251\230\066\271\362\373\317\046\041\166\327\117\360\067\067\217"
	"\224\207\063\254\200\246\150\153\321\122\151\063\231\141\230\103"
	"\372\317\374\354\313\313\023\355\101\352\074\062\041\164\302\265"
	"\374\366\141\175\234\312\350\156\034\121\241\266\262\072\371\255"
	"\012\365\231\325\301\255\303\002\230\377\064\272\164\367\157\160"
	"\355\321\356\212\234\326\370\271\050\232\160\333\324\151\210\337"
	"\137\042\264\040\317\167\043\147\167\130\041\354\117\221\135\074"
	"\143\113\306\377\041\277\270\111\131\050\045\056\222\255\015\362"
	"\317\301\023\236\071\067\006\261\220\047\236\337\271\373\034\035"
	"\106\343\034\150\242\325\261\374\376\327\052\221\204\067\204\123"
	"\371\227\362\063\317\371\344\137\041\202\077\332\176\133\367\304"
	"\077\024\054\342\352\336\336\351\265\010\172\071\077\376\215\070"
	"\226\200\153\146\172\120\305\233\323\004\166\121\140\155\026\237"
	"\202\102\201\154\041\137\125\326\150\320\020\247\317\236\340\146"
	"\037\114\314\231\235\221\064\161\225\252\303\365\030\331\225\232"
	"\034\026\007\075\166\135\023\336\056\044\206\375\302\147\143\253"
	"\041\340\035\356\056\275\337\003\133\223\077\134\050\060\215\067"
	"\163\200\366\171\311\016\006\137\227\362\327\056\133\107\331\175"
	"\047\366\153\126\264\113\131\017\337\231\154\007\312\372\077\076"
	"\172\065\270\103\103\276\242\333\261\172\011\014\302\342"
#define      chk1_z	22
#define      chk1	((&data[396]))
	"\365\100\215\100\231\374\321\345\317\373\320\264\346\337\124\336"
	"\333\305\265\050\214\150\367\142\121\227\255\235\037\063\012\047"
#define      chk2_z	19
#define      chk2	((&data[423]))
	"\120\140\146\073\026\241\065\043\275\242\141\345\051\115\247\244"
	"\333\110\112\074\177"
#define      msg2_z	19
#define      msg2	((&data[448]))
	"\337\262\146\273\236\015\221\232\072\300\311\203\265\152\336\373"
	"\056\204\343\170\350\007\375\143\340\305"
#define      lsto_z	1
#define      lsto	((&data[470]))
	"\023"
#define      msg1_z	42
#define      msg1	((&data[477]))
	"\356\314\017\057\146\255\025\164\236\303\223\324\350\007\070\101"
	"\362\136\215\221\024\012\235\202\265\277\306\261\256\340\306\100"
	"\231\202\265\355\010\322\325\025\045\343\070\151\342\023\204\161"
	"\117\231\267\166\227"
#define      opts_z	1
#define      opts	((&data[524]))
	"\165"
#define      shll_z	10
#define      shll	((&data[526]))
	"\377\241\303\206\351\132\012\164\115\145\174\131\172"
#define      tst1_z	22
#define      tst1	((&data[538]))
	"\270\250\355\316\245\054\010\372\136\310\242\072\053\131\110\223"
	"\031\236\341\226\154\045\105\331\116\350\201"
#define      inlo_z	3
#define      inlo	((&data[565]))
	"\005\073\170"
#define      text_z	274
#define      text	((&data[585]))
	"\145\247\300\264\101\170\052\330\065\007\254\161\200\164\160\331"
	"\357\250\125\154\330\027\040\211\205\074\163\031\126\100\333\237"
	"\002\053\123\031\311\052\362\353\037\205\132\074\353\071\233\314"
	"\202\346\103\004\211\276\377\271\176\076\162\361\201\266\340\226"
	"\151\300\211\171\110\176\000\305\042\225\022\222\357\162\015\203"
	"\053\245\174\121\131\041\167\044\246\033\012\177\101\046\072\004"
	"\051\312\265\015\121\234\300\045\375\141\162\014\216\104\100\355"
	"\141\331\021\327\153\370\030\072\153\062\240\121\155\235\002\320"
	"\150\042\003\017\127\337\247\370\126\177\201\200\175\163\377\236"
	"\275\262\130\051\334\063\356\024\076\245\056\073\025\004\170\171"
	"\227\002\230\011\024\343\231\312\234\107\227\011\123\157\273\147"
	"\055\344\354\232\224\165\334\015\211\344\113\173\334\242\067\332"
	"\131\036\046\370\172\077\322\053\147\146\260\147\152\110\311\311"
	"\004\333\165\074\212\037\005\365\017\203\245\230\325\355\346\016"
	"\020\307\272\350\057\216\010\051\072\341\231\374\152\003\065\207"
	"\106\220\231\053\210\127\172\233\121\165\233\300\125\350\327\306"
	"\352\056\202\240\051\044\222\120\345\335\150\174\273\346\061\370"
	"\016\325\042\276\125\064\146\274\071\072\167\145\332\165\222\357"
	"\134\234\314\326\356\315\034\307"
#define      date_z	1
#define      date	((&data[864]))
	"\213"/* End of data[] */;
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
