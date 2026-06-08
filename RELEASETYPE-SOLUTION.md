# ReleaseType 匹配解决方案

## 问题：releaseType 不匹配

### 设备是 Beta 版本

**症状：** 设备系统是Beta/测试版

**解决方案：使用 debug 构建**

#### 方法1：DevEco Studio切换
```
1. 点击左侧 Build Variants 标签
2. 选择 entry → debug
3. 重新运行应用
```

#### 方法2：命令行构建
```powershell
hvigorw clean
hvigorw assembleHap --mode debug
```

---

### 设备是 Release 版本

**症状：** 设备系统是正式发布版

**解决方案：使用 release 构建**

#### 方法1：DevEco Studio切换
```
1. 点击左侧 Build Variants 标签
2. 选择 entry → release
3. 重新运行应用
```

#### 方法2：命令行构建
```powershell
hvigorw clean
hvigorw assembleHap --mode release
```

---

## 如何判断设备类型？

### 方法1：DevEco Studio
```
Tools → Device Manager → 选择设备 → 查看System Type
```

### 方法2：设备设置
```
设置 → 关于手机 → 系统版本
- 如果版本号包含 "Beta" → Beta版本
- 如果版本号是纯数字 → Release版本
```

### 方法3：运行诊断页面
```
应用启动后会显示设备ReleaseType
```

---

## 快速解决方案

### 先尝试 debug 构建（推荐）
```powershell
hvigorw clean
hvigorw assembleHap --mode debug
```

### 如果仍失败，尝试 release 构建
```powershell
hvigorw clean
hvigorw assembleHap --mode release
```

---

## 当前配置

- API版本：API 10 (通用兼容)
- 构建模式：需要根据设备类型选择
- 下一步：根据设备Beta/Release类型选择构建模式
