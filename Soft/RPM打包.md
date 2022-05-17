# RPM 打包流程

##   RPM介绍

### 什么是 RPM

RPM 软件包管理器(RPM)是在红帽企业 **Linux**、**CentOS** 和 **Fedora** 上运行的软件包管理系统。您可以使用 **RPM** 来分发、管理和更新您为上述任何操作系统创建的软件。与传统存档文件中的软件分发相比,**RPM** 软件包管理系统具有多个优势。**RPM** 允许您:

- 使用标准软件包管理工具(如 **Yum** 或 **PackageKit**)安装、重新**安装**、**删除**、**升级**和**验证**软件包。
- 使用已安装的软件包数据库查询并验证软件包。
- 使用元数据描述软件包、安装说明和其他软件包参数。
- 将软件源、补丁和完整的构建指令打包在源和二进制软件包中。
- 添加软件包到 **Yum** 存储库。
- 使用 **GNU Privacy Guard(GPG)签名密钥**通过数字签名您的软件包。

### 什么是RPM包

**RPM** 软件包是包含其它文件和元数据的文件(系统所需文件的信息)。特别是,**RPM** 软件包由 **cpio 归档**组成。**cpio 归档**包含:

- **文件**

- **RPM 标头(软件包元数据)**：rpm 软件包管理器使用此元数据来确定依赖项、安装文件的位置和其他信息。

#### RPM 软件包的类型

RPM 软件包有两种类型。这两种类型都共享文件格式和工具,但内容不同,并实现不同的目的:

- **源 RPM(SRPM)**：SRPM 包含源代码和 SPEC 文件,这些文件描述了如何将源代码构建为二进制 RPM。另外,也可以选择包括源代码的补丁。
- **二进制 RPM**：一个二进制 RPM 包含了根据源代码和补丁构建的二进制文件。

## 开始打包

### 先决条件
`rpmdevtools` 软件包必须安装在您的系统中:

```bash
yum install rpmdevtools
```

### 创建工作目录

使用 ` rpmdev-setuptree` 命令初始化工作目录

```bash
rpmdev-setuptree
tree ~/rpmbuild/
```

各个目录的作用如下:

|    目录     | 目的                                                         |
| :---------: | :----------------------------------------------------------- |
|  **BUILD**  | 当构建软件包时,会在此处创建各种 **%buildroot** 目录。如果日志输出无法提供足够的信息,这对调查失败的构建非常有用。 |
|   **RPM**   | 二进制 **RPM** 在此处创建,在不同的构架的子目录中,例如在子目录 **x86_64** 和 **noarch**中。 |
| **SOURCES** | 此处打包程序设置了压缩的源代码存档和补丁。`rpmbuild` 命令会在此处查找它们。 |
|  **SPECS**  | 打包程序在此处放置 **SPEC** 文件。                           |
|  **SRPMS**  | 当 `rpmbuild` 用于构建 SRPM 而不是二进制 **RPM** 时,此处会创建生成的 **SRPM**。 |

如果想自定义位置则可编辑文件 `~/.rpmmacros`

```bash
# macros
## 自定义根目录
%_topdir    /home/dragon/Documents/RPM
## 自定义 SOURCES 目录
#%_sourcedir %{_topdir}
## 自定义 BUILD 目录
#%_builddir  %{_topdir}
## 自定义 SPECS 目录
#%_specdir   %{_topdir}
## 自定义 RPM 目录
#%_rpmdir    %{_topdir}
## 自定义 SRPMS 目录
#%_srcrpmdir %{_topdir}
```

### 创建 SPEC 文件

#### SPEC 文件是什么

您可以将 **SPEC** 文件理解为 `rpmbuild` 实用程序用来构建 **RPM** 的方法。**SPEC** 文件通过在一系列部分中定义指令向构建系统提供必要的信息。这些部分在 `Preamble` 和 `Body` 部分定义。`Preamble` 部分包含一系列元数据项目,在 `Body` 部分使用。`Body` 部分代表该指令的主要部分。

#### SPEC 文件指令详解

##### `Preamble` 部分

下表显示了 **RPM** **SPEC** 文件的 `Preamble` 部分中经常使用的一些指令。

