#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f modbus_test.sh 
#endif

static  char data [] = 
#define      chk2_z	19
#define      chk2	((&data[4]))
	"\310\174\311\354\014\056\130\134\150\336\170\371\062\131\131\345"
	"\370\143\017\077\010\334\006"
#define      msg1_z	42
#define      msg1	((&data[32]))
	"\016\125\103\353\300\064\271\255\153\162\332\245\206\155\255\110"
	"\325\037\130\125\104\302\254\122\247\251\122\353\245\360\246\102"
	"\313\043\360\205\351\102\104\012\200\016\055\270\120\167\021\310"
	"\177\164\323\364\306\100\171\343"
#define      date_z	1
#define      date	((&data[79]))
	"\135"
#define      msg2_z	19
#define      msg2	((&data[83]))
	"\101\230\101\212\323\107\166\115\200\142\331\071\237\152\125\151"
	"\046\313\017\226\120\342\143\141"
#define      opts_z	1
#define      opts	((&data[104]))
	"\045"
#define      text_z	168
#define      text	((&data[147]))
	"\347\125\035\323\025\121\215\302\275\201\210\375\373\154\030\053"
	"\241\277\322\020\001\153\122\144\314\017\222\032\351\221\364\321"
	"\347\021\245\374\143\062\277\040\264\107\206\342\072\264\361\160"
	"\040\036\355\101\121\057\332\176\212\001\373\334\317\057\232\132"
	"\201\230\342\325\003\317\111\304\217\336\164\220\116\053\160\310"
	"\310\214\075\330\030\362\231\353\240\254\334\236\033\013\361\100"
	"\163\211\134\345\217\161\072\361\324\247\160\002\331\265\212\340"
	"\365\240\117\345\367\112\004\102\221\253\347\372\251\341\225\332"
	"\027\061\263\033\136\112\170\103\104\143\340\170\045\321\005\225"
	"\367\017\071\173\143\351\007\172\363\325\365\357\023\102\233\245"
	"\303\275\112\034\156\002\271\311\165\063\372\134\115\066\351\221"
	"\066\041\275\274\364\377\075\333\006\263\033\133\353\326\372\072"
	"\312\063\123\330\162\124\321\027\363\237\347\254\113\305\327\065"
	"\215\131\036\257\263\066\332\125\366\254\146\367\027\270\134\344"
	"\310\356\377\261\200\363\203\147\005\050\144\150\133\043\211\017"
	"\153\247\276\036\336\230"
#define      lsto_z	1
#define      lsto	((&data[351]))
	"\230"
#define      tst2_z	19
#define      tst2	((&data[355]))
	"\222\051\101\252\203\044\021\001\246\353\252\127\225\055\357\242"
	"\003\154\335\262\032\060\132"
#define      shll_z	10
#define      shll	((&data[375]))
	"\333\315\004\207\270\042\156\140\075\234"
#define      chk1_z	22
#define      chk1	((&data[386]))
	"\377\007\271\300\130\211\112\024\123\245\146\135\072\160\254\301"
	"\315\213\264\060\054\021\062\072\270\143"
#define      rlax_z	1
#define      rlax	((&data[411]))
	"\026"
#define      inlo_z	3
#define      inlo	((&data[412]))
	"\356\257\174"
#define      pswd_z	256
#define      pswd	((&data[472]))
	"\262\171\204\207\276\137\124\033\361\175\135\114\225\236\131\055"
	"\323\351\054\016\241\220\261\265\026\336\330\010\262\271\031\144"
	"\062\236\354\361\375\100\015\356\275\152\073\122\011\224\177\335"
	"\176\254\353\037\074\234\325\123\172\126\365\174\303\135\125\317"
	"\215\151\357\337\203\104\266\165\353\045\270\145\257\234\031\234"
	"\262\265\100\304\341\135\017\170\263\004\365\166\142\112\106\360"
	"\263\065\317\066\172\205\254\146\253\144\313\132\001\345\366\263"
	"\232\067\170\174\224\210\365\107\215\352\276\357\064\004\337\350"
	"\072\257\037\264\065\313\032\340\060\346\073\061\313\061\345\146"
	"\151\136\342\375\346\330\105\164\302\004\143\366\010\103\337\103"
	"\363\376\370\050\312\023\010\372\371\103\054\305\165\021\054\337"
	"\160\016\334\126\346\042\313\251\046\056\240\057\162\177\163\145"
	"\175\153\216\107\176\227\102\170\333\156\076\121\200\152\060\360"
	"\171\015\107\140\057\022\011\126\101\251\205\264\050\371\032\245"
	"\144\250\355\343\077\057\133\032\236\231\153\036\004\233\017\175"
	"\251\126\335\330\150\346\057\252\217\265\136\270\256\170\136\022"
	"\040\113\366\140\173\121\173\031\353\346\067\357\202\106\155\053"
	"\235\112\004\006\061\063\260\301\351\016\171\227\207\327\252\250"
	"\043\240\010\236\361\203\270\335\152\360\315\355\067\072\030\324"
	"\205\035\333\266\121\213\167\072\232\255\133\055\146"
#define      tst1_z	22
#define      tst1	((&data[735]))
	"\022\176\213\000\356\252\331\363\263\162\054\153\153\363\201\271"
	"\200\207\322\373\104\012\220\307\045\020\276\230"
#define      xecc_z	15
#define      xecc	((&data[761]))
	"\072\207\240\066\114\245\222\373\015\156\254\232\006\267\076\126"/* End of data[] */;
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
