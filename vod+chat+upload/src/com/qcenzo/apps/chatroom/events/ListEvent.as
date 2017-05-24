package com.qcenzo.apps.chatroom.events
{
	import flash.events.Event;
	
	public class ListEvent extends Event
	{
		public static const SELECT:String = "select";
		
		public static const LIVE:String = "live";
		public static const VOD:String = "vod"; 
		public static const UPLOAD:String = "upload";
		public static const SUBSCRIBE:String = "subscribe";
		public static const PRIVATE_CHAT:String = "privateChat";

		public var action:String;
		public var data:String;
		
		public function ListEvent(type:String, action:String = null, data:String = null)
		{
			super(type);
			this.action = action;
			this.data = data;
		}
	}
}