#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f server_slave_dnp3.sh 
#endif

static  char data [] = 
#define      tst1_z	22
#define      tst1	((&data[3]))
	"\076\304\220\037\205\221\005\226\152\112\144\310\000\222\133\220"
	"\231\350\230\225\112\112\360\075\304\153\114\370\246\237"
#define      inlo_z	3
#define      inlo	((&data[30]))
	"\121\203\313"
#define      chk1_z	22
#define      chk1	((&data[34]))
	"\140\260\175\155\112\205\100\137\246\367\172\231\043\316\045\107"
	"\131\176\163\275\111\140\121\276\043\164\307\042"
#define      lsto_z	1
#define      lsto	((&data[61]))
	"\352"
#define      tst2_z	19
#define      tst2	((&data[62]))
	"\123\015\134\360\071\030\171\143\264\113\366\162\026\077\033\100"
	"\170\333\025\260\213\125\106"
#define      msg2_z	19
#define      msg2	((&data[87]))
	"\377\376\315\353\136\064\232\072\170\067\051\257\056\160\152\143"
	"\043\236\336\311\064"
#define      xecc_z	15
#define      xecc	((&data[109]))
	"\367\076\233\152\231\240\233\204\003\006\014\352\072\052\206\222"
	"\244\306\143\312"
#define      opts_z	1
#define      opts	((&data[126]))
	"\366"
#define      rlax_z	1
#define      rlax	((&data[127]))
	"\147"
#define      text_z	118
#define      text	((&data[147]))
	"\321\056\357\360\012\240\174\140\347\354\363\362\353\362\112\343"
	"\227\101\041\213\300\104\006\076\145\323\366\267\107\360\206\213"
	"\160\344\151\246\055\334\057\016\236\033\314\364\011\232\142\004"
	"\071\300\074\122\234\206\276\265\151\120\172\124\076\132\370\225"
	"\262\232\151\352\126\273\371\164\307\006\247\165\006\057\204\016"
	"\156\251\001\024\215\212\161\175\065\056\300\030\343\321\134\014"
	"\262\341\236\274\267\302\133\162\115\027\332\272\126\036\050\260"
	"\210\155\017\377\345\354\253\157\121\366\253\252\344\335\106\333"
	"\051\277\336\347\155\042\376\100\070\063"
#define      chk2_z	19
#define      chk2	((&data[270]))
	"\006\026\201\213\176\376\275\155\243\054\225\151\347\235\262\247"
	"\103\265\041\047\305\176\215\265\317\062\301"
#define      pswd_z	256
#define      pswd	((&data[317]))
	"\221\153\121\016\313\070\372\277\053\346\261\165\312\111\267\354"
	"\174\134\330\167\142\357\370\356\156\321\216\137\236\122\056\147"
	"\134\365\237\072\306\102\200\147\243\234\276\021\022\260\230\217"
	"\264\262\320\253\004\374\230\163\315\046\322\154\170\001\323\325"
	"\366\163\017\274\265\220\044\131\054\342\152\077\223\002\316\110"
	"\265\237\363\271\233\214\055\151\262\377\325\053\000\250\001\367"
	"\034\021\264\321\241\330\052\316\273\225\016\116\230\335\226\116"
	"\175\212\010\030\026\065\201\311\065\126\365\065\377\366\055\034"
	"\007\341\355\251\271\030\170\165\256\207\304\107\144\133\225\341"
	"\345\235\372\374\323\173\305\010\322\272\076\322\261\153\356\270"
	"\114\334\142\006\365\333\173\243\142\077\352\307\232\200\251\200"
	"\035\243\174\360\037\102\371\362\375\067\305\256\242\263\147\356"
	"\220\312\364\205\245\160\051\007\260\024\316\113\224\167\314\262"
	"\033\110\243\072\213\234\054\210\323\361\067\165\245\236\144\066"
	"\150\131\273\015\312\344\025\172\371\344\305\215\134\221\100\167"
	"\332\343\262\146\200\337\356\123\321\045\311\166\304\056\254\055"
	"\210\150\073\122\115\120\314\106\065\222\324\221\044\024\011\377"
	"\367\274\145\170\233\123\314\154\245\307\040\146\150\201\027\372"
	"\355\151\010\270\241\003\170\314\351\052\102\264\163\371\240\357"
	"\126\170\147\271\150\137\247\015\047\307\164\220\110\214\212\066"
	"\365\223\357\227"
#define      msg1_z	42
#define      msg1	((&data[621]))
	"\200\221\246\064\011\076\327\113\324\202\231\227\143\340\176\355"
	"\001\327\033\317\336\206\340\036\003\200\171\141\321\161\047\140"
	"\205\201\373\103\373\242\174\267\257\116\312\104\376\173\004\240"
	"\324\364"
#define      date_z	1
#define      date	((&data[667]))
	"\054"
#define      shll_z	10
#define      shll	((&data[670]))
	"\127\303\066\056\067\266\233\046\112\224\315\072\343\036"/* End of data[] */;
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
