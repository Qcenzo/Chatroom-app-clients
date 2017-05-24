package
{
	import com.qcenzo.apps.chatroom.ui.Login;
	import com.qcenzo.apps.chatroom.ui.Main;
	import com.qcenzo.light.components.Toast;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	[SWF(width="1280", height="720", frameRate="60")]
	public class index extends Sprite
	{
		private const VERSION:String = Math.random() + "";
		private const ROOT:String = "rtmp://localhost/chatroom";
		private const UPLOAD:String = "http://localhost:5080/chatroom/upload";
		private const LIVE:String = "http://localhost:5080/chatroom/live.swf";
		
		private var conn:NetConnection;
		private var logn:Login;
		private var main:Main; 
		
		public function index()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Toast.me.root = this;
			
			main = new Main(UPLOAD);
			
			conn = new NetConnection();
			conn.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			conn.client = main;
			
			logn = new Login(onSure);
			addChild(logn);
		}
		  
		private function onSure(name:String, avatar:int):void
		{
			stage.mouseChildren = false;
			Toast.me.show("连接服务器...", int.MAX_VALUE);
			main.name = name;
			main.liveUrl = LIVE +"?v=" + VERSION + "&name=" + name + "&avatar=" + avatar;
			conn.connect(ROOT, name, avatar, 0);
		}
		
		private function onStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success": 
					Toast.me.show("连接成功");
					removeChild(logn);
					main.connection = conn;
					addChild(main);
					break;
				case "NetConnection.Connect.Failed":
					Toast.me.show("“" + main.name + "”已被使用");
					break;
			}
			stage.mouseChildren = true;
		}
	}
}