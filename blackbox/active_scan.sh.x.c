#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f active_scan.sh 
#endif

static  char data [] = 
#define      msg2_z	19
#define      msg2	((&data[0]))
	"\077\040\260\166\313\233\355\247\171\140\313\124\364\270\225\250"
	"\164\114\174\010\346"
#define      tst2_z	19
#define      tst2	((&data[22]))
	"\017\240\240\260\244\306\042\110\132\210\236\370\322\152\007\227"
	"\003\375\153\072\346\127"
#define      rlax_z	1
#define      rlax	((&data[43]))
	"\272"
#define      pswd_z	256
#define      pswd	((&data[78]))
	"\363\351\115\266\061\145\345\041\243\054\174\162\015\313\026\056"
	"\137\037\024\114\141\251\134\110\000\373\260\052\007\070\162\372"
	"\041\277\233\044\336\174\372\346\102\114\162\005\245\227\222\127"
	"\016\141\307\123\244\310\113\075\324\064\057\304\242\323\045\015"
	"\364\300\061\323\075\054\272\177\170\054\205\036\303\030\166\322"
	"\171\075\046\035\005\161\132\332\246\212\236\110\135\304\126\121"
	"\204\210\045\302\264\337\101\055\013\306\113\317\336\302\241\130"
	"\377\310\165\005\072\320\337\340\133\176\051\270\102\200\012\307"
	"\010\057\211\275\016\313\352\032\221\066\351\160\370\213\310\370"
	"\124\076\375\216\017\335\157\152\133\230\042\236\030\054\145\041"
	"\134\357\336\153\272\311\205\114\000\157\274\371\373\205\362\117"
	"\304\360\335\323\315\114\076\051\345\141\307\376\215\055\037\352"
	"\034\376\125\326\310\332\042\310\112\337\302\105\145\264\225\051"
	"\244\163\375\161\277\073\233\245\234\142\243\052\217\302\024\254"
	"\301\151\202\211\104\245\121\217\204\024\325\351\310\152\023\154"
	"\335\020\336\235\113\171\102\347\334\346\022\153\250\046\027\152"
	"\220\232\363\325\100\105\144\304\131\071\256\042\244\302\216\201"
	"\322\155\037\035\347\141\005\303\107\027\056\360\076\106\132\316"
	"\341\116\261\122\044\226\164\307\302\361\071\320\274\120\376\033"
	"\157\023\150\321"
#define      opts_z	1
#define      opts	((&data[352]))
	"\062"
