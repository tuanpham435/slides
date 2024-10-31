# Declarations
Name:           %{prefixed_name}
Version:        %{version}
Release:        %{release}
Summary:        Tool to build an RPM for distributing %{course_code} instructor slides

License:        Copyright %(date +%%Y) Red Hat, Inc.
URL:            https://github.com/RedHatTraining/%{course_code}
Source0:        %{prefixed_fullname}.tar.gz

BuildArch:      noarch

%description
Generates an RPM to deploy %{course_code} instructor slides on an instructor machine.
Slides are unpacked to the /content/slides/%{fullname} directory

%prep
%setup -q -c -n %{prefixed_fullname}

%build

%install
mkdir -p -m755 %{buildroot}/content/slides/%{fullname}

cp -a . %{buildroot}/content/slides/%{fullname}

%files
%defattr(-,root,root,-)
%license LICENSE
/content/slides/%{fullname}
