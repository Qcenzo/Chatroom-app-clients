package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.light.components.Document;
	import com.qcenzo.light.components.Toast;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class Login extends Document
	{
		include "vars/loginVars.as";
		
		[Embed(source="assets/login.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		private var ld:Loader;
		private var req:URLRequest;
		private var id:int;
		private var last:Sprite;
		private var onsr:Function;
		
		public function Login(sureFunc:Function)
		{
			super(new bytes());
			
			onsr = sureFunc;
			
			nameTi.onEnterKeyDown = onSure;
			sureBt.onClick = onSure;
			
			photoSp.addEventListener(MouseEvent.CLICK, onSelect);
			
			req = new URLRequest();
			ld = new Loader();
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			load();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		
		private function onSure():void
		{
			if (nameTi.isEmpty)
			{
				Toast.me.show("名字不能为空");
				return;
			}
			onsr(nameTi.text, photoSp.getChildIndex(last));
		}
		
		private function onComplete(event:Event):void
		{
			var a:Sprite = new Sprite();
			a.addChild(ld.content);
			a.x = photoSp.numChildren * a.width;
			photoSp.addChild(a);
			
			if (++id < 8)
				load();
			else
			{
				ld.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				status(photoSp.getChildAt(0));
			}
		}
		 
		private function load():void
		{
			req.url = "assets/avatar/" + id + ".png";
			ld.load(req); 
		}
		
		private function onSelect(event:MouseEvent):void
		{
			status(event.target);
		}
		
		private function status(item:*):void
		{
			if (last != null)
				last.graphics.clear();
			last = item;
			last.graphics.beginFill(0, 0.2);
			last.graphics.drawRect(0, 0, last.width, last.height);
			last.graphics.endFill();
		}
		
		private function onRemove(event:Event):void
		{
			onsr = null;
		}
	}
}