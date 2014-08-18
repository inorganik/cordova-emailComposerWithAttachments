Cordova - Email Composer
====================================
### Supports custom attachment filenames

PhoneGap plugin that allows you to add attachments and specify filenames of attachments to an email compose window. This is a modification of the original email composer plugin written by [Guido Sabatini](https://github.com/guidosabatini) in the [purple cabbage phonegap plugin repo](https://github.com/purplecabbage/phonegap-plugins), which itself recommends that devs keep and maintain their own repos of the plugins. 

It has been modified so that you can add filenames to attachments, and support for Cordova 3.X added.

### Usage

1. Add the plugin:

		cordova plugin add https://github.com/inorganik/cordova-emailComposerWithAttachments.git

2. Build the appropriate platform

		cordova build ios

3. For iOS: include `MessagesUI.framework` in your project by clicking on the target, then Build Phases, and expand 'Link Binary With Libraries'. Click the "+" and add `MessagesUI.framework`.

4. In your index.html file, make sure EmailComposer.js is linked properly.

5. In your JavaScript file, call 

		window.plugins.emailComposer.showEmailComposer(subject,body,toRecipients,ccRecipients,bccRecipients,bIsHTML,attachments,filenames);

Params (all optional):

- `subject` = String
- `body` = String
- `toRecipients` = Array
- `ccRecipients` = Array
- `bccRecipients` = Array
- `bIsHtml` = Boolean
- `attachments` = Array
- `filenames` = Array

### Example

Assumes you have a reference to a file, `myFile`. Also that you have defined email params: `subject`, `body`, `toRecipients`, etc.

```js
function sendLog() {

    // save the file locally, so it can be retrieved from emailComposer
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function(fileSystem) {
        // create the file if it doesn't exist
        fileSystem.root.getFile('myFile.txt', {create: true, exclusive: false}, function(file) {
            // create writer
            file.createWriter(function(writer) {
                // write
                writer.write(myFile);
                // when done writing, call up email composer
                writer.onwriteend = function(evt) {
                    // params: subject,body,toRecipients,ccRecipients,bccRecipients,bIsHTML,attachments,filenames
                    window.plugins.emailComposer.showEmailComposer(subject,body,[],[],[],false,['myFile.txt'], ['myFile']);
                }
            }, fileSystemError);
        }, fileSystemError);
    }, fileSystemError);
}

function fileSystemError(error) {
    console.log('Error getting file system: '+error.code);
}
```