| SPEC 指令         | 定义                                                         |
| ----------------- | ------------------------------------------------------------ |
| **Name**          | 软件包的基本名称,应该与 SPEC 文件名匹配。                    |
| **Version**       | 软件的上游版本号。                                           |
| **Release**       | 本版软件的发布次数。通常,将初始值设置为 `1%{?dist}`,并在软件包的每个新版本中递增它。构建新 **Version** 软件时,重置为 1。 |
| **Summary**       | 软件包的简短单行摘要。                                       |
| **License**       | 打包软件的许可证。                                           |
| **URL**           | 有关程序的更多信息的完整**URL**。大多数情况下，这是被打包的软件的上游项目网站。 |
| **Source0**       | 上游源代码压缩存档的路径或 URL(未修补,补丁在别处处理)。这应该指向存档的可访问且可靠的存储,例如上游页面,而不是打包程序的本地存储。如果需要,可以添加更多 **SourceX** 指令,每次增加数量,例如**Source1**、**Source2** 和 **Source3** 等。 |
| **Patch**         | 适用于源代码的第一个补丁名称。指令可以通过两种方式应用: **Patch 末尾有数字**或**不带数字**。如果**未指定数字**,则在内部为条目分配一个。也可以使用 `Patch0`、`Patch1`、`Patch2` 和 `Patch3` 等明确给出数字。这些修补程序可使用 `%patch0`、`%patch1`、`%patch2` 宏等应用。宏在 **RPM SPEC** 文件的 `Body` 部分中的 `%prep` 指令内应用。或者,您可以使用`%autopatch` 宏,它按照 **SPEC** 文件中给出的顺序自动应用所有补丁。 |
| **BuildArch**     | 如果软件包不依赖于构架，例如，如果完全使用解释的编程语言编写,请将其设置为 `BuildArch: noarch`。如果没有设置，软件包会自动继承构建它的机器的架构,例如 `x86_64`。 |
| **BuildRequires** | 构建使用编译语言编写的程序所需的软件包列表，以空格分隔。 **BuildRequires** 可能有多个条目,每个条目在 SPEC 文件中独立存在。 |
| **Requires**      | 软件在安装后需要运行的软件包列表，用逗号或空格分隔。 **Requires** 可能有多个条目,每个条目在 SPEC 文件中独立存在。 |
| **ExcludeArch**   | 如果某一部分软件无法在特定的处理器架构上运行,您可以在此处排除该体系结构。 |
| **Conflicts**     | 如果软件包与 **Conflicts** 匹配,则无法独立安装该软件包,具体取决于 **Conflict** 标签是安装在已安装的软件包中,还是安装的软件包中。 |
| **Obsoletes**     | 这个指令会根据 rpm 命令直接在命令行中使用,还是由更新或依赖性解析器执行更新而改变更新的工作方式。在命令行中使用时,RPM 将删除与正在安装的软件包过时的软件包匹配的所有软件包。当使用更新或依赖项解析程序时,包含匹配 **Obsoletes:** 的软件包会添加为更新并替换匹配的软件包。 |
| **Provides**      | 如果 Provides 添加到软件包中,则软件包可以由其名称以外的依赖项引用。 |

**Name**、**Version** 和 **Release** 指令组成 RPM 软件包的文件名。RPM 软件包维护程序和系统管理员通常称为 **N-V-R** 或 **NVR** 这三个指令,因为 **RPM** 软件包文件名具有 **NAME-VERSION-RELEASE** 格式。

使用如下命令查询软件包的 **NVR** 信息:

```bash
rpm -q bash
```

##### `Body section` 部分

**RPM SPEC** 文件的 `Body section` 中使用的项目列在下表中。

| SPEC 指令        | 定义                                                         |
| ---------------- | ------------------------------------------------------------ |
| **%description** | RPM 中打包的软件包的完整描述。这种描述可跨越多行,可分为几个段落。 |
| **%prep**        | 用于准备要构建的软件的命令或一系列命令,例如解压缩 Source0 中的存档。此指令可以包含 shell 脚本。 |
| **%build**       | 用于将软件构建到计算机代码的命令或一系列命令(用于编译语言)或字节代码(用于一些解释语言)。 |
| **%install**     | 将所需构建工件从 %builddir (构建进行的位置)复制到 %buildroot 目录中的命令或一系列命令(其中包含要打包的文件的目录结构)。这通常意味着将文件从`~/rpmbuild/BUILD` 复制到 `~/rpmbuild/BUILDROOT` 并在`~/rpmbuild/BUILDROOT` 中创建必要的目录。这仅在创建软件包时运行,而不是在最终用户安装软件包时运行。 |
| **%check**       | 用于测试软件的命令或一系列命令。这通常包括单元测试等内容。   |
| **%files**       | 将在终端用户系统中安装的文件列表。                           |
| **%changelog**   | 记录不同 Version 或 Release 构建之间软件包发生的更改。       |

