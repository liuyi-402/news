# HarmonyOS 配置交互式选择工具

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HarmonyOS 设备兼容性配置工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "请选择你的设备类型：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. HarmonyOS 4.0 设备 (API 10)" -ForegroundColor White
Write-Host "   - 旧版HarmonyOS手机" -ForegroundColor Gray
Write-Host ""
Write-Host "2. HarmonyOS 4.1 设备 (API 11) [当前配置]" -ForegroundColor Green
Write-Host "   - 华为Mate 60/P60系列" -ForegroundColor Gray
Write-Host "   - 大多数已发布的HarmonyOS手机" -ForegroundColor Gray
Write-Host ""
Write-Host "3. HarmonyOS 5.0 设备 (API 12)" -ForegroundColor White
Write-Host "   - 华为Mate 70/P70系列" -ForegroundColor Gray
Write-Host "   - 最新HarmonyOS手机" -ForegroundColor Gray
Write-Host ""
Write-Host "4. HarmonyOS Next 设备 (API 22)" -ForegroundColor White
Write-Host "   - HarmonyOS Next开发者预览版" -ForegroundColor Gray
Write-Host "   - Beta测试设备" -ForegroundColor Gray
Write-Host ""
Write-Host "5. 不确定，查看设备信息" -ForegroundColor Yellow
Write-Host ""
Write-Host "6. 退出" -ForegroundColor Red
Write-Host ""

$choice = Read-Host "请输入选项 (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "正在切换到 API 10 配置..." -ForegroundColor Yellow
        & ".\switch-api.ps1" -ApiVersion 10
    }
    "2" {
        Write-Host ""
        Write-Host "当前已是 API 11 配置" -ForegroundColor Green
        Write-Host "如果仍有问题，请检查：" -ForegroundColor Yellow
        Write-Host "1. 设备是否为Beta版本（需要使用debug构建）" -ForegroundColor White
        Write-Host "2. 设备是否为Release版本（需要使用release构建）" -ForegroundColor White
    }
    "3" {
        Write-Host ""
        Write-Host "正在切换到 API 12 配置..." -ForegroundColor Yellow
        & ".\switch-api.ps1" -ApiVersion 12
    }
    "4" {
        Write-Host ""
        Write-Host "正在切换到 API 22 配置..." -ForegroundColor Yellow
        & ".\switch-api.ps1" -ApiVersion 22
    }
    "5" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "查看设备信息的方法：" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "方法1：DevEco Studio" -ForegroundColor Yellow
        Write-Host "1. 打开 DevEco Studio" -ForegroundColor White
        Write-Host "2. Tools → Device Manager" -ForegroundColor White
        Write-Host "3. 选择设备查看 API Version" -ForegroundColor White
        Write-Host ""
        Write-Host "方法2：运行诊断页面" -ForegroundColor Yellow
        Write-Host "1. 运行应用（已配置为诊断页面启动）" -ForegroundColor White
        Write-Host "2. 查看显示的设备API版本" -ForegroundColor White
        Write-Host "3. 根据显示的API版本重新选择" -ForegroundColor White
        Write-Host ""
        Write-Host "方法3：设备设置" -ForegroundColor Yellow
        Write-Host "1. 打开设备设置" -ForegroundColor White
        Write-Host "2. 关于手机 → 系统版本" -ForegroundColor White
        Write-Host "3. 查看HarmonyOS版本号" -ForegroundColor White
        Write-Host ""
        
        $retry = Read-Host "是否重新选择？(Y/N)"
        if ($retry -eq "Y" -or $retry -eq "y") {
            & ".\config-tool.ps1"
        }
    }
    "6" {
        Write-Host "退出" -ForegroundColor Yellow
        exit
    }
    default {
        Write-Host "无效选项，请重新运行脚本" -ForegroundColor Red
    }
}
