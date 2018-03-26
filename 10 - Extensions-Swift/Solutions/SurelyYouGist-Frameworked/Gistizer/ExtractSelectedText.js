var ExtractSelectedText = function() {};

ExtractSelectedText.prototype = {

    run: function(arguments) {
        document.body.style.backgroundColor = "#ff00ff"
        var selectedText = "No Selection";
        if (window.getSelection) {
            selectedText = window.getSelection().getRangeAt(0).toString();
        } else {
            selectedText = document.getSelection().getRangeAt(0).toString();
        }
        var results = {
            "selectedText" : selectedText
        };
        arguments.completionFunction(results);
    },
    finalize: function(arguments) {
        // This method is run after the native code completes.
    }
};

var ExtensionPreprocessingJS = new ExtractSelectedText
