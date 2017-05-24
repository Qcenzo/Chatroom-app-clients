package com.qcenzo.apps.chatroom.ui
{
	import com.qcenzo.light.components.Document;
	
	import fl.motion.ColorMatrix;
	
	import flash.filters.ColorMatrixFilter;
	import flash.media.Video;
	
	public class Setting extends Document
	{
		include "vars/settingVars.as";
		
		[Embed(source="assets/setting.qua", mimeType="application/octet-stream")]
		private var bytes:Class;
		private var vd:Video;
		private var mat:ColorMatrix;
		private var flt:ColorMatrixFilter;
		private var flts:Array;
		
		public function Setting(video:Video)
		{
			super(new bytes());
			
			vd = video;
			
			mat = new ColorMatrix();
			flt = new ColorMatrixFilter();
			flts = [flt]; 
			  
			hueSld.maximum = 2 * Math.PI;
			hueSld.onChange = onChgh;
			
			saturationSld.maximum = 10;
			saturationSld.onChange = onChgs;
			
			brightnessSld.maximum = 128;
			brightnessSld.onChange = onChgb;
			
			contrastSld.minimum = 128;
			contrastSld.maximum = 255;
			contrastSld.onChange = onChgc;
			
			closeBt.onClick = onClose;
		}
		
		private function onChgh():void
		{
			mat.SetHueMatrix(hueSld.value);
			update();
		}
		
		private function onChgs():void
		{
			mat.SetSaturationMatrix(saturationSld.value);
			update();
		}
		
		private function onChgc():void
		{
			mat.SetContrastMatrix(contrastSld.value);
			update();
		}
		
		private function onChgb():void
		{
			mat.SetBrightnessMatrix(brightnessSld.value); 
			update();
		}
		
		private function update():void
		{
			flt.matrix = mat.GetFlatArray();
			vd.filters = flts;
		}
		
		private function onClose():void
		{
			parent && parent.removeChild(this);
		}
	}
}