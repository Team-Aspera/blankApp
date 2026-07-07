
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import MethodChannel, {
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import sensor from '@ohos.sensor';
import window from '@ohos.window';

const DEVICE_CHANNEL = 'blank_app/device';
const EVENT_SCREEN_TAP = 'BLANK_APP_SCREEN_TAP';
const PROXIMITY_COVERED_KEY = 'proximityCovered';

export default class EntryAbility extends FlutterAbility {
  private deviceChannel: MethodChannel | null = null;
  private appWindow: window.Window | null = null;
  private proximityRegistered: boolean = false;
  private proximityNear: boolean = false;
  private screenTapRegistered: boolean = false;
  private screenTapCallback = (): void => {
    this.deviceChannel?.invokeMethod('nextPage', null);
  };
  private proximityCallback = (data: sensor.ProximityResponse): void => {
    const isNear = data.distance <= 0;
    if (isNear === this.proximityNear) {
      return;
    }

    this.proximityNear = isNear;
    AppStorage.setOrCreate(PROXIMITY_COVERED_KEY, isNear);
    this.deviceChannel?.invokeMethod('proximityChanged', isNear);
    this.setProximityDisplayState(isNear);
  };

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    this.deviceChannel = new MethodChannel(flutterEngine.getDartExecutor(), DEVICE_CHANNEL);
    this.deviceChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        if (call.method === 'enableProximityScreenOff') {
          result.success(this.enableProximitySensor());
          return;
        }

        if (call.method === 'disableProximityScreenOff') {
          this.disableProximitySensor();
          result.success(null);
          return;
        }

        result.notImplemented();
      }
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate(PROXIMITY_COVERED_KEY, false);
    super.onWindowStageCreate(windowStage);
    this.registerScreenTapCallback();
    this.enableProximitySensor();
    this.appWindow = windowStage.getMainWindowSync();
    this.applyFullscreen();
  }

  onForeground(): void {
    super.onForeground();
    this.enableProximitySensor();
    this.applyFullscreen();
  }

  onBackground(): void {
    this.disableProximitySensor();
    super.onBackground();
  }

  onDestroy(): void {
    this.unregisterScreenTapCallback();
    this.disableProximitySensor();
    this.deviceChannel?.setMethodCallHandler(null);
    this.deviceChannel = null;
    this.appWindow = null;
    super.onDestroy();
  }

  private registerScreenTapCallback(): void {
    if (this.screenTapRegistered) {
      return;
    }

    this.context.eventHub.on(EVENT_SCREEN_TAP, this.screenTapCallback);
    this.screenTapRegistered = true;
  }

  private unregisterScreenTapCallback(): void {
    if (!this.screenTapRegistered) {
      return;
    }

    this.context.eventHub.off(EVENT_SCREEN_TAP, this.screenTapCallback);
    this.screenTapRegistered = false;
  }

  private enableProximitySensor(): boolean {
    if (this.proximityRegistered) {
      return true;
    }

    try {
      sensor.on(sensor.SensorId.PROXIMITY, this.proximityCallback, { interval: 'normal' });
      this.proximityRegistered = true;
      return true;
    } catch (error) {
      console.error('Failed to enable proximity sensor: ' + JSON.stringify(error));
      return false;
    }
  }

  private disableProximitySensor(): void {
    if (!this.proximityRegistered) {
      return;
    }

    try {
      sensor.off(sensor.SensorId.PROXIMITY, this.proximityCallback);
    } catch (error) {
      console.error('Failed to disable proximity sensor: ' + JSON.stringify(error));
    }

    this.proximityRegistered = false;
    this.proximityNear = false;
    AppStorage.setOrCreate(PROXIMITY_COVERED_KEY, false);
    this.deviceChannel?.invokeMethod('proximityChanged', false);
    this.setProximityDisplayState(false);
  }

  private setProximityDisplayState(isCovered: boolean): void {
    const targetBrightness = isCovered ? 0 : -1;
    this.appWindow?.setWindowBrightness(targetBrightness).catch((error: Error) => {
      console.error('Failed to update proximity brightness: ' + JSON.stringify(error));
    });
  }

  private applyFullscreen(): void {
    const mainWindow = this.appWindow;
    if (!mainWindow) {
      return;
    }

    try {
      mainWindow.setImmersiveModeEnabledState(true);
      mainWindow.setWindowBackgroundColor('#FFFFFF');
    } catch (error) {
      console.error('Failed to set immersive window state: ' + JSON.stringify(error));
    }

    mainWindow.setWindowLayoutFullScreen(true).catch((error: Error) => {
      console.error('Failed to set full screen layout: ' + JSON.stringify(error));
    });
    mainWindow.setWindowSystemBarEnable([]).catch((error: Error) => {
      console.error('Failed to hide system bars: ' + JSON.stringify(error));
    });
    mainWindow.setSpecificSystemBarEnabled('status', false, false).catch((error: Error) => {
      console.error('Failed to hide status bar: ' + JSON.stringify(error));
    });
    mainWindow.setSpecificSystemBarEnabled('navigation', false, false).catch((error: Error) => {
      console.error('Failed to hide navigation bar: ' + JSON.stringify(error));
    });
    mainWindow.setSpecificSystemBarEnabled('navigationIndicator', false, false).catch((error: Error) => {
      console.error('Failed to hide navigation indicator: ' + JSON.stringify(error));
    });
  }
}
