package 
{
	import com.qcenzo.light.components.Document;
	import com.qcenzo.light.components.Toast;
	import com.qcenzo.light.net.FileUploader;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class Main extends Document
	{
		include "liveVars.as";

		[Embed(source="assets/live.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		
		private const RES_LIST:Array = 
			[
				" 1920   x   1080                                                  ",
				" 1280   x   720                                                    ",
				" 1024   x   768                                                    ",
				"   720   x   576                                                    ",
				"   720   x   480                                                    "
			];
		
		private var nc:NetConnection;
		private var ns:NetStream;
		private var upload:FileUploader;
		private var toStop:Boolean;
		private var mute:Boolean;
		private var clock:Timer;
		
		public function Main(name:String, avatar:int)
		{
			super(new bytes());
			
			setupSetting();
			
			this.name = name;
			nameTf.htmlText = "<font color='#FF0000'>" + name + "</font> 的直播间";
			photoLoad.url = "assets/avatar/" + avatar + ".png";
			
			setupWaterMark();
			
			setupToggle();
			setupVolume();
			securityBt.onClick = Security.showSettings;
			
			bgLoader.url = "assets/bg.jpg";
		}
		
		public function set connection(connection:NetConnection):void
		{
			nc = connection;
			ns = new NetStream(nc);
			ns.client = {};
		}
		
		private function setupSetting():void
		{
			currResTf.text = "1280   x   720";
			var htm:String = "";
			var run:Array = [0, 0];
			for (var i:int = 0; i < RES_LIST.length; ++i)
			{
				run[1] += RES_LIST[i].length + 1; 
				htm += "<a href='event:" + run[0] + "_" + run[1] + "_" + RES_LIST[i] + "'>" 
					+ RES_LIST[i] + "</a>\r";
				run[0] = run[1];
			}
			resListTf.htmlText = htm;
			resListTf.addEventListener(TextEvent.LINK, onLnk);
			fpsTi.restrict = "0-9";
			fpsTi.text = "30";
			quaSld.value = 180;
			quaSld.maximum = 255;
			startBt.onClick = startLive;
			recBt.onClick = function():void {Toast.me.show("暂未开放")};
		}
		
		private function onLnk(event:TextEvent):void
		{
			var run:Array = event.text.split("_");
			resListTf.setSelection(run[0], run[1]);
			currResTf.text = run[2];
		}
		
		private function setupWaterMark():void
		{
			addWaterMarkBt.visible = false;
			addWaterMarkBt.onClick = addWaterMark;
			waterMark.tryReloadTime = 10;
		}
		
		private function addWaterMark():void
		{
			upload ||= new FileUploader(live.UPLOAD, [new FileFilter("Media(*.swf;*.jpg;*.png）", "*.swf;*.jpg;*.png")], 30 * 1024);
			if (upload.loading)
				Toast.me.show("正在处理，请稍候");
			else
			{
				upload.onLoading = onLoading;
				upload.onError = Toast.me.show;
				upload.browse().onLoaded = 
					function(file:String):void
					{
						waterMark.url = live.DWLOAD + file;
						addWaterMarkBt.visible = false;
						
						ns.send("onTextData", {handler:"addWaterMark", 
							parameters:[waterMark.url, new Rectangle(waterMark.x, waterMark.y, 
									waterMark.width, waterMark.height)]});
					}
			}
		}
		
		private function onLoading(percent:Number):void
		{
			Toast.me.show("文件上传中..." + int(percent * 100) + "%");
		}
		
		private function setupToggle():void
		{
			playToggleSp.addEventListener(MouseEvent.CLICK, onPToggle);
			playToggleStatus(false);
		}
		
		private function onPToggle(event:MouseEvent):void
		{
			playToggleStatus(toStop = !toStop);
			toStop ? clock.stop() : clock.start();
		}
		
		private function playToggleStatus(status:Boolean):void
		{
			playToggleSp.getChildAt(1).visible = !status;
			playToggleSp.getChildAt(0).visible = status;
		}
		
		private function setupVolume():void
		{
			volSp.addEventListener(MouseEvent.CLICK, onVolToggle);  
			volToggleStatus(false);
		}
		
		private function onVolToggle(event:MouseEvent):void
		{
			volToggleStatus(mute = !mute);
			ns.attachAudio(mute ? null : Microphone.getMicrophone());
		}
		
		private function volToggleStatus(status:Boolean):void
		{
			volSp.getChildAt(1).visible = !status;
			volSp.getChildAt(0).visible = status;
		}
		
		private function scale(w:int, h:int):void
		{
			video.height = video.height;
			video.width = video.height * w / h;
			video.x = bgLoader.x + (bgLoader.width - video.width >> 1);
			video.y = bgLoader.y;
		}
		
		//---------------------------------------------------------------
		// 
		//
		//
		//---------------------------------------------------------------
		
		private function startLive():void
		{
			removeChild(setting);
			
			var res:Array = currResTf.text.split("x");
			var w:int = int(res[0]);
			var h:int = int(res[1]);
			
			var camera:Camera = Camera.getCamera();
			camera.setQuality(0, quaSld.value);
			camera.setMode(w, h, int(fpsTi.text));
			
			var snm:String = streamName();
			ns.attachCamera(camera);
			ns.attachAudio(Microphone.getMicrophone());
			ns.publish(snm);
			
			ns.send("@setDataFrame", "onMetaData", {width:w, height:h, d:0});
			
			video.attachCamera(camera);
			scale(w, h);
			
			waterMark.x = addWaterMarkBt.x = video.x + video.width - addWaterMarkBt.width - addWaterMarkBt.y;
			addWaterMarkBt.visible = true;
			
			nc.call("insertVideoList", null, snm, name, "subscribe");
			
			clock = new Timer(1000);
			clock.addEventListener(TimerEvent.TIMER, onTick);
			clock.start();
		}
		
		private function onTick(event:TimerEvent):void
		{
			var n:int = clock.currentCount;
			if (n > 3600)
			{
				timeTf.text = String(int(n / 3600) + 100).substr(1) + ":";
				n %= 3600;
				timeTf.appendText(String(int(n / 60) + 100).substr(1)
					+ ":" + String(n % 60 + 100).substr(1));
			}
			else if (n > 60)
				timeTf.text = "00:" + String(int(n / 60) + 100).substr(1) + ":" 
					+ String(n % 60 + 100).substr(1);
			else
				timeTf.text = "00:00:" + int(n + 100).toString().substr(1);
		}
		
		private function streamName():String
		{
			return name + "s show";
		}		
	}
}