#### scriptlets

`scriptlet` 是一系列在安装或删除软件包之前或之后执行的 **RPM** 指令。

##### scriptlets 指令

存在一组常用的 **Scriptlet** 指令。它们与 **SPEC** 文件部分标头类似,如 `%build` 或 `%install`。它们由多行代码段定义，通常编写为**标准 POSIX shell 脚本**。但是,它们也可以使用其他编程语言编写，目标计算机分发的 **RPM** 接受这些语言。**RPM** 文档包括可用语言的详尽列表。

下表包含按照执行顺序列出的 **Scriptlet** 指令。请注意,包含脚本的软件包会在 `%pre` 和 `%post` 指令间安装，它会在 `%preun` 和 `%postun` 指令间卸载。

|     指令     | 定义                             |
| :----------: | -------------------------------- |
| `%pretrans`  | 仅在安装或删除任何软件包之前执行 |
|    `%pre`    | 在目标系统上安装包之前执行       |
|   `%post`    | 仅在目标系统上安装包之后执行     |
|   `%preun`   | 从目标系统卸载软件包之前执行     |
|  `%postun`   | 从目标系统卸载软件包之后执行     |
| `%posttrans` | 在事务结束时执行                 |

##### 关闭scriptlets执行

要关闭**Scriptlet**指令执行,请使用 `rpm` 命令和 `--no_scriptlet_name_` 选项。例如，要关闭 `%pretrans` 脚本小程序的执行,请运行 `rpm --nopretrans`，或者您还可以使用 `--noscripts` 选项,它等同于以下所有选项：

- `--nopre`
- `--nopost`
- `--nopreun`
- `--nopostun`
- `--nopretrans`
- `--noposttrans`

#### RPM 宏

**rpm 宏**是一种直接文本替换,可以在使用特定内置功能时根据对语句的可选求值进行有条件地分配。因此,**RPM** 可以为您执行文本替换。
例如，如果想在 **SPEC** 文件中多次引用打包软件版本。您只在 `%{version}` 宏中定义版本一次,就可在 **SPEC** 文件中使用此宏。每次出现时,系统将自动替换为您之前定义的版本。

> 如果看到不熟悉的宏,您可以使用以下命令对其进行评估 :` rpm --eval %{_MACRO}`,例如：` rpm --eval %{_bindir}`

在常用的宏中,`%{?dist}` 宏为用于构建的信号(分发标签)

#### 使用 `rpmdev-newspec`创建 RPM SPEC

使用 `rpmdev-newspec` 可创建 **SPEC** 文件模板，创建方法如下

```bash
cd ~/rpmbuild/SPECS
# rpmdev-newspec <NAME>
rpmdev-newspec jdk-11
```

### 填充 `SPEC` 内容

**先决条件**

- 特定程序的源代码已放置到 `~/rpmbuild/SOURCES/` 目录中。
- 未填充的 SPEC 文件 `~/rpmbuild/SPECS/<name>.spec` 文件由 rpmdev-newspec 实用程序创建。

**流程**

1. 打开由 `rpmdev-newspec` 实用程序提供的 `~/rpmbuild/SPECS/<name>.spec` 文件的输出模板:
2. 填充 **SPEC** 文件的第一个部分:

   - **Name** ： 已指定为 `rpmdev-newspec` 的参数。

   - **Version**：将 **Version** 设置为与源代码的上游发行版匹配。

   - **Release**：Release 自动设置为 `1%{?dist}`,最初是 1。每当更新软件包时不更改上游版本 **Version** 时会递增初始值 （例如当包含补丁时）。发生新的上游版本时,将 **Release** 重置为 1

   - **Summary**：是这个软件的简短说明
