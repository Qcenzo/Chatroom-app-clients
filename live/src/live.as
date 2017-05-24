package
{
	import com.qcenzo.light.components.Toast;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.NetConnection;
	
	[SWF(width="1280", height="720", frameRate="60")]
	public class live extends Sprite
	{
		public static const UPLOAD:String = "http://localhost:5080/chatroom/upload";
		public static const DWLOAD:String = "http://localhost:5080/chatroom/streams/";
		private const ROOT:String = "rtmp://localhost/chatroom";
		
		private var nc:NetConnection;
		private var main:Main;

		public function live()
		{
			if (ExternalInterface.available)
				ExternalInterface.addCallback("receiveInfo", init);
			else
				init("test", 0);
		}
		
		private function init(user:String, avatar:int):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Toast.me.root = this;
			Toast.me.show("连接服务器", int.MAX_VALUE);
			
			nc = new NetConnection();
			nc.client = {};
			nc.addEventListener(NetStatusEvent.NET_STATUS, onStat);
			nc.connect(ROOT, user, avatar, int.MAX_VALUE);
			
			main = new Main(user, avatar);
		}
		
		private function onStat(event:NetStatusEvent):void
		{
			if (event.info.code == "NetConnection.Connect.Success")
			{
				main.connection = nc;
				addChild(main);
			}
		}
	}
}