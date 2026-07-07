import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos'

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'
const EVENT_SCREEN_TAP = 'BLANK_APP_SCREEN_TAP'

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('viewId') viewId: string = "";
  @StorageLink('proximityCovered') proximityCovered: boolean = false;
  @State pageIndex: number = 0;

  private nextPage(): void {
    if (this.proximityCovered) {
      return;
    }

    this.pageIndex = (this.pageIndex + 1) % 5;
    this.context.eventHub.emit(EVENT_SCREEN_TAP);
  }

  @Builder
  private screenContent() {
    if (this.pageIndex === 0) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
    } else if (this.pageIndex === 1) {
      this.threeDMarkScreen($rawfile('flutter_assets/assets/screens/3dmark_1.jpg'))
    } else if (this.pageIndex === 2) {
      this.threeDMarkScreen($rawfile('flutter_assets/assets/screens/3dmark_2.jpg'))
    } else if (this.pageIndex === 3) {
      this.threeDMarkScreen($rawfile('flutter_assets/assets/screens/3dmark_3.jpg'))
    } else {
      this.stretchedScreen($rawfile('flutter_assets/assets/screens/geekbench.jpg'))
    }
  }

  @Builder
  private threeDMarkScreen(source: Resource) {
    Stack() {
      Image(source)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .backgroundColor(Color.Black)
  }

  @Builder
  private stretchedScreen(source: Resource) {
    Image(source)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Fill)
      .backgroundColor(Color.White)
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.viewId })
        .width(1)
        .height(1)
        .opacity(0)
        .position({ x: -10, y: -10 })

      this.screenContent()

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.nextPage()
        })

      if (this.proximityCovered) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onClick(() => {
      this.nextPage()
    })
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}
