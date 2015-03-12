
##In a nutshell
Form & Function reminds a user that their time-investment matters to you and your organization by giving the best possible experience when filling out a form.

##In brief technical jargon
Form & Function creates the relationship between a validator, a formatter, and a restrictor for the most popular form types, and then notifies the developer and user about a form’s validity.

##Features
* takes care of the validation routines, the character restrictions and the maximum character limits.
* offers a built in validity checker and dirty flag handler for each form item that you specify is required.
* provides a symmetrical grid, so labels, controls, format hints and colors are consistent from line to line.
* encapsulates this logic, giving  you a simple tag-based approach to building a robust, long-form.
* provides feedback about how far along the user is in the completion process, and what’s wrong as they go along. The user may have scrolled so far down the form after a few minutes that he never notices the “First Name” field is incomplete.
* gives a visual hint within its own field-column. Basically, if a social security number has to be entered in a specific format, Form & Functionprovides an example that should be visually recognizable as an example. If you need to add more information, you can omit the example and replace it with a built-in “More Info” link. Consider the  “More Info” link as a very tiny help center for each field. The link either opens up a simple text file that you specify, or you can have Flash open a new HTML Window if you have considerably more information to specify.
* incorporates a Graphical Animated Feedback Indicator (GAFI), as well as form items that change their color based on their validity * state. So users are always aware which form items are valid, which are invalid, and which items haven’t had any interaction yet. And the GAFI keeps the user aware how many items he has left to complete.

##What types of fields does Form & Function support?
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

##How Can I customize Form & Function?
* Most methods that makes up the Base FormItem Class can be overridden. There’s also a generic input that allows you to specify generic string restraints & requirements. I’ll be working to add some interfaces to help you along for performing extensions, along with sample code.
* The styles are externalized so you can easily change the feedback colors, form-item colors, and more.
* The Graphical Animated Feedback Indicator (GAFI) is optional.