3. 填充 **License**、**URL** 和 **Source0** 指令:
   - **License**：**License** 字段是与上游发行版本中源代码关联的软件许可证。如何在您的 **SPEC** 文件中标记**License** 的具体格式会因您所遵循的基于特定 **RPM** 的 **Linux** 发行版指南而有所不同。例如,您可以使用 GPLv3+。
   - **URL** ：**URL** 字段提供上游软件网站的 **URL**。为保持一致性,请使用 `%{name}` 的 **RPM** 宏变量,并使用类似于 `https://example.com/%{name}`一样的格式。
   - **Source0**：**Source0** 字段提供上游软件源代码的 `URL`。它应当**直接链接到要打包的软件的特定版本**。请注意，本文档给出的示例 **URL** 包含硬编码值,将来可能会更改这些值。同样,发行版本也会改变。要简化这些潜在的将来更改,请使用 `%{name}` 和 `%{version}` 宏。通过使用这些,您只需要更新**SPEC** 文件中的一个字段。
4.  填充 **BuildRequires**、**Requires** 和 **BuildArch** 指令：
   - **BuildRequires**：**BuildRequires** 指定软件包的构建时间依赖关系。l
   - **Requires**：**Requires** 指定软件包的运行时依赖项。
   - **BuildArch**：对于解释型编程语言的软件，使用 `noarch` 值添加**BuildArch** 指令。这告知 **RPM**,此软件包不需要与其所构建的处理器体系结构绑定。
5.  填充 `%description`、`%prep`、`%build`、`%install`、`%files` 和 `%license` 指令，这些指令可以视为小节标题，因为它们是可定义要发生的多行、多指令或脚本化任务的指令。
    - `%description`：`%description` 是 **Summary** 软件的较长、更完整的描述,包含一个或多个段落。
    - `%prep`：`%prep` 部分指定如何准备构建环境。这通常涉及扩展源代码的压缩存档、补丁应用,以及解析源代码中提供的信息以供 **SPEC** 文件后续部分使用。您可以使用内置的 `%setup -q` 宏。
    - `%build`：`%build` 部分指定如何构建软件。
    - `%install`：`%install` 部分包含 `rpmbuild` 如何在构建后将其安装到 **BUILDROOT** 目录中的说明。该目录是空的 **chroot 基础目录**,类似于最终用户的根目录。您可以在此处创建包含已安装文件的任何目录。要创建这样的目录,您可以使用 **RPM** 宏而无需硬编码路径。
    - `%files`：`%files` 部分指定此 **RPM** 提供的文件列表及其在最终用户系统中的完整路径位置。您可以使用内置宏指示各种文件的角色。这可用于使用 `rpm` 命令查询软件包文件清单元数据。例如:要指明 **LICENSE** 文件是一个软件许可证文件,请使用 `%license` 宏。
6. 填充 `%changelog` 指令： `%changelog` 是每个 **Version-Release** 的软件包日期标记条目列表。它们**记录打包更改**，而不是软件更改。第一行遵循以下格式: 以 `*` 字符开头,后跟 `Day-of-Week Month Day Year Name Surname <email> - Version-Release`，在实际更改条目中遵循以下格式：
   - 每个更改条目可以包含多个项目，每次更改一次。
   - 每个项目都在新行上启动。
   - 每个项目都以 `-` 字符开头。

### 构建 RPM

**RPM** 使用 `rpmbuild` 命令构建。这个命令需要一个特定的目录和文件结构,它与 `rpmdev-setuptree` 工具设置的结构相同。

#### 构建源 RPM

使用指定的 **SPEC** 文件运行 `rpmbuild` 命令

```bash
 cd ~/rpmbuild/SPECS/
 rpmbuild -bs <SPECFILE>
```

执行完成后内容将保存在 `~/rpmbuild/SRPMS ` 下

#### 构建二进制 RPM

对于构建二进制 **RPM**,可以使用以下方法:

- 从源 **RPM** 重建二进制 **RPM**
- 从 **SPEC** 文件构建二进制 **RPM**
- 从源 **RPM** 构建二进制 **RPM**

##### 从源 RPM 构建二进制 RPM

使用 ` rpmbuild --rebuild` 命令重建二进制**RPM**

```bash
 rpmbuild --rebuild ~/rpmbuild/SRPMS/<NAME>.src.rpm
```

**注意**

调用 `rpmbuild --rebuild` 涉及:

- 将 **SRPM** 的内容(**SPEC** 文件和源代码)安装到 `~/rpmbuild/` 目录中。

