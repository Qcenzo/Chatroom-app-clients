package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.apps.chatroom.events.ListEvent;
	import com.qcenzo.light.components.IPlayer;
	import com.qcenzo.light.components.Toast;
	import com.qcenzo.light.net.FileUploader;
	import com.qcenzo.light.net.NetStreamX;
	
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class Main extends Sprite
	{
		private var nc:NetConnection;
		private var ns:NetStreamX;
		private var list:List;
		private var upload:FileUploader;
		private var input:Input;
		private var danm:Danmu;
		private var lvUrl:String;

		public function Main(uploadUrl:String)
		{
			upload = new FileUploader(uploadUrl, [new FileFilter("Media(*.flv;*.mp4)", "*.flv;*.mp4")]);
			
			list = new List();
			list.addEventListener(ListEvent.SELECT, onSelect);
			addChild(list);
			
			input = new Input(onSend);
			addChild(input);
			
			danm = new Danmu();
			danm.scrollRect = new Rectangle(3, 3, 1001, 485);
			addChild(danm);
		}
		
		override public function set name(value:String):void
		{
			super.name = list.name = value;
		}
		
		public function set liveUrl(url:String):void
		{
			lvUrl = url;
		}
		
		public function set connection(value:NetConnection):void
		{
			nc = value;
			ns = new NetStreamX(nc, addChildAt(new Player(), 0) as IPlayer);
			ns.addEventListener(NetStatusEvent.NET_STATUS, onStat);
		}
		
		public function quit():void
		{
			Toast.me.show("连接已断开", int.MAX_VALUE);
			ns.dispose();
			stage.mouseChildren = false;
		}
		
		public function receiveVideoList(...argu):void
		{
			list.videos(argu);
		}
		
		public function receiveVisitorList(...argu):void
		{
			list.visitors(argu);
		}
		
		public function receiveGroupChat(message:String):void
		{
			danm.fly(message);
		}
		
		public function receivePrivateChat(from:String, message:String):void
		{
			Toast.me.show(from + "对你说：" + message); 
		}
		
		private function onSelect(event:ListEvent):void
		{
			switch (event.action)
			{
				case ListEvent.LIVE:
					if (Camera.getCamera() == null)
						Toast.me.show("没有摄像头，无法直播");
					else
						navigateToURL(new URLRequest(lvUrl));
					break;
				case ListEvent.UPLOAD:
					if (upload.loading)
					{
						Toast.me.show("正在上传，请稍候");
						return;
					}
					upload.onLoading = onLoading;
					upload.onError = Toast.me.show;
					upload.browse().onLoaded = function 
						(file:String):void
					{
						nc.call("insertVideoList", null, file, name, ListEvent.VOD);
					}
					break;
				case ListEvent.VOD:
					ns.play(event.data, 0);
					break;
				case ListEvent.SUBSCRIBE:
					ns.play(event.data, -1);
					break;
				case ListEvent.PRIVATE_CHAT:
					input.at(event.data);
					break;
			}
		}
		
		private function onLoading(percent:Number):void
		{
			Toast.me.show("文件上传中..." + int(percent * 100) + "%");
		}
		
		private function onSend(info:Object):void
		{
			switch (info.action)
			{
				case Input.GROUP_CHAT:
					nc.call("groupChat", null, [info.message]);
					break;
				case Input.PRIVATE_CHAT:
					nc.call("privateChat", null, name, info.to, info.message);
					break;
			}
		}
		
		private function onStat(event:NetStatusEvent):void
		{
			if (event.info.code == "NetStream.Play.UnpublishNotify")
					Toast.me.show("主播已离线");
		}
	}
}