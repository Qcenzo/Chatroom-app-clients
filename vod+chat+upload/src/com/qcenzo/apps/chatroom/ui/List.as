package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.apps.chatroom.events.ListEvent;
	import com.qcenzo.light.components.Document;
	
	import flash.events.TextEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	[Event(name="select", type=" com.qcenzo.apps.chatroom.events.ListEvent")]
	
	public class List extends Document
	{
		include "vars/listVars.as";
		
		[Embed(source="assets/list.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		private var tfm:TextFormat;
		private var run:Object;
		private var tmr:Timer;
		
		public function List()
		{
			super(new bytes());
			
			tfm = new TextFormat();
			tmr = new Timer(400, 1);
			videoList.addEventListener(TextEvent.LINK, onVideoLnk);
			visitorList.addEventListener(TextEvent.LINK, onVisitorLnk);
		}
		
		public function videos(argu:Array):void
		{
			var l:String = "";
			var item:Array;
			for (var i:int = 0; i < argu.length; i++)
			{
				item = argu[i];
				l += "\r[" + (item[3] == ListEvent.SUBSCRIBE ? "直播" : "点播") + "]" +
					"<a href='event:" + item[3] + "_" + item[0] + "'>" + item[0] + "(" + item[1] + " " + item[2] + ")</a>"; 
			}
			videoList.htmlText = "<textformat leading='4'>" + 
				"\r<font color='#FF0000'>[置顶]</font><a href='event:" + ListEvent.LIVE + "'>我要直播</a>" +
				"\r<font color='#FF0000'>[置顶]</font><a href='event:" + ListEvent.UPLOAD + "'>上传视频(文件大小不超过100MB)</a>"
				+ l + "</textformat>";
		}
		
		public function visitors(argu:Array):void
		{
			for (var i:int = 0, n:int = argu.length; i < n; i += 2)
				if (argu[i] == name)
				{
					var v:Array = argu.splice(i, 2);
					argu.unshift(v[0], v[1]);
					break;
				}
			
			var start:int = 2;
			var end:int;
			var html:String = "";
			for (i = 0; i < n; i += 2)
			{
				end = start + argu[i].length;
				html += "\r<a href='event:" + start + "_" + end + "_" + argu[i] + "'>" +
					"<img hspace='0' vspace='0' width='22' height='22' src='assets/avatar/" + argu[i + 1] + ".png'/>" +
					"<font color='" + (i == 0 ? "#FF0000" : "#8A8A8A") + "' size='14'>" + argu[i] + "</font></a>";
				start = end + 2;
			}
			visitorList.htmlText = "<textformat leading='2'>" + html + "</textformat>"; 
		}
		
		private function onVideoLnk(event:TextEvent):void
		{
			var e:ListEvent = new ListEvent(ListEvent.SELECT);
			var t:String = event.text;
			if (t == ListEvent.LIVE || t == ListEvent.UPLOAD)
				e.action = t;
			else
			{
				var i:int = t.indexOf("_");
				e.action = t.substring(0, i);
				e.data = t.substring(i + 1);
			}
			dispatchEvent(e);
		}
		
		private function onVisitorLnk(event:TextEvent):void
		{
			if (tmr.running)
			{
				if (run[2] != name)
					dispatchEvent(new ListEvent(ListEvent.SELECT,
						ListEvent.PRIVATE_CHAT, run[2]));
			}
			else
				tmr.start();
			
			if (run != null)
			{
				tfm.size = 14;
				tfm.bold = false;
				visitorList.setTextFormat(tfm, run[0], run[1]);
			}
			run = event.text.split("_");
			tfm.size = 16;
			tfm.bold = true;
			visitorList.setTextFormat(tfm, run[0], run[1]);
		}
	}
}