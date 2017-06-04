package com.qcenzo.apps.chatroom.net
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class FileUploader
	{
		private const KB:int = 1024;
		private const MB:int = KB * KB;
		private const MAX_SIZE:int = 100 * MB;
		
		private var file:FileReference;
		private var req:URLRequest;
		private var loadedFunc:Function;
		private var loadingFunc:Function;
		private var errorFunc:Function;
		private var flts:Array;
		private var maxs:int;
		
		public function FileUploader(url:String, filters:Array, maxSize:int = MAX_SIZE)
		{
			flts = filters;
			maxs = (maxSize < 0 || maxSize > MAX_SIZE) ? MAX_SIZE : maxSize;
			
			file = new FileReference();
			file.addEventListener(Event.SELECT, onSelect);
			file.addEventListener(ProgressEvent.PROGRESS, onProgress);
			file.addEventListener(Event.COMPLETE, onComplete);
			file.addEventListener(Event.CANCEL, onCancel);
			req = new URLRequest(url);
		}
		
		public function browse():FileUploader
		{
			file.browse(flts); 
			return this;
		}
		
		public function set onLoaded(func:Function):void
		{
			loadedFunc = func;  
		}
		
		public function set onLoading(func:Function):void
		{
			loadingFunc = func;
		}
		
		public function set onError(func:Function):void
		{
			errorFunc = func;
		}
		
		public function get loading():Boolean
		{
			return loadedFunc != null;
		}
		
		public function get data():ByteArray
		{
			return file.data;
		}
		
		private function onSelect(event:Event):void
		{
			if(file.size >= maxs)
			{
				if (errorFunc != null)
					errorFunc("文件大小不能超过" + max());
				onCancel(null);
				return;
			}
			file.upload(req);
		}
		
		private function onProgress(event:ProgressEvent):void 
		{
			if (loadingFunc != null)
				loadingFunc(event.bytesLoaded / event.bytesTotal);
		}
		
		private function onComplete(event:Event):void
		{
			loadedFunc(file.name);
			onCancel(null);
		}
		
		private function onCancel(event:Event):void
		{
			loadedFunc = null;
			loadingFunc = null;
			errorFunc = null;
		}
		
		private function max():String
		{
			var m:String = "";
			if (maxs > MB)
				m = int(maxs / MB) + "MB";
			else if (maxs > KB)
				m = int(maxs / KB) + "KB";
			else
				m = maxs + "字节";
			return m;
		}
	}
}