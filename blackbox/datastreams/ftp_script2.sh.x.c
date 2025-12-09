#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f ftp_script2.sh 
#endif

static  char data [] = 
#define      inlo_z	3
#define      inlo	((&data[0]))
	"\320\175\101"
#define      tst1_z	22
#define      tst1	((&data[5]))
	"\235\141\357\121\211\320\320\274\125\131\132\250\124\300\060\336"
	"\323\061\010\166\044\265\204\061\331\343\052"
#define      opts_z	1
#define      opts	((&data[30]))
	"\021"
#define      date_z	1
#define      date	((&data[31]))
	"\365"
#define      text_z	186
#define      text	((&data[45]))
	"\120\142\350\131\246\374\361\271\026\121\342\152\205\054\351\066"
	"\014\233\143\145\203\314\326\342\307\275\351\046\130\227\241\012"
	"\137\204\043\277\215\212\040\260\372\275\307\261\346\316\061\330"
	"\156\235\213\322\172\166\374\235\146\352\376\252\223\142\035\074"
	"\241\157\330\010\166\150\027\311\137\356\054\006\055\267\263\201"
	"\272\066\364\127\354\302\334\370\051\234\254\073\064\332\147\371"
	"\357\114\070\347\050\245\311\015\156\100\230\076\377\113\157\072"
	"\274\045\076\364\204\265\172\217\076\021\054\076\331\155\241\201"
	"\223\264\207\123\202\070\236\366\313\330\164\355\207\030\010\256"
	"\103\312\013\025\033\166\161\336\275\311\275\115\121\044\154\217"
	"\161\266\373\364\342\060\233\112\057\340\160\123\025\236\352\054"
	"\271\065\045\257\034\103\215\265\217\306\353\364\325\272\176\323"
	"\201\025\371\125\305\000\251\214\342\377\063\177\141\014\143\213"
	"\313\120\056\361\133\322\310\244"
#define      shll_z	10
#define      shll	((&data[248]))
	"\002\061\040\272\026\235\240\266\103\270"
#define      msg1_z	42
#define      msg1	((&data[262]))
	"\025\143\146\054\052\214\045\241\215\362\300\067\152\355\344\354"
	"\041\113\023\261\202\047\103\326\057\023\264\350\042\377\040\020"
	"\127\254\366\203\121\037\131\036\307\347\312\230\211\107\265\110"
	"\227\072\325\171\072"
#define      pswd_z	256
#define      pswd	((&data[374]))
	"\025\134\047\340\255\126\322\011\050\232\255\130\263\263\161\045"
	"\140\207\211\306\263\076\017\112\171\344\304\264\354\276\117\001"
	"\033\167\342\310\316\264\321\366\117\177\117\002\062\301\050\223"
	"\110\262\131\374\360\150\107\152\114\013\036\071\312\156\072\241"
	"\125\300\276\276\371\223\354\260\243\075\332\341\170\020\070\277"
	"\002\315\263\200\141\071\135\245\176\125\000\106\303\252\350\030"
	"\152\246\327\144\071\303\024\335\001\357\277\171\377\367\071\002"
	"\305\355\202\046\047\340\314\245\066\315\354\371\167\324\022\342"
	"\172\351\106\264\255\133\221\256\112\121\050\112\110\142\114\016"
	"\120\317\064\170\260\000\036\346\316\012\340\105\337\363\047\131"
	"\334\155\016\212\310\240\071\023\361\142\135\071\304\251\107\025"
	"\171\174\216\051\175\254\020\113\266\361\220\226\344\270\357\301"
	"\046\376\114\356\236\205\002\217\347\137\311\254\011\021\302\202"
	"\216\120\254\013\374\275\126\263\256\347\111\223\240\071\125\306"
	"\067\241\265\325\046\267\145\016\026\056\272\040\100\175\242\316"
	"\315\117\331\312\014\060\175\273\027\306\117\267\000\244\175\067"
	"\105\063\015\154\352\162\172\001\240\065\041\341\263\303\257\200"
	"\023\210\112\040\271\310\333\320\217\052\210\217\317\006\307\025"
	"\071\324\201\044\106\374\045\347\062\106\310\345\012\170\146\035"
	"\001\261\075\272\171\031\213\010\104\023\230\023\032\137\050\345"
	"\346\035\256\264\322\200\253\041\377\373\044\062\274\115\305\004"
	"\377\037\001\360\207\110\132\324\124\171\016\036\350\111\004\316"
	"\146\263\203\070\063\056"
#define      xecc_z	15
#define      xecc	((&data[669]))
	"\103\037\114\302\346\355\205\073\056\200\320\303\071\200\374"
#define      chk1_z	22
#define      chk1	((&data[686]))
	"\314\053\332\371\143\147\076\124\304\047\030\072\144\044\326\307"
	"\103\340\362\155\217\264\214\364\353\313\112\354\273"
#define      tst2_z	19
#define      tst2	((&data[714]))
	"\247\367\167\314\250\373\012\061\373\040\310\075\117\021\222\164"
	"\032\332\063\303"
#define      msg2_z	19
#define      msg2	((&data[735]))
	"\247\167\052\031\115\221\336\200\134\210\066\043\241\035\112\375"
	"\366\201\243\227\146\376\253\106"
#define      lsto_z	1
#define      lsto	((&data[757]))
	"\041"
#define      rlax_z	1
#define      rlax	((&data[758]))
	"\110"
#define      chk2_z	19
#define      chk2	((&data[762]))
	"\166\054\011\317\343\263\114\364\350\160\034\051\003\110\141\265"
	"\070\136\332\056\020\162"/* End of data[] */;
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