#define      text_z	739
#define      text	((&data[492]))
	"\350\310\002\132\302\044\032\164\167\076\012\354\006\315\335\100"
	"\235\231\220\234\265\000\257\036\321\154\343\353\052\243\265\023"
	"\153\270\156\056\335\210\242\124\306\255\101\315\173\036\015\030"
	"\270\235\265\156\236\144\214\157\321\157\132\374\023\020\017\177"
	"\311\176\255\246\006\120\373\315\376\074\232\171\133\250\222\023"
	"\106\107\201\344\253\016\123\175\175\256\171\221\276\211\020\207"
	"\007\276\056\016\016\051\333\015\146\166\206\301\036\030\324\144"
	"\140\126\111\013\144\234\211\342\113\002\164\011\213\204\221\222"
	"\102\277\240\121\351\174\136\117\363\345\021\206\216\160\203\012"
	"\262\327\206\274\003\351\037\047\320\011\145\106\305\357\230\236"
	"\044\221\167\353\262\163\165\311\360\341\150\241\250\312\347\047"
	"\042\002\335\227\171\234\313\115\300\014\322\206\034\014\312\141"
	"\174\113\306\354\135\242\025\142\367\176\114\137\316\360\246\313"
	"\306\346\345\167\047\251\216\225\056\034\004\256\300\150\371\264"
	"\357\215\217\130\004\345\114\212\220\264\141\256\007\301\006\374"
	"\075\210\122\115\032\354\051\362\103\347\077\001\351\372\101\020"
	"\317\241\223\243\233\350\372\100\016\072\312\164\336\300\323\014"
	"\032\042\207\366\234\007\264\312\322\053\077\151\055\370\341\355"
	"\345\366\057\311\367\025\211\222\246\304\206\122\162\007\123\076"
	"\236\135\252\165\276\107\246\253\260\105\073\301\240\075\314\371"
	"\333\245\361\310\342\031\227\372\273\305\377\240\136\221\316\323"
	"\063\211\304\364\343\240\324\063\274\227\372\352\011\175\104\217"
	"\005\131\356\037\305\025\340\214\136\322\030\077\016\017\146\256"
	"\135\041\035\173\213\073\353\343\251\123\031\121\236\141\017\066"
	"\372\236\051\254\314\251\102\221\370\371\326\372\321\345\356\001"
	"\242\106\157\070\131\044\377\225\220\021\167\265\312\016\174\034"
	"\271\200\306\172\326\310\054\164\222\211\073\056\007\207\166\221"
	"\226\170\117\314\333\000\012\071\217\215\216\144\204\077\152\306"
	"\377\055\010\220\253\375\274\213\302\116\100\154\030\344\123\114"
	"\322\136\152\135\331\173\120\233\151\263\023\067\124\232\055\204"
	"\034\207\202\170\323\001\056\340\246\177\340\116\164\155\273\126"
	"\121\127\342\032\047\010\133\076\017\274\000\020\351\000\213\116"
	"\016\115\302\336\175\106\165\376\267\052\232\120\010\032\343\101"
	"\157\171\302\236\247\062\067\333\226\214\233\255\062\056\003\351"
	"\143\231\146\053\177\005\115\036\277\273\173\050\201\324\121\014"
	"\301\065\255\012\346\063\167\265\264\063\053\054\120\054\017\036"
	"\245\122\027\154\326\140\136\277\143\050\303\214\306\010\205\376"
	"\065\234\050\233\212\047\146\003\172\364\223\257\316\332\353\127"
	"\003\304\033\212\250\176\065\260\271\376\305\067\004\354\136\347"
	"\355\077\017\170\360\152\245\165\114\146\232\026\020\100\123\062"
	"\334\146\046\234\015\331\305\346\074\212\126\262\152\031\032\102"
	"\110\331\165\030\067\356\161\166\072\265\333\045\062\166\335\367"
	"\071\143\175\366\040\371\120\263\170\125\213\115\210\140\033\075"
	"\256\366\314\134\143\266\120\101\014\024\263\316\060\135\250\340"
	"\017\357\164\305\025\267\066\176\015\235\253\256\305\320\313\312"
	"\336\147\240\370\040\041\375\236\046\164\330\026\271\201\343\033"
	"\111\021\255\346\160\140\331\133\232\047\376\075\063\355\156\363"
	"\254\304\061\277\120\342\073\271\254\234\150\135\165\255\053\261"
	"\375\170\343\265\310\060\071\131\330\143\200\220\112\263\005\162"
	"\230\205\201\370\141\307\344\332\131\235\037\025\271\311\075\123"
	"\243\160\274\335\325\020\013\226\353\354\217\033\337\055\032\204"
	"\313\010\234\372\117\241\027\346\330\143\047\222\161\144\305\130"
	"\336\072\116\377\245\264\034\336\174\145\175\070\023\000\236\205"
	"\250\060\253\026\206\264\063\075\023\372\115\233\201\044\126\043"
	"\103\026\132\016\341\245\352\165\234\027\162\023\203\321\022\376"
	"\346\167\136\074\300\152\241\135\363\204\250\365\370\262\200\174"
	"\103\023\277\003\264\021\355\061\160\075\044\125\116\066\123\064"
	"\255\261\161\156\033\023\313\016\227\163\004\217\045\205\014\151"
	"\230\314\155\115\335\132\176\116\230\242\243\346\331\367\033\207"
	"\250\214\365\304\237\300\323\067\063\327\307\131\135\323\302\365"
	"\240\060\103\176\213\301\314\043\144\160\012\075\147\045\305\020"
	"\262\272\324\122\173\250\211\257\200\120\010\335\044\313\323\305"
	"\373\026\103\206\330\017\252\074\177\264\171\347\331\077\367\214"
	"\371\314\336\164\165\150\044\365\271\054\323\335\370\247\242\364"
#define      chk2_z	19
#define      chk2	((&data[1381]))
	"\225\366\045\321\236\256\012\107\231\054\210\132\236\335\101\265"
	"\255\170\236\337\260\213\016\165\332"
#define      inlo_z	3
#define      inlo	((&data[1402]))
	"\331\367\023"
#define      chk1_z	22
#define      chk1	((&data[1406]))
	"\204\200\364\251\245\336\322\175\250\212\102\155\013\045\063\235"
	"\042\134\156\163\224\201\220\040"
#define      msg1_z	42
#define      msg1	((&data[1439]))
	"\207\035\213\100\112\137\036\103\006\300\076\053\155\166\177\110"
	"\306\116\204\032\135\142\170\036\101\351\344\234\025\237\376\337"
	"\227\074\050\111\342\162\125\355\244\305\030\156\053\271\317\125"
	"\176\006\032\302\067\303\247\263\131\235"
#define      date_z	1
#define      date	((&data[1487]))
	"\247"
#define      shll_z	10
#define      shll	((&data[1489]))
	"\147\130\136\101\013\252\213\236\267\043\060\002"
#define      xecc_z	15
#define      xecc	((&data[1502]))
	"\345\306\253\375\137\210\207\314\315\242\115\261\220\205\137\331"
	"\045\200\173"
#define      lsto_z	1
#define      lsto	((&data[1519]))
	"\345"
#define      tst1_z	22
#define      tst1	((&data[1525]))
	"\254\054\154\155\144\306\331\143\317\162\170\135\045\064\061\236"
	"\117\242\006\123\303\377\364\137\155\057\031\060\024"/* End of data[] */;
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