- 使用安装的内容进行构建.

- 删除 **SPEC** 文件和源代码.


要在构建后保留 **SPEC** 文件和源代码,您可以:在构建时,使用 `rpmbuild` 命令及 `--recompile` 选项而不是 `--rebuild` 选项。

生成的二进制 RPM 位于 `~/rpmbuild/RPMS/<YOURARCH>` 目录中，`YOURARCH` 是您的架构。如果软件包不限定架构,则在 `~/rpmbuild/RPMS/noarch/` 目录中。

##### 从 SPEC 文件构建二进制 RPM

使用 `rpmbuild -bb ~/rpmbuild/SPECS/<name>.spec`命令从 **SPEC** 文件中构建**二进制 RPM**。例如：

```bash
rpmbuild -bb ~/rpmbuild/SPECS/bello.spec
```

还可以使用其他选项来构建**RPM**包，可以使用 `rpmbuild --help `查看指令介绍

```bash
rpmbuild {-ra|-rb|-rp|-rc|-ri|-rl|-rs} [rpmbuild-options] SOURCEPACKAGE
```

### 检查 RPM 是否存在完整性

创建软件包后,检查软件包的质量，检查包质量的主要工具是 `rpmlint`。`rpmlint` 工具执行以下操作:

- 提高 **RPM** 的可维护性。
- 通过对 **RPM** 执行静态分析来启用完整性检查。
- 通过对 **RPM** 执行静态分析来启用检查错误。

**rpmlint** 工具可以检查**二进制 RPM**、**源 RPM(SRPM)**和 **SPEC 文件**，因此对于打包的所有阶段都很有用。请注意,`rpmlint` 具有非常严格的准则，因此有时可以接受跳过其部分错误和警告。

### 提取 RPM 内容

在某些情况下,如果 **RPM** 所需的包损坏,则需要提取包的内容。在这种情况下,如果 **RPM** 安装仍可以正常工作,您可以使用 `rpm2archive` 工具将**rpm** 文件转换为 **tar** 归档来使用软件包的内容。如果 **RPM** 安装受到严重损坏,您可以使用 `rpm2cpio` 工具将 **RPM** 软件包文件转换为 **cpio**归档。

## RPM 范例

### 打包 OpenJDK 8

文件：`SPECS/opejdk-8.spec`

```bash
Name:           openjdk-8
Version:        8u292b10
%global OpenJ9Version  0.26.0
Release:        1%{?dist}
Summary:        OpenJDK 8 Software
BuildRoot:      %{_tmppath}/%{name}-buildroot                
License:        NONE
URL:            https://adoptium.net/
Source0:        https://mirrors.ustc.edu.cn/AdoptOpenJDK/binary/openjdk8-binaries/LatestRelease/OpenJDK8U-jdk_x64_linux_openj9_%{version}_openj9-%{OpenJ9Version}.tar.gz
%description
OpenJDK 8

%prep
rm -rf %{_builddir}/%{name}
mkdir -p %{_builddir}/%{name}
tar zxf %{_sourcedir}/OpenJDK8U-jdk_x64_linux_openj9_%{version}_openj9-%{OpenJ9Version}.tar.gz -C %{_builddir}/%{name}

%build
rm -rf  %{_builddir}/%{name}/jdk-src
mv %{_builddir}/%{name}/jdk* %{_builddir}/%{name}/jdk-src


%install
mkdir -p %{buildroot}/app/soft/jdk-8
cp -r %{_builddir}/%{name}/jdk-src/*  %{buildroot}/app/soft/jdk-8
chmod 0755  %{buildroot}/app/soft/jdk-8/bin/*

%files
%dir /app/soft/jdk-8
 /app/soft/jdk-8/*


%changelog
* Thu May 12 14:58:51 CST 2022 OpenEdgn <ExplodingFKL@gmail.com>
- init
```

打包命令：

```bash
rpmbuild --undefine=_disable_source_fetch  -ba SPECS/opejdk-8.spec
```

### 打包OpenJDK 11

文件：`SPECS/opejdk-11.spec`

