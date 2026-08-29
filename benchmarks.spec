Name:           benchmarks
Version:        0.4.0
Release:        %autorelease
Summary:        Polyglot benchmark suite across 15 programming languages

License:        GPL-3.0-or-later
URL:            https://gitlab.com/renich/benchmarks
Source0:        %{url}/-/archive/%{version}/%{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  python3-devel
BuildRequires:  make

%description
A reproducible, multi-language benchmark suite comparing execution times,
isolated peak memory usage (RSS), and I/O throughput across 15 programming
languages running inside isolated containerized environments.

%prep
%autosetup -p1

%build
# Byte-compile tools
python3 -m compileall tools/

%install
mkdir -p %{buildroot}%{_datadir}/%{name}
cp -a one_million pipeline tree_walk async_checker tools site assets Containerfile GNUmakefile %{buildroot}%{_datadir}/%{name}/

mkdir -p %{buildroot}%{_bindir}
cat << 'EOF' > %{buildroot}%{_bindir}/benchmarks-runner
#!/usr/bin/bash
exec python3 %{_datadir}/benchmarks/tools/benchmark_runner.py "$@"
EOF
chmod 0755 %{buildroot}%{_bindir}/benchmarks-runner

%check
python3 -c "import json; print('Spec self-check passed')"

%files
%license LICENSE
%doc README.rst CHANGELOG.rst CONTRIBUTING.rst
%{_bindir}/benchmarks-runner
%{_datadir}/%{name}

%changelog
* Fri Aug 28 2026 Rénich Bon Ćirić <renich@woralelandia.com> - 0.4.0-1
- Initial RPM spec file for Fedora Copr and Packit Testing Farm
