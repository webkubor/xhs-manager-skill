---
name: xhs-manager-skill
description: "XHS (Little Red Book) Multi-Account Management Protocol. Optimized for automated publishing, profile isolation, and matrix operations."
version: 1.0.0
author: "司南烛 (Si Nan Zhu)"
license: "MIT"
keywords: ["xhs", "multi-account", "automation", "matrix-ops"]
allowed-tools: ["run_command", "list_dir", "grep_search"]
user-invocable: true
---

# 📢 XHS Manager Skill (小红书矩阵管理大师)

> **定位**: 小红书多账户全自动运营中枢。负责账号隔离、内容分发、评论互动与矩阵数据巡检。

## 📖 核心职责 (Core Responsibilities)

### 1. 账号物理隔离 (Profile Isolation)
- **多开管理**: 基于 Playwright Browser Context 实现多账号登录隔离，每个账号拥有独立 Cookie 与 LocalStorage。
- **登录维护**: 自动检测登录状态，过期后触发扫码或 Token 自动注入。

### 2. 自动化矩阵发布 (Matrix Publishing)
- **跨账号分发**: 支持一键将图文/视频素材根据预设模板分发至不同账号。
- **智能排期**: 根据各账号历史表现与权重自动安排发布时段。

### 3. 数据与互动巡检
- **自动收割**: 每日自动拉取各账号的点赞、收藏、评论及粉丝变动，生成 Lark 简报。
- **神回复助手**: 根据老爹的语气，自动回复各账号下方的热门评论。

## 🧱 详细内核
- 多账号隔离指南：[references/multi-account-isolation.md](references/multi-account-isolation.md)
- 自动发布 SOP：[references/publish-sop.md](references/publish-sop.md)