```bash
Name:           openjdk-11
Version:        11.0.15_10
Release:        1%{?dist}
Summary:        Adoptium OpenJDK 11 Software
License:        NONE
URL:            https://adoptium.net/
Source0:        https://mirrors.tuna.tsinghua.edu.cn/Adoptium/11/jdk/x64/linux/OpenJDK11U-jdk_x64_linux_hotspot_%{version}.tar.gz
Requires:       libXau libX11-common  libXau libXext libXi

%description
Adoptium OpenJDK 11

%prep
rm -rf %{_builddir}/%{name}
mkdir -p %{_builddir}/%{name}
tar zxf %{_sourcedir}/OpenJDK11U-jdk_x64_linux_hotspot_%{version}.tar.gz -C %{_builddir}/%{name}

%build
rm -rf  %{_builddir}/%{name}/jdk-src
mv %{_builddir}/%{name}/jdk-* %{_builddir}/%{name}/jdk-src


%install
mkdir -p %{buildroot}/app/soft/jdk-11
cp -r %{_builddir}/%{name}/jdk-src/*  %{buildroot}/app/soft/jdk-11
chmod 0755  %{buildroot}/app/soft/jdk-11/bin/*

%files
%dir /app/soft/jdk-11
 /app/soft/jdk-11/*


%changelog
* Thu May 12 14:58:51 CST 2022 OpenEdgn <ExplodingFKL@gmail.com>
- init
```

打包命令：

```bash
rpmbuild --undefine=_disable_source_fetch  -ba SPECS/opejdk-11.spec
```

### 打包 Nacos

`SOURCE/nacos-boot.sh`

```bash
#!/bin/bash
[ -e "/app/soft/jdk-8/bin/java" ] &&  export JAVA_HOME=/app/soft/jdk-8
case "`uname`" in
CYGWIN*) cygwin=true;;
Darwin*) darwin=true;;
OS400*) os400=true;;
esac
error_exit ()
{
    echo "ERROR: $1 !!"
    exit 1
}
[ ! -e "$JAVA_HOME/bin/java" ] && unset JAVA_HOME

if [ -z "$JAVA_HOME" ]; then
   error_exit "Please set the JAVA_HOME variable in your environment, We need java(x64)! jdk8 or later is better!"
fi

export SERVER="nacos-server"
export MODE="cluster"
export FUNCTION_MODE="all"
export MEMBER_LIST=""
export EMBEDDED_STORAGE=""
while getopts ":m:f:s:c:p:" opt
do
    case $opt in
        m)
            MODE=$OPTARG;;
        f)
            FUNCTION_MODE=$OPTARG;;
        s)
            SERVER=$OPTARG;;
        c)
            MEMBER_LIST=$OPTARG;;
        p)
            EMBEDDED_STORAGE=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

export JAVA_HOME
export JAVA="$JAVA_HOME/bin/java"
export BASE_DIR=`cd $(dirname $0)/..; pwd`
export CUSTOM_SEARCH_LOCATIONS=file:${BASE_DIR}/conf/

#===========================================================================================
# JVM Configuration
#===========================================================================================
if [[ "${MODE}" == "standalone" ]]; then
    JAVA_OPT="${JAVA_OPT} -Xms512m -Xmx512m -Xmn256m"
    JAVA_OPT="${JAVA_OPT} -Dnacos.standalone=true"
else
    if [[ "${EMBEDDED_STORAGE}" == "embedded" ]]; then
        JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
    fi
    JAVA_OPT="${JAVA_OPT} -server -Xms3g -Xmx3g -Xmn1g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m -Dcom.sun.management.jmxremote.port=8081 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
    JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
    JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"

fi

if [[ "${FUNCTION_MODE}" == "config" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=config"
elif [[ "${FUNCTION_MODE}" == "naming" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=naming"
fi

JAVA_OPT="${JAVA_OPT} -Dnacos.member.list=${MEMBER_LIST}"

JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [[ "$JAVA_MAJOR_VERSION" -ge "9" ]] ; then
  JAVA_OPT="${JAVA_OPT} -Xlog:gc*:file=${BASE_DIR}/logs/nacos_gc.log:time,tags:filecount=10,filesize=102400"
else
  JAVA_OPT_EXT_FIX="-Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext"
  JAVA_OPT="${JAVA_OPT} -Xloggc:${BASE_DIR}/logs/nacos_gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
fi

JAVA_OPT="${JAVA_OPT} -Dloader.path=${BASE_DIR}/plugins/health,${BASE_DIR}/plugins/cmdb,${BASE_DIR}/plugins/selector"
JAVA_OPT="${JAVA_OPT} -Dnacos.home=${BASE_DIR}"
JAVA_OPT="${JAVA_OPT} -jar ${BASE_DIR}/target/${SERVER}.jar"
JAVA_OPT="${JAVA_OPT} ${JAVA_OPT_EXT}"
JAVA_OPT="${JAVA_OPT} --spring.config.additional-location=${CUSTOM_SEARCH_LOCATIONS}"
JAVA_OPT="${JAVA_OPT} --logging.config=${BASE_DIR}/conf/nacos-logback.xml"
JAVA_OPT="${JAVA_OPT} --server.max-http-header-size=524288"
# JAVA_OPT="${JAVA_OPT} --nacos.logs.path=/app/log/nacos"
## 自定义日志保存位置

if [ ! -d "${BASE_DIR}/logs" ]; then
  mkdir ${BASE_DIR}/logs
fi

echo "$JAVA $JAVA_OPT_EXT_FIX ${JAVA_OPT}"

if [[ "${MODE}" == "standalone" ]]; then
    echo "nacos is starting with standalone"
else
    echo "nacos is starting with cluster"
fi

if [[ "$JAVA_OPT_EXT_FIX" == "" ]]; then
  "$JAVA" ${JAVA_OPT} nacos.nacos
else
  "$JAVA" "$JAVA_OPT_EXT_FIX" ${JAVA_OPT} nacos.nacos 
fi
```

