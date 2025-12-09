#if 0
	shc Version 3.8.9b, Generic Script Compiler
	Copyright (c) 1994-2015 Francisco Rosales <frosal@fi.upm.es>

	shc -v -f firewall.sh 
#endif

static  char data [] = 
#define      msg2_z	19
#define      msg2	((&data[0]))
	"\255\116\215\230\334\113\121\043\017\206\163\300\027\212\306\202"
	"\242\253\253\211\063"
#define      chk2_z	19
#define      chk2	((&data[21]))
	"\301\236\020\153\347\320\346\066\222\346\307\171\210\303\011\114"
	"\235\171\311\130\310\004"
#define      tst2_z	19
#define      tst2	((&data[45]))
	"\145\253\034\213\206\237\016\342\370\202\300\172\226\001\137\241"
	"\005\267\234\265\040\244\134"
#define      tst1_z	22
#define      tst1	((&data[69]))
	"\225\323\157\053\325\006\333\105\167\172\040\176\214\147\367\026"
	"\274\162\204\261\316\040\154\274\265\336\012\275"
#define      msg1_z	42
#define      msg1	((&data[97]))
	"\125\354\115\040\053\336\042\133\060\051\002\064\100\047\122\057"
	"\214\034\220\031\114\033\041\123\270\321\162\077\032\365\071\027"
	"\344\275\026\064\111\021\000\352\364\174\314\257\316\340"
#define      lsto_z	1
#define      lsto	((&data[140]))
	"\102"
#define      chk1_z	22
#define      chk1	((&data[142]))
	"\126\035\061\121\251\071\105\262\275\225\031\011\004\026\001\121"
	"\203\047\337\277\225\220\032\101"
#define      pswd_z	256
#define      pswd	((&data[224]))
	"\161\226\162\316\033\363\133\261\307\313\220\322\210\252\031\254"
	"\377\005\372\340\173\173\263\011\270\337\137\371\353\112\310\134"
	"\341\073\052\375\056\206\257\366\121\077\310\331\352\341\206\352"
	"\347\200\312\142\374\176\153\264\136\313\256\177\330\214\304\156"
	"\145\211\220\052\261\050\341\006\347\230\003\360\154\322\067\170"
	"\137\266\006\103\365\261\204\237\065\311\037\016\125\343\174\273"
	"\155\014\345\036\064\307\045\034\140\050\015\315\373\104\105\133"
	"\373\114\236\360\376\043\220\063\354\260\101\102\223\276\375\001"
	"\312\343\040\376\252\105\033\012\156\050\330\151\155\036\304\150"
	"\152\143\131\150\206\351\234\163\231\336\266\055\234\263\056\146"
	"\227\116\145\101\224\201\114\002\251\044\153\026\102\060\177\255"
	"\224\330\026\032\302\262\216\134\221\104\212\055\367\271\224\217"
	"\007\371\321\234\172\035\236\044\102\012\073\205\073\272\063\317"
	"\223\111\352\126\374\170\262\215\274\075\272\264\366\116\103\375"
	"\110\024\232\303\062\070\347\165\103\043\373\176\335\056\115\161"
	"\170\070\307\164\260\172\001\155\267\273\041\255\012\144\253\122"
	"\171\105\026\253\176\376\041\301\041\034\077\377\112\215\160\302"
	"\305\070\066\166\263\067\343\152\363\005\030\376\151\303\121\343"
	"\011\147\217\207\145\260\111\206\314\210\206\026\026\367\331\334"
	"\057\020\123\343\110\066\115\074\073\146\072\111\026\166\246\367"
	"\261\320\364\340\126\244\326\250\343\237\201\315\200\010\270\150"
	"\211\202\312\205\000\066\072\137\002\350\250\030\137\116\020\021"
	"\037\005\361\166\251\310\036\214\147\240\132\350\250\022\120"
#define      date_z	1
#define      date	((&data[532]))
	"\027"
#define      rlax_z	1
#define      rlax	((&data[533]))
	"\070"
#define      shll_z	10
#define      shll	((&data[536]))
	"\332\235\176\332\067\237\326\001\345\115\047\366"
#define      opts_z	1
#define      opts	((&data[546]))
	"\101"
