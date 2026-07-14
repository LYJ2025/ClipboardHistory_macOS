# 剪贴板历史（macOS 版）

一个用于 macOS 的剪贴板历史管理软件，支持文字和图片记录、搜索、置顶、删除、全局快捷键等功能。

## 功能特性

- 自动记录文字和图片剪贴板内容
- 按时间降序排列，支持置顶
- 搜索历史记录
- 点击卡片复制到剪贴板
- 删除时二次确认
- 60 天自动清理
- 开机自启动
- 自定义全局快捷键（显示/隐藏窗口）
- 背景透明度调节（液态玻璃效果）
- 顶部菜单栏图标

## 安装使用

1. 下载 `ClipboardHistory.app.zip`
2. 解包后拖到 **应用程序**(application) 文件夹
3. 双击打开

首次运行可能需要到「系统设置 → 隐私与安全性」中允许运行。

## 数据存储

所有数据保存在本地：

```
~/Library/Application Support/ClipboardHistory/
├── history.json
└── images/
```

## 本地构建

```bash
swift build
./build_app.sh
```
