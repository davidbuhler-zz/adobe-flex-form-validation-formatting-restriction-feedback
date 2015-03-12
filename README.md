
##In a Nutshell
The Form reminds a user that their time-investment matters to you and your organization by giving the best possible experience when filling out a form.

##In Brief Jargon
The Form creates the relationship between a validator, a formatter, and a restrictor for the most popular form types, and then notifies the developer and user about a form’s validity.

##Features
* Associates validation routines, such as character restrictions and the maximum character limits
* Encapsulates validity check and dirty flag handler for each required form item
* Lays our form items in a symmetrical grid, so labels, controls, format hints and colors are consistent
* Provides a simple tag-based approach to building a robust, long-form
* Gives feedback about how far along the user is in the completion process
* Shows a visual hint within its own field-column. 
* Incorporates a Graphical Animated Feedback Indicator (GAFI), as well as form items that change their color based on their validity * state.

##Supported Fields
* Address 1
* Address 2
* Captcha
* CheckBox
* ComboBox
* American Express, Discover, Diner’s Club, Visa, MasterCard
* Credit Card Expiration Date
* Credit Card Number
* Credit Card Security Code
* Credit Card Type
* Currency
* Date
* Email
* File Manager (including the previewing of image files)
* First Name
* Last Name
* Generic Input
* Numeric Stepper
* Password
* Phone Number
* Radio Button Group (confirming the user Selected 1 choice)
* Rich Text Editor
* Social Security
* Time
* Website
* Zip Code (with or without Extension)

##Customization
* Most methods that makes up the Base FormItem Class can be overridden. There’s also a generic input that allows you to specify generic string restraints & requirements. I’ll be working to add some interfaces to help you along for performing extensions, along with sample code.
* The styles are externalized so you can easily change the feedback colors, form-item colors, and more.
* The Graphical Animated Feedback Indicator (GAFI) is optional.