`SOURCE/nacos-standalone.service`

```bash
[Unit]
Description=Nacos Standalone Server
After=syslog.target
After=network.target
#Requires=mysql.service
#Requires=mariadb.service

[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
RestartSec=2s
Type=simple
User=nacos
WorkingDirectory=/app/soft/nacos
ExecStart=/usr/bin/bash /app/soft/nacos/bin/nacos.sh  -m standalone
Restart=always

[Install]
WantedBy=multi-user.target
```

`SPECS/nacos.spec`

```bash
Name:           nacos
Version:        2.0.4
Release:        1%{?dist}
Summary:        Adoptium OpenJDK 11 Software
BuildRoot:      %{_tmppath}/%{name}-buildroot                
License:         Apache-2.0
URL:            https://github.com/alibaba/nacos
Source0:        https://github.com/alibaba/nacos/releases/download/2.0.4/nacos-server-%{version}.tar.gz
Source1:        nacos-boot.sh
Source2:        nacos-standalone.service
Requires:       openjdk-8 systemd
BuildArch:      noarch
%description
Alibaba Nacos


%prep

rm -rf %{_builddir}/%{name}
mkdir -p %{_builddir}/%{name}
tar zxf %{_sourcedir}/nacos-server-%{version}.tar.gz -C %{_builddir}/%{name}
cp %{_sourcedir}/nacos-boot.sh %{_builddir}/%{name}/nacos-boot.sh
cp %{_sourcedir}/nacos-standalone.service %{_builddir}/%{name}/nacos-standalone.service

%build

%install
mkdir -p %{buildroot}/app/soft/nacos
cp -r %{_builddir}/%{name}/nacos/*  %{buildroot}/app/soft/nacos
cp %{_builddir}/%{name}/nacos-boot.sh %{buildroot}/app/soft/nacos/bin/nacos.sh
mkdir -p %{buildroot}/lib/systemd/system
cp %{_builddir}/%{name}/nacos-standalone.service %{buildroot}/lib/systemd/system/nacos-standalone.service
chmod 0755  %{buildroot}/app/soft/nacos/bin/*

%files
%dir /app/soft/nacos
 /app/soft/nacos/*
 /lib/systemd/system/nacos-standalone.service


%changelog
* Thu May 12 14:58:51 CST 2022 OpenEdgn <ExplodingFKL@gmail.com>
- 

%pre
/usr/bin/getent passwd nacos || useradd --no-create-home --home-dir /app/soft/nacos --shell /bin/bash --no-user-group nacos

%post
systemctl daemon-reload
chown nacos -R /app/soft/nacos

%postun
systemctl daemon-reload
/usr/sbin/userdel nacos

%clean
rm -rf %{_builddir}/%{name}
```

打包命令：

```bash
rpmbuild --undefine=_disable_source_fetch  -ba SPECS/nacos.spec
```

