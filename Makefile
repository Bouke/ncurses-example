build:
	swift build \
		-Xlinker -l
		-Xcc -D_DARWIN_C_SOURCE \
		-Xcc -I/usr/local/Cellar/ncurses/6.0_2/include \
		-Xcc -I/usr/local/Cellar/ncurses/6.0_2/include/ncursesw \
		-Xlinker -L/usr/local/Cellar/ncurses/6.0_2/lib
