import deviceInfo from '@ohos.deviceInfo'

@Entry
@Component
struct DeviceDiagnostic {
  @State deviceApiVersion: string = '检测中...'
  @State deviceReleaseType: string = '检测中...'
  @State deviceSdkVersion: string = '检测中...'
  @State deviceBrand: string = '检测中...'
  @State deviceModel: string = '检测中...'
  @State appConfig: string = '检测中...'
  @State matchStatus: string = '检测中...'
  @State isMatched: boolean = false

  aboutToAppear() {
    this.detectDeviceInfo()
  }

  detectDeviceInfo() {
    try {
      // 获取设备信息
      this.deviceApiVersion = deviceInfo.sdkApiVersion.toString()
      this.deviceReleaseType = deviceInfo.osReleaseType || 'Unknown'
      this.deviceSdkVersion = deviceInfo.sdkApiVersion.toString()
      
      // 获取设备品牌和型号
      this.deviceBrand = deviceInfo.brand || 'Unknown'
      this.deviceModel = deviceInfo.marketName || 'Unknown'
      
      // 应用配置信息（从build-profile.json5）
      this.appConfig = 'API 11 (4.1.0)'
      
      // 检查匹配状态
      const deviceApi = parseInt(this.deviceApiVersion)
      const appApi = 11 // 当前应用配置的API
      
      if (deviceApi === appApi) {
        this.matchStatus = '✅ API版本匹配'
        this.isMatched = true
      } else if (deviceApi > appApi) {
        this.matchStatus = `⚠️ 设备API(${deviceApi}) > 应用API(${appApi})，建议升级应用配置`
        this.isMatched = false
      } else {
        this.matchStatus = `❌ 设备API(${deviceApi}) < 应用API(${appApi})，需要降低应用配置`
        this.isMatched = false
      }
      
      // 检查releaseType
      const isBeta = this.deviceReleaseType.includes('Beta')
      if (isBeta) {
        this.matchStatus += '\n⚠️ 设备是Beta版本，请使用debug构建模式'
      } else {
        this.matchStatus += '\n✅ 设备是Release版本'
      }
      
    } catch (error) {
      this.deviceApiVersion = '获取失败'
      this.deviceReleaseType = '获取失败'
      console.error('Device detection failed:', error)
    }
  }

  build() {
    Column() {
      // 标题
      Text('设备兼容性诊断')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // 设备信息卡片
      Column() {
        Text('📱 设备信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 15 })

        this.InfoRow('设备品牌', this.deviceBrand)
        this.InfoRow('设备型号', this.deviceModel)
        this.InfoRow('API版本', this.deviceApiVersion)
        this.InfoRow('Release类型', this.deviceReleaseType)
        this.InfoRow('SDK版本', this.deviceSdkVersion)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 应用配置卡片
      Column() {
        Text('⚙️ 应用配置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 15 })

        this.InfoRow('目标API', this.appConfig)
        this.InfoRow('兼容API', this.appConfig)
        this.InfoRow('构建模式', 'Debug')
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 匹配状态卡片
      Column() {
        Text('🔍 兼容性检查')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 15 })

        Text(this.matchStatus)
          .fontSize(16)
          .fontColor(this.isMatched ? '#4CAF50' : '#FF5722')
          .lineHeight(24)
      }
      .width('90%')
      .padding(20)
      .backgroundColor(this.isMatched ? '#E8F5E9' : '#FFEBEE')
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 操作按钮
      Button('重新检测')
        .width('90%')
        .height(50)
        .backgroundColor('#2196F3')
        .onClick(() => {
          this.detectDeviceInfo()
        })
        .margin({ bottom: 15 })

      Button('返回主页')
        .width('90%')
        .height(50)
        .backgroundColor('#757575')
        .onClick(() => {
          // 返回主页逻辑
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label + ':')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('40%')

      Text(value)
        .fontSize(16)
        .fontColor('#666666')
        .width('60%')
    }
    .width('100%')
    .margin({ bottom: 10 })
  }
}
