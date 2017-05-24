package com.qcenzo.apps.chatroom.utils
{
	public class StringTool
	{
		public static function formatMMSS(sec:int):String
		{
			return int(100 + sec / 60).toString().substr(1, 2) + ":" 
				+ (100 + sec % 60).toString().substr(1, 2);
		}
	}
}