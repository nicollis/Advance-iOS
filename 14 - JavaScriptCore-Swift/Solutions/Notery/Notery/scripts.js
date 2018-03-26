
var reverseWords = function (s) {
	return s.split(' ').reverse().join(' ');
}

var rot13 = function (s) {
    var input = s;
    var output = "";
    for(i = 0; i < input.length; i++) {
        var ch = input.slice(i, i+1);
        var val = ch.charCodeAt(0);
        var convert = -1;
        if (val >= 65 && val <= 90) {
            convert = 65;
        } else if (val >= 97 && val <= 122) {
            convert = 97;
        }
        var rot = val;
        if (convert > 0) {
            var temp = val - convert;
            rot = (temp + 13) % 26;
            rot = rot + convert;
        }
        newChar = String.fromCharCode(rot);
        output = output + newChar;
    }
    return output;
}

var lorem = function (s) {
	s += "\n";
	s += "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n";
	return s;
}

var noteryScripts = ['lorem', 'reverseWords', 'rot13'];
