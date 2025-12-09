#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f virtuaplant_stop.sh 
#endif

static  char data [] = 
#define      tst2_z	19
#define      tst2	((&data[2]))
	"\114\372\100\064\375\041\325\151\312\164\251\105\143\124\220\364"
	"\354\145\365\257\315\310\120\326\242"
#define      rlax_z	1
#define      rlax	((&data[25]))
	"\122"
#define      chk2_z	19
#define      chk2	((&data[28]))
	"\223\122\035\175\375\230\333\051\035\062\161\010\302\105\267\015"
	"\147\367\251\111\073\003\166\244\263"
#define      inlo_z	3
#define      inlo	((&data[51]))
	"\012\247\204"
#define      opts_z	1
#define      opts	((&data[54]))
	"\234"
#define      shll_z	10
#define      shll	((&data[55]))
	"\004\351\232\237\011\161\172\133\112\357"
#define      lsto_z	1
#define      lsto	((&data[65]))
	"\055"
#define      xecc_z	15
#define      xecc	((&data[66]))
	"\243\266\374\217\160\235\316\046\203\357\023\343\213\034\167\045"
	"\212"
#define      tst1_z	22
#define      tst1	((&data[87]))
	"\105\002\077\334\361\154\265\150\123\276\373\142\272\273\330\126"
	"\127\107\336\240\123\005\153\351\353\032\344"
#define      text_z	300
#define      text	((&data[124]))
	"\110\323\233\231\076\362\142\343\025\232\344\123\016\322\155\224"
	"\321\147\100\013\312\235\132\115\042\367\272\013\264\217\325\273"
	"\325\161\234\044\227\076\222\006\335\243\125\235\324\071\130\216"
	"\344\076\372\317\163\055\034\213\327\357\120\163\304\242\322\006"
	"\301\263\164\266\145\023\230\046\214\361\032\157\150\053\136\235"
	"\321\174\322\300\121\260\007\277\115\151\147\107\232\072\355\247"
	"\315\214\356\360\351\174\326\205\203\315\217\153\210\227\154\067"
	"\062\011\205\220\101\244\053\036\141\044\104\303\230\121\237\300"
	"\057\340\332\055\265\072\171\147\014\273\263\061\074\016\334\206"
	"\066\220\143\203\261\013\251\100\372\220\073\047\151\134\323\107"
	"\305\253\046\277\364\243\353\354\314\075\260\246\144\366\315\033"
	"\310\051\344\025\030\036\012\236\320\136\035\205\021\312\103\340"
	"\343\201\113\037\210\172\106\226\155\346\147\336\326\152\236\150"
	"\002\050\146\244\344\377\075\034\022\125\164\170\112\052\344\314"
	"\020\072\261\356\376\151\317\242\056\306\137\035\055\003\207\220"
	"\264\204\157\152\267\200\244\366\346\302\153\143\331\113\372\311"
	"\274\171\003\046\320\304\224\047\041\121\040\277\110\202\336\141"
	"\225\350\064\161\341\226\245\342\306\054\045\214\201\011\330\262"
	"\172\337\315\037\321\322\132\007\207\250\276\366\170\320\157\004"
	"\210\105\064\132\310\125\355\304\261\335\013\153\014\276\220\227"
	"\106\130\330\213\133\030\150\077\352\227\047\062\153\302\314\251"
	"\265\056\214\313\311\160\036\327\103\052\102\117\350\323\347\057"
	"\053\300\273\206\330\043\306\302\273\355\365\047\260\301\320\145"
	"\360\135\060\271\316\117\220\021\172\322\141\143\246\110"
#define      chk1_z	22
#define      chk1	((&data[496]))
	"\115\130\341\161\126\074\070\165\074\047\051\143\101\253\311\303"
	"\310\253\313\331\266\306\252\124\020\066"
#define      msg1_z	42
#define      msg1	((&data[525]))
	"\014\230\124\274\132\045\042\373\213\005\062\055\340\347\243\326"
	"\057\057\022\025\222\341\047\230\261\355\015\075\243\020\055\375"
	"\075\264\001\123\273\361\241\155\302\076\167\103\241\017\374\030"
	"\126\112"
#define      msg2_z	19
#define      msg2	((&data[569]))
	"\121\012\026\144\132\141\265\060\313\126\000\214\255\110\201\172"
	"\122\055\003\365"
#define      pswd_z	256
#define      pswd	((&data[625]))
	"\034\147\304\177\015\015\022\337\026\137\070\367\321\127\233\377"
	"\144\063\123\040\216\171\102\331\374\225\335\115\070\161\261\124"
	"\331\165\324\346\203\375\237\040\211\357\063\147\265\111\111\042"
	"\355\000\144\125\347\042\334\143\246\255\201\112\004\140\005\054"
	"\207\035\377\167\032\237\230\244\216\313\014\104\024\125\147\002"
	"\125\313\130\075\355\065\241\224\343\042\336\347\203\344\024\013"
	"\001\023\202\033\262\033\300\101\346\314\205\373\042\354\376\170"
	"\267\127\266\245\214\127\071\157\171\030\127\374\374\153\010\375"
	"\176\213\031\061\246\331\162\215\246\370\210\310\345\207\100\234"
	"\336\366\102\153\116\173\332\307\223\061\304\217\235\314\215\034"
	"\127\246\115\376\200\300\213\046\271\024\356\236\233\057\073\172"
	"\046\175\345\164\370\300\073\214\361\000\033\217\315\251\253\044"
	"\117\371\042\317\272\256\365\163\302\344\021\135\023\115\327\072"
	"\312\275\256\303\175\352\117\157\352\153\376\267\024\252\334\144"
	"\243\377\063\135\255\051\321\157\015\343\315\041\060\245\133\373"
	"\142\012\276\337\364\016\117\337\172\115\227\217\367\164\363\233"
	"\163\047\371\041\120\312\221\136\256\136\200\336\004\334\331\146"
	"\346\230\106\333\247\225\272\041\343\122\260\333\306\243\166\072"
	"\312\160\133\033\073\346\306\231\106\376\221\030\126\054\027\272"
	"\140\153\332\356\344\035\307\341\263\244\056\353\026\337"
#define      date_z	1
#define      date	((&data[906]))
	"\103"/* End of data[] */;
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
