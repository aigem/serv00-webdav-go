# serv00-webdav-go
【免费webdav】在 serv00上部署了 WebDAV(go) 服务，并通过 PM2 保证其持久运行
---

## 项目简介

此项目旨在简化 WebDAV 的安装流程，并通过 PM2 来托管 WebDAV 服务。它允许您一键获得 WebDAV 文件共享服务【免费】。

## 特性

- 使用简单的脚本自动安装 WebDAV-go
- 支持 FreeBSD 系统的 PM2 管理工具，确保服务自动重启
- 允许自定义端口号、用户名和密码
- 自动生成网页信息，帮助用户快速访问 WebDAV

## 系统要求

- [Serv00免费主机](https://www.serv00.com/)

## 安装步骤

### 1. 克隆项目仓库

首先，克隆 GitHub 仓库到你的 FreeBSD 用户目录：

```bash
git clone https://github.com/aigem/serv00-webdav-go.git
cd serv00-webdav-go && chmod +x go-webdav.sh
./go-webdav.sh
```

./install_wsgidav.sh
### 2. 使用 `go-webdav.sh` 脚本安装 WebDAV-go

运行脚本开始安装和配置 WebDAV-go 服务：

```bash
bash go-webdav.sh
```

### 3. 安装过程中的用户交互

在安装过程中，脚本将引导你进行以下设置：

- **选择端口号**：你可以选择一个已经开放的端口号，或者让脚本自动为你开放一个新端口。
- **设置 WebDAV 用户名和密码**：提供自定义用户名和密码来保护 WebDAV 资源访问。
- **网站指向**：脚本会询问是否重置你的网站，并指向 WebDAV 服务的端口。

### 4. 启动 WebDAV-go

脚本完成后，WebDAV-go 服务会自动使用 PM2 启动。服务将托管在你指定的端口上，并可以通过 `pm2` 管理。

查看 PM2 运行的服务列表：

```bash
pm2 list
```

### 5. 自动生成的 `info.html`

脚本会自动生成一个 `info.html` 文件，位于你的公开网站目录中。你可以通过访问 `https://<你的用户名>.serv00.net/info.html` 来查看 WebDAV 服务的详细信息和访问链接。

### 6. PM2 进程管理

- **查看服务日志**：

  ```bash
  pm2 logs
  ```

- **重启服务**：

  ```bash
  pm2 restart all
  ```

- **停止服务**：

  ```bash
  pm2 stop webdav
  ```

- **在系统重启后恢复 PM2 进程**：

  ```bash
  pm2 resurrect
  ```

## 自定义配置

脚本会生成一个默认的 WebDAV 配置文件 `gowebdav.yaml`，它存放在以下路径：

```bash
/usr/home/你的用户名/gowebdav.yaml
```

你可以手动编辑此文件来更改 WebDAV 的配置，例如修改访问目录、权限、日志格式等。



