##
### RPM related targets
##

package=ntc-wr-deployment-tooling

RPM_DIR= ${CURDIR}
RPM_COMMAND=`which rpmbuild || which rpm`


rpms: env ${package} ## target to build all RPM's

# set up RPM build environment
env::
	mkdir -p ${RPM_DIR}/BUILD
	mkdir -p ${RPM_DIR}/RPMS
	mkdir -p ${RPM_DIR}/SOURCES
	mkdir -p ${RPM_DIR}/SRPMS

# copy files to BUILD directory
DEPLOY:
	cp -a ${CURDIR}/src/* ${RPM_DIR}/BUILD

# build the actual RPM
BUILD_RPM:
	${RPM_COMMAND} -bb --define '_topdir ${RPM_DIR}' --buildroot ${RPM_DIR}/ROOT SPECS/${package}.spec

# build sequence: deploy; build
${package}: DEPLOY BUILD_RPM

clean:: ## cleanup
	if [ ! -z ${RPM_DIR}/BUILD ]; then rm -r --force ${RPM_DIR}/BUILD ; fi;
	if [ ! -z ${RPM_DIR}/RPMS ]; then rm -r --force ${RPM_DIR}/RPMS ; fi;
	if [ ! -z ${RPM_DIR}/SOURCES ]; then rm -r --force ${RPM_DIR}/SOURCES ; fi;
	if [ ! -z ${RPM_DIR}/SRPMS ]; then rm -r --force ${RPM_DIR}/SRPMS ; fi;
	if [ ! -z ${RPM_DIR}/ROOT ]; then rm -r --force ${RPM_DIR}/ROOT ; fi;
	if [ ! -z ${RPM_DIR}/BUILDROOT ]; then rm -r --force ${RPM_DIR}/BUILDROOT ; fi;

#setup some variables
tag: REPOURL   := $(filter http%, $(shell svn info ${CURDIR} 2> /dev/null | grep '^Repository Root'))
tag: TAGSURL   := $(REPOURL)/tags/packaging
tag: URL       := $(filter http%, $(shell svn info ${CURDIR} 2> /dev/null | grep '^URL'))
#tag it
tag:
#check it we're in a svn checkout directory
	@svn info ${CURDIR}> /dev/null
ifneq ($(shell svn status ${CURDIR} | grep '^[ACDIMR?!~]' | wc -l),0)
	@echo "There are uncommitted files."
	exit 1
endif
#If no TAG variable is specified, use the calucated tag 
ifeq ($(TAG),)
	@tagurls=`svn ls '$(TAGSURL)' | grep '^$(package)-[0-9]'`;\
	newtag=`for tag in $$tagurls; do svn info "$(TAGSURL)/$$tag"; done | awk -F': ' '/URL:/ { url=$$2 }; /Last Changed Rev:/ { if ($$2 > rev) { rev=$$2; lasturl=url}}; END { print lasturl }' | awk -F/ '{print $$NF}' | perl -e '$$lasttag = <STDIN>; if ($$lasttag =~ /(.*[^\d])(\d+)$$/) { print "$$1".($$2+1) } elsif ($$lasttag =~ /^\s*$$/) { print "" } else { print $$lasttag."_2" }'`;\
	if echo "$$newtag" | grep -q '^$(package)-[0-9]'; then true; else echo "Tag should start with '$(package)-': $$newtag"; exit 1; fi;\
	echo "svn cp $(URL) $(TAGSURL)/$$newtag";\
	svn cp $(URL) $(TAGSURL)/$$newtag
else
#else use the TAG variable
	@if echo '$(TAG)' | grep -q '^$(package)-[0-9]'; then true; else echo "Tag should start with '$(package)-'"; exit 1; fi
	svn cp $(URL) $(TAGSURL)/$(TAG)
endif

