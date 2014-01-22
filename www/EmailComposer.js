//
//  EmailComposer.js
//
//  Version 1.2
//
//  Created by Guido Sabatini in 2012.
//

function EmailComposer() {
	this.resultCallback = null; // Function
}

EmailComposer.ComposeResultType = {
	Cancelled:0,
	Saved:1,
	Sent:2,
	Failed:3,
	NotSent:4
}
/* showEmailComposer : all args optional

	subject = String
	Body = String
	toRecipients = Array
	ccRecipients = Array
	bccRecipients = Array
	bIsHtml = Boolean
	attachments = Array
	filenames = Array
*/

EmailComposer.prototype.showEmailComposer = function(subject,body,toRecipients,ccRecipients,bccRecipients,bIsHTML,attachments,filenames) {
	var args = {};
	if(toRecipients)
		args.toRecipients = toRecipients;
	if(ccRecipients)
		args.ccRecipients = ccRecipients;
	if(bccRecipients)
		args.bccRecipients = bccRecipients;
	if(subject)
		args.subject = subject;
	if(body)
		args.body = body;
	if(bIsHTML)
		args.bIsHTML = bIsHTML;
    if(attachments)
        args.attachments = attachments;
    if(filenames)
        args.filenames = filenames;
	
	cordova.exec(null, null, "EmailComposer", "showEmailComposer", [args]);
}

EmailComposer.prototype.showEmailComposerWithCallback = function(callback, subject, body, toRecipients, ccRecipients, bccRecipients, isHTML, attachments, filenames) {
	this.resultCallback = callback;
	this.showEmailComposer.apply(this,[subject,body,toRecipients,ccRecipients,bccRecipients,isHTML,attachments, filenames]);
}

EmailComposer.prototype._didFinishWithResult = function(res) {
	this.resultCallback(res);
}

cordova.addConstructor(function()  {
	if(!window.plugins) {
		window.plugins = {};
	}

	// shim to work in 1.5 and 1.6
	if (!window.Cordova) {
		window.Cordova = cordova;
	}

	window.plugins.emailComposer = new EmailComposer();
});