#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f ftp_script.sh 
#endif

static  char data [] = 
#define      rlax_z	1
#define      rlax	((&data[0]))
	"\030"
#define      chk2_z	19
#define      chk2	((&data[5]))
	"\230\210\300\334\234\366\150\232\116\015\007\206\050\111\316\005"
	"\162\326\034\346\117\146\365\310\153"
#define      date_z	1
#define      date	((&data[26]))
	"\070"
#define      lsto_z	1
#define      lsto	((&data[27]))
	"\017"
#define      xecc_z	15
#define      xecc	((&data[30]))
	"\026\362\167\107\004\376\315\130\355\025\334\161\062\365\317\361"
	"\244\145"
#define      inlo_z	3
#define      inlo	((&data[46]))
	"\372\100\135"
#define      opts_z	1
#define      opts	((&data[49]))
	"\001"
#define      pswd_z	256
#define      pswd	((&data[75]))
	"\234\132\364\026\362\174\326\317\105\102\366\166\325\141\330\242"
	"\300\131\377\327\114\145\040\216\007\202\010\112\213\301\311\376"
	"\132\306\151\143\310\147\100\361\236\173\372\264\043\227\162\106"
	"\160\031\261\175\361\055\373\151\257\003\264\073\305\176\071\037"
	"\104\243\202\015\012\303\376\250\076\370\135\141\220\320\250\001"
	"\351\132\176\333\207\171\105\067\174\372\162\101\170\254\141\275"
	"\117\343\313\132\247\311\003\345\302\140\107\123\061\357\124\033"
	"\112\322\366\321\114\074\010\310\066\173\012\257\047\153\154\166"
	"\117\070\320\366\002\323\333\304\064\042\030\146\022\154\201\134"
	"\077\167\056\213\263\067\124\352\262\137\231\331\312\006\120\031"
	"\076\041\020\100\364\353\005\051\016\035\217\040\211\020\175\311"
	"\210\253\125\074\342\252\046\225\011\277\156\323\305\276\355\003"
	"\340\375\104\324\351\111\376\370\146\216\030\360\236\226\272\047"
	"\101\017\143\044\271\212\271\302\112\050\226\017\347\204\023\307"
	"\202\127\234\153\241\232\143\007\050\174\370\307\022\262\356\124"
	"\301\122\171\173\334\062\076\046\133\324\066\102\131\112\011\333"
	"\242\245\107\103\100\252\113\150\047\103\060\072\365\037\217\266"
	"\161\010\062\116\073\160\165\226\105\332\105\077\330"
#define      msg2_z	19
#define      msg2	((&data[336]))
	"\003\162\162\317\222\347\354\374\136\113\127\171\334\243\336\065"
	"\216\150\202\121\105\213"
#define      msg1_z	42
#define      msg1	((&data[365]))
	"\305\006\243\274\175\170\035\126\241\026\222\143\171\032\164\304"
	"\353\017\303\270\155\237\167\255\052\064\042\116\355\026\213\106"
	"\204\161\007\216\251\054\306\114\214\327\327\263\253\053\060\302"
	"\305\202\033\336\260\033"
#define      text_z	174
#define      text	((&data[454]))
	"\326\213\210\260\321\310\210\172\031\375\176\136\210\164\037\352"
	"\072\046\216\366\244\006\023\372\042\361\252\076\247\247\277\175"
	"\063\107\055\005\017\266\200\051\264\376\207\130\277\276\156\211"
	"\027\001\050\310\372\177\036\074\005\277\336\122\340\075\007\274"
	"\035\030\357\176\137\056\337\200\336\362\162\234\157\103\300\131"
	"\101\011\265\236\140\152\121\254\277\343\016\062\247\327\140\347"
	"\220\123\152\347\006\224\063\023\076\035\240\071\276\134\377\055"
	"\161\355\075\221\274\101\142\146\105\272\072\223\024\215\021\151"
	"\022\204\014\162\012\330\163\044\325\062\220\312\050\351\137\004"
	"\330\101\312\071\013\357\104\322\326\017\352\341\112\250\135\347"
	"\256\107\176\004\326\211\346\026\165\200\141\301\155\040\310\210"
	"\304\032\047\015\207\143\135\305\143\363\201\222\023\302\041\374"
	"\310\132\314\131\166\017\002\077\362\311\142\155\314\140\260\024"
	"\157\201\331\051\301\165\023\221\041\075\162\247\047\254\315\266"
	"\243\161\274\266\154\337\250\026\035\117\276\334\314\362\044"
#define      shll_z	10
#define      shll	((&data[652]))
	"\261\167\140\330\323\375\305\000\312\244\034\246"
#define      tst1_z	22
#define      tst1	((&data[664]))
	"\344\243\154\007\073\001\314\226\070\150\014\367\344\242\336\064"
	"\305\270\335\027\144\151\327\152\350\213"
#define      tst2_z	19
#define      tst2	((&data[690]))
	"\201\070\027\322\255\142\013\051\307\300\330\302\260\022\251\303"
	"\045\045\025\352\372\313"
#define      chk1_z	22
#define      chk1	((&data[715]))
	"\035\227\116\072\346\303\320\363\350\263\353\323\353\115\250\377"
	"\066\016\032\162\030\227\171\241\272\336\113\015"/* End of data[] */;
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
