# serv00-webdav-go
【免费webdav】在 serv00上部署了 WebDAV(go) 服务，并通过 PM2 保证其持久运行
---

# WebDAV-go 安装指南

这是一个基于 FreeBSD 的 WebDAV-go 自动安装和配置脚本项目，使用 [PM2](https://pm2.keymetrics.io/) 来管理 WebDAV 服务，确保系统重启后自动恢复服务。

## 项目简介

此项目旨在简化 WebDAV-go 的安装流程，并通过 PM2 来托管 WebDAV 服务。它允许您快速设置一个运行在 FreeBSD 上的 WebDAV 文件共享服务。

## 特性

- 使用简单的脚本自动安装 WebDAV-go
- 支持 FreeBSD 系统的 PM2 管理工具，确保服务自动重启
- 允许自定义端口号、用户名和密码
- 自动生成网页信息，帮助用户快速访问 WebDAV

## 系统要求

- FreeBSD 系统
- FreeBSD 用户权限，无需 root 权限
- 需要安装 [Go](https://golang.org/) 语言环境
- 安装 [npm](https://www.npmjs.com/) 用于安装 PM2

## 安装步骤

### 1. 克隆项目仓库

首先，克隆 GitHub 仓库到你的 FreeBSD 用户目录：

```bash
git clone https://github.com/aigem/serv00-webdav-go.git
cd serv00-webdav-go && chmod +x go-webdav.sh && sh go-webdav.sh
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
/usr/home/你的用户名/webdav/gowebdav.yaml
```

你可以手动编辑此文件来更改 WebDAV 的配置，例如修改访问目录、权限、日志格式等。

### 配置示例

```yaml
address: 0.0.0.0
port: 8080
prefix: /
directory: /usr/home/你的用户名/webdav
permissions: R
users:
  - username: user
    password: password
```

## 参考资源

- [Go](https://golang.org/)
- [PM2](https://pm2.keymetrics.io/)
- [WebDAV-go 项目](https://github.com/hacdias/webdav)

---
