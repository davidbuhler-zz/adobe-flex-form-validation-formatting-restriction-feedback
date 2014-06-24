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
package org.davidbuhler.formandfunction.common
{

	public final class InputRestrictions
	{

		public static const ADDRESS_1_MAX_CHARS:uint=125;
		public static const ADDRESS_1_MIN_CHARS:uint=2;
		public static const ADDRESS_2_MAX_CHARS:uint=50;
		public static const ADDRESS_2_MIN_CHARS:uint=3;
		public static const ALLOWED_FORMAT_CHARACTERS_PHONE:String=String("\#\-\(\)\ \.\/");
		public static const CAPTCHA_MAX_CHARS:uint=6;
		public static const COMPANY_NAME_MAX_CHARS:uint=125;
		public static const COMPANY_NAME_MIN_CHARS:uint=2;
		public static const STANDARD_US_DATE_FORMAT:String="MM/DD/YYYY";
		public static const DATE_MAX_CHARS:uint=10;
		public static const EMAIL_MAX_CHARS:uint=125;
		public static const FIRST_NAME_MAX_CHARS:uint=75;
		public static const FIRST_NAME_MIN_CHARS:uint=2;
		public static const LAST_NAME_MAX_CHARS:uint=75;
		public static const LAST_NAME_MIN_CHARS:uint=2;
		public static const GENERIC_MAX_CHARS:uint=255;
		public static const PHONE_NUMBER_MAX_CHARS:uint=14;
		public static const PHONE_NUMBER_MIN_DIGITS:uint=10;
		public static const ZIP_CODE_MAX:uint=10;
		public static const SOCIAL_SECURITY_MAX:uint=12;
		public static const PASSWORD_MAX_CHARS:uint=12;
		public static const TIME_MAX_CHARS:uint=7;
		public static const TIME_MIN_CHARS:uint=7;
		public static const PASSWORD_MIN_CHARS:uint=6;
		public static const URL_MAX_CHARS:uint=1066;

		public static const RESTRICT_TO_ADDRESS:String=String("\\0-9\\a-z\\A-Z\\_\\.\\ \\#\\,\\");
		public static const RESTRICT_TO_CURRENCY:String=String("0-9\\.\\,");
		public static const RESRICT_TO_GENERIC:String=String("\\<\\>\\/\\*\\:\\(\\)\\0-9\\!\\&\\+\\-\\,\\'\\#\\$\\?\\[\\]\\a-z\\A-Z\\_\\.\\ \\");
		public static const RESTRICT_TO_DATE:String=String("\\0-9\\/\\-\\.\\");
		public static const RESTRICT_TO_EMAIL:String=String("\\a-z\\A-Z\\0-9\\_\\.\\-\\@\\+\\!\\#\\$\\%\\&\\'\\*\\+\\-\\/\\=\\?\\^\\`\\{\\/|\\}\\~\\");
		public static const RESTRICT_TO_CHARS_SPACES:String=String("\\a-z\\A-Z\\_\\.\\ \\");
		public static const RESTRICT_TO_NUMBERS:String=String("\\0-9");
		public static const RESTRICT_TO_NUMBERS_CHARS:String=String("\\0-9\\a-z\\A-Z");
		public static const RESTRICT_TO_NUMBERS_FORWARD_SLASH:String=String("\\0-9\\/\\");
		public static const RESTRICT_TO_NUMBERS_HYPHENS:String=String("\\0-9\\-/");
		public static const RESTRICT_TO_PHONE_NUMBER:String=String("\\-\\0-9\\(\\)\\.\\ \\");
		public static const RESTRICT_TO_PASSWORD:String=String("\\0-9\\!\\?\\.\\a-z\\A-Z\\_\\");
		public static const RESTRICT_TO_TIME:String=String("\\0-9\\:\\am\\pm\\/");
		public static const RESTRICT_TO_KITCHEN_SINK:String=String("\\<\\>\\/\\*\\:\\(\\)\\0-9\\!\\&\\+\\-\\,\\'\\#\\$\\?\\[\\]\\a-z\\A-Z\\_\\.\\ \\");

		public function InputRestrictions()
		{
		}
	}
}

