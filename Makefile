#
# Makefile for generating instructor slides package for a course
#

#*************************************************************************"
# 'WARNING: RPMs built on Fedora may not install properly on RHEL unless the'
# 'following lines are in your ~/.rpmmacros file'
#"*************************************************************************"
#	""
#	'%_source_filedigest_algorithm 1'
#	'%_binary_filedigest_algorithm 1'
#	'%_binary_payload w9.bzdio'
#	'%_source_payload w9.bzdio'
#	""
#	"DO NOT build production RPMs on Fedora without this!"
#

SPEC_FILE := slides.spec
NAME_PREFIX = redhat-training-slides
NAME = $(COURSE_CODE)-$(PRODUCT)-$(LANGUAGE)
PREFIXED_NAME = $(NAME_PREFIX)-$(NAME)
FULLNAME = $(NAME)-$(VERSION)-$(RELEASE)
PREFIXED_FULLNAME = $(NAME_PREFIX)-$(FULLNAME)
ARCH := noarch

# If this doesn't work for you, add the following to ~/.rpmmacros
#%_topdir %(echo $HOME)/rpmbuild
BUILDDIR=$(shell rpm --eval '%_topdir')

RPMBUILD=rpmbuild -D "version $(VERSION)" -D "release $(RELEASE)" -D "arch $(ARCH)" -D "name $(NAME)" -D "prefixed_name $(PREFIXED_NAME)" -D "fullname $(FULLNAME)" -D "prefixed_fullname $(PREFIXED_FULLNAME)" -D "course_code $(COURSE_CODE)" -D "version $(VERSION)" -D "language $(LANGUAGE)" -D "release $(RELEASE)"
RPMSIGN=rpmsign --addsign --define='_gpg_name F053023A'
TAR=tar --exclude=.git --exclude=.gitkeep --exclude=package.json --exclude=bower.json --exclude=Gruntfile.js -hcvzf

.PHONY: rpm tgz srpm final copy clean

default: rpm

tgz:
ifdef WORKSPACE
	cp -a . $(WORKSPACE)/$(PREFIXED_FULLNAME)
	([ -e $(PREFIXED_FULLNAME) ] || ln -sf $(WORKSPACE)/$(PREFIXED_FULLNAME) $(PREFIXED_FULLNAME))
	$(TAR) $(PREFIXED_FULLNAME).tar.gz -C $(WORKSPACE)/$(PREFIXED_FULLNAME) .
else
	cp -a . $(BUILDDIR)/$(PREFIXED_FULLNAME)
	([ -e $(PREFIXED_FULLNAME) ] || ln -sf $(BUILDDIR)/$(PREFIXED_FULLNAME) $(PREFIXED_FULLNAME))
	$(TAR) $(PREFIXED_FULLNAME).tar.gz -C $(BUILDDIR)/$(PREFIXED_FULLNAME) .
endif

srpm: tgz
ifdef WORKSPACE
	$(RPMBUILD) -D '_topdir ${WORKSPACE}' -ts --clean $(PREFIXED_FULLNAME).tar.gz
else
	$(RPMBUILD) -ts --clean $(PREFIXED_FULLNAME).tar.gz
endif

copy:
ifdef WORKSPACE
	$(RPMBUILD) -D '_topdir ${WORKSPACE}' -ta --clean --rmsource $(PREFIXED_FULLNAME).tar.gz
	$(RPMSIGN) $(GPGKEY) $(WORKSPACE)/RPMS/$(ARCH)/$(PREFIXED_FULLNAME).$(ARCH).rpm
	(cp $(WORKSPACE)/RPMS/$(ARCH)/$(PREFIXED_FULLNAME).$(ARCH).rpm .)
else
	$(RPMBUILD) -ta --clean --rmsource $(PREFIXED_FULLNAME).tar.gz
	$(RPMSIGN) $(GPGKEY) $(BUILDDIR)/RPMS/$(ARCH)/$(PREFIXED_FULLNAME).$(ARCH).rpm
	(cp $(BUILDDIR)/RPMS/$(ARCH)/$(PREFIXED_FULLNAME).$(ARCH).rpm .)
endif

rpm: tgz copy clean

final:
	GPGKEY="--define='_gpg_name 530679EE'" make rpm

clean:
	rm -rf $(PREFIXED_FULLNAME) $(PREFIXED_FULLNAME).tar.gz
	rm -f $(PREFIXED_FULLNAME)
