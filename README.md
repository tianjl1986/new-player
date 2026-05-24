<img width="1646" height="1090" alt="image" src="https://github.com/user-attachments/assets/6e85532c-04c1-4840-8663-9dc1e81a851c" />

# 💽 Tin Player iOS

Tin Player 是一款向黄金模拟时代致敬的现代音乐播放应用。该项目摒弃了千篇一律的扁平化设计，在“极简 UI 容器”与“重度工业机械部件”之间找到了绝佳的视觉平衡点。

我们通过像素级的打磨与严谨的 SwiftUI / HTML5 代码转换，在移动端屏幕上重构了真实的黑胶唱机物理交互体验，打造出一套既具备复古机械浪漫，又符合现代交互逻辑的数字艺术品。

## ✨ 核心亮点

* **双轨制视觉体系 (Dual-Track Aesthetics)**：克制且呼吸感极强的“轻量级新拟态 (Neumorphism)”UI 容器，结合极具压迫感与精密度的“重度拟物 (Heavy Skeuomorphism)”部件（拉丝枪灰底盘、金属镀铬唱臂）。
* **工业级物理状态机 (Industrial-Grade Logic)**：所有的按钮（如 33/45 转速键、推子）均具备真实的物理 Z 轴高度，包含“凸起”到“深坑”的光影变换与 LED 反馈。
* **跨平台代码架构**：
  * `Sources/` - 基于原生 SwiftUI `Path` 与渐变算法重构的高保真 iOS 界面。
  * `preview/` - 基于 Web 引擎实现的高精度 CSS/SVG 跨平台预览沙盒。

## 🚀 本地运行

**iOS 开发者 (macOS / Xcode)**：
1. 使用 Xcode 打开本文件夹（识别为 Swift Package 或直接引入 Xcode Project）。
2. 选择目标模拟器或连接 iPhone 真机。
3. 点击 `Run` 即可编译运行。

**Web 预览测试 (跨平台)**：
1. 采用浏览器打开 `preview/index.html`。
2. 即可体验 1:1 还原的 UI 布局体系与 CSS 物理动画逻辑。

## 🎨 设计规范

本项目依托于独创的《Tin Player 全案设计规范》，核心网格基于 iPhone 14 Pro (393x852) 构筑，全局 UI 色彩、文字排版体系均遵循严格的参数化与变量化 (Design Tokens) 管理。

---
*Crafted with precision for the love of mechanical interactions.*
