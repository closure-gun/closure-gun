UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OUTFILE = libNailgunTest.so
	CCFLAGS = -fPIC -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux
endif
ifeq ($(UNAME_S),Darwin)
	OUTFILE = libNailgunTest.jnilib
	CCFLAGS = -I$(shell /usr/libexec/java_home)/include -I$(shell /usr/libexec/java_home)/include/darwin
endif

install: bin/$(OUTFILE) closure-compiler nailgun

bin/$(OUTFILE):
	cd "bin" && javac "NailgunTest.java" && gcc "NailgunTest.c" -shared -o $(OUTFILE) $(CCFLAGS)

closure-compiler:
	mkdir "closure-compiler"

# Use the compiler provide by google-closure-compiler, if available
ifneq ("$(wildcard ../google-closure-compiler/compiler.jar)","")
	cp "../google-closure-compiler/compiler.jar" "./closure-compiler/compiler.jar"

else
# Else, init bootstraping
	rm -fr "tmp"; mkdir -p "tmp/closure-compiler"
# Download latest Google Closure Compiler
	curl -L -o "./tmp/compiler-latest.tgz" "https://dl.google.com/closure-compiler/compiler-latest.tar.gz" \
		&& tar -xf "./tmp/compiler-latest.tgz" -C "./tmp/closure-compiler"
# Move compiler.jar
	mv ./tmp/closure-compiler/closure-compiler-*.jar "./closure-compiler/compiler.jar"
# Cleanup
	rm -fr "tmp"
endif

nailgun:
# Init bootstraping
	rm -fr "tmp"; mkdir -p "tmp" "nailgun"
# Download latest Google Closure Compiler
	curl -L -o "./tmp/denji-0.9.2.tgz" "https://github.com/closure-gun/nailgun/archive/denji-0.9.2.tar.gz" \
		&& tar -xf "tmp/denji-0.9.2.tgz" -C "./tmp/"
# Maven building Nailgun-Server and "ng" binaries
	make ng -C "./tmp/nailgun-denji-0.9.2" && mvn package --quiet -f "./tmp/nailgun-denji-0.9.2/nailgun-server/pom.xml"
# Move nailgun-server-*.jar and "ng" binaries
	mv "./tmp/nailgun-denji-0.9.2/nailgun-server/target/nailgun-server-0.9.2.jar" "./nailgun/nailgun.jar"
	mv "./tmp/nailgun-denji-0.9.2/ng" "./nailgun/ng"
# Cleanup
	rm -fr "tmp"

clean:
	rm -rf "bin/$(OUTFILE)" "bin/NailgunTest.class" "closure-compiler" "nailgun" "tmp"
