package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.light.components.Document;
	
	public class Input extends Document
	{
		public static const GROUP_CHAT:String = "groupChat";
		public static const PRIVATE_CHAT:String = "privateChat";
		
		include "vars/inputVars.as";
		
		[Embed(source="assets/input.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		private var info:Object;
		private var onsnd:Function;
		
		private const AT_WHO:RegExp = /^@[^:]+:/g;
		private const NULL:RegExp = /^\s*$/;
		
		public function Input(onSend:Function)
		{
			super(new bytes());
			
			info = {};
			onsnd = onSend;
			
			msgTi.maskWords = Vector.<String>(["sb", "fuck"]);
			msgTi.onEnterKeyDown = sendMessage;
			
			sendBt.onClick = sendMessage;
		}
		
		public function at(visitor:Object):void
		{
			msgTi.text = "@" + visitor + ":";
			msgTi.caretIndex = visitor.length + 2;
			stage.focus = msgTi;
		}
		
		private function sendMessage():void
		{
			if (msgTi.isEmpty)
				return;
			
			var v:Array = msgTi.text.match(AT_WHO);
			if (v.length == 0)
			{
				info.action = GROUP_CHAT;
				info.message = msgTi.text;
				onsnd(info);
				
				msgTi.text = "";
			}
			else
			{
				var atWho:String = v[0];
				var msg:String = msgTi.text.substr(atWho.length);
				if (!NULL.test(msg))
				{
					info.action = PRIVATE_CHAT;
					info.to = atWho.substring(1, atWho.length - 1);
					info.message = msg;
					onsnd(info);
					
					msgTi.text = atWho; 
				}
			}
			
			stage.focus = null;
			stage.focus = msgTi;
			
			msgTi.caretIndex = msgTi.length; 
		}
	}
}