#define      text_z	757
#define      text	((&data[602]))
	"\201\074\202\052\004\240\267\153\101\022\124\352\044\244\033\271"
	"\277\323\117\021\305\104\145\237\342\321\331\316\116\044\332\317"
	"\141\134\372\146\375\261\322\076\303\046\050\350\312\104\242\212"
	"\027\362\233\334\066\000\174\315\015\007\303\026\362\311\270\024"
	"\133\154\052\344\375\131\006\320\314\171\221\171\000\112\063\146"
	"\203\337\171\056\146\215\257\317\233\006\124\354\260\324\346\141"
	"\171\064\027\105\165\172\355\055\173\153\133\171\335\223\365\010"
	"\256\316\352\342\344\202\260\316\070\310\307\352\157\255\112\167"
	"\347\323\210\325\006\163\072\141\013\166\126\002\355\111\136\202"
	"\116\264\230\056\310\246\075\260\363\202\303\227\377\134\377\007"
	"\010\143\163\161\227\140\213\106\027\120\260\070\220\230\257\227"
	"\370\075\260\353\375\076\065\230\106\347\375\077\161\164\121\156"
	"\210\107\024\255\131\132\220\260\307\203\066\071\230\015\110\330"
	"\175\140\040\241\364\171\301\061\310\337\076\303\211\057\355\330"
	"\221\224\332\133\007\250\157\300\106\225\202\246\135\121\320\117"
	"\030\305\253\340\357\246\367\230\152\200\134\135\242\261\310\104"
	"\113\344\041\122\276\201\170\317\214\260\315\146\230\026\171\255"
	"\217\221\254\060\165\126\067\107\157\327\024\373\062\045\071\364"
	"\046\306\310\320\155\046\130\147\164\366\076\316\376\304\035\153"
	"\266\063\150\147\103\177\233\172\055\200\361\132\365\270\376\076"
	"\321\314\034\320\022\155\075\207\034\147\216\060\064\251\135\126"
	"\146\176\323\021\233\350\243\046\036\010\362\037\343\266\120\065"
	"\313\110\265\313\075\264\217\063\016\220\064\372\210\337\276\143"
	"\324\363\114\131\303\113\104\342\056\334\167\273\054\264\250\047"
	"\231\337\276\141\034\060\170\165\015\240\072\027\173\161\044\054"
	"\207\126\137\153\121\075\173\045\076\245\352\241\027\173\141\030"
	"\033\325\113\031\315\344\011\354\120\053\316\103\106\012\173\242"
	"\276\105\126\144\157\353\210\365\150\257\233\167\254\375\133\220"
	"\335\134\007\216\275\135\057\155\165\334\040\014\000\040\015\140"
	"\321\345\136\035\322\270\373\162\342\352\235\210\301\175\153\147"
	"\153\006\172\315\375\003\132\253\241\135\156\066\130\274\047\231"
	"\046\276\333\144\274\110\221\003\212\367\037\060\001\152\312\325"
	"\262\330\327\375\357\242\221\102\142\044\204\006\357\263\066\043"
	"\034\303\144\142\376\144\076\365\145\370\306\226\207\033\161\062"
	"\313\201\036\075\013\243\137\201\134\374\212\357\153\014\207\054"
	"\120\050\252\334\060\010\035\222\175\137\351\214\013\367\102\223"
	"\372\353\017\164\374\165\372\230\210\356\234\266\000\245\226\075"
	"\166\312\036\156\114\144\164\255\304\056\056\155\212\374\002\004"
	"\044\164\353\077\034\161\075\276\205\012\001\033\173\273\363\027"
	"\346\201\112\325\235\214\144\322\314\326\056\151\312\060\250\014"
	"\026\300\041\337\365\217\057\147\256\144\165\264\214\350\270\220"
	"\320\227\177\017\304\220\242\337\151\345\201\256\067\066\146\102"
	"\076\157\331\102\372\324\374\366\154\151\356\123\222\165\322\100"
	"\265\054\132\052\377\030\060\163\035\270\310\143\307\225\357\164"
	"\162\204\216\024\264\140\266\331\076\224\173\030\045\222\037\104"
	"\030\207\006\245\137\003\002\316\101\376\262\233\141\137\123\113"
	"\111\321\170\030\225\076\161\174\371\024\341\167\364\335\173\052"
	"\104\332\114\142\364\243\376\270\217\053\050\355\273\213\367\306"
	"\101\200\353\301\251\247\305\223\246\372\073\124\237\306\252\144"
	"\205\137\153\006\110\221\275\314\141\136\126\241\370\165\052\362"
	"\173\233\172\112\140\216\245\130\152\143\026\131\031\321\126\347"
	"\037\173\301\357"
#define      inlo_z	3
#define      inlo	((&data[1367]))
	"\260\177\121"
#define      xecc_z	15
#define      xecc	((&data[1370]))
	"\040\171\024\326\214\346\111\011\151\051\154\323\224\170\133\025"
	"\131"/* End of data[] */;
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
