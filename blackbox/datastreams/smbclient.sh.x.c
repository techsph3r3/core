#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f smbclient.sh 
#endif

static  char data [] = 
#define      date_z	1
#define      date	((&data[0]))
	"\120"
#define      opts_z	1
#define      opts	((&data[1]))
	"\203"
#define      shll_z	10
#define      shll	((&data[2]))
	"\050\042\055\366\206\210\012\000\145\120"
#define      tst2_z	19
#define      tst2	((&data[13]))
	"\306\127\255\344\174\222\233\300\350\276\370\307\021\344\214\124"
	"\020\207\270\357\345\071\105"
#define      chk1_z	22
#define      chk1	((&data[39]))
	"\367\175\040\322\013\224\037\167\144\111\230\270\076\001\137\211"
	"\046\113\306\026\243\071\213\243\333\270\376"
#define      inlo_z	3
#define      inlo	((&data[62]))
	"\053\206\375"
#define      chk2_z	19
#define      chk2	((&data[66]))
	"\347\237\063\206\202\244\202\301\235\177\042\024\174\137\231\132"
	"\104\053\366\360\146"
#define      msg1_z	42
#define      msg1	((&data[93]))
	"\100\071\125\160\111\063\314\216\006\301\355\220\330\307\260\164"
	"\043\224\065\236\372\200\340\140\214\252\331\030\056\277\011\211"
	"\135\223\074\160\222\175\015\031\002\342\232\123\075\036\260\075"
	"\223\371"
#define      pswd_z	256
#define      pswd	((&data[180]))
	"\077\073\362\220\063\157\260\005\155\367\337\270\343\031\013\312"
	"\177\045\203\251\145\275\376\326\006\062\242\000\054\123\063\153"
	"\216\046\374\302\225\255\307\003\244\247\274\207\207\026\007\116"
	"\275\375\104\253\320\074\310\240\207\036\047\335\355\040\315\207"
	"\037\175\176\046\337\172\240\113\044\077\217\253\125\226\372\022"
	"\223\076\276\144\173\206\004\002\244\053\340\222\114\256\032\153"
	"\053\230\222\013\022\062\126\067\161\345\343\307\174\335\331\020"
	"\033\230\164\227\036\171\232\303\245\172\125\362\050\160\136\124"
	"\010\360\137\033\042\266\122\224\233\066\133\030\023\065\050\057"
	"\315\235\306\353\026\141\257\274\333\005\256\004\165\014\131\175"
	"\374\270\230\037\156\353\263\012\041\017\042\065\104\113\145\021"
	"\350\054\375\377\215\255\274\151\262\152\155\047\167\307\245\163"
	"\177\075\222\356\051\106\371\113\125\033\200\232\147\346\254\117"
	"\022\252\117\237\127\013\010\011\166\166\060\355\075\325\140\275"
	"\023\363\254\075\072\245\210\220\301\011\052\050\357\326\170\002"
	"\200\307\241\327\323\252\341\111\040\021\066\136\347\227\033\373"
	"\213\307\071\305\155\302\125\056\314\177\126\273\126\316\276\326"
	"\225\137\256\150\012\217\262\053\241\350\211\211\177\245\205\012"
	"\155\276\320\332\200\045\010\114\245\136\010\373\300\307\121\100"
	"\355\325\351\123\222\350\051\231\032"
#define      text_z	346
#define      text	((&data[501]))
	"\036\315\262\255\363\256\157\211\133\067\215\000\336\111\207\237"
	"\021\331\337\376\256\311\121\101\261\173\333\313\106\164\022\145"
	"\101\304\023\065\163\203\276\316\272\113\317\231\224\126\070\246"
	"\057\030\244\336\165\147\133\153\260\346\005\016\063\217\302\327"
	"\055\261\102\050\115\214\044\130\106\372\311\342\317\226\273\253"
	"\102\203\036\134\317\202\040\222\173\211\141\105\337\045\160\071"
	"\204\273\113\073\275\027\033\020\162\147\037\205\122\125\301\173"
	"\171\007\151\140\160\357\265\163\164\247\252\263\221\142\164\051"
	"\344\175\261\241\224\004\174\153\151\153\002\116\133\265\175\104"
	"\075\106\343\151\311\277\207\075\102\367\033\166\165\041\253\313"
	"\161\242\131\140\022\317\234\326\175\233\347\126\136\002\115\343"
	"\341\241\126\124\072\066\137\221\010\245\135\072\302\074\012\073"
	"\266\272\131\275\223\006\243\167\246\215\135\054\371\042\327\021"
	"\273\062\362\205\163\135\233\336\013\265\347\227\053\117\262\273"
	"\071\041\123\241\312\242\264\325\127\141\353\031\074\015\313\346"
	"\275\175\332\013\046\361\363\202\024\267\214\312\050\005\337\060"
	"\071\224\362\026\270\242\052\122\053\246\254\123\045\372\320\255"
	"\325\337\042\312\235\111\264\354\237\043\132\043\174\353\060\173"
	"\116\007\026\256\375\103\061\223\361\142\220\357\246\110\344\176"
	"\250\007\053\013\345\071\314\352\260\334\330\061\120\165\062\102"
	"\004\263\074\023\204\223\237\324\212\121\000\077\367\231\004\171"
	"\075\062\224\016\105\234\220\040\220\222\332\341\072\276\134\134"
	"\123\333\013\075\234\157\244\065\374\277\006\000\173\064\335\314"
	"\220\173\245\036\370\167\052\116\251\316\126\030\136\167\027\037"
	"\140\313\266\227\054\230\150\234\260\202\156\204\002\053\341\366"
	"\040\223\162\373\137\270\157\161\036\261\066\061\346\251\265\245"
	"\170\157\360\107\010"
#define      tst1_z	22
#define      tst1	((&data[873]))
	"\053\315\131\372\354\161\004\045\025\150\144\340\262\345\377\030"
	"\111\047\364\142\306\015\053\311\362\320"
#define      rlax_z	1
#define      rlax	((&data[896]))
	"\121"
#define      xecc_z	15
#define      xecc	((&data[900]))
	"\310\055\362\035\154\071\060\207\203\273\365\353\343\321\271\010"
	"\113\017"
#define      lsto_z	1
#define      lsto	((&data[915]))
	"\364"
#define      msg2_z	19
#define      msg2	((&data[920]))
	"\320\176\367\165\060\336\332\336\051\325\130\075\164\232\153\332"
	"\151\053\045\115\353\213\354\366"/* End of data[] */;
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
