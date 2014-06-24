/*
 * #%L
 * GwtBootstrap3
 * %%
 * Copyright (C) 2013 FormFunction
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package org.davidbuhler.formandfunction.utils
{
	import flash.filters.DropShadowFilter;
	import mx.containers.Canvas;
	import mx.formatters.DateFormatter;

	public class Utils
	{
		private static var dateFormatter:DateFormatter=new DateFormatter();

		public static function getCurrency(str:String):Number
		{
			var pattern:RegExp=/[\d]*(\.[\d]+)?/;
			return Number(str.replace(pattern, ""));
		}

		public static function getLastSavedDateTime(value:Date):String
		{
			return dateFormatter.format(value);
		}

		public static function getNumbers(str:String):int
		{
			var pattern:RegExp=/[^0-9]/g;
			return int(str.replace(pattern, ""));
		}

		public static function getShadowedCanvas():Canvas
		{
			var canvas:Canvas=new Canvas();
			var filters:Array=new Array();
			var dFilter:DropShadowFilter=new DropShadowFilter();
			dFilter.angle=90;
			dFilter.distance=1;
			dFilter.alpha=.5;
			dFilter.color=0xcccccc;
			filters.push(dFilter);
			canvas.percentWidth=100;
			canvas.percentHeight=100;
			canvas.filters=filters;
			return canvas;
		}

		public static function trim(value:String):String
		{
			var pattern:RegExp=/^\s+|\s+$/g;
			return String((value.replace(pattern, '')));
		}

		public function Utils()
		{
		}
		dateFormatter.formatString='MMMM. D, YYYY at L:NNA';
	}
}

