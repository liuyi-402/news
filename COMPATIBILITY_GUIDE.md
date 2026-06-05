# HarmonyOS 设备兼容性完整解决方案

## 🔍 问题诊断

错误信息：`compatibleSdkVersion and releaseType of the app do not match the apiVersion and releaseType on the device`

### 根本原因
1. **API版本不匹配**：设备API ≠ 应用配置API
2. **ReleaseType不匹配**：设备类型（Beta/Release）与应用构建模式不匹配

---

## 🛠️ 解决方案

### 方案1：使用诊断页面（推荐）

**步骤：**
1. 在DevEco Studio中运行应用
2. 如果应用无法启动，修改启动页面为诊断页面：

修改 `entry/src/main/resources/base/profile/main_pages.json`：
```json
{
  "src": [
    "pages/DeviceDiagnostic",
    "pages/Index"
  ]
}
```

3. 运行应用，查看设备实际API版本
4. 根据诊断结果调整配置

---

### 方案2：手动配置（快速）

根据下表选择对应配置：

| 设备类型 | API版本 | 配置文件 |
|---------|---------|---------|
| HarmonyOS 4.0 | API 10 | build-profile-API10.json5 |
| HarmonyOS 4.1 | API 11 | build-profile-API11.json5 |
| HarmonyOS 5.0 | API 12 | build-profile-API12.json5 |
| HarmonyOS Next | API 22 | build-profile-API22.json5 |

**使用方法：**
```bash
# 例如：设备是API 12
# 复制对应配置
cp build-profile-API12.json5 build-profile.json5

# 重新构建
hvigorw clean
hvigorw assembleHap
```

---

### 方案3：DevEco Studio查看设备信息

**操作步骤：**
1. 打开 DevEco Studio
2. 点击 **Tools → Device Manager**
3. 选择你的设备
4. 查看右侧面板：
   - **API Version**: 记录数字
   - **System Type**: Beta 或 Release
   - **Device Type**: Phone/Emulator

---

## 📋 配置文件详解

### API 10 配置 (HarmonyOS 4.0)
```json5
{
  "app": {
    "products": [{
      "targetSdkVersion": "4.0.0(10)",
      "compatibleSdkVersion": "4.0.0(10)",
      "runtimeOS": "HarmonyOS",
      "buildOption": {
        "strictMode": {
          "caseSensitiveCheck": true,
          "useNormalizedOHMUrl": false
        }
      }
    }]
  }
}
```

### API 11 配置 (HarmonyOS 4.1) - 当前配置
```json5
{
  "app": {
    "products": [{
      "targetSdkVersion": "4.1.0(11)",
      "compatibleSdkVersion": "4.1.0(11)",
      "runtimeOS": "HarmonyOS",
      "buildOption": {
        "strictMode": {
          "caseSensitiveCheck": true,
          "useNormalizedOHMUrl": false
        }
      }
    }]
  }
}
```

### API 12 配置 (HarmonyOS 5.0)
```json5
{
  "app": {
    "products": [{
      "targetSdkVersion": "5.0.0(12)",
      "compatibleSdkVersion": "5.0.0(12)",
      "runtimeOS": "HarmonyOS",
      "buildOption": {
        "strictMode": {
          "caseSensitiveCheck": true,
          "useNormalizedOHMUrl": true
        }
      }
    }]
  }
}
```

### API 22 配置 (HarmonyOS Next)
```json5
{
  "app": {
    "products": [{
      "targetSdkVersion": "6.0.2(22)",
      "compatibleSdkVersion": "6.0.2(22)",
      "runtimeOS": "HarmonyOS",
      "buildOption": {
        "strictMode": {
          "caseSensitiveCheck": true,
          "useNormalizedOHMUrl": true
        }
      }
    }]
  }
}
```

---

## 🎯 ReleaseType 匹配

### 问题：设备Beta/Release类型不匹配

**解决方案：**

| 设备类型 | 构建模式 | 操作 |
|---------|---------|------|
| Beta | Debug | DevEco Studio → Build → Select Build Variant → debug |
| Release | Release | DevEco Studio → Build → Select Build Variant → release |

**在DevEco Studio中切换构建模式：**
1. 点击左侧 **Build Variants** 标签
2. 选择对应的构建模式（debug/release）
3. 重新构建应用

---

## 🚀 快速修复流程

### 步骤1：确认设备API版本
```
方法A：使用诊断页面（已创建）
方法B：DevEco Studio → Device Manager
方法C：查看设备系统信息
```

### 步骤2：选择对应配置
```
根据设备API版本，选择对应的build-profile配置
```

### 步骤3：匹配ReleaseType
```
Beta设备 → 使用debug构建
Release设备 → 使用release构建
```

### 步骤4：重新构建运行
```
清理项目 → 重新构建 → 运行应用
```

---

## 💡 常见设备配置参考

### 华为手机系列
- **Mate 60 / P60 系列**: API 11 (HarmonyOS 4.1)
- **Mate 70 / P70 系列**: API 12 (HarmonyOS 5.0)
- **Nova 系列**: API 11 或 API 12（取决于系统版本）

### 模拟器
- **Phone Emulator**: 创建时选择的API版本
- **Tablet Emulator**: 创建时选择的API版本

### HarmonyOS Next设备
- **Developer Preview**: API 22
- **Beta版本**: API 22 (Beta)

---

## ❓ 故障排查

### Q1: 仍然报错怎么办？
**A:** 请提供以下信息：
1. 设备API版本（从诊断页面获取）
2. 设备ReleaseType（Beta/Release）
3. 完整错误信息
4. DevEco Studio版本

### Q2: 如何查看当前配置？
**A:** 查看 `build-profile.json5` 文件中的：
- `targetSdkVersion`
- `compatibleSdkVersion`

### Q3: 构建失败怎么办？
**A:** 检查：
1. `useNormalizedOHMUrl` 设置（API < 12 必须为 false）
2. SDK是否正确安装
3. 项目依赖是否完整

---

## 📞 需要帮助？

如果以上方案都无法解决，请提供：
1. **设备信息截图**（Device Manager截图）
2. **诊断页面截图**（运行诊断页面）
3. **完整错误日志**

我会根据具体信息提供定制化解决方案。
