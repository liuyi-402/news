import { CommonConstants } from '../common/CommonConstants';

/**
 * 登录/注册页面
 * 支持手机号验证码登录和第三方登录
 */
@Component
export struct LoginPage {
  @State phoneNumber: string = '';
  @State verifyCode: string = '';
  @State isAgree: boolean = false;
  @State isLoading: boolean = false;
  @State countdown: number = 0;
  @State isRegister: boolean = false;
  
  build() {
    Column() {
      // 顶部栏
      this.HeaderBar()
      
      Scroll() {
        Column({ space: CommonConstants.SPACING.XL }) {
          // Logo和标题
          this.LogoSection()
          
          // 登录表单
          this.LoginForm()
          
          // 协议同意
          this.AgreementSection()
          
          // 登录按钮
          this.LoginButton()
          
          // 第三方登录
          this.ThirdPartyLogin()
        }
        .width('100%')
        .padding(CommonConstants.SPACING.XXL)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.COLORS.WHITE)
  }
  
  @Builder
  HeaderBar() {
    Row({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.ic_close'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.onClose();
        })
      
      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .height(CommonConstants.HEADER_HEIGHT)
    .padding({ left: CommonConstants.SPACING.LG, right: CommonConstants.SPACING.LG })
  }
  
  @Builder
  LogoSection() {
    Column({ space: CommonConstants.SPACING.MD }) {
      Image($r('app.media.app_logo'))
        .width(80)
        .height(80)
      
      Text(this.isRegister ? '注册账号' : '欢迎回来')
        .fontSize(CommonConstants.FONT_SIZE.TITLE)
        .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
      
      Text('新闻资讯，尽在掌握')
        .fontSize(CommonConstants.FONT_SIZE.BODY)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
    }
    .width('100%')
    .margin({ top: CommonConstants.SPACING.XXL })
  }
  
  @Builder
  LoginForm() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 手机号输入
      Row({ space: CommonConstants.SPACING.SM }) {
        Text('+86')
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
        
        Divider()
          .vertical(true)
          .height(20)
          .color(CommonConstants.COLORS.DIVIDER)
        
        TextInput({ placeholder: '请输入手机号', text: this.phoneNumber })
          .layoutWeight(1)
          .height(48)
          .backgroundColor(Color.Transparent)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
          .type(InputType.Number)
          .maxLength(11)
          .onChange((value: string) => {
            this.phoneNumber = value;
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.MD })
      .backgroundColor('#FFF5F5F5')
      .borderRadius(CommonConstants.BORDER_RADIUS.MD)
      
      // 验证码输入
      Row({ space: CommonConstants.SPACING.SM }) {
        TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
          .layoutWeight(1)
          .height(48)
          .backgroundColor(Color.Transparent)
          .fontSize(CommonConstants.FONT_SIZE.BODY)
          .fontColor(CommonConstants.COLORS.TEXT_PRIMARY)
          .placeholderColor(CommonConstants.COLORS.TEXT_HINT)
          .type(InputType.Number)
          .maxLength(6)
          .onChange((value: string) => {
            this.verifyCode = value;
          })
        
        // 获取验证码按钮
        Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(this.countdown > 0 ? CommonConstants.COLORS.TEXT_HINT : CommonConstants.COLORS.PRIMARY)
          .backgroundColor(Color.Transparent)
          .height(36)
          .padding({ left: 12, right: 12 })
          .enabled(this.countdown === 0 && this.phoneNumber.length === 11)
          .onClick(() => {
            this.getVerifyCode();
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: CommonConstants.SPACING.MD, right: CommonConstants.SPACING.SM })
      .backgroundColor('#FFF5F5F5')
      .borderRadius(CommonConstants.BORDER_RADIUS.MD)
    }
    .width('100%')
  }
  
  @Builder
  AgreementSection() {
    Row({ space: CommonConstants.SPACING.SM }) {
      Checkbox()
        .select(this.isAgree)
        .selectedColor(CommonConstants.COLORS.PRIMARY)
        .onChange((value: boolean) => {
          this.isAgree = value;
        })
      
      Column() {
        Row({ space: 4 }) {
          Text('我已阅读并同意')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          
          Text('《用户协议》')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.PRIMARY)
            .onClick(() => {
              // TODO: 查看用户协议
            })
          
          Text('和')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
          
          Text('《隐私政策》')
            .fontSize(CommonConstants.FONT_SIZE.CAPTION)
            .fontColor(CommonConstants.COLORS.PRIMARY)
            .onClick(() => {
              // TODO: 查看隐私政策
            })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
  
  @Builder
  LoginButton() {
    Column({ space: CommonConstants.SPACING.MD }) {
      // 登录按钮
      Button(this.isRegister ? '注册' : '登录')
        .width('100%')
        .height(48)
        .fontSize(CommonConstants.FONT_SIZE.SUBTITLE)
        .fontColor(CommonConstants.COLORS.WHITE)
        .backgroundColor(this.canLogin() ? CommonConstants.COLORS.PRIMARY : CommonConstants.COLORS.TEXT_HINT)
        .borderRadius(CommonConstants.BORDER_RADIUS.MD)
        .enabled(this.canLogin() && !this.isLoading)
        .onClick(() => {
          this.onLogin();
        })
      
      // 切换登录/注册
      Row() {
        Text(this.isRegister ? '已有账号？' : '没有账号？')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
        
        Text(this.isRegister ? '立即登录' : '立即注册')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.PRIMARY)
          .onClick(() => {
            this.isRegister = !this.isRegister;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
  }
  
  @Builder
  ThirdPartyLogin() {
    Column({ space: CommonConstants.SPACING.LG }) {
      // 分割线
      Row({ space: CommonConstants.SPACING.MD }) {
        Divider()
          .color(CommonConstants.COLORS.DIVIDER)
          .layoutWeight(1)
        
        Text('其他登录方式')
          .fontSize(CommonConstants.FONT_SIZE.CAPTION)
          .fontColor(CommonConstants.COLORS.TEXT_HINT)
        
        Divider()
          .color(CommonConstants.COLORS.DIVIDER)
          .layoutWeight(1)
      }
      .width('100%')
      
      // 第三方登录图标
      Row({ space: CommonConstants.SPACING.XXL }) {
        // 微信登录
        this.ThirdPartyItem($r('app.media.ic_wechat'), '微信', () => {
          this.onWechatLogin();
        })
        
        // QQ登录
        this.ThirdPartyItem($r('app.media.ic_qq'), 'QQ', () => {
          this.onQQLogin();
        })
        
        // 微博登录
        this.ThirdPartyItem($r('app.media.ic_weibo'), '微博', () => {
          this.onWeiboLogin();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .margin({ top: CommonConstants.SPACING.XL })
  }
  
  @Builder
  ThirdPartyItem(icon: Resource, name: string, onClick: () => void) {
    Column({ space: CommonConstants.SPACING.SM }) {
      Image(icon)
        .width(48)
        .height(48)
      
      Text(name)
        .fontSize(CommonConstants.FONT_SIZE.CAPTION)
        .fontColor(CommonConstants.COLORS.TEXT_SECONDARY)
    }
    .onClick(() => onClick())
  }
  
  // ==================== 事件处理 ====================
  
  private canLogin(): boolean {
    return this.phoneNumber.length === 11 && 
           this.verifyCode.length === 6 && 
           this.isAgree;
  }
  
  private onClose() {
    // TODO: 关闭登录页
    console.log('关闭登录页');
  }
  
  private getVerifyCode() {
    if (this.phoneNumber.length !== 11) {
      return;
    }
    
    // 模拟发送验证码
    console.log(`发送验证码到: ${this.phoneNumber}`);
    
    // 开始倒计时
    this.countdown = 60;
    const timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(timer);
      }
    }, 1000);
  }
  
  private onLogin() {
    if (!this.canLogin()) {
      return;
    }
    
    this.isLoading = true;
    
    // 模拟登录
    setTimeout(() => {
      this.isLoading = false;
      console.log(`登录成功: ${this.phoneNumber}`);
      // TODO: 跳转到主页
    }, 2000);
  }
  
  private onWechatLogin() {
    // TODO: 微信登录
    console.log('微信登录');
  }
  
  private onQQLogin() {
    // TODO: QQ登录
    console.log('QQ登录');
  }
  
  private onWeiboLogin() {
    // TODO: 微博登录
    console.log('微博登录');
  }
}